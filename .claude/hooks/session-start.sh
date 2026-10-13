#!/usr/bin/env bash
# Cloud sessions start from a fresh clone: install the local video toolchain.
set -euo pipefail
[[ "${CLAUDE_CODE_REMOTE:-}" == "true" ]] || exit 0
cd "$CLAUDE_PROJECT_DIR"
bash scripts/setup.sh >&2
