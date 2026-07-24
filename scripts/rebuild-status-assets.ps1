[CmdletBinding()]
param(
    [string]$Version = "2.0.0",
    [string]$TestedDate = "2026-07-25",
    [switch]$SkipStatusOverlay,
    [switch]$ForceStatusOverlay
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$framesRoot = Join-Path $repoRoot "source\frames"
$rowStripRoot = Join-Path $repoRoot "source\row-strips"
$distRoot = Join-Path $repoRoot "dist\malou"
$assetsRoot = Join-Path $repoRoot "assets"
$previewsRoot = Join-Path $assetsRoot "previews"
$metadataPath = Join-Path $repoRoot "metadata\atlas.json"
$manifestPath = Join-Path $framesRoot "frames-manifest.json"
$atlasPngPath = Join-Path $repoRoot "dist\malou\spritesheet.png"
$atlasWebpPath = Join-Path $distRoot "spritesheet.webp"
$contactSheetPath = Join-Path $assetsRoot "contact-sheet.png"
$directionSheetPath = Join-Path $assetsRoot "look-directions.png"
$shaPath = Join-Path $repoRoot "SHA256SUMS.txt"

$cellWidth = 192
$cellHeight = 208
$columns = 8
$rows = 11

function New-Color {
    param([int]$R, [int]$G, [int]$B, [int]$A = 255)
    [System.Drawing.Color]::FromArgb($A, $R, $G, $B)
}

function New-BitmapFromFile {
    param([Parameter(Mandatory = $true)][string]$Path)

    $source = [System.Drawing.Bitmap]::FromFile($Path)
    try {
        $bitmap = New-Object System.Drawing.Bitmap $source.Width, $source.Height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.Clear([System.Drawing.Color]::Transparent)
            $graphics.DrawImageUnscaled($source, 0, 0)
        } finally {
            $graphics.Dispose()
        }
        return $bitmap
    } finally {
        $source.Dispose()
    }
}

function Save-Png {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Bitmap]$Bitmap,
        [Parameter(Mandatory = $true)][string]$Path
    )

    Normalize-TransparentPixels -Bitmap $Bitmap
    $tempPath = "$Path.tmp.png"
    $Bitmap.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Png)
    Move-Item -LiteralPath $tempPath -Destination $Path -Force
}

function Normalize-TransparentPixels {
    param([Parameter(Mandatory = $true)][System.Drawing.Bitmap]$Bitmap)

    $transparent = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)

    for ($y = 0; $y -lt $Bitmap.Height; $y++) {
        for ($x = 0; $x -lt $Bitmap.Width; $x++) {
            $pixel = $Bitmap.GetPixel($x, $y)
            if ($pixel.A -eq 0 -and ($pixel.R -ne 0 -or $pixel.G -ne 0 -or $pixel.B -ne 0)) {
                $Bitmap.SetPixel($x, $y, $transparent)
            }
        }
    }
}

function Normalize-FramePngs {
    $frames = Get-ChildItem -LiteralPath $framesRoot -Recurse -Filter "*.png"

    foreach ($frameFile in $frames) {
        $bitmap = New-BitmapFromFile -Path $frameFile.FullName
        try {
            Save-Png -Bitmap $bitmap -Path $frameFile.FullName
        } finally {
            $bitmap.Dispose()
        }
    }
}

function New-AntiAliasGraphics {
    param([Parameter(Mandatory = $true)][System.Drawing.Bitmap]$Bitmap)

    $graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    return $graphics
}

function Draw-RoundLine {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [Parameter(Mandatory = $true)][System.Drawing.Color]$Color,
        [float]$Width,
        [float]$X1,
        [float]$Y1,
        [float]$X2,
        [float]$Y2
    )

    $pen = New-Object System.Drawing.Pen $Color, $Width
    try {
        $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
        $Graphics.DrawLine($pen, $X1, $Y1, $X2, $Y2)
    } finally {
        $pen.Dispose()
    }
}

