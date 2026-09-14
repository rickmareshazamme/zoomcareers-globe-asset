#!/usr/bin/env bash
# duda-iframe.html is the single source of truth for the embeddable page.
# Every duda-iframe-vN.html is a byte-identical copy that exists only to give
# Duda/browsers a fresh URL when their cache will not release the old markup.
# Run this after editing duda-iframe.html so no variant can drift.
set -euo pipefail
cd "$(dirname "$0")"
for f in duda-iframe-v*.html; do
  cp duda-iframe.html "$f"
  echo "synced $f"
done
