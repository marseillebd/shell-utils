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
SYNTAX

  Documentation strings are lines that begin with two hashes and then a space `/^>( |$)/`.
  Everything after that prefix is reproduced verbatim when documentation is generated.

  If the first lines of a file are a docstring, that describes the command.
  Whitespace-only and comment lines are allowed.
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
      # TODO remember to split apart single-letter options in the interpreter
      *) break ;;
    esac
    shift
  done
  case "$1" in
    '') std::die "expected command" ;;
    help) genhelp "$@"
  esac
)

genhelp() (
  trap 'rm -f tmp-genhelp-*.$$' EXIT
  cat >"tmp-genhelp-full.$$"
  awk <"tmp-genhelp-full.$$" >"tmp-genhelp-top.$$" '
    # comment and blank lines are ignored
    /^[[:space:]]*(#.*)?$/ { next }

    # except for docstrings, cmd-start mode is fragile and decays to cmd mode
    $1 != ">" { if (mode == "cmd-start") mode = "cmd" }

    # exit out of (start-)command mode from any command mode
    #{ print "ASDFG", $1, end }
    $1 == end { if (mode ~ /^cmd/) { mode=""; next } }

    # enter command mode from standard mode
    $1 ~ /^==+$/ && $1 == $3 && $2 ~ /^[a-zA-Z][a-zA-Z0-9-]*$/ {
      if (mode == "") {
        mode = "cmd-start";
        end = $1
        print; next
      }
    }

    # but beyond the mode-changing, just print lines unaltered
    { if (mode != "cmd") print }
'

  commands="$(grep <"tmp-genhelp-top.$$" -Ex '(==+)\s+[a-z0-9_-]+\s+\1' || true)"
  awk <"tmp-genhelp-full.$$" '
    /^>( |$)/ { print; y=1; next }

    /^#/ { if(!y) next }
    /^[[:space:]]*$/ { if(!y) next }

    { exit }
' | sed -E 's/^>( |$)//'

  echo ""
  # TODO
  echo "$commands"
)
