#!/bin/bash
set -e

usage() (
  echo "$(basename "0")"' docgen help
  parse options and generate documentation from an options specification
'
)

help() (
  usage
  cat <<'END'
MOTIVATION
  Command-line arguments genearlly conform to a fixed conventions, but the
  standard tools for parsing options are not capable of understanding them in
  full. At the same time, these tools do not generate documentation, so it is
  easy for help screens to fall out-of-sync with real parsing. `argspec` can
  produce both argument parsers and documentation from a human-readable
  specification.

  So, what conventions does optparse support?

  * Most arguments to a command are one of:
    * short options (a single dash and single character)
    * long options (starting with a double dash)
    * arguments of the command (most everything else)
  * Additionally, there are names for particular sorts of arguments:
    * flags: simply exist or not, without reference to other command arguments
    * non-flag arguments: expect a following option, which is called the
      argument _to the option_
    * Some commands have sub-commands. Here, the first command argument is
      interpreted as the name of a sub-command, and all following arguments are
      arguments _of the sub-command_. Sub-commands can even have
      sub-sub-commands, and so on.
  * Multiple short flags can be combined: a single dash followed by the
    characters of each short flag.
  * An option can be combined with its argument, separated by an equals sign.
  * The special argument `--` states that all following options are treated as
    arguments, even if they start with dashes. It is otherwise ignored.
  * Some arguments may be bundled up and parsed elsewhere. These are surrounded
    by a pair of arguments with the same name except that the first begins with
    a plus, and the second with a minus. This convention effectively creates
    parentheses.

SYNTAX

Lexical Structure:
  The syntax of an args-file is largely line-based, and simple to parse.
  * A line that starts with a dash is an option definition line.
  * A line whose first column (as in `awk`) is at least two equals signs defines a section.
    The section continues until a line whose first column is the same number of equals signs as started the section.
    There are three major types of sections, described below.
  * TODO lines beginning with a percent sign are directives.
  * Lines that start with a single- or double-bird foot (`>` or `>>`) are docstring lines.
  * A comment is a line that starts with a `#` character (and possibly leading whitespace).
    End-of-line and block comments are not supported.
    Comment and empty (up to whitespace) lines are ignored.
  * all other lines are errors

Option Definition:
  TODO --?[a-zA-Z0-9][a-zA-Z0-9_-]*, separated by whitespace
Sections:
  TODO
Directives:
  TODO version directive
  TODO semantics directives
  TODO include directive
Docstrings:
  Docstrings generally apply to the definition that preceedes them.
  Docstrings at the start of a file describe the command as a whole.

  A single bird foot is a standard docstring line.
  Blocks of these lines together form a standard docstring.

  A double bird foot is a synopsis line, and often must be only one line long. (TODO: when?)
  The synopsis should come _before_ the general docstring.

  Everything after the bird foot is reproduced verbatim when documentation is generated.
  We recommend writing docstring/synopsis content in markdown.
END
)

version() (
  cat <<END
v0.0.1
END
)

main() (
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --help) usage; exit 0 ;;
      --version) version; exit 0 ;;
      -*) std::die "unrecognized option: $1" ;;
      *) break ;;
    esac
    shift
  done
  case "$1" in
    '') std::die "expected command" ;;
    help) genhelp "$@" ;;
    bash) genbash "$@" ;;
  esac
)

genhelp() (
  full="$(cat)"
  top="$(echo "$full" | takeTop)"

  echo "$top" | awk '
    $1 ~ /^>$/ { print; y=1; next }

    /^#/ { if(!y) next }
    /^[[:space:]]*$/ { if(!y) next }

    { exit }
  ' | sed -E 's/^>( |$)//'

  echo ""
  echo "OPTIONS"
  cat <<END
  --help
    Show this help message and exit.
END
  echo "$top" | awk '
    # print a flag option, or option with argument
    /^-/ {
      if (mode == "docs") { printf "\n" }
      if ($NF ~ /<.*>/) { arg = " "$NF; NF-- } else { arg = "" }
      sep = "  "
      for(i = 1; i <= NF; i++) {
        printf("%s%s%s", sep, $i, arg)
        sep = ", "
      }
      printf "\n"
      mode = "docs";
      next
    }

    # print documentation following an option
    $1 ~/^>$/ { if (mode == "docs") { print; next } }

    # exit documentation mode, and skip everything else
    { if (mode == "docs") { printf "\n"; mode = "" } }
  ' | sed -E 's/^>( |$)/    /'


  cmdlen="$(echo "$top" | awk '
    BEGIN { max = 0 }
    $1 ~ /^(==+)$/ && $2 ~ /^[a-zA-Z]/ { if (length($2) > max) max = length($2) }
    END { print max }
  ')"
  if [[ "$cmdlen" -gt 0 ]]; then
    echo "COMMANDS"
    echo "$top" | awk '
      function drain() {
        if (cmd) {
          if (synopsis)
            printf("  %-'"$((cmdlen + 1))"'s   %s\n", cmd, synopsis)
          else
            printf("  %s\n", cmd)
          cmd = "";
          mode = "";
          synopsis = "";
        }
      }

      $1 ~ /^==+/ && $1 == $3 && $2 ~ /^[a-zA-Z]/ {
        cmd = $2;
        mode = "synopsis";
        next;
      }
      $1 == ">>" { synopsis = $0 }
      { drain() }
      END { drain() }
    ' | sed -E 's/^(\s*[a-zA-Z0-9_-]+\s*)>>\s+/\1/'
  fi

  # document `+FOO … -FOO` options

)

