#!/bin/bash
set -e

usage() {
  echo >&2 "USAGE: $0 <seconds> <command>"
  echo >&2 '  execute a command, and then kill it after some number of seconds'
}

case $# in
  0) usage; exit 1 ;;
  *) ;;
esac

case $1 in
  *) t=$1; shift;; # must be a number FIXME
esac

$@ &
pid=$!
sleep "${t}s"
kill $pid