function Draw-SpinnerGlyph {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [int]$CenterX,
        [int]$CenterY,
        [int]$FrameIndex
    )

    $brush = New-Object System.Drawing.SolidBrush (New-Color 255 255 255)
    try {
        for ($i = 0; $i -lt 3; $i++) {
            $angle = (($FrameIndex * 35) + ($i * 120)) * [Math]::PI / 180
            $radius = 9
            $dotSize = if ($i -eq 0) { 7 } else { 6 }
            $x = $CenterX + [Math]::Cos($angle) * $radius - ($dotSize / 2)
            $y = $CenterY + [Math]::Sin($angle) * $radius - ($dotSize / 2)
            $Graphics.FillEllipse($brush, [float]$x, [float]$y, [float]$dotSize, [float]$dotSize)
        }
    } finally {
        $brush.Dispose()
    }
}

function Draw-PawGlyph {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [int]$CenterX,
        [int]$CenterY
    )

    $brush = New-Object System.Drawing.SolidBrush (New-Color 255 255 255)
    try {
        $Graphics.FillEllipse($brush, $CenterX - 8, $CenterY, 16, 13)
        $Graphics.FillEllipse($brush, $CenterX - 13, $CenterY - 8, 7, 8)
        $Graphics.FillEllipse($brush, $CenterX - 5, $CenterY - 12, 7, 9)
        $Graphics.FillEllipse($brush, $CenterX + 4, $CenterY - 11, 7, 9)
        $Graphics.FillEllipse($brush, $CenterX + 11, $CenterY - 6, 6, 8)
    } finally {
        $brush.Dispose()
    }
}

function Draw-EyeGlyph {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [int]$CenterX,
        [int]$CenterY
    )

    $white = New-Object System.Drawing.SolidBrush (New-Color 255 255 255)
    $dark = New-Object System.Drawing.SolidBrush (New-Color 23 26 28)
    try {
        $Graphics.FillEllipse($white, $CenterX - 13, $CenterY - 7, 26, 14)
        $Graphics.FillEllipse($dark, $CenterX - 4, $CenterY - 4, 8, 8)
        Draw-RoundLine -Graphics $Graphics -Color (New-Color 255 255 255) -Width 4 -X1 ($CenterX - 15) -Y1 $CenterY -X2 ($CenterX - 8) -Y2 ($CenterY - 7)
        Draw-RoundLine -Graphics $Graphics -Color (New-Color 255 255 255) -Width 4 -X1 ($CenterX + 8) -Y1 ($CenterY - 7) -X2 ($CenterX + 15) -Y2 $CenterY
    } finally {
        $white.Dispose()
        $dark.Dispose()
    }
}

function Draw-TearGlyph {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [int]$CenterX,
        [int]$CenterY
    )

    $tear = New-Object System.Drawing.SolidBrush (New-Color 94 203 255)
    $highlight = New-Object System.Drawing.SolidBrush (New-Color 255 255 255 190)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    try {
        $path.AddBezier($CenterX, $CenterY - 13, $CenterX + 11, $CenterY - 1, $CenterX + 8, $CenterY + 13, $CenterX, $CenterY + 15)
        $path.AddBezier($CenterX, $CenterY + 15, $CenterX - 8, $CenterY + 13, $CenterX - 11, $CenterY - 1, $CenterX, $CenterY - 13)
        $Graphics.FillPath($tear, $path)
        $Graphics.FillEllipse($highlight, $CenterX - 3, $CenterY - 5, 4, 7)
    } finally {
        $path.Dispose()
        $tear.Dispose()
        $highlight.Dispose()
    }
}

