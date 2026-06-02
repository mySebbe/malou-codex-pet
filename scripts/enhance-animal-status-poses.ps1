[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$framesRoot = Join-Path $repoRoot "source\frames"

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

function New-PixelGraphics {
    param([Parameter(Mandatory = $true)][System.Drawing.Bitmap]$Bitmap)

    $graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    return $graphics
}

function Fill-Ellipse {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [Parameter(Mandatory = $true)][System.Drawing.Color]$Color,
        [int]$X,
        [int]$Y,
        [int]$W,
        [int]$H
    )

    $brush = New-Object System.Drawing.SolidBrush $Color
    try {
        $Graphics.FillEllipse($brush, $X, $Y, $W, $H)
    } finally {
        $brush.Dispose()
    }
}

function Fill-Polygon {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [Parameter(Mandatory = $true)][System.Drawing.Color]$Color,
        [Parameter(Mandatory = $true)][System.Drawing.Point[]]$Points
    )

    $brush = New-Object System.Drawing.SolidBrush $Color
    try {
        $Graphics.FillPolygon($brush, $Points)
    } finally {
        $brush.Dispose()
    }
}

function Draw-Line {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [Parameter(Mandatory = $true)][System.Drawing.Color]$Color,
        [int]$Width,
        [int]$X1,
        [int]$Y1,
        [int]$X2,
        [int]$Y2
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

function Draw-RaisedAskingPaw {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [int]$FrameIndex
    )

    $outline = New-Color 31 18 13
    $cream = New-Color 255 236 191
    $shadow = New-Color 190 129 58
    $x = 44 + ($FrameIndex % 2)
    $y = 105 - [int]([Math]::Sin(($FrameIndex / 6.0) * [Math]::PI * 2) * 2)

    Fill-Ellipse -Graphics $Graphics -Color $outline -X ($x - 4) -Y ($y - 4) -W 28 -H 38
    Fill-Ellipse -Graphics $Graphics -Color $cream -X $x -Y $y -W 21 -H 31
    Fill-Ellipse -Graphics $Graphics -Color $shadow -X ($x + 12) -Y ($y + 15) -W 5 -H 10
    Fill-Ellipse -Graphics $Graphics -Color $outline -X ($x + 1) -Y ($y + 3) -W 5 -H 5
    Fill-Ellipse -Graphics $Graphics -Color $outline -X ($x + 8) -Y ($y + 1) -W 5 -H 5
    Fill-Ellipse -Graphics $Graphics -Color $outline -X ($x + 15) -Y ($y + 4) -W 4 -H 5
}

function Draw-WorkingPaws {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [int]$FrameIndex
    )

    $outline = New-Color 31 18 13
    $cream = New-Color 255 236 191
    $leftY = 137 + (($FrameIndex % 2) * 8)
    $rightY = 145 - (($FrameIndex % 2) * 8)

    Fill-Ellipse -Graphics $Graphics -Color $outline -X 61 -Y ($leftY - 3) -W 31 -H 24
    Fill-Ellipse -Graphics $Graphics -Color $cream -X 65 -Y $leftY -W 24 -H 17
    Fill-Ellipse -Graphics $Graphics -Color $outline -X 103 -Y ($rightY - 3) -W 31 -H 24
    Fill-Ellipse -Graphics $Graphics -Color $cream -X 107 -Y $rightY -W 24 -H 17

    $brow = New-Color 36 19 12
    Draw-Line -Graphics $Graphics -Color $brow -Width 4 -X1 61 -Y1 64 -X2 77 -Y2 61
    Draw-Line -Graphics $Graphics -Color $brow -Width 4 -X1 105 -Y1 61 -X2 121 -Y2 64
}

