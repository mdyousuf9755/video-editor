# video-editor

Video editing workspace driven by Claude Code. **HyperFrames** (HTML → deterministic MP4) is the
animation and rendering engine; plain **FFmpeg** handles simple footage operations.

## Engine policy — which tool for which job

| Job | Use |
| --- | --- |
| Titles, kinetic text, captions, lower-thirds, overlays, transitions, motion graphics, slideshows, anything composited or animated | **HyperFrames** composition in `projects/<name>/`, rendered with `hyperframes render` |
| Edits on existing footage that add graphics (captioned talking-head, recut with overlays, beat-synced music video) | **HyperFrames** workflow skills (`/embedded-captions`, `/talking-head-recut`, `/music-to-video`, …) |
| Pure footage ops with no graphics: trim, concat, cut silences, transcode, resize/crop, extract/replace audio, loudness normalise | **FFmpeg** directly — faster, lossless where possible, no browser |
| Prep before a HyperFrames composition (rough cut, proxy, audio cleanup) | FFmpeg first, then feed the result to HyperFrames |

When unsure, start with the `/hyperframes` router skill.

## Local setup (all local, pinned)

- CLI: `hyperframes@0.8.153` and `gsap@3.14.2` are exact-pinned devDependencies — always call `npx hyperframes …`
  (from a project dir use `npx --prefix ../.. hyperframes …` or the project's own `npm run` scripts).
- Headless Chrome lives in `~/.cache/hyperframes`; `npm run setup` (or the SessionStart hook in cloud
  sessions) installs everything. Check with `npm run doctor`.
- Skills: the 21 published HyperFrames skills are **vendored** into `.claude/skills/`, pinned to the
  same release tag (see `.claude/skills/.hyperframes-skills.lock`). Upstream `heygen-com/hyperframes`
  is read-only to us — never push to it or edit vendored skill files; refresh with
  `npm run sync-skills [-- <version>]` after bumping the CLI pin.
- Env (`.claude/settings.json`): `HYPERFRAMES_SKIP_SKILLS=1`, telemetry and update checks off.

## Overrides to the upstream HyperFrames skills

These take precedence over instructions inside the vendored skills:

1. **Never run `npx hyperframes skills update …` / `npx skills add …`.** Every workflow skill is
   already vendored here; those commands write to the global `~/.claude/skills`. Just read the
   workflow's `SKILL.md` from `.claude/skills/<workflow>/`.
2. **Don't upgrade the CLI pin on your own** (`hyperframes upgrade`, `@latest`). Ask first; a bump
   means updating `package.json`, re-running `npm run sync-skills`, and re-checking projects.
3. **No CDN scripts in compositions.** The render browser has no reliable network. Load GSAP from
   `assets/vendor/gsap.min.js` (`scripts/new-project.sh` does this); vendor any other runtime
   library into the project's `assets/` the same way.
4. Don't use HeyGen cloud / Lambda / Cloud Run rendering or `publish` unless the user asks — render locally.

## Workflow

```bash
npm run new -- <name> [--resolution portrait|landscape|square] [--video path/to/clip.mp4]
cd projects/<name>
npx --prefix ../.. hyperframes check                  # lint + runtime + layout gate; must pass
npx --prefix ../.. hyperframes snapshot               # PNG key frames for visual review
npx --prefix ../.. hyperframes render -q draft        # quick preview → renders/<name>.mp4
npx --prefix ../.. hyperframes render -q delivery -o renders/final.mp4
```

Raw footage and renders are git-ignored (`*.mp4`, `*.mov`, …, `projects/*/renders/`).
`projects/smoke-test/` is a minimal composition for verifying the toolchain renders.