function Draw-StatusBadge {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [Parameter(Mandatory = $true)][string]$Kind,
        [int]$FrameIndex
    )

    $diameter = 36
    $centerX = 148
    $centerY = 35 + [int]([Math]::Sin(($FrameIndex / 6.0) * [Math]::PI * 2) * 2)
    $x = $centerX - ($diameter / 2)
    $y = $centerY - ($diameter / 2)

    $fill = Get-StatusBadgeColor -Kind $Kind

    $shadow = New-Object System.Drawing.SolidBrush (New-Color 0 0 0 55)
    $outer = New-Object System.Drawing.SolidBrush (New-Color 255 255 255)
    $inner = New-Object System.Drawing.SolidBrush $fill
    $outline = New-Object System.Drawing.Pen (New-Color 46 49 52), 2
    try {
        $Graphics.FillEllipse($shadow, $x + 3, $y + 4, $diameter + 2, $diameter + 2)
        $Graphics.FillEllipse($outer, $x - 4, $y - 4, $diameter + 8, $diameter + 8)
        $Graphics.FillEllipse($inner, $x, $y, $diameter, $diameter)
        $Graphics.DrawEllipse($outline, $x, $y, $diameter, $diameter)

        switch ($Kind) {
            "working" { Draw-SpinnerGlyph -Graphics $Graphics -CenterX $centerX -CenterY $centerY -FrameIndex $FrameIndex }
            "waiting" { Draw-PawGlyph -Graphics $Graphics -CenterX $centerX -CenterY ($centerY - 2) }
            "review" { Draw-EyeGlyph -Graphics $Graphics -CenterX $centerX -CenterY $centerY }
            "failed" { Draw-TearGlyph -Graphics $Graphics -CenterX $centerX -CenterY ($centerY - 1) }
        }
    } finally {
        $shadow.Dispose()
        $outer.Dispose()
        $inner.Dispose()
        $outline.Dispose()
    }
}

function Get-StatusBadgeColor {
    param([Parameter(Mandatory = $true)][string]$Kind)

    switch ($Kind) {
        "working" { return (New-Color 29 125 255) }
        "waiting" { return (New-Color 245 166 35) }
        "review" { return (New-Color 34 162 119) }
        "failed" { return (New-Color 221 83 83) }
        default { return (New-Color 90 90 90) }
    }
}

function Test-StatusBadgePresent {
    param(
        [Parameter(Mandatory = $true)][string]$FramePath,
        [Parameter(Mandatory = $true)][string]$Kind
    )

    $fill = Get-StatusBadgeColor -Kind $Kind
    $bitmap = New-BitmapFromFile -Path $FramePath
    $matchCount = 0

    try {
        for ($y = 16; $y -le 54; $y++) {
            for ($x = 128; $x -le 168; $x++) {
                $pixel = $bitmap.GetPixel($x, $y)
                if (
                    $pixel.A -gt 220 -and
                    [Math]::Abs($pixel.R - $fill.R) -le 10 -and
                    [Math]::Abs($pixel.G - $fill.G) -le 10 -and
                    [Math]::Abs($pixel.B - $fill.B) -le 10
                ) {
                    $matchCount++
                }
            }
        }
    } finally {
        $bitmap.Dispose()
    }

    return $matchCount -gt 80
}

function Apply-StatusSemantics {
    $states = @{
        "running" = "working"
        "waiting" = "waiting"
        "review" = "review"
        "failed" = "failed"
    }

    foreach ($entry in $states.GetEnumerator()) {
        $state = $entry.Key
        $kind = $entry.Value
        $stateDir = Join-Path $framesRoot $state
        $frames = Get-ChildItem -LiteralPath $stateDir -Filter "*.png" | Sort-Object Name

        if ($frames.Count -gt 0 -and -not $ForceStatusOverlay -and (Test-StatusBadgePresent -FramePath $frames[0].FullName -Kind $kind)) {
            Write-Host "Status badge already present for $state; skipping overlay."
            continue
        }

        for ($index = 0; $index -lt $frames.Count; $index++) {
            $framePath = $frames[$index].FullName
            $bitmap = New-BitmapFromFile -Path $framePath
            try {
                $graphics = New-AntiAliasGraphics -Bitmap $bitmap
                try {
                    Draw-StatusBadge -Graphics $graphics -Kind $kind -FrameIndex $index
                } finally {
                    $graphics.Dispose()
                }
                Save-Png -Bitmap $bitmap -Path $framePath
            } finally {
                $bitmap.Dispose()
            }
        }
    }
}

