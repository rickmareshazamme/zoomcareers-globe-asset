#!/usr/bin/env bash
# duda-iframe.html is the single source of truth for the embeddable page.
# Every duda-iframe-vN.html is a byte-identical copy of it; the vN suffixes
# exist only to hand Duda/browsers a fresh URL when their cache will not
# release the old markup.
#
# index.html (local preview) and duda-widget.html (Duda paste fragment) have
# their own page shells, so they cannot be copied wholesale. This script
# instead checks that their copy block still matches the canonical one, which
# is where every drift in this repo has come from.
set -euo pipefail
shopt -s nullglob
cd "$(dirname "$0")"

SRC=duda-iframe.html

for f in duda-iframe-v*.html; do
  cp "$SRC" "$f"
  echo "synced $f"
done

block() {
  sed -n '/<div style="position:absolute;top:60px/,/^<\/div>$/p' "$1"
}

status=0
for f in index.html duda-widget.html; do
  if [ "$(block "$SRC")" = "$(block "$f")" ]; then
    echo "ok     $f (copy block matches $SRC)"
  else
    echo "DRIFT  $f copy block differs from $SRC" >&2
    status=1
  fi
done
exit "$status"