genbash() (
  source="$(cat)"
  full="$(echo "$source" | awk '
    /^[[:space:]]*(#.*)?$/ { next }
    /^>>?( |$)/ { next }
    { print }
  ')"
  top="$(echo "$full" | takeTop)"
  echo 'while [[ "$#" -gt 0 ]]; do'
  echo "  case \"\$1\" in"
  echo "    --help) cat <<'ARGSPEC__END_HELP'"
  echo "$source" | genhelp
  echo "ARGSPEC__END_HELP"
  echo '      exit ;;'
  echo "    --) shift; set -- \"\${ARGSPEC__ARGS[@]}\" \"\$@\"; break ;;"

  # TODO --version, --machine-version
  # TODO print usage on error

  # generate long and short option parsing
  readarray -t dashargs < <(echo "$top" | grep -E '^-' || true)
  for arg in "${dashargs[@]}"; do
    # setup before accumulator loop
    maxA=''
    pat=''
    sep=''
    argName=''
    # end setup
    for a in $arg; do
      # special processing for the argument name
      if [[ "$a" =~ ^'<'(.*)'>'$ ]]; then
        argName="$(echo "${BASH_REMATCH[1]}" | tr 'a-z-' 'A-Z_')"
        continue
      fi
      # construct a case pattern
      pat+="$sep$a"
      sep='|'
      # remove single- or double-dash
      a="${a#-}"
      a="${a#-}"
      # find the maximum argument
      if [[ "${#a}" -gt "${#maxA}" ]]; then maxA="$a"; fi
    done

    # recognize options with an argument
    if [[ -n "$argName" ]]; then
      var="$(echo "${maxA%--}" | tr 'a-z-' 'A-Z_')"
      echo "    $pat)"
      echo "      if [[ \"\$#\" -lt 2 ]]; then echo >&2 \"missing argument for \$1 <$argName>\"; exit 1 fi"
      echo "      ${var}_$argName+=(\"\$2\"); shift 2 ;;"
      # equal-sign syntax
      for a in ${arg%%<*}; do
        echo "    $a=*) ${var}_$argName+=(\"\${a#*=}\"); shift ;;"
      done
      # combine short args
      for a in $arg; do
        if [[ "$a" =~ ^-[a-zA-Z0-9]$ ]]; then
          echo "    $a*)"
          echo "      if [[ \"\$#\" -lt 2 ]]; then echo >&2 \"missing argument for $a <$argName>\"; exit 1 fi"
          echo "      ${var}_$argName+=(\"\$2\") ;;"
          echo "      set -- \"-\${1#$a}\" \"\${@:2}\"\""
        fi
      done
    # recognize flags
    else
      var="$(echo "${maxA%--}" | tr 'a-z-' 'A-Z_')"
      echo "    $pat) ${var}_FLAG+=(1); shift ;;"
      # combine short args
      for a in $arg; do
        if [[ "$a" =~ ^-[a-zA-Z0-9]$ ]]; then
          echo "    $a*) ${var}_FLAG+=(1); set -- \"-\${1#$a}\" \"\${@:1}\" ;;"
        fi
      done
    fi
  done

  # deal with unrecognized short/long options
  echo "    --*|-*) echo >&2 \"unrecognized option \$1\" exit 1 ;;"

  commands="$(echo "$top" | awk '
    $1 ~ /^==+/ && $1 == $3 && $2 ~ /^[a-zA-Z]/ {
      printf("%s%s", sep, $2)
      sep = "|"
    }
  ')"
  echo "    $commands)"
  echo "      SUBCOMMAND=\"\$1\"; shift"
  echo "      SUBARGS=(\"\$@\")"
  echo "      set -- \"\${ARGSPEC__ARGS[@]}\""
  echo "      break ;;"
  if [[ -n "$commands" ]]; then
    echo "    *) echo >&2 \"unrecognized subcommand: \$1\"; exit 1 ;;"
  else
    echo "    *) set -- \"\${ARGSPEC__ARGS[@]} \"\$@\"; break ;;"
  fi

  # deal with `+FOO … -FOO` options

  echo '  esac'
  echo 'done'

  # TODO handle some basic semantics
)

takeTop() (
  awk '
    BEGIN { mode = "after-open" }

    # comment and blank lines are ignored
    /^[[:space:]]*(#.*)?$/ { next }

    # except for docstrings, after-cmd mode is fragile and decays to cmd mode
    $1 !~ ">>?" { if (mode == "after-cmd") mode = "cmd" }

    # exit out of (start-)command mode from any command mode
    #{ print "ASDFG", $1, end }
    $1 == end { if (mode ~ /^cmd/) { mode=""; next } }

    # enter command mode from standard mode
    $1 ~ /^==+$/ && $1 == $3 && $2 ~ /^[a-zA-Z][a-zA-Z0-9-]*$/ {
      if (mode == "") {
        mode = "after-cmd";
        end = $1
        print; next
      }
    }

    # but beyond the mode-changing, just print lines unaltered
    { if (mode != "cmd") print }
  '
)