function Build-RowStripsAndAtlas {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    New-Item -ItemType Directory -Force -Path $rowStripRoot, $distRoot | Out-Null

    $atlas = New-Object System.Drawing.Bitmap ($columns * $cellWidth), ($rows * $cellHeight), ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $atlasGraphics = [System.Drawing.Graphics]::FromImage($atlas)
    try {
        $atlasGraphics.Clear([System.Drawing.Color]::Transparent)

        foreach ($state in $manifest.states) {
            $strip = New-Object System.Drawing.Bitmap ($columns * $cellWidth), $cellHeight, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            $stripGraphics = [System.Drawing.Graphics]::FromImage($strip)
            try {
                $stripGraphics.Clear([System.Drawing.Color]::Transparent)
                for ($index = 0; $index -lt $state.frames.Count; $index++) {
                    $framePath = Join-Path $framesRoot $state.frames[$index]
                    $frame = New-BitmapFromFile -Path $framePath
                    try {
                        $stripGraphics.DrawImageUnscaled($frame, $index * $cellWidth, 0)
                        $atlasGraphics.DrawImageUnscaled($frame, $index * $cellWidth, $state.row * $cellHeight)
                    } finally {
                        $frame.Dispose()
                    }
                }

                Save-Png -Bitmap $strip -Path (Join-Path $rowStripRoot "$($state.state).png")
            } finally {
                $stripGraphics.Dispose()
                $strip.Dispose()
            }
        }

        foreach ($lookRow in @(9, 10)) {
            $directions = @($manifest.lookDirections | Where-Object { $_.row -eq $lookRow } | Sort-Object column)
            if ($directions.Count -ne $columns) {
                throw "Look row $lookRow must contain exactly $columns direction frames."
            }

            $strip = New-Object System.Drawing.Bitmap ($columns * $cellWidth), $cellHeight, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
            $stripGraphics = [System.Drawing.Graphics]::FromImage($strip)
            try {
                $stripGraphics.Clear([System.Drawing.Color]::Transparent)
                foreach ($direction in $directions) {
                    $framePath = Join-Path $framesRoot $direction.frame
                    $frame = New-BitmapFromFile -Path $framePath
                    try {
                        $x = [int]$direction.column * $cellWidth
                        $y = [int]$direction.row * $cellHeight
                        $stripGraphics.DrawImageUnscaled($frame, $x, 0)
                        $atlasGraphics.DrawImageUnscaled($frame, $x, $y)
                    } finally {
                        $frame.Dispose()
                    }
                }

                Save-Png -Bitmap $strip -Path (Join-Path $rowStripRoot "look-row-$lookRow.png")
            } finally {
                $stripGraphics.Dispose()
                $strip.Dispose()
            }
        }

        Save-Png -Bitmap $atlas -Path $atlasPngPath
    } finally {
        $atlasGraphics.Dispose()
        $atlas.Dispose()
    }

    Convert-PngToLosslessWebp -InputPath $atlasPngPath -OutputPath $atlasWebpPath
    Remove-Item -LiteralPath $atlasPngPath -Force
}

function Convert-PngToLosslessWebp {
    param(
        [Parameter(Mandatory = $true)][string]$InputPath,
        [Parameter(Mandatory = $true)][string]$OutputPath
    )

    $sharpRoot = Join-Path $repoRoot "tmp\sharp-runtime"
    $sharpModule = Join-Path $sharpRoot "node_modules\sharp"

    if (-not (Test-Path -LiteralPath $sharpModule -PathType Container)) {
        $npm = Get-Command npm.cmd -ErrorAction Stop
        & $npm.Source install --prefix $sharpRoot sharp@0.34.5 --no-save
    }

    $node = Get-Command node.exe -ErrorAction Stop
    $script = "const sharp=require(process.argv[1]); sharp(process.argv[2]).webp({lossless:true, effort:6}).toFile(process.argv[3]).catch((error)=>{ console.error(error); process.exit(1); });"
    & $node.Source -e $script $sharpModule $InputPath $OutputPath
}

