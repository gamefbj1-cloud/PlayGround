#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
RUNTIME="${RUNTIME_DIR:-/home/runner/work/_temp/omgithub-runtime}"
export RUNTIME_DIR="$RUNTIME"
/usr/bin/time -p test -n "${CAPTURE_URL:-}" || { echo 'Set CAPTURE_URL.' >&2; exit 1; }
/usr/bin/time -p test -n "${CAPTURE_DIR:-}" || { echo 'Set CAPTURE_DIR.' >&2; exit 1; }
/usr/bin/time -p test -f "$RUNTIME/scripts/default-capture.mjs" || { echo 'Capture runtime missing.' >&2; exit 75; }
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p node "$RUNTIME/scripts/default-capture.mjs"
