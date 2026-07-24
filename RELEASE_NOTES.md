# Malou Codex Pet v2.0.0

V2 looking-direction release for Malou, ready for Codex Desktop and the ChatGPT Web custom-pet uploader.

Landing page: https://myseb.be/malou-codex-pet/

## Highlights

- Extended the atlas from `8 x 9` to the Codex v2 `8 x 11` layout.
- Added 16 coherent clockwise look directions in 22.5-degree steps.
- Preserved the structure and motion of the nine approved standard animation rows and applied the final v2 transparency and chroma cleanup.
- Added `spriteVersionNumber: 2` to `dist/malou/pet.json`.
- Added a labeled look-direction sheet, two public look row strips, and 16 individual transparent direction frames.
- Passed deterministic atlas, chroma-despill, direction semantics, blind-direction, continuity, and independent final visual QA.
- Added a separately verified `1536 x 2288` ChatGPT Web PNG whose neutral cell follows the web renderer's compatibility behavior.
- Published and verified Malou's public ChatGPT adoption link.
- Kept private photos, prompts, logs, Codex state backups, tokens, passwords, and machine-specific paths out of the repository.

## Install in Codex Desktop

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

## Upload to ChatGPT Web

Open **Settings > Personalization > Pet > Select pet**, choose **Upload pet**, enter `Malou`, and upload:

- `dist/chatgpt-web/malou/spritesheet.png`

The web form stores its own name and description, so `pet.json` is not uploaded there. The web-specific PNG keeps row 0, column 6 transparent; use the WebP package under `dist/malou/` for Codex Desktop.

Adopt Malou directly:

- https://chatgpt.com/s/sharepet_6a63ebbf4b448191bc9b6fb597429a15

## Verification

Main spritesheet SHA-256:

```text
08330293f421dbd864e908ea9c23ece1fc9eb065e6126ac62b55f7602241b6c0  dist/malou/spritesheet.webp
10bf406875a69e17ec75e5b65b3f66510d3ac0ee47c41001be07b6fe201d512c  dist/chatgpt-web/malou/spritesheet.png
```
