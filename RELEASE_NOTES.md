# Malou Codex Pet v1.2.0

Status-readable refresh for the Malou custom Codex pet, with mobile sync repair and stable checkout verification on Windows.

Landing page: https://myseb.be/malou-codex-pet/

## Highlights

- Updated `dist/malou/spritesheet.webp` with status-readable badges for working, waiting for input, review, and failed states.
- Regenerated the contact sheet, row strips, source frames, metadata, checksums, and MP4 animation previews.
- Added install support for selecting Malou as `custom:malou` from PowerShell.
- Added `scripts/rebuild-status-assets.ps1` to rebuild the status-aware package assets.
- Added after-exit repair support for Codex Desktop restarts that rewrite `.codex-global-state.json`.
- Documented how Codex mobile on Android and iOS picks up the selected desktop pet through the connected desktop workspace.
- Added repository line-ending rules so the checksum verifier remains stable after a fresh Windows checkout.
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
497f61dd133e2ba125f83bc219c6eee987f91d340bd4a12e2f09b67b8cca1c9d  dist/malou/spritesheet.webp
```
