#!/usr/bin/env bash
# duda-iframe.html is the single source of truth for the embeddable page.
# Every duda-iframe-vN.html is a byte-identical copy of it; the vN suffixes
# exist only to hand Duda/browsers a fresh URL when their cache will not
# release the old markup.
#
# FROZEN is the exception: those are published URLs that must keep serving the
# markup they serve today, so the sync skips them. Only remove one when the
# owner has asked for that URL to be republished.
#
# index.html (local preview) and duda-widget.html (Duda paste fragment) have
# their own page shells, so they cannot be copied wholesale. This script
# instead checks that their copy block still matches the canonical one, which
# is where every drift in this repo has come from.
set -euo pipefail
shopt -s nullglob
cd "$(dirname "$0")"

SRC=duda-iframe.html
FROZEN=(duda-iframe-v7.html)

# bash 3.2 is still /bin/bash on macOS and treats "${FROZEN[@]}" as unbound
# under `set -u` when the array is empty, so expand it defensively.
is_frozen() {
  local f
  for f in ${FROZEN[@]+"${FROZEN[@]}"}; do
    [ "$1" = "$f" ] && return 0
  done
  return 1
}

for f in duda-iframe-v*.html; do
  if is_frozen "$f"; then
    echo "frozen $f (left as published)"
    continue
  fi
  cp "$SRC" "$f"
  echo "synced $f"
done

block() {
  sed -n '/<div class="globe-copy"/,/^<\/div>$/p' "$1"
}

# Two empty block() results must never compare equal, or a changed anchor
# would turn this guard into a silent pass.
canonical="$(block "$SRC")"
if [ -z "$canonical" ]; then
  echo "FATAL  no copy block found in $SRC (anchor changed?)" >&2
  exit 1
fi

status=0
for f in index.html duda-widget.html; do
  found="$(block "$f")"
  if [ -z "$found" ]; then
    echo "DRIFT  $f has no copy block (anchor missing)" >&2
    status=1
  elif [ "$canonical" = "$found" ]; then
    echo "ok     $f (copy block matches $SRC)"
  else
    echo "DRIFT  $f copy block differs from $SRC" >&2
    status=1
  fi
done
exit "$status"
