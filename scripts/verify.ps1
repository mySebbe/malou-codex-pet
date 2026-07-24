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

$webSpritesheetPath = Join-Path $repoRoot "dist\chatgpt-web\malou\spritesheet.png"
$webSpritesheet = Get-Item -LiteralPath $webSpritesheetPath
if ($webSpritesheet.Length -le 0) {
    throw "ChatGPT Web spritesheet.png is empty"
}

if ($webSpritesheet.Length -gt 20MB) {
    throw "ChatGPT Web spritesheet.png exceeds the 20 MiB upload limit"
}

function Assert-PngDimensions {
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [Parameter(Mandatory)]
        [int]$ExpectedWidth,
        [Parameter(Mandatory)]
        [int]$ExpectedHeight
    )

    $stream = [System.IO.File]::OpenRead($Path)
    try {
        $header = New-Object byte[] 24
        if ($stream.Read($header, 0, $header.Length) -ne $header.Length) {
            throw "PNG is too short: $Path"
        }
    }
    finally {
        $stream.Dispose()
    }

    $signature = @(137, 80, 78, 71, 13, 10, 26, 10)
    for ($index = 0; $index -lt $signature.Count; $index++) {
        if ($header[$index] -ne $signature[$index]) {
            throw "Invalid PNG signature: $Path"
        }
    }

    $width = ([int]$header[16] * 16777216) + ([int]$header[17] * 65536) + ([int]$header[18] * 256) + [int]$header[19]
    $height = ([int]$header[20] * 16777216) + ([int]$header[21] * 65536) + ([int]$header[22] * 256) + [int]$header[23]
    if ($width -ne $ExpectedWidth -or $height -ne $ExpectedHeight) {
        throw "Unexpected PNG dimensions for ${Path}: ${width} x ${height}"
    }
}

Assert-PngDimensions -Path $webSpritesheetPath -ExpectedWidth 1536 -ExpectedHeight 2288
Assert-PngDimensions -Path (Join-Path $repoRoot "assets\malou-look-directions-share.png") -ExpectedWidth 1200 -ExpectedHeight 1200

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

if ($atlasMetadata.chatgptWeb.spritesheet -ne "dist/chatgpt-web/malou/spritesheet.png") {
    throw "metadata must point ChatGPT Web to the verified PNG"
}

if (-not $atlasMetadata.chatgptWeb.uploadVerified -or -not $atlasMetadata.chatgptWeb.shareUrlVerified) {
    throw "metadata must record the verified ChatGPT Web upload and share link"
}

Write-Host "Malou pet package verified."
