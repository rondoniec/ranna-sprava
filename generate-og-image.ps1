Add-Type -AssemblyName System.Drawing

$w = 1200; $h = 630
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

$g.Clear([System.Drawing.Color]::FromArgb(26, 18, 8))

$goldBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 150, 42))
$g.FillRectangle($goldBrush, 0, 0, $w, 8)
$g.FillRectangle($goldBrush, 0, ($h - 8), $w, 8)

$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$dimBrush   = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 160, 120))
$goldDimBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 150, 42))

$titleFont = New-Object System.Drawing.Font("Georgia", 88, [System.Drawing.FontStyle]::Bold)
$tagFont   = New-Object System.Drawing.Font("Georgia", 26, [System.Drawing.FontStyle]::Italic)
$urlFont   = New-Object System.Drawing.Font("Georgia", 20, [System.Drawing.FontStyle]::Regular)

$titleStr = "RANNA SPRAVA"
$titleSize = $g.MeasureString($titleStr, $titleFont)
$g.DrawString($titleStr, $titleFont, $whiteBrush, [float](($w - $titleSize.Width) / 2), [float]150)

$tagStr = "Slovensky denny newsletter"
$tagSize = $g.MeasureString($tagStr, $tagFont)
$g.DrawString($tagStr, $tagFont, $dimBrush, [float](($w - $tagSize.Width) / 2), [float]310)

$urlStr = "rannasprava.sk"
$urlSize = $g.MeasureString($urlStr, $urlFont)
$g.DrawString($urlStr, $urlFont, $goldDimBrush, [float](($w - $urlSize.Width) / 2), [float]420)

$g.Dispose()

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$outPath = Join-Path $root "og-image.png"
$bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

Write-Host "Created: $outPath"
