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

$spritesheetPath = Join-Path $repoRoot "dist\malou\spritesheet.webp"
if ((Get-Item -LiteralPath $spritesheetPath).Length -le 0) {
    throw "spritesheet.webp is empty"
}

Write-Host "Malou pet package verified."
