#!/usr/bin/env bash
# Install this repo's local video toolchain: pinned HyperFrames CLI + GSAP
# (node_modules) and the headless Chrome HyperFrames renders with.
# Safe to re-run; used by the SessionStart hook in cloud sessions.
set -euo pipefail
cd "$(dirname "$0")/.."

export HYPERFRAMES_SKIP_SKILLS=1 HYPERFRAMES_NO_TELEMETRY=1 HYPERFRAMES_NO_UPDATE_CHECK=1

if [[ -f package-lock.json ]]; then npm ci --no-audit --no-fund; else npm install --no-audit --no-fund; fi
npx hyperframes browser ensure
command -v ffmpeg >/dev/null || echo "warning: ffmpeg not found — HyperFrames needs FFmpeg to render" >&2
