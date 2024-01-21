#!/bin/sh
# SPDX-FileCopyrightText: © 2024 Marseille Bouchard <marseillebd@proton.me>
# SPDX-License-Identifier: GPL-3.0-or-later
set -e

main() (
  # TODO read arguments
  if [ -n "$1" ]; then
    exec <"$1"
  fi
  if command -v which >/dev/null 2>&1; then haveWhich=1; else haveWhich=0; fi
  summary=''
  while read -r cmd; do
    case "$cmd" in
      '#'*) continue ;;
    esac

    commandv="$(if command -v "$cmd" >/dev/null 2>&1; then echo 1; fi)"
    commandV="$(esctoml "$(command -V "$cmd")")"
    if [ ! "$haveWhich" = 0 ]; then
      # shellcheck disable=SC2230
      which="$(esctoml "$(which "$cmd")")"
    fi

    summary="$(printf '%s\n%s = %s' "$summary" "$cmd" "$(if [ -n "$commandv" ]; then echo 'true'; else echo 'false'; fi)")"

    echo "[command.$cmd]"
    # looking for the command's location
    if [ ! "$haveWhich" = 0 ]; then
      echo "which = $which"
    fi
    echo "command-V = $commandV"
    echo 'paths = ['
    (
      IFS=:
      set -o noglob
      for p in $PATH; do
        if [ -e "$p/$cmd" ]; then
          info="$(printf '%s%s' \
            "$p/$cmd" \
            "$(if [ -L "$p/$cmd" ]; then echo " -> $(readlink "$p/$cmd")"; fi)" \
          )"
          echo "  $(esctoml "$info"),"
        fi
      done
    )
    echo ']'
    # testing command information
    if command -v "$cmd" >/dev/null 2>&1; then
      echo ""
      version="$("$cmd" --version 2>/dev/null || true)"
      if [ -n "$version" ]; then
        echo "version = $(esctoml "$version")"
      fi
    fi
    echo ""
  done
  echo "[summary]"
  echo "$summary"
)

esctoml() (
  if [ "$(echo "$1" | wc -l)" -gt 1 ];  then hasNl=1;      else hasNl=0;      fi
  if echo "$1" | grep -qF \';           then hasTick=1;    else hasTick=0;    fi
  if echo "$1" | grep -qF \'\'\';       then has3Ticks=1;  else has3Ticks=0;  fi

  if [ "$hasNl" = 0 ] && [ "$hasTick" = 0 ]; then
    printf "'%s'" "$1"
  elif [ "$has3Ticks" = 0 ]; then
    printf "'''\n%s\n'''" "$1"
  else
    echo >&2 "toml string escape unimplemented" # TODO
  fi
)

main "$@"