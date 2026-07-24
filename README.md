# Malou Codex Pet

[![Release](https://img.shields.io/github/v/release/mySebbe/malou-codex-pet?label=release)](https://github.com/mySebbe/malou-codex-pet/releases/latest)
[![License](https://img.shields.io/badge/license-MIT%20%2B%20CC--BY--NC--4.0-blue)](LICENSE.md)

[Landing page](https://myseb.be/malou-codex-pet/) · [Latest release](https://github.com/mySebbe/malou-codex-pet/releases/latest) · [Adopt Malou in ChatGPT](https://chatgpt.com/s/sharepet_6a63ebbf4b448191bc9b6fb597429a15)

![Malou contact sheet](assets/contact-sheet.png)

Malou is a custom v2 pet based on a brown-and-white dog companion. The package contains the ready-to-install Codex Desktop files plus a separately verified ChatGPT Web atlas, curated source frames, and preview media for anyone who wants to inspect the animation. Both v2 variants preserve all nine status animation rows and add 16 clockwise look directions. Working, waiting, review, and failed states include matching body poses plus small attached status badges so Malou remains readable in compact mobile bubbles.

This is not an official OpenAI or Codex asset.

## Release Downloads

The [v2.0.0 release](https://github.com/mySebbe/malou-codex-pet/releases/tag/v2.0.0) provides four ready-to-use assets:

- [`malou-codex-pet-v2.0.0.zip`](https://github.com/mySebbe/malou-codex-pet/releases/download/v2.0.0/malou-codex-pet-v2.0.0.zip) — desktop package containing the `malou` pet folder
- [`malou-chatgpt-web-v2.0.0.png`](https://github.com/mySebbe/malou-codex-pet/releases/download/v2.0.0/malou-chatgpt-web-v2.0.0.png) — direct ChatGPT Web upload
- [`malou-look-directions-v2.0.0.png`](https://github.com/mySebbe/malou-codex-pet/releases/download/v2.0.0/malou-look-directions-v2.0.0.png) — shareable 16-direction showcase
- [`malou-v2.0.0-SHA256SUMS.txt`](https://github.com/mySebbe/malou-codex-pet/releases/download/v2.0.0/malou-v2.0.0-SHA256SUMS.txt) — release-asset checksums

## Install

### Windows PowerShell

Either download and extract `malou-codex-pet-v2.0.0.zip`, then copy its `malou` folder to `%USERPROFILE%\.codex\pets\`, or install from a clone:

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
3. Enter `Malou` as the name and upload `malou-chatgpt-web-v2.0.0.png` from the release, or `dist/chatgpt-web/malou/spritesheet.png` from a repository checkout.
4. Save the upload, then select Malou in the pet list.

The live ChatGPT Web uploader accepted this transparent `1536 x 2288` v2 PNG on 2026-07-25, including all 16 look directions. The current [public OpenAI Pets documentation](https://learn.chatgpt.com/docs/pets) still lists the v1 `1536 x 1872` upload size, so this repository records the tested v2 behavior separately. The web variant also keeps row 0, column 6 transparent because the live upload path rejected Malou's desktop atlas when that desktop-only neutral cell was populated. The desktop package uses `dist/malou/spritesheet.webp`, which includes its explicit neutral-look cell. The web form takes the pet name and description directly; it does not require `pet.json`.

The public adoption page is [chatgpt.com/s/sharepet_6a63ebbf4b448191bc9b6fb597429a15](https://chatgpt.com/s/sharepet_6a63ebbf4b448191bc9b6fb597429a15).

## Mobile Sync

There is no separate Android or iOS pet package. Install and select Malou on the desktop machine that ChatGPT Remote connects to, then open the remote session on iOS or Android.

Current OpenAI references:

- ChatGPT Remote: https://chatgpt.com/remote/
- Pets: https://learn.chatgpt.com/docs/pets

Checklist:

1. Install this package into `${CODEX_HOME:-$HOME/.codex}/pets/malou`.
2. Select `Malou` in Codex Desktop or run `.\scripts\install.ps1 -Select` on Windows PowerShell.
3. Restart Codex Desktop and use Settings > Appearance > Pets > Refresh custom pets if Malou is not listed.
4. Open ChatGPT Remote on iOS or Android with the same account and connected desktop.
5. Wake or select the Pet from the supported desktop or remote interface.

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

Validated on 2026-07-25 as a Codex v2 custom pet package with an `8 x 11` atlas, all nine standard animation rows, and 16 clockwise look directions. The standard row poses come from the previously tested Codex Desktop and Android Codex Pet release and passed final v2 visual QA after atlas cleanup. The separate ChatGPT Web PNG was successfully uploaded, selected, shared, and opened through its public adoption link on the same date.

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
| `dist/malou/spritesheet.webp` | Transparent v2 animated pet atlas for Codex Desktop |
| `dist/chatgpt-web/malou/spritesheet.png` | Verified transparent v2 atlas for direct ChatGPT Web upload |
| `assets/contact-sheet.png` | Visual overview of the complete `8 x 11` atlas |
| `assets/look-directions.png` | Labeled overview of all 16 clockwise look directions |
| `assets/malou-look-directions-share.png` | Square social card showing the 16 look directions |
| `assets/previews/*.mp4` | Short animation previews by state |
| `source/frames/` | Curated transparent standard and look-direction frames |
| `source/row-strips/` | Standard animation strips plus the two v2 look rows |
| `metadata/atlas.json` | Public atlas metadata and checksums |
| `scripts/package-release.ps1` | Builds the four versioned GitHub release assets |

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
| ChatGPT Web atlas SHA-256 | `10bf406875a69e17ec75e5b65b3f66510d3ac0ee47c41001be07b6fe201d512c` |

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

The Codex Desktop neutral look frame is standard row 0, column 6. The ChatGPT Web upload variant intentionally leaves that desktop-only cell transparent. See [`assets/look-directions.png`](assets/look-directions.png) for the labeled QA sheet.

## Verify

```powershell
.\scripts\verify.ps1
.\scripts\package-release.ps1 -Version 2.0.0
```

Expected repository checksums are listed in `SHA256SUMS.txt`; the packaging script creates a separate checksum file for GitHub release downloads.

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
