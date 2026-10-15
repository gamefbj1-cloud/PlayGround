#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
/usr/bin/time -p test -n "${CAPTURE_URL:-}" || { echo "Set CAPTURE_URL." >&2; exit 1; }
/usr/bin/time -p test -n "${CAPTURE_DIR:-}" || { echo "Set CAPTURE_DIR." >&2; exit 1; }
/usr/bin/time -p test -n "${RUNTIME_DIR:-}" || { echo "Set RUNTIME_DIR." >&2; exit 1; }
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p test -f "${RUNTIME_DIR}/scripts/default-capture.mjs" || { echo "Missing default-capture.mjs." >&2; exit 1; }
set +e
/usr/bin/time -p node "${RUNTIME_DIR}/scripts/default-capture.mjs"
capture_status=$?
set -e
/usr/bin/time -p printf 'capture backend exited %s\n' "$capture_status"
if [ "$capture_status" -ne 0 ]; then exit "$capture_status"; fi
/usr/bin/time -p test -f "$CAPTURE_DIR/final-desktop.png" || { echo "Missing final-desktop.png." >&2; exit 1; }
/usr/bin/time -p test -f "$CAPTURE_DIR/final-mobile.png" || { echo "Missing final-mobile.png." >&2; exit 1; }
/usr/bin/time -p node -e 'const fs=require("fs");for(const n of ["final-desktop.png","final-mobile.png"]){const p=require("path").join(process.env.CAPTURE_DIR,n);const b=fs.readFileSync(p);if(b.length<24||b.subarray(0,8).toString("hex")!=="89504e470d0a1a0a"){console.error("Not a PNG: "+n);process.exit(1);}console.log(n+" "+b.length+" bytes");}'
