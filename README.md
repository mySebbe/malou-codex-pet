# Malou Codex Pet

[![Release](https://img.shields.io/github/v/release/mySebbe/malou-codex-pet?label=release)](https://github.com/mySebbe/malou-codex-pet/releases/latest)
[![License](https://img.shields.io/badge/license-MIT%20%2B%20CC--BY--NC--4.0-blue)](LICENSE.md)

[Landing page](https://myseb.be/malou-codex-pet/) · [Latest release](https://github.com/mySebbe/malou-codex-pet/releases/latest)

![Malou contact sheet](assets/contact-sheet.png)

Malou is a custom v2 pet based on a brown-and-white dog companion. The package contains the ready-to-install `pet.json` and transparent `spritesheet.webp` for Codex Desktop and ChatGPT Web, plus curated source frames and preview media for anyone who wants to inspect the atlas. The v2 atlas preserves all nine status animation rows and adds 16 clockwise look directions. Working, waiting, review, and failed states include matching body poses plus small attached status badges so Malou remains readable in compact mobile bubbles.

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

## ChatGPT Web

ChatGPT Web stores uploaded pets separately from Codex Desktop, so installing Malou locally does not automatically add her to the web pet picker.

1. Open ChatGPT Web and go to **Settings > Personalization > Pet > Select pet**.
2. Choose **Upload pet**.
3. Enter `Malou` as the name and upload `dist/malou/spritesheet.webp`.
4. Save the upload, then select Malou in the pet list.

The current ChatGPT Web uploader accepts transparent PNG or WebP atlases in either `1536 x 1872` (v1) or `1536 x 2288` (v2), up to 20 MiB. This repository ships the v2 atlas, including all 16 look directions. The web upload form takes the pet name and description directly; it does not require `pet.json`.

OpenAI pet documentation: https://learn.chatgpt.com/docs/pets

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

Validated on 2026-07-25 as a Codex v2 custom pet package with an `8 x 11` atlas, all nine standard animation rows, and 16 clockwise look directions. The standard row poses come from the previously tested Codex Desktop and Android Codex Pet release and passed final v2 visual QA after atlas cleanup; the v2 atlas also matches the current ChatGPT Web upload dimensions.

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
| 16 look directions | [`look-directions.png`](assets/look-directions.png) |

## Package

| File | Purpose |
| --- | --- |
| `dist/malou/pet.json` | Codex pet manifest |
| `dist/malou/spritesheet.webp` | Transparent v2 animated pet atlas for Codex Desktop and ChatGPT Web |
| `assets/contact-sheet.png` | Visual overview of the complete `8 x 11` atlas |
| `assets/look-directions.png` | Labeled overview of all 16 clockwise look directions |
| `assets/previews/*.mp4` | Short animation previews by state |
| `source/frames/` | Curated transparent standard and look-direction frames |
| `source/row-strips/` | Standard animation strips plus the two v2 look rows |
| `metadata/atlas.json` | Public atlas metadata and checksums |

## Atlas Specs

| Property | Value |
| --- | --- |
| Pet id | `malou` |
| Version | `2.0.0` |
| Sprite version | `2` |
| Atlas format | WebP, RGBA |
| Atlas size | `1536 x 2288` |
| Grid | `8 x 11` |
| Cell size | `192 x 208` |
| Standard animation rows | `9` |
| Look directions | `16`, clockwise in 22.5° steps |
| Unused cells | Transparent |
| Main spritesheet SHA-256 | `08330293f421dbd864e908ea9c23ece1fc9eb065e6126ac62b55f7602241b6c0` |

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

## Look Directions

The look sequence advances clockwise. `000` means looking up, not a neutral pose.

| Atlas row | Directions |
| ---: | --- |
| 9 | `000`, `022.5`, `045`, `067.5`, `090`, `112.5`, `135`, `157.5` |
| 10 | `180`, `202.5`, `225`, `247.5`, `270`, `292.5`, `315`, `337.5` |

The neutral look frame is standard row 0, column 6. See [`assets/look-directions.png`](assets/look-directions.png) for the labeled QA sheet.

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
