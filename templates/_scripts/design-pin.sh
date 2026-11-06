#!/bin/bash
# design-pin.sh <phase> [export-folder]
# Pin the design frames a UI phase is built against. Used by /apple:plan.
# Copies the export folder's PNGs (if given) into .planning/design/phase-<N>/pinned/
# and writes pin.tsv (frame name <TAB> sha256). Run from the project root.
set -u
[ $# -ge 1 ] || { echo "usage: design-pin.sh <phase> [export-folder]" >&2; exit 2; }
pin=".planning/design/phase-$1"
mkdir -p "$pin/pinned"
if [ $# -ge 2 ]; then
  ls "$2"/*.png >/dev/null 2>&1 || { echo "design-pin: no PNGs in $2" >&2; exit 1; }
  cp "$2"/*.png "$pin/pinned/"
fi
ls "$pin/pinned"/*.png >/dev/null 2>&1 || { echo "design-pin: no PNGs in $pin/pinned" >&2; exit 1; }
( cd "$pin/pinned" && shasum -a 256 -- *.png ) | sed -E 's/^([0-9a-f]+) [ *](.*)$/\2	\1/' | sort > "$pin/pin.tsv"
echo "✓ Pinned $(wc -l < "$pin/pin.tsv" | tr -d ' ') frames in $pin"