function Draw-ReviewFocusPose {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [int]$FrameIndex
    )

    $outline = New-Color 31 18 13
    $cream = New-Color 255 236 191
    $brow = New-Color 32 18 13
    $chinX = 72 + (($FrameIndex % 3) - 1)
    $chinY = 112 - [int]([Math]::Sin(($FrameIndex / 6.0) * [Math]::PI * 2) * 2)

    Fill-Ellipse -Graphics $Graphics -Color $outline -X ($chinX - 6) -Y ($chinY - 4) -W 32 -H 24
    Fill-Ellipse -Graphics $Graphics -Color $cream -X ($chinX - 2) -Y $chinY -W 24 -H 16
    Draw-Line -Graphics $Graphics -Color $brow -Width 4 -X1 61 -Y1 58 -X2 78 -Y2 62
    Draw-Line -Graphics $Graphics -Color $brow -Width 4 -X1 102 -Y1 62 -X2 119 -Y2 58
}

function Draw-FailedBodyTear {
    param(
        [Parameter(Mandatory = $true)][System.Drawing.Graphics]$Graphics,
        [int]$FrameIndex
    )

    $tear = New-Color 70 195 255
    $tearDark = New-Color 28 93 159
    $highlight = New-Color 255 255 255
    $mouth = New-Color 35 18 12
    $x = 68 + ($FrameIndex % 2)
    $y = 83 + [int]([Math]::Sin(($FrameIndex / 8.0) * [Math]::PI * 2) * 2)

    $outlinePoints = [System.Drawing.Point[]]@(
        [System.Drawing.Point]::new($x, $y - 11),
        [System.Drawing.Point]::new($x + 8, $y + 1),
        [System.Drawing.Point]::new($x + 2, $y + 13),
        [System.Drawing.Point]::new($x - 7, $y + 3)
    )
    $innerPoints = [System.Drawing.Point[]]@(
        [System.Drawing.Point]::new($x, $y - 8),
        [System.Drawing.Point]::new($x + 5, $y + 1),
        [System.Drawing.Point]::new($x + 1, $y + 9),
        [System.Drawing.Point]::new($x - 4, $y + 3)
    )

    Fill-Polygon -Graphics $Graphics -Color $tearDark -Points $outlinePoints
    Fill-Polygon -Graphics $Graphics -Color $tear -Points $innerPoints
    Fill-Ellipse -Graphics $Graphics -Color $highlight -X ($x - 1) -Y ($y - 2) -W 3 -H 4
    Draw-Line -Graphics $Graphics -Color $mouth -Width 3 -X1 77 -Y1 101 -X2 91 -Y2 104
}

function Enhance-State {
    param(
        [Parameter(Mandatory = $true)][string]$State,
        [Parameter(Mandatory = $true)][scriptblock]$Enhancer
    )

    $stateDir = Join-Path $framesRoot $State
    $frames = Get-ChildItem -LiteralPath $stateDir -Filter "*.png" | Sort-Object Name

    for ($index = 0; $index -lt $frames.Count; $index++) {
        $bitmap = New-BitmapFromFile -Path $frames[$index].FullName
        try {
            $graphics = New-PixelGraphics -Bitmap $bitmap
            try {
                & $Enhancer $graphics $index
            } finally {
                $graphics.Dispose()
            }
            Save-Png -Bitmap $bitmap -Path $frames[$index].FullName
        } finally {
            $bitmap.Dispose()
        }
    }
}

Enhance-State -State "waiting" -Enhancer { param($graphics, $index) Draw-RaisedAskingPaw -Graphics $graphics -FrameIndex $index }
Enhance-State -State "running" -Enhancer { param($graphics, $index) Draw-WorkingPaws -Graphics $graphics -FrameIndex $index }
Enhance-State -State "review" -Enhancer { param($graphics, $index) Draw-ReviewFocusPose -Graphics $graphics -FrameIndex $index }
Enhance-State -State "failed" -Enhancer { param($graphics, $index) Draw-FailedBodyTear -Graphics $graphics -FrameIndex $index }

Write-Host "Enhanced Malou animal poses for status readability."
