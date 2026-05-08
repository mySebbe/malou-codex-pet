# Malou Codex Pet v1.0.0

Initial public release of the Malou custom Codex Desktop pet.

Landing page: https://myseb.be/malou-codex-pet/

## Highlights

- Installable Codex pet package in `dist/malou/`.
- Transparent WebP atlas with 9 animation rows and 58 curated source frames.
- Contact sheet and short MP4 previews for visual inspection.
- Sanitized metadata and checksums.
- No private prompts, logs, Codex state files, tokens, passwords, or original private photo files.

## Install

Download the release ZIP or clone the repository, then copy:

- `dist/malou/pet.json`
- `dist/malou/spritesheet.webp`

to:

- Windows: `%USERPROFILE%\.codex\pets\malou\`
- macOS/Linux: `${CODEX_HOME:-$HOME/.codex}/pets/malou/`

Restart Codex Desktop and choose `Malou`.

## Verification

Main spritesheet SHA-256:

```text
09df813e132d69f9e03a652ef0c14d51fcb30ac79f4ead9d026c5c5c13b9f5bb  dist/malou/spritesheet.webp
```
