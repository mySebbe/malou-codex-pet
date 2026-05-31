# Malou Codex Pet

[![Release](https://img.shields.io/github/v/release/mySebbe/malou-codex-pet?label=release)](https://github.com/mySebbe/malou-codex-pet/releases/latest)
[![License](https://img.shields.io/badge/license-MIT%20%2B%20CC--BY--NC--4.0-blue)](LICENSE.md)

[Landing page](https://myseb.be/malou-codex-pet/) · [Latest release](https://github.com/mySebbe/malou-codex-pet/releases/latest)

![Malou contact sheet](assets/contact-sheet.png)

Malou is a custom Codex Desktop pet based on a brown-and-white dog companion. The package contains the ready-to-install `pet.json` and mobile-bubble-optimized `spritesheet.webp`, plus curated source frames and preview media for anyone who wants to inspect the atlas.

This is not an official OpenAI or Codex asset.

## Install

### Windows PowerShell

```powershell
git clone https://github.com/mySebbe/malou-codex-pet.git
cd malou-codex-pet
.\scripts\install.ps1 -Select
```

Manual install:

```powershell
$target = Join-Path $HOME ".codex\pets\malou"
New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item ".\dist\malou\pet.json" $target -Force
Copy-Item ".\dist\malou\spritesheet.webp" $target -Force
```

After a manual copy, select `Malou` in Codex Desktop and restart the app. For the scripted install, the `-Select` flag sets `custom:malou` as the active desktop pet and writes the desktop state used by Codex mobile sync.

### macOS or Linux

```bash
git clone https://github.com/mySebbe/malou-codex-pet.git
cd malou-codex-pet
mkdir -p "${CODEX_HOME:-$HOME/.codex}/pets/malou"
cp dist/malou/pet.json "${CODEX_HOME:-$HOME/.codex}/pets/malou/"
cp dist/malou/spritesheet.webp "${CODEX_HOME:-$HOME/.codex}/pets/malou/"
```

Then select `Malou` in Codex Desktop under Settings > Appearance > Pets, or set `selected-avatar-id = "custom:malou"` in your Codex desktop configuration.

## Mobile Sync

There is no separate Android or iOS pet package. Install and select Malou on the desktop machine that ChatGPT mobile connects to, then open Codex in the ChatGPT app on iOS or Android.

OpenAI documents Codex mobile as using the connected desktop workspace files, project state, and configuration:

- Codex for mobile: https://chatgpt.com/codex/mobile/
- Codex pets: https://developers.openai.com/codex/app/settings#codex-pets

Checklist:

1. Install this package into `${CODEX_HOME:-$HOME/.codex}/pets/malou`.
2. Select `Malou` in Codex Desktop or run `.\scripts\install.ps1 -Select` on Windows PowerShell.
3. Restart Codex Desktop and use Settings > Appearance > Pets > Refresh custom pets if Malou is not listed.
4. Open Codex in the ChatGPT mobile app on iOS or Android with the same account and connected desktop.
5. Wake the Codex Pet from the mobile Codex UI. On Android, enable chat bubbles in Android settings if the bubble is not shown.

If Android falls back to the default pet after it worked before, check the desktop state that mobile sync uses:

```powershell
.\scripts\check-mobile-sync.ps1
```

Repair the local install and selected desktop state with:

```powershell
.\scripts\check-mobile-sync.ps1 -Repair
```

If Codex Desktop is still running and rewrites `.codex-global-state.json` back to the default pet, arm the after-exit repair first, then fully close and reopen Codex Desktop:

```powershell
.\scripts\repair-after-codex-exit.ps1
```

The important value is `selected-avatar-id = "custom:malou"` in both `config.toml` and `.codex-global-state.json`. Codex Desktop may rewrite `.codex-global-state.json` during app updates or restarts, so rerun the repair command and restart Codex Desktop if mobile stops showing Malou.

## Compatibility

Tested as a Codex Desktop custom pet package and Android Codex Pet bubble on 2026-05-31, including the after-exit repair path for Codex Desktop restarts.

## Previews

| State | Preview |
| --- | --- |
| `idle` | [`idle.mp4`](assets/previews/idle.mp4) |
| `running-right` | [`running-right.mp4`](assets/previews/running-right.mp4) |
| `running-left` | [`running-left.mp4`](assets/previews/running-left.mp4) |
| `waving` | [`waving.mp4`](assets/previews/waving.mp4) |
| `jumping` | [`jumping.mp4`](assets/previews/jumping.mp4) |
| `failed` | [`failed.mp4`](assets/previews/failed.mp4) |
| `waiting` | [`waiting.mp4`](assets/previews/waiting.mp4) |
| `running` | [`running.mp4`](assets/previews/running.mp4) |
| `review` | [`review.mp4`](assets/previews/review.mp4) |

## Package

| File | Purpose |
| --- | --- |
| `dist/malou/pet.json` | Codex pet manifest |
| `dist/malou/spritesheet.webp` | Transparent animated pet atlas, optimized for desktop and mobile bubbles |
| `assets/contact-sheet.png` | Visual overview of the atlas |
| `assets/previews/*.mp4` | Short animation previews by state |
| `source/frames/` | Curated transparent frame sources |
| `source/row-strips/` | Row-level atlas strips |
| `metadata/atlas.json` | Public atlas metadata and checksums |

## Atlas Specs

| Property | Value |
| --- | --- |
| Pet id | `malou` |
| Version | `1.1.1` |
| Atlas format | WebP, RGBA |
| Atlas size | `1536 x 1872` |
| Grid | `8 x 9` |
| Cell size | `192 x 208` |
| Unused cells | Transparent |
| Main spritesheet SHA-256 | `89e86f6dabb1d1f4ad838add39d3cf1207c3121db1dede26d2ad23623e2d4375` |

## Animations

| State | Row | Frames |
| --- | ---: | ---: |
| `idle` | 0 | 6 |
| `running-right` | 1 | 8 |
| `running-left` | 2 | 8 |
| `waving` | 3 | 4 |
| `jumping` | 4 | 5 |
| `failed` | 5 | 8 |
| `waiting` | 6 | 6 |
| `running` | 7 | 6 |
| `review` | 8 | 6 |

## Verify

```powershell
.\scripts\verify.ps1
```

Expected core checksums are listed in `SHA256SUMS.txt`.

## Privacy

This public repository intentionally excludes raw private generation data:

- original private photo/reference material
- prompt dumps and job logs
- local Codex state files
- local install-repair scripts and backups
- tokens, passwords, API keys, or machine-specific paths

The files included here are the curated public pet package, visual source frames, row strips, preview media, and sanitized metadata.

## License

Code, scripts, documentation, and metadata are MIT licensed.

Malou artwork assets in `dist/`, `assets/`, and `source/` are licensed under CC BY-NC 4.0 unless another written permission is granted by the owner.

See `LICENSE.md` and `ATTRIBUTION.md`.
