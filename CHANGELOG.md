# Changelog

All notable changes to this project are documented here.

## Unreleased

No unreleased changes.

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
