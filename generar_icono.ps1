$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::White)

# Fondo degradado rosa -> lavanda (diagonal)
$rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
$c1 = [System.Drawing.Color]::FromArgb(255, 232, 122, 157)  # rosa principal
$c2 = [System.Drawing.Color]::FromArgb(255, 230, 213, 242)  # lavanda
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $c1, $c2,
    [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal)
$g.FillRectangle($brush, $rect)

# Círculo de vidrio central (corona estilizada)
$brush.Dispose()

# Dibujar una corona sencilla y elegante en blanco
$white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 60)
$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

# Corona: 3 picos
$cx = $size / 2
$baseY = $size * 0.72
$topY = $size * 0.30
$midY = $size * 0.48

$points = @(
    [System.Drawing.PointF]::new([float]($cx - $size*0.30), [float]$baseY),
    [System.Drawing.PointF]::new([float]($cx - $size*0.30), [float]$midY),
    [System.Drawing.PointF]::new([float]($cx - $size*0.15), [float]$topY),
    [System.Drawing.PointF]::new([float]$cx, [float]$midY),
    [System.Drawing.PointF]::new([float]($cx + $size*0.15), [float]$topY),
    [System.Drawing.PointF]::new([float]($cx + $size*0.30), [float]$midY),
    [System.Drawing.PointF]::new([float]($cx + $size*0.30), [float]$baseY)
)
$g.DrawLines($pen, $points)

# Base de la corona
$g.DrawLine($pen, [System.Drawing.PointF]::new([float]($cx - $size*0.30), [float]$baseY),
                   [System.Drawing.PointF]::new([float]($cx + $size*0.30), [float]$baseY))

$g.Dispose()
$out = Join-Path (Split-Path -Parent $PSScriptRoot) "Assets.xcassets\AppIcon.appiconset\AppIcon.png"
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "Icono generado: $out"
