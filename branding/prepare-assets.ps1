# SPDX-FileCopyrightText: 2026 MSHost contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
param()
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$sourceRoot = Split-Path -Parent $PSScriptRoot
$resourceRoot = Join-Path $sourceRoot 'app\src\generic\res'
$logo = [Drawing.Bitmap]::new((Join-Path $PSScriptRoot 'icon2-clear.png'))
$white = [Drawing.Bitmap]::new($logo.Width, $logo.Height, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
for ($x = 0; $x -lt $logo.Width; $x++) {
    for ($y = 0; $y -lt $logo.Height; $y++) {
        $white.SetPixel($x, $y, [Drawing.Color]::FromArgb($logo.GetPixel($x, $y).A, 255, 255, 255))
    }
}
function Save-Icon([Drawing.Image]$Image, [int]$Size, [double]$Fraction, [string]$RelativePath, [bool]$Background) {
    $destination = Join-Path $resourceRoot $RelativePath
    New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($destination)) -Force | Out-Null
    $canvas = [Drawing.Bitmap]::new($Size, $Size, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $graphics = [Drawing.Graphics]::FromImage($canvas)
    try {
        $graphics.Clear([Drawing.Color]::Transparent)
        if ($Background) { $graphics.Clear([Drawing.ColorTranslator]::FromHtml('#101827')) }
        $graphics.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $ratio = $Size * $Fraction / [math]::Max($Image.Width, $Image.Height)
        $width = [int][math]::Round($Image.Width * $ratio)
        $height = [int][math]::Round($Image.Height * $ratio)
        $rectangle = [Drawing.Rectangle]::new([int](($Size-$width)/2), [int](($Size-$height)/2), $width, $height)
        $graphics.DrawImage($Image, $rectangle)
        $canvas.Save($destination, [Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $canvas.Dispose() }
}
try {
    $nodpi = Join-Path $resourceRoot 'drawable-nodpi'
    New-Item -ItemType Directory -Path $nodpi -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'icon2-clear.png') -Destination (Join-Path $nodpi 'mshost_logo.png')
    Save-Icon $logo 432 0.58 'drawable-nodpi\mshost_launcher_foreground.png' $false
    Save-Icon $white 432 0.58 'drawable-nodpi\mshost_launcher_monochrome.png' $false
    Save-Icon $white 96 0.86 'drawable-nodpi\mshost_notification_icon.png' $false
    $densities = @(@('mdpi',1),@('hdpi',1.5),@('xhdpi',2),@('xxhdpi',3),@('xxxhdpi',4))
    foreach ($density in $densities) {
        $name = $density[0]; $scale = $density[1]
        Save-Icon $logo ([int](48*$scale)) 0.78 ('mipmap-'+$name+'\ic_launcher.png') $true
    }
} finally { $white.Dispose(); $logo.Dispose() }
Write-Output 'MSHost launcher, themed launcher, splash and monochrome notification artwork prepared.'
