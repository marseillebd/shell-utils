#!/bin/bash
# SPDX-FileCopyrightText: © 2024 Marseille Bouchard <marseillebd@proton.me>
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

main() (
  flags=('--color=auto')
  flags+=('--exclude-dir=.git')

  grep -r "${flags[@]}" '\bTODO\b' . || true
  grep -r "${flags[@]}" '\bFIX\(ME\)?\b' . || true
  grep -r "${flags[@]}" '\bDEL\(ETE\)\?\(ME\)\?\b' . || true
)

main "$@"