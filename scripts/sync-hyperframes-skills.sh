#!/usr/bin/env bash
# Vendor HyperFrames' published agent skills into this repo's .claude/skills/,
# pinned to the same release as the hyperframes CLI in package.json.
# Upstream (heygen-com/hyperframes) is only read, never modified.
#
# Usage: scripts/sync-hyperframes-skills.sh            # version from package.json
#        scripts/sync-hyperframes-skills.sh 0.8.160    # explicit version
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-$(node -p "require('$ROOT/package.json').devDependencies.hyperframes")}"
TAG="v${VERSION}"
DEST="$ROOT/.claude/skills"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git -c advice.detachedHead=false clone --quiet --depth 1 --branch "$TAG" --filter=blob:none --sparse \
  https://github.com/heygen-com/hyperframes.git "$TMP/hf"
git -C "$TMP/hf" sparse-checkout set --no-cone /skills/ /LICENSE
COMMIT="$(git -C "$TMP/hf" rev-parse HEAD)"

mkdir -p "$DEST"
# Remove previously vendored HyperFrames skills (listed in the old lock file);
# project-owned skills in .claude/skills are left alone.
if [[ -f "$DEST/.hyperframes-skills.lock" ]]; then
  grep -E '^skill ' "$DEST/.hyperframes-skills.lock" | cut -d' ' -f2 | while read -r s; do
    rm -rf "${DEST:?}/$s"
  done
fi

SKILLS=()
for dir in "$TMP/hf/skills"/*/; do
  name="$(basename "$dir")"
  [[ -f "$dir/SKILL.md" ]] || continue
  cp -R "$dir" "$DEST/$name"
  SKILLS+=("$name")
done
cp "$TMP/hf/LICENSE" "$DEST/HYPERFRAMES-LICENSE"

{
  echo "# Vendored by scripts/sync-hyperframes-skills.sh — do not edit by hand."
  echo "source https://github.com/heygen-com/hyperframes"
  echo "tag $TAG"
  echo "commit $COMMIT"
  for s in "${SKILLS[@]}"; do echo "skill $s"; done
} > "$DEST/.hyperframes-skills.lock"

echo "Vendored ${#SKILLS[@]} HyperFrames skills from $TAG ($COMMIT) into $DEST"
