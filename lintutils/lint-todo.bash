#!/bin/bash
# SPDX-FileCopyrightText: © 2024 Marseille Bouchard <marseillebd@proton.me>
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

main() (
  flags=('--color=auto')
  flags+=('--exclude-dir=.git')

  grep -Er "${flags[@]}" '\bTODO\b' . || true
  grep -Er "${flags[@]}" '\bFIX(ME)?\b' . || true
  grep -Er "${flags[@]}" '\bDEL(ETE)?(ME)?\b' . || true
  grep -Er "${flags[@]}" '\bDEBUG\b' . || true
)

main "$@"