[CmdletBinding()]
param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }),
    [switch]$Repair
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$expectedAvatarId = "custom:malou"

function Get-ExpectedPackageHash {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    $checksumsPath = Join-Path $repoRoot "SHA256SUMS.txt"

    if (-not (Test-Path -LiteralPath $checksumsPath -PathType Leaf)) {
        throw "Missing SHA256SUMS.txt"
    }

    foreach ($line in Get-Content -LiteralPath $checksumsPath) {
        if ($line -match "^([a-f0-9]{64})\s+(.+)$" -and $Matches[2].Trim() -eq $RelativePath) {
            return $Matches[1]
        }
    }

    throw "Missing checksum for $RelativePath"
}

$expectedSpriteHash = Get-ExpectedPackageHash -RelativePath "dist/malou/spritesheet.webp"
$expectedPetHash = Get-ExpectedPackageHash -RelativePath "dist/malou/pet.json"

function Get-SelectedAvatarFromConfig {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }

    $text = Get-Content -LiteralPath $Path -Raw
    $desktopMatch = [regex]::Match($text, "(?ms)^\[desktop\]\s*(.*?)(?=^\[|\z)")

    if (-not $desktopMatch.Success) {
        return $null
    }

    $selectedMatch = [regex]::Match($desktopMatch.Value, '(?m)^selected-avatar-id\s*=\s*"([^"]+)"')
    if ($selectedMatch.Success) {
        return $selectedMatch.Groups[1].Value
    }

    return $null
}

function Get-SelectedAvatarFromGlobalState {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }

    $state = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    if (-not ($state.PSObject.Properties.Name -contains "electron-persisted-atom-state")) {
        return $null
    }

    $atom = $state."electron-persisted-atom-state"
    if ($atom.PSObject.Properties.Name -contains "selected-avatar-id") {
        return $atom."selected-avatar-id"
    }

    return $null
}

function Test-FileHash {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$ExpectedHash
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $false
    }

    $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
    return $actualHash -eq $ExpectedHash
}

if ($Repair) {
    & (Join-Path $PSScriptRoot "install.ps1") -CodexHome $CodexHome -Select
}

$petDir = Join-Path $CodexHome "pets\malou"
$petJson = Join-Path $petDir "pet.json"
$spritesheet = Join-Path $petDir "spritesheet.webp"
$configPath = Join-Path $CodexHome "config.toml"
$statePath = Join-Path $CodexHome ".codex-global-state.json"

$checks = @(
    [pscustomobject]@{
        Name = "pet.json"
        Ok = Test-FileHash -Path $petJson -ExpectedHash $expectedPetHash
        Detail = $petJson
    },
    [pscustomobject]@{
        Name = "spritesheet.webp"
        Ok = Test-FileHash -Path $spritesheet -ExpectedHash $expectedSpriteHash
        Detail = $spritesheet
    },
    [pscustomobject]@{
        Name = "config.toml selected-avatar-id"
        Ok = (Get-SelectedAvatarFromConfig -Path $configPath) -eq $expectedAvatarId
        Detail = $configPath
    },
    [pscustomobject]@{
        Name = ".codex-global-state.json selected-avatar-id"
        Ok = (Get-SelectedAvatarFromGlobalState -Path $statePath) -eq $expectedAvatarId
        Detail = $statePath
    }
)

$failed = $checks | Where-Object { -not $_.Ok }

foreach ($check in $checks) {
    $status = if ($check.Ok) { "OK" } else { "FAIL" }
    Write-Host "$status $($check.Name) - $($check.Detail)"
}

if ($failed) {
    Write-Host ""
    Write-Host "Malou is not fully ready for Codex mobile sync."
    Write-Host "Repair with: .\scripts\check-mobile-sync.ps1 -Repair"
    exit 1
}

Write-Host ""
Write-Host "Malou is installed and selected for Codex Desktop and mobile sync."
