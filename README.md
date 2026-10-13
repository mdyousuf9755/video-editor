# video-editor
Video editing project managed with Claude Code, using [HyperFrames](https://github.com/heygen-com/hyperframes)
as the local animation and rendering engine (FFmpeg for plain footage operations).

```bash
npm run setup                 # pinned HyperFrames CLI + GSAP + headless Chrome (needs Node 22+, FFmpeg)
npm run new -- my-video --resolution portrait
cd projects/my-video && npx --prefix ../.. hyperframes render
```

See `CLAUDE.md` for the engine policy and local setup rules.
