# shellcheck shell=bash

die() {
  if [ "$#" -gt 0 ]; then echo >&2 "$@"; fi
  exit 1
}

## # Split by Fences
## `split_fences <start pattern> <end pattern>`
##
## A filter that prints only lines in-between (exclusive) lines matching the start/end patterns.
## The patterns can be
## - (default) awk regex
## - `-F` literal (TODO)
split_fences() (
  start="$1"
  end="$2"
  awk "/$start/ {y=1; next} /$end/ {y=0; next} y {print}"
)

shld::takedocs() (
  awk '
/^##( |$)/ { print; y=1; next }
y { print ""; y=0 }
{next}
' | sed -E 's/^##( |$)//'
)

shld::listfuncs() (
  grep -Eix '(function )?[a-z:_-]+\(\) [({]\s*(#.*)?' | grep -Eo --color=never '\b[a-z:_-]+\b'
)
