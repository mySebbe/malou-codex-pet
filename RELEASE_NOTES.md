# Malou Codex Pet v2.0.0

V2 looking-direction release for Malou, ready for Codex Desktop and the ChatGPT Web custom-pet uploader.

Landing page: https://myseb.be/malou-codex-pet/

## Release Assets

- `malou-codex-pet-v2.0.0.zip` — ready-to-copy desktop `malou` folder, install notes, license, and attribution
- `malou-chatgpt-web-v2.0.0.png` — verified direct upload for ChatGPT Web
- `malou-look-directions-v2.0.0.png` — square showcase of all 16 look directions
- `malou-v2.0.0-SHA256SUMS.txt` — SHA-256 checksums for the three downloadable assets above

## Highlights

- Extended the atlas from `8 x 9` to the Codex v2 `8 x 11` layout.
- Added 16 coherent clockwise look directions in 22.5-degree steps.
- Preserved the structure and motion of the nine approved standard animation rows and applied the final v2 transparency and chroma cleanup.
- Added `spriteVersionNumber: 2` to `dist/malou/pet.json`.
- Added a labeled look-direction sheet, two public look row strips, and 16 individual transparent direction frames.
- Passed deterministic atlas, chroma-despill, direction semantics, blind-direction, continuity, and independent final visual QA.
- Added a separately verified `1536 x 2288` ChatGPT Web PNG whose neutral cell follows the web renderer's compatibility behavior.
- Published and verified Malou's public ChatGPT adoption link.
- Added reproducible web-asset and GitHub-release packaging helpers.
- Updated all repository documentation, current OpenAI Pets and Remote links, release metadata, contribution guidance, and security support information for v2.
- Kept private photos, prompts, logs, Codex state backups, tokens, passwords, and machine-specific paths out of the repository.

## Install in Codex Desktop

Download `malou-codex-pet-v2.0.0.zip` and copy its `malou` folder into your local `.codex/pets/` directory, or clone the repository:

```powershell
git clone https://github.com/mySebbe/malou-codex-pet.git
cd malou-codex-pet
.\scripts\install.ps1 -Select
```

The `-Select` flag installs Malou into `%USERPROFILE%\.codex\pets\malou\` and sets `custom:malou` as the active Codex pet for desktop and mobile sync.

For macOS or Linux, copy these files to `${CODEX_HOME:-$HOME/.codex}/pets/malou/`, then select Malou in Codex Desktop:

- `dist/malou/pet.json`
- `dist/malou/spritesheet.webp`

## Upload to ChatGPT Web

Open **Settings > Personalization > Pet > Select pet**, choose **Upload pet**, enter `Malou`, and upload:

- Release asset: `malou-chatgpt-web-v2.0.0.png`
- Repository path: `dist/chatgpt-web/malou/spritesheet.png`

The live uploader accepted this `1536 x 2288` v2 PNG on 2026-07-25. The [public OpenAI Pets documentation](https://learn.chatgpt.com/docs/pets) still lists the v1 `1536 x 1872` upload size as of that check, so the verified v2 behavior is recorded explicitly here. The web form stores its own name and description, so `pet.json` is not uploaded there. The web-specific PNG keeps row 0, column 6 transparent; use the WebP package under `dist/malou/` for the desktop app.

Adopt Malou directly:

- https://chatgpt.com/s/sharepet_6a63ebbf4b448191bc9b6fb597429a15

## Repository Verification

Core atlas SHA-256 values:

```text
08330293f421dbd864e908ea9c23ece1fc9eb065e6126ac62b55f7602241b6c0  dist/malou/spritesheet.webp
10bf406875a69e17ec75e5b65b3f66510d3ac0ee47c41001be07b6fe201d512c  dist/chatgpt-web/malou/spritesheet.png
```

Use `malou-v2.0.0-SHA256SUMS.txt` for the downloadable GitHub release assets.
