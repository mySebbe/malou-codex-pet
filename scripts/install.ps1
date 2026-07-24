[CmdletBinding()]
param(
    [string]$CodexHome = $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }),
    [switch]$Select
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$source = Join-Path $repoRoot "dist\malou"
$target = Join-Path $CodexHome "pets\malou"

$manifest = Join-Path $source "pet.json"
$spritesheet = Join-Path $source "spritesheet.webp"
$avatarId = "custom:malou"

if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
    throw "Missing package file: $manifest"
}

if (-not (Test-Path -LiteralPath $spritesheet -PathType Leaf)) {
    throw "Missing package file: $spritesheet"
}

New-Item -ItemType Directory -Force -Path $target | Out-Null
Copy-Item -LiteralPath $manifest -Destination $target -Force
Copy-Item -LiteralPath $spritesheet -Destination $target -Force

function Set-CodexConfigSelection {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath,
        [Parameter(Mandatory = $true)]
        [string]$SelectedAvatarId
    )

    $selectedLine = "selected-avatar-id = `"$SelectedAvatarId`""

    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ConfigPath) | Out-Null
        [System.IO.File]::WriteAllText($ConfigPath, "[desktop]`n$selectedLine`n", [System.Text.UTF8Encoding]::new($false))
        return
    }

    $text = Get-Content -LiteralPath $ConfigPath -Raw
    $desktopMatch = [regex]::Match($text, "(?ms)^\[desktop\]\s*(.*?)(?=^\[|\z)")

    if ($desktopMatch.Success) {
        $desktopBlock = $desktopMatch.Value
        if ($desktopBlock -match "(?m)^selected-avatar-id\s*=") {
            $updatedBlock = $desktopBlock -replace "(?m)^selected-avatar-id\s*=.*$", $selectedLine
        } else {
            $updatedBlock = $desktopBlock.TrimEnd() + "`n$selectedLine`n"
        }
        $text = $text.Remove($desktopMatch.Index, $desktopBlock.Length).Insert($desktopMatch.Index, $updatedBlock)
    } else {
        $separator = if ($text.EndsWith("`n")) { "" } else { "`n" }
        $text = $text + $separator + "`n[desktop]`n$selectedLine`n"
    }

    [System.IO.File]::WriteAllText($ConfigPath, $text, [System.Text.UTF8Encoding]::new($false))
}

function Set-CodexGlobalStateSelection {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StatePath,
        [Parameter(Mandatory = $true)]
        [string]$SelectedAvatarId
    )

    if (-not (Test-Path -LiteralPath $StatePath -PathType Leaf)) {
        return
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = "$StatePath.malou-install-backup-$timestamp"
    Copy-Item -LiteralPath $StatePath -Destination $backupPath -Force

    $state = Get-Content -LiteralPath $StatePath -Raw | ConvertFrom-Json
    if (-not ($state.PSObject.Properties.Name -contains "electron-persisted-atom-state")) {
        $state | Add-Member -NotePropertyName "electron-persisted-atom-state" -NotePropertyValue ([pscustomobject]@{})
    }

    $atom = $state."electron-persisted-atom-state"
    if ($atom.PSObject.Properties.Name -contains "selected-avatar-id") {
        $atom."selected-avatar-id" = $SelectedAvatarId
    } else {
        $atom | Add-Member -NotePropertyName "selected-avatar-id" -NotePropertyValue $SelectedAvatarId
    }

    $json = $state | ConvertTo-Json -Depth 100 -Compress
    [System.IO.File]::WriteAllText($StatePath, $json + "`n", [System.Text.UTF8Encoding]::new($false))
    Write-Host "Backed up Codex global state to $backupPath"
}

Write-Host "Installed Malou to $target"

if ($Select) {
    Set-CodexConfigSelection -ConfigPath (Join-Path $CodexHome "config.toml") -SelectedAvatarId $avatarId
    Set-CodexGlobalStateSelection -StatePath (Join-Path $CodexHome ".codex-global-state.json") -SelectedAvatarId $avatarId
    Write-Host "Selected Malou as $avatarId for Codex Desktop and mobile sync."
} else {
    Write-Host "To select Malou for Codex Desktop and mobile sync, run: .\scripts\install.ps1 -Select"
}

Write-Host "Restart Codex Desktop, then open Codex in the ChatGPT iOS or Android app."
Write-Host "ChatGPT Web uses a separate custom-pet upload; upload dist\malou\spritesheet.webp under Settings > Personalization > Pet."
