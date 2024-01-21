#!/bin/bash
# SPDX-FileCopyrightText: © 2024 Marseille Bouchard <marseillebd@proton.me>
# SPDX-License-Identifier: GPL-3.0-or-later
set -e

usage() {
  echo >&2 "$0 -r <requirements file> <source script>"
}

runCompiler() (
  if [[ -n "$1" ]]; then reqfile="$1"; else die "missing requirements file ('-r <file>')"; fi
  if [[ -n "$2" ]]; then srcfile="$2"; else die "missing source file"; fi
  if [[ -n "$3" ]]; then outfile="$3"; else die "missing output file ('-o <file>')"; fi
  tmpfile="$(mktemp shld-tmp.XXXXXXXXXX)"
  trap 'rm -f "$tmpfile"' EXIT

  {
    # TODO un-literate the code
    cat "$srcfile"

    case "$reqfile" in
      *.txt) true ;;
      # TODO if the requirements file is toml,json,yaml,or whatnot, use an appropriate tool
      *) die "unrecognized requirement file format"
    esac
    readarray -t reqs <"$reqfile"
    for req in "${reqs[@]}"; do
      echo ""
      echo "# shld: INCLUDE '$req'"
      echo "# SPDX-SnippetBegin"
      dispatchReq "$reqfile" "$req"
      echo "# SPDX-SnippetEnd"
      echo '# shld: END INCLUDE'
      # TODO we might even want to check for transitive dependencies
    done

    echo ""
    echo 'main "$@"'
  } >"$tmpfile"

  # TODO run shellcheck
  # TODO analyze for commands, maybe just heuristacally at first
  mv "$tmpfile" "$outfile"
  chmod +x "$outfile" # TODO use permissions of old file
)

dispatchReq() (
  reqfile="$1"
  req="$2"
  if [[ "$req" =~ ^local[[:space:]]+(.*)$ ]]; then
    localld "$reqfile" "${BASH_REMATCH[1]}"
  elif [[ "$req" =~ ^git[[:space:]]([^[:space:]]*)([[:space:]](.*))?$ ]]; then
    url="${BASH_REMATCH[1]}"
    args="${BASH_REMATCH[2]}"
    if [[ "$args" =~ 'file='([^[:space:]]*) ]]; then
      file="${BASH_REMATCH[1]}"
    else
      die "file=<path> required in git dependency"
    fi
    if [[ "$args" =~ 'commit='([^[:space:]]*) ]]; then
      commit="${BASH_REMATCH[1]}"
    else
      warn "no commit specified in git dependency"
      commit=''
    fi
    gitld "$url" "$file" "$commit"
  elif [[ "$req" =~ ^[[:space:]]*# ]]; then
    true
  else
    die "unrecognized requirement format '$req'"
  fi
)

localld() (
  reqfile="$1"
  req="$2"
  case "$req" in
    # name starts with slash is absolute
    /*) cat "$req" ;;
    # slash in name means a relative file (relative to the requirements file)
    */*) cat "$(dirname "$reqfile")/$req" ;;
    # no slash means we look it up in SHLD_PATH, with a semver version number
    *) die "search through SHLD_PATH is unimplemented" # TODO
  esac
)

gitld() (
  url="$1"
  file="$2"
  commit="$3"
  echo >&2 "url $1"
  echo >&2 "file $2"
  echo >&2 "commit $3"
  die 'git-based requirement support unimplemented'
)

main() (
  # parse cli arguments
  local reqfile=''
  local srcfiles=()
  local outfile=''
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --help) usage; exit 0 ;; # TODO print more detailed help than the plain usage
      -o) shift; outfile=$1 ;;
      -r) shift; reqfile=$1 ;;
      # TODO an option that builds and runs (for testing workflow)
      -*) die "unrecognized option '$1'" ;;
      *) srcfiles+=("$1") ;;
    esac
    shift
  done

  # ensure we have all required arguments
  if [[ -z "$reqfile" ]]; then die "requirements file is required '-r <file>'"; fi
  case "${#srcfiles[@]}" in
    1) srcfile="${srcfiles[0]}" ;;
    0) die "source script required" ;;
    *) die "at most one source script allowed" ;;
  esac
  if [[ -z "$outfile" ]]; then die "output filename is required '-o <file>'"; fi

  runCompiler "$reqfile" "$srcfile" "$outfile"
)

die() {
  if [[ "$#" -gt 0 ]]; then echo >&2 "$@" >&2; fi
  exit 1
}

warn() {
  echo >&2 "$@"
}

main "$@"