function Draw-Checkerboard {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [int]$Square = 16
    )

    $a = New-Object System.Drawing.SolidBrush (New-Color 242 242 242)
    $b = New-Object System.Drawing.SolidBrush (New-Color 222 222 222)
    try {
        for ($yy = 0; $yy -lt $Height; $yy += $Square) {
            for ($xx = 0; $xx -lt $Width; $xx += $Square) {
                $brush = if ((([int]($xx / $Square) + [int]($yy / $Square)) % 2) -eq 0) { $a } else { $b }
                $Graphics.FillRectangle($brush, $X + $xx, $Y + $yy, $Square, $Square)
            }
        }
    } finally {
        $a.Dispose()
        $b.Dispose()
    }
}

function Build-ContactSheet {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $scale = 0.5
    $thumbWidth = [int]($cellWidth * $scale)
    $thumbHeight = [int]($cellHeight * $scale)
    $headerHeight = 22
    $rowHeight = $headerHeight + $thumbHeight
    $sheetWidth = $columns * $thumbWidth
    $sheetHeight = [int]$manifest.atlas.rows * $rowHeight

    $sheet = New-Object System.Drawing.Bitmap $sheetWidth, $sheetHeight, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [System.Drawing.Graphics]::FromImage($sheet)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half

    $font = New-Object System.Drawing.Font "Arial", 9
    $smallFont = New-Object System.Drawing.Font "Arial", 7
    $headerBrush = New-Object System.Drawing.SolidBrush (New-Color 0 0 0)
    $whiteBrush = New-Object System.Drawing.SolidBrush (New-Color 255 255 255)
    $blackBrush = New-Object System.Drawing.SolidBrush (New-Color 0 0 0)
    $greenPen = New-Object System.Drawing.Pen (New-Color 0 111 64), 2
    $redPen = New-Object System.Drawing.Pen (New-Color 210 45 45), 2

    try {
        $graphics.Clear([System.Drawing.Color]::White)

        foreach ($state in $manifest.states) {
            $rowY = [int]$state.row * $rowHeight
            $graphics.FillRectangle($headerBrush, 0, $rowY, $sheetWidth, $headerHeight)
            $graphics.DrawString(("row {0}: {1}" -f $state.row, $state.state), $font, $whiteBrush, 4, $rowY + 4)
            $graphics.DrawString(("{0} frames" -f $state.frames.Count), $font, $whiteBrush, $sheetWidth - 78, $rowY + 4)

            for ($column = 0; $column -lt $columns; $column++) {
                $x = $column * $thumbWidth
                $y = $rowY + $headerHeight
                Draw-Checkerboard -Graphics $graphics -X $x -Y $y -Width $thumbWidth -Height $thumbHeight -Square 12

                if ($column -lt $state.frames.Count) {
                    $framePath = Join-Path $framesRoot $state.frames[$column]
                    $frame = New-BitmapFromFile -Path $framePath
                    try {
                        $graphics.DrawImage($frame, $x, $y, $thumbWidth, $thumbHeight)
                    } finally {
                        $frame.Dispose()
                    }
                    $graphics.DrawRectangle($greenPen, $x, $y, $thumbWidth - 1, $thumbHeight - 1)
                } else {
                    $graphics.DrawRectangle($redPen, $x, $y, $thumbWidth - 1, $thumbHeight - 1)
                }

                $graphics.DrawString([string]$column, $smallFont, $blackBrush, $x + 3, $y + 3)
            }
        }

        foreach ($lookRow in @(9, 10)) {
            $directions = @($manifest.lookDirections | Where-Object { $_.row -eq $lookRow } | Sort-Object column)
            $rowY = $lookRow * $rowHeight
            $graphics.FillRectangle($headerBrush, 0, $rowY, $sheetWidth, $headerHeight)
            $graphics.DrawString(("row {0}: look directions" -f $lookRow), $font, $whiteBrush, 4, $rowY + 4)
            $graphics.DrawString("8 frames", $font, $whiteBrush, $sheetWidth - 78, $rowY + 4)

            for ($column = 0; $column -lt $columns; $column++) {
                $x = $column * $thumbWidth
                $y = $rowY + $headerHeight
                Draw-Checkerboard -Graphics $graphics -X $x -Y $y -Width $thumbWidth -Height $thumbHeight -Square 12

                $direction = $directions | Where-Object { $_.column -eq $column } | Select-Object -First 1
                if ($null -ne $direction) {
                    $framePath = Join-Path $framesRoot $direction.frame
                    $frame = New-BitmapFromFile -Path $framePath
                    try {
                        $graphics.DrawImage($frame, $x, $y, $thumbWidth, $thumbHeight)
                    } finally {
                        $frame.Dispose()
                    }
                    $graphics.DrawRectangle($greenPen, $x, $y, $thumbWidth - 1, $thumbHeight - 1)
                    $graphics.DrawString(("{0}°" -f $direction.degrees), $smallFont, $blackBrush, $x + 3, $y + 3)
                } else {
                    $graphics.DrawRectangle($redPen, $x, $y, $thumbWidth - 1, $thumbHeight - 1)
                }
            }
        }

        Save-Png -Bitmap $sheet -Path $contactSheetPath
    } finally {
        $font.Dispose()
        $smallFont.Dispose()
        $headerBrush.Dispose()
        $whiteBrush.Dispose()
        $blackBrush.Dispose()
        $greenPen.Dispose()
        $redPen.Dispose()
        $graphics.Dispose()
        $sheet.Dispose()
    }
}

