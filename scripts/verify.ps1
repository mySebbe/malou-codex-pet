[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$checksumsPath = Join-Path $repoRoot "SHA256SUMS.txt"

if (-not (Test-Path -LiteralPath $checksumsPath -PathType Leaf)) {
    throw "Missing SHA256SUMS.txt"
}

foreach ($line in Get-Content -LiteralPath $checksumsPath) {
    if ([string]::IsNullOrWhiteSpace($line)) {
        continue
    }

    if ($line -notmatch "^([a-f0-9]{64})\s+(.+)$") {
        throw "Invalid checksum line: $line"
    }

    $expected = $Matches[1]
    $relativePath = $Matches[2].Trim()
    $filePath = Join-Path $repoRoot $relativePath

    if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) {
        throw "Missing file listed in SHA256SUMS.txt: $relativePath"
    }

    $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $filePath).Hash.ToLowerInvariant()
    if ($actual -ne $expected) {
        throw "Checksum mismatch for ${relativePath}: expected $expected, got $actual"
    }
}

$petJsonPath = Join-Path $repoRoot "dist\malou\pet.json"
$petJson = Get-Content -LiteralPath $petJsonPath -Raw | ConvertFrom-Json

if ($petJson.id -ne "malou") {
    throw "pet.json id must be 'malou'"
}

if ($petJson.displayName -ne "Malou") {
    throw "pet.json displayName must be 'Malou'"
}

if ($petJson.spritesheetPath -ne "spritesheet.webp") {
    throw "pet.json spritesheetPath must be 'spritesheet.webp'"
}

if ($petJson.spriteVersionNumber -ne 2) {
    throw "pet.json spriteVersionNumber must be 2"
}

$spritesheetPath = Join-Path $repoRoot "dist\malou\spritesheet.webp"
$spritesheet = Get-Item -LiteralPath $spritesheetPath
if ($spritesheet.Length -le 0) {
    throw "spritesheet.webp is empty"
}

if ($spritesheet.Length -gt 20MB) {
    throw "spritesheet.webp exceeds the 20 MiB ChatGPT Web upload limit"
}

$atlasMetadataPath = Join-Path $repoRoot "metadata\atlas.json"
$atlasMetadata = Get-Content -LiteralPath $atlasMetadataPath -Raw | ConvertFrom-Json

if ($atlasMetadata.package.width -ne 1536 -or $atlasMetadata.package.height -ne 2288) {
    throw "metadata atlas size must be 1536 x 2288"
}

if ($atlasMetadata.grid.columns -ne 8 -or $atlasMetadata.grid.rows -ne 11) {
    throw "metadata grid must be 8 x 11"
}

if ($atlasMetadata.lookDirections.Count -ne 16) {
    throw "metadata must list all 16 look directions"
}

Write-Host "Malou pet package verified."
