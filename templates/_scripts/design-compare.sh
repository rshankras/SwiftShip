#!/bin/bash
# design-compare.sh <phase> <fresh-export-folder>
# Compare a fresh export with the phase's pin. Used by /apple:verify 3.7c.
# Prints one line per difference: added|removed|changed <TAB> frame name.
# No output = design unchanged. Run from the project root.
set -u
[ $# -eq 2 ] || { echo "usage: design-compare.sh <phase> <fresh-export-folder>" >&2; exit 2; }
pin=".planning/design/phase-$1"
[ -f "$pin/pin.tsv" ] || { echo "design-compare: no pin at $pin/pin.tsv" >&2; exit 1; }
ls "$2"/*.png >/dev/null 2>&1 || { echo "design-compare: no PNGs in $2" >&2; exit 1; }
t="${TMPDIR:-/tmp}/pin.$$"
( cd "$2" && shasum -a 256 -- *.png ) | sed -E 's/^([0-9a-f]+) [ *](.*)$/\2	\1/' | sort > "$t"
awk -F'\t' 'FNR==NR { old[$1]=$2; next }
  { seen[$1]=1; if (!($1 in old)) print "added\t" $1; else if (old[$1] != $2) print "changed\t" $1 }
  END { for (n in old) if (!(n in seen)) print "removed\t" n }' "$pin/pin.tsv" "$t" | sort
rm -f "$t"