function Build-Previews {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    $ffmpeg = Get-Command ffmpeg.exe -ErrorAction Stop
    New-Item -ItemType Directory -Force -Path $previewsRoot | Out-Null

    foreach ($state in $manifest.states) {
        $tempDir = Join-Path $repoRoot ("build\preview-" + $state.state)
        New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

        try {
            for ($index = 0; $index -lt $state.frames.Count; $index++) {
                $preview = New-Object System.Drawing.Bitmap ($cellWidth * 2), ($cellHeight * 2), ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
                $graphics = [System.Drawing.Graphics]::FromImage($preview)
                $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
                try {
                    Draw-Checkerboard -Graphics $graphics -X 0 -Y 0 -Width ($cellWidth * 2) -Height ($cellHeight * 2) -Square 24
                    $frame = New-BitmapFromFile -Path (Join-Path $framesRoot $state.frames[$index])
                    try {
                        $graphics.DrawImage($frame, 0, 0, $cellWidth * 2, $cellHeight * 2)
                    } finally {
                        $frame.Dispose()
                    }
                    Save-Png -Bitmap $preview -Path (Join-Path $tempDir ("{0:D2}.png" -f $index))
                } finally {
                    $graphics.Dispose()
                    $preview.Dispose()
                }
            }

            $output = Join-Path $previewsRoot "$($state.state).mp4"
            & $ffmpeg.Source -y -hide_banner -loglevel error -framerate 6 -i (Join-Path $tempDir "%02d.png") -vf "format=yuv420p" -movflags +faststart $output
        } finally {
            if ((Test-Path -LiteralPath $tempDir) -and $tempDir.StartsWith((Join-Path $repoRoot "build"))) {
                Remove-Item -LiteralPath $tempDir -Recurse -Force
            }
        }
    }
}

function Get-PngStats {
    param([Parameter(Mandatory = $true)][string]$Path)

    $bitmap = New-BitmapFromFile -Path $Path
    $colors = @{}
    $visiblePixels = 0
    $lowAlphaPixels = 0
    $visiblePurplePixels = 0
    $transparentPurplePixels = 0

    try {
        for ($y = 0; $y -lt $bitmap.Height; $y++) {
            for ($x = 0; $x -lt $bitmap.Width; $x++) {
                $pixel = $bitmap.GetPixel($x, $y)
                $isPurple = $pixel.R -gt 180 -and $pixel.B -gt 180 -and $pixel.G -lt 120
                if ($pixel.A -gt 0) {
                    $visiblePixels++
                    $colors[$pixel.ToArgb()] = $true
                    if ($pixel.A -lt 255) {
                        $lowAlphaPixels++
                    }
                    if ($isPurple) {
                        $visiblePurplePixels++
                    }
                } elseif ($isPurple) {
                    $transparentPurplePixels++
                }
            }
        }

        [pscustomobject]@{
            Width = $bitmap.Width
            Height = $bitmap.Height
            VisiblePixels = $visiblePixels
            VisibleColors = $colors.Count
            LowAlphaPixels = $lowAlphaPixels
            VisiblePurplePixels = $visiblePurplePixels
            TransparentPurplePixels = $transparentPurplePixels
        }
    } finally {
        $bitmap.Dispose()
    }
}

