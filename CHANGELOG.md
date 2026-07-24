# Changelog

All notable changes to this project are documented here.

## Unreleased

No unreleased changes.

## [2.0.0] - 2026-07-25

### Added

- Added 16 clockwise look directions in 22.5-degree steps across atlas rows 9 and 10.
- Added labeled look-direction QA artwork plus public direction row strips and individual transparent direction frames.
- Added a separately verified ChatGPT Web v2 atlas, direct adoption link, upload instructions, and square sharing card.
- Added reproducible web-asset and GitHub-release packaging helpers plus versioned desktop, web, showcase, and checksum release downloads.

### Changed

- Upgraded `dist/malou/spritesheet.webp` from the `8 x 9` v1 layout to the `8 x 11` v2 layout.
- Added `spriteVersionNumber: 2` to the pet manifest.
- Updated the contact sheet, public metadata, checksums, release notes, citation metadata, and verification checks.
- Preserved the approved structure and motion of all nine standard animation rows while applying the final v2 transparency and chroma cleanup.
- Kept the Codex Desktop neutral-look cell in the desktop package while making the corresponding cell transparent in the ChatGPT Web compatibility variant.
- Updated README, release notes, citation, attribution, contribution guidance, security support, issue templates, install output, metadata, and current OpenAI Pets and Remote links for v2.

### Validated

- Passed deterministic v2 atlas, chroma-despill, direction semantics, blind-direction, continuity, and independent final visual QA.
- Successfully uploaded, selected, shared, and reopened Malou through the public ChatGPT Web adoption page.

## [1.3.0] - 2026-06-02

### Changed

- Made Malou's own animation poses communicate status without relying only on badges: failed looks sad, waiting raises an asking paw, running shows focused work, and review shows a checking pose.
- Regenerated the atlas, contact sheet, source frames, row strips, previews, metadata, and package checksums for the new status-pose frames.

## [1.2.0] - 2026-06-02

### Changed

- Made Malou's status states more readable in small Codex mobile bubbles by adding attached visual badges for working, waiting for input, review, and failed states.

### Added

- Added `scripts/rebuild-status-assets.ps1` to regenerate status frames, row strips, atlas, contact sheet, preview videos, metadata, and package checksums.

### Fixed

- Updated `scripts/check-mobile-sync.ps1` to read current package hashes from `SHA256SUMS.txt` instead of hardcoding stale hashes.

## [1.1.2] - 2026-05-31

### Added

- Added `scripts/repair-after-codex-exit.ps1` for the case where a running Codex Desktop process keeps rewriting `.codex-global-state.json` back to the default pet.
- Added `scripts/check-mobile-sync.ps1` to verify and repair the local Codex Desktop state used by Android and iOS pet sync.

### Fixed

- Documented the Android fallback case where `.codex-global-state.json` loses `selected-avatar-id` and needs `custom:malou` restored.

## [1.1.1] - 2026-05-30

### Fixed

- Added `.gitattributes` so text assets keep stable line endings across Windows checkouts.
- Updated the public `pet.json` checksum to match the normalized repository file.

## [1.1.0] - 2026-05-30

### Changed

- Replaced the shipped Malou spritesheet with a mobile-bubble-optimized atlas.
- Regenerated the public contact sheet, row strips, source frames, and preview media from the optimized atlas.
- Updated package metadata and checksums for the new atlas.

### Added

- Documented the Codex Desktop to ChatGPT mobile sync path for Android and iOS.
- Added `scripts/install.ps1 -Select` support to install Malou and set `custom:malou` as the active Codex pet for mobile sync.

## [1.0.0] - 2026-05-09

### Added

- Initial public Malou Codex pet package.
- Ready-to-install `pet.json` and transparent WebP spritesheet.
- Curated source frames, row strips, contact sheet, and animation preview videos.
- Sanitized atlas metadata, checksums, install script, and verification script.
- Public repository docs, attribution, security policy, contribution guide, and release notes.
