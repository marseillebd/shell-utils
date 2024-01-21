#!/bin/bash
# SPDX-FileCopyrightText: © 2024 Marseille Bouchard <marseillebd@proton.me>
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

main () (
  exclude_exts="$1" # TODO make this an `--exclude-exts` argument
  # TODO make an `--exclude-dirs` argument
  # TODO make an `--exclude-globs` argument

  flags=('--exclude-dir=.git')
  if [[ -f .gitignore ]]; then flags+=('--exclude-from=.gitignore'); fi
  # TODO ignore inside SPDX-Snipped{Begin,End}
  mapfile -t files < <(grep -rL "${flags[@]}" 'SPDX-\(FileCopyrightText\|License-Identifier\)' .)
  for f in "${files[@]}"; do
    fbase="$(basename "$f")"
    case "$fbase" in
      .*|LICENSE) continue ;;
      *.*) ext="${fbase#*.}" ;;
      *) ext='' ;;
    esac
    case "$ext" in
      '') found=1; echo "$f" ;;
      *)
        if ! echo ",$1," | grep -qF ",$ext,"; then
          found=1; echo "$f"
        fi ;;
    esac
  done
  if [[ -n "$found" ]]; then
    echo >&2 "WARNING: missing SPDX metadata"
    exit 1
  fi
)

# TODO a function to generate

main "$@"
