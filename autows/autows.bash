#!/bin/bash
# SPDX-FileCopyrightText: © 2024 Marseille Bouchard <marseillebd@proton.me>
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

main() (
  while [[ "$#" -gt 0 ]]; do
    shift
    if [[ ! -f "$0" ]]; then continue; fi
    trailingws <"$0" \
    | squeezenls \
    | trailingnl \
    | sponge "$0"
  done
)

trailingws() (
  # `\s\+$` match one or more whitespace chars at end of line
  # `s/…//` remove
  # `-i` in-place
  sed 's/\s\+$//'
)

trailingnl() (
  sed -e '$a\'
)

squeezenls() (
  # roughly means:
  # - `$!N` If you're not at the last line, read in another line.
  # - `/^\n$/` Now look at what you have and see if it is a blankline followed by a blank line
  # - `!P` if it ISN'T, print out the line
  # - `D` Now discard the line (up to the newline).
  sed '$!N; /^\n$/!P; D'
)

main "$@"
