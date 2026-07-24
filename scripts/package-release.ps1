[CmdletBinding()]
param(
    [ValidatePattern("^\d+\.\d+\.\d+$")]
    [string]$Version = "2.0.0",
    [string]$OutputDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $repoRoot "release\v$Version"
}

$metadataPath = Join-Path $repoRoot "metadata\atlas.json"
$metadata = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json
if ([string]$metadata.pet.version -ne $Version) {
    throw "Requested version $Version does not match metadata version $($metadata.pet.version)."
}

& (Join-Path $PSScriptRoot "verify.ps1")

$outputRoot = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

$versionLabel = "v$Version"
$desktopArchive = Join-Path $outputRoot "malou-codex-pet-$versionLabel.zip"
$webAtlas = Join-Path $outputRoot "malou-chatgpt-web-$versionLabel.png"
$lookCard = Join-Path $outputRoot "malou-look-directions-$versionLabel.png"
$releaseChecksums = Join-Path $outputRoot "malou-$versionLabel-SHA256SUMS.txt"

$stageRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("malou-release-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $stageRoot | Out-Null

try {
    $desktopFolder = Join-Path $stageRoot "malou"
    New-Item -ItemType Directory -Path $desktopFolder | Out-Null
    Copy-Item -LiteralPath (Join-Path $repoRoot "dist\malou\pet.json") -Destination $desktopFolder
    Copy-Item -LiteralPath (Join-Path $repoRoot "dist\malou\spritesheet.webp") -Destination $desktopFolder
    Copy-Item -LiteralPath (Join-Path $repoRoot "LICENSE.md") -Destination $stageRoot
    Copy-Item -LiteralPath (Join-Path $repoRoot "ATTRIBUTION.md") -Destination $stageRoot

    $installText = @'
Malou Codex Pet __VERSION_LABEL__

Desktop:
Copy the included "malou" folder to:
- Windows: %USERPROFILE%\.codex\pets\malou
- macOS/Linux: ${CODEX_HOME:-$HOME/.codex}/pets/malou

Then refresh or restart the ChatGPT/Codex desktop app and select Malou.

ChatGPT Web:
Use the separate malou-chatgpt-web-__VERSION_LABEL__.png release asset under
Settings > Personalization > Pet > Select pet > Upload pet.

Adopt Malou:
__SHARE_URL__
'@
    $installText = $installText.Replace("__VERSION_LABEL__", $versionLabel)
    $installText = $installText.Replace("__SHARE_URL__", [string]$metadata.chatgptWeb.shareUrl)
    [System.IO.File]::WriteAllText(
        (Join-Path $stageRoot "INSTALL.txt"),
        $installText + "`n",
        [System.Text.UTF8Encoding]::new($false)
    )

    if (Test-Path -LiteralPath $desktopArchive) {
        Remove-Item -LiteralPath $desktopArchive -Force
    }

    Add-Type -AssemblyName System.IO.Compression
    $releaseTimestamp = [DateTimeOffset]::ParseExact(
        [string]$metadata.release.date,
        "yyyy-MM-dd",
        [System.Globalization.CultureInfo]::InvariantCulture
    )
    $archiveEntries = @(
        @{ Source = (Join-Path $stageRoot "ATTRIBUTION.md"); Name = "ATTRIBUTION.md" }
        @{ Source = (Join-Path $stageRoot "INSTALL.txt"); Name = "INSTALL.txt" }
        @{ Source = (Join-Path $stageRoot "LICENSE.md"); Name = "LICENSE.md" }
        @{ Source = (Join-Path $desktopFolder "pet.json"); Name = "malou/pet.json" }
        @{ Source = (Join-Path $desktopFolder "spritesheet.webp"); Name = "malou/spritesheet.webp" }
    )

    $archiveStream = [System.IO.File]::Open(
        $desktopArchive,
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::Write,
        [System.IO.FileShare]::None
    )
    try {
        $archive = [System.IO.Compression.ZipArchive]::new(
            $archiveStream,
            [System.IO.Compression.ZipArchiveMode]::Create,
            $false
        )
        try {
            foreach ($archiveEntry in $archiveEntries) {
                $entry = $archive.CreateEntry(
                    $archiveEntry.Name,
                    [System.IO.Compression.CompressionLevel]::Optimal
                )
                $entry.LastWriteTime = $releaseTimestamp
                $sourceStream = [System.IO.File]::OpenRead($archiveEntry.Source)
                $entryStream = $entry.Open()
                try {
                    $sourceStream.CopyTo($entryStream)
                } finally {
                    $entryStream.Dispose()
                    $sourceStream.Dispose()
                }
            }
        } finally {
            $archive.Dispose()
        }
    } finally {
        $archiveStream.Dispose()
    }
} finally {
    $resolvedTempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    $resolvedStageRoot = [System.IO.Path]::GetFullPath($stageRoot)
    if (-not $resolvedStageRoot.StartsWith($resolvedTempRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove unexpected staging path: $resolvedStageRoot"
    }
    if (Test-Path -LiteralPath $resolvedStageRoot) {
        Remove-Item -LiteralPath $resolvedStageRoot -Recurse -Force
    }
}

Copy-Item -LiteralPath (Join-Path $repoRoot "dist\chatgpt-web\malou\spritesheet.png") -Destination $webAtlas -Force
Copy-Item -LiteralPath (Join-Path $repoRoot "assets\malou-look-directions-share.png") -Destination $lookCard -Force

$releaseAssets = @($desktopArchive, $webAtlas, $lookCard)
$checksumLines = foreach ($asset in $releaseAssets) {
    $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $asset).Hash.ToLowerInvariant()
    "$hash  $([System.IO.Path]::GetFileName($asset))"
}
[System.IO.File]::WriteAllText(
    $releaseChecksums,
    ($checksumLines -join "`n") + "`n",
    [System.Text.Encoding]::ASCII
)

foreach ($asset in @($releaseAssets + $releaseChecksums)) {
    Write-Host "release_asset=$asset"
}