function Update-MetadataAndChecksums {
    $metadata = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json
    $stats = Get-PngStats -Path $contactSheetPath
    $atlasForStats = Join-Path $repoRoot "build\spritesheet-stats.png"
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $atlasForStats) | Out-Null

    try {
        $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
        $atlas = New-Object System.Drawing.Bitmap ($columns * $cellWidth), ($rows * $cellHeight), ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $graphics = [System.Drawing.Graphics]::FromImage($atlas)
        try {
            $graphics.Clear([System.Drawing.Color]::Transparent)
            foreach ($state in $manifest.states) {
                for ($index = 0; $index -lt $state.frames.Count; $index++) {
                    $frame = New-BitmapFromFile -Path (Join-Path $framesRoot $state.frames[$index])
                    try {
                        $graphics.DrawImageUnscaled($frame, $index * $cellWidth, $state.row * $cellHeight)
                    } finally {
                        $frame.Dispose()
                    }
                }
            }

            foreach ($direction in $manifest.lookDirections) {
                $frame = New-BitmapFromFile -Path (Join-Path $framesRoot $direction.frame)
                try {
                    $graphics.DrawImageUnscaled(
                        $frame,
                        [int]$direction.column * $cellWidth,
                        [int]$direction.row * $cellHeight
                    )
                } finally {
                    $frame.Dispose()
                }
            }
            Save-Png -Bitmap $atlas -Path $atlasForStats
        } finally {
            $graphics.Dispose()
            $atlas.Dispose()
        }

        $atlasStats = Get-PngStats -Path $atlasForStats

        $metadata.pet.version = $Version
        $metadata.pet.description = "A clean photo-based brown-and-white dog companion for Codex Desktop, ChatGPT Web, and mobile Codex Pet bubbles, with readable status poses and 16 clockwise look directions."
        $metadata.package.spriteVersionNumber = 2
        $metadata.package.width = $atlasStats.Width
        $metadata.package.height = $atlasStats.Height
        $metadata.package.visiblePixels = $atlasStats.VisiblePixels
        $metadata.package.visibleColors = $atlasStats.VisibleColors
        $metadata.package.lowAlphaPixels = $atlasStats.LowAlphaPixels
        $metadata.package.visiblePurplePixels = $atlasStats.VisiblePurplePixels
        $metadata.package.transparentPurplePixels = $atlasStats.TransparentPurplePixels
        $metadata.validation.date = $TestedDate

        $spriteHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $atlasWebpPath).Hash.ToLowerInvariant()
        $petHash = (Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $distRoot "pet.json")).Hash.ToLowerInvariant()
        $contactHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $contactSheetPath).Hash.ToLowerInvariant()
        $directionHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $directionSheetPath).Hash.ToLowerInvariant()

        $metadata.checksums."dist/malou/spritesheet.webp" = $spriteHash
        $metadata.checksums."dist/malou/pet.json" = $petHash
        $metadata.checksums."assets/contact-sheet.png" = $contactHash
        $metadata.checksums."assets/look-directions.png" = $directionHash

        $metadata | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $metadataPath -Encoding utf8

        @(
            "$spriteHash  dist/malou/spritesheet.webp"
            "$petHash  dist/malou/pet.json"
            "$contactHash  assets/contact-sheet.png"
            "$directionHash  assets/look-directions.png"
        ) | Set-Content -LiteralPath $shaPath -Encoding ascii
    } finally {
        if (Test-Path -LiteralPath $atlasForStats) {
            Remove-Item -LiteralPath $atlasForStats -Force
        }
    }
}

if (-not $SkipStatusOverlay) {
    Apply-StatusSemantics
}
Normalize-FramePngs
Build-RowStripsAndAtlas
Build-ContactSheet
Build-Previews
Update-MetadataAndChecksums

Write-Host "Rebuilt Malou status assets for version $Version."
