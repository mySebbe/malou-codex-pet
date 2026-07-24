# Contributing

Small fixes are welcome.

## Useful Contributions

- README or install-instruction fixes
- checksum or metadata corrections
- improved preview media
- Codex compatibility notes
- asset validation improvements

## Asset Rules

- Do not commit raw private photos.
- Do not commit prompt dumps, job logs, local Codex state, or machine-specific paths.
- Do not commit tokens, passwords, API keys, or private credentials.
- Keep `dist/malou/pet.json` and `dist/malou/spritesheet.webp` installable together.
- Keep `dist/chatgpt-web/malou/spritesheet.png` reproducible with `scripts/build-web-assets.py`.
- Preserve the v2 `8 x 11` atlas layout, `spriteVersionNumber: 2`, all nine standard animation rows, and all 16 clockwise look directions.
- Update `SHA256SUMS.txt`, `metadata/atlas.json`, and `CHANGELOG.md` when changing released assets.

## Before Opening a Pull Request

```powershell
.\scripts\verify.ps1
.\scripts\package-release.ps1 -Version 2.0.0
```

Release output is written under the ignored `release/` directory. Also inspect `git diff` for accidental private paths or generated logs.
