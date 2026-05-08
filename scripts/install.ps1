[CmdletBinding()]
param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" })
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$source = Join-Path $repoRoot "dist\malou"
$target = Join-Path $CodexHome "pets\malou"

$manifest = Join-Path $source "pet.json"
$spritesheet = Join-Path $source "spritesheet.webp"

if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
    throw "Missing package file: $manifest"
}

if (-not (Test-Path -LiteralPath $spritesheet -PathType Leaf)) {
    throw "Missing package file: $spritesheet"
}

New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -LiteralPath $manifest -Destination $target -Force
Copy-Item -LiteralPath $spritesheet -Destination $target -Force

Write-Host "Installed Malou to $target"
Write-Host "Restart Codex Desktop and select Malou."
