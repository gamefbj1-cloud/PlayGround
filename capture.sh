#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
if [[ -z "${CAPTURE_URL:-}" ]]; then echo "Set CAPTURE_URL and CAPTURE_DIR." >&2; exit 1; fi
if [[ -z "${CAPTURE_DIR:-}" ]]; then echo "Set CAPTURE_URL and CAPTURE_DIR." >&2; exit 1; fi
RUNTIME_DIR="${RUNTIME_DIR:-/home/runner/work/_temp/omgithub-runtime}"
export RUNTIME_DIR
/usr/bin/time -p bash -c 'echo "capturing $CAPTURE_URL -> $CAPTURE_DIR"'
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p bash -c 'case "$CAPTURE_DIR" in "$PWD"/*) echo "CAPTURE_DIR must be outside the project source: $CAPTURE_DIR" >&2; exit 1;; esac'
/usr/bin/time -p node "${RUNTIME_DIR}/scripts/default-capture.mjs"
/usr/bin/time -p test -f "$CAPTURE_DIR/final-desktop.png"
/usr/bin/time -p test -f "$CAPTURE_DIR/final-mobile.png"
/usr/bin/time -p ls -lh "$CAPTURE_DIR/final-desktop.png" "$CAPTURE_DIR/final-mobile.png"
