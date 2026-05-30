# Malou Codex Pet v1.1.0

Mobile sync refresh for the Malou custom Codex pet.

Landing page: https://myseb.be/malou-codex-pet/

## Highlights

- Updated `dist/malou/spritesheet.webp` with the larger mobile-bubble-optimized Malou atlas.
- Regenerated the contact sheet, row strips, source frames, and MP4 animation previews.
- Added install support for selecting Malou as `custom:malou` from PowerShell.
- Documented how Codex mobile on Android and iOS picks up the selected desktop pet through the connected desktop workspace.
- Kept private photos, prompts, logs, Codex state backups, tokens, passwords, and machine-specific paths out of the repository.

## Install

Download the release ZIP or clone the repository:

```powershell
git clone https://github.com/mySebbe/malou-codex-pet.git
cd malou-codex-pet
.\scripts\install.ps1 -Select
```

The `-Select` flag installs Malou into `%USERPROFILE%\.codex\pets\malou\` and sets `custom:malou` as the active Codex pet for desktop and mobile sync.

For macOS or Linux, copy these files to `${CODEX_HOME:-$HOME/.codex}/pets/malou/`, then select Malou in Codex Desktop:

- `dist/malou/pet.json`
- `dist/malou/spritesheet.webp`

Restart Codex Desktop, open Codex in the ChatGPT iOS or Android app with the same account, and wake the Codex Pet.

## Verification

Main spritesheet SHA-256:

```text
89e86f6dabb1d1f4ad838add39d3cf1207c3121db1dede26d2ad23623e2d4375  dist/malou/spritesheet.webp
```
