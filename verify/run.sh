#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
for a in 1 2 3 4 5 6 7 8; do bash verify/AC-$a.sh; done
echo "ALL 8 GATES PASS"
