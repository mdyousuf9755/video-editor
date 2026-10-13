#!/usr/bin/env bash
# Scaffold a HyperFrames composition under projects/<name>, wired for fully
# local rendering (GSAP served from the project, not a CDN).
#
# Usage: scripts/new-project.sh <name> [extra `hyperframes init` flags]
#   e.g. scripts/new-project.sh promo --resolution portrait
#        scripts/new-project.sh recut --video footage/raw.mp4
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${1:?usage: new-project.sh <name> [hyperframes init flags]}"
shift
export HYPERFRAMES_SKIP_SKILLS=1 HYPERFRAMES_NO_TELEMETRY=1

mkdir -p "$ROOT/projects"
cd "$ROOT/projects"
npx --prefix "$ROOT" hyperframes init "$NAME" --non-interactive "$@"

PROJECT="$ROOT/projects/$NAME"
mkdir -p "$PROJECT/assets/vendor"
cp "$ROOT/node_modules/gsap/dist/gsap.min.js" "$PROJECT/assets/vendor/gsap.min.js"
# Point any CDN GSAP <script> at the local copy.
find "$PROJECT" -name '*.html' -not -path '*/node_modules/*' -print0 |
  xargs -0 sed -i -E 's#https://cdn\.jsdelivr\.net/npm/gsap@[^"]*/dist/gsap\.min\.js#assets/vendor/gsap.min.js#g'

# The scaffold's agent notes say to run `skills update`; this repo vendors skills instead.
for doc in "$PROJECT/CLAUDE.md" "$PROJECT/AGENTS.md"; do
  [[ -f "$doc" ]] && printf '\n> **This repo:** HyperFrames skills are vendored in the root `.claude/skills/` — do not run\n> `hyperframes skills update` or `skills add`. Root `CLAUDE.md` overrides take precedence.\n' >> "$doc"
done

echo "Created $PROJECT"
