Add-Type -AssemblyName System.Drawing

$size = 1024
$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Background gradient: primaryContainer -> primary (terracota palette)
$rect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
$colorTop    = [System.Drawing.ColorTranslator]::FromHtml('#91412b')
$colorBottom = [System.Drawing.ColorTranslator]::FromHtml('#5a1f0e')
$brushBg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $colorTop, $colorBottom, 90)
$g.FillRectangle($brushBg, $rect)

# Plate: cream circle centered
$plateColor = [System.Drawing.ColorTranslator]::FromHtml('#fff0ed')
$plateBrush = New-Object System.Drawing.SolidBrush($plateColor)
$plateInset = 140
$g.FillEllipse($plateBrush, $plateInset, $plateInset, $size - 2*$plateInset, $size - 2*$plateInset)

# Plate inner ring (subtle)
$ringPen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#dbc1ba'), 8)
$ringInset = 220
$g.DrawEllipse($ringPen, $ringInset, $ringInset, $size - 2*$ringInset, $size - 2*$ringInset)

# Letter "P" in primary terracota, bold serif for recipe/elegance feel
$letterColor = [System.Drawing.ColorTranslator]::FromHtml('#732b16')
$letterBrush = New-Object System.Drawing.SolidBrush($letterColor)
$font = New-Object System.Drawing.Font('Georgia', 520, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
$textRect = New-Object System.Drawing.RectangleF(0, 30, $size, $size)
$g.DrawString('P', $font, $letterBrush, $textRect, $sf)

# Accent: golden dot (secondary container) like food highlight
$dotColor = [System.Drawing.ColorTranslator]::FromHtml('#fdb733')
$dotBrush = New-Object System.Drawing.SolidBrush($dotColor)
$g.FillEllipse($dotBrush, 660, 280, 90, 90)

$out = Join-Path $PSScriptRoot 'app_icon.png'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)

# Foreground (Android adaptive): same letter without background, transparent
$bmpFg = New-Object System.Drawing.Bitmap($size, $size)
$gFg = [System.Drawing.Graphics]::FromImage($bmpFg)
$gFg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gFg.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
# Adaptive icon safe zone: keep content within central 66% (~336-688)
$plateBrushFg = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#fff0ed'))
$gFg.FillEllipse($plateBrushFg, 280, 280, 464, 464)
$ringPenFg = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#dbc1ba'), 6)
$gFg.DrawEllipse($ringPenFg, 320, 320, 384, 384)
$fontFg = New-Object System.Drawing.Font('Georgia', 320, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$textRectFg = New-Object System.Drawing.RectangleF(0, 20, $size, $size)
$gFg.DrawString('P', $fontFg, $letterBrush, $textRectFg, $sf)
$dotBrushFg = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#fdb733'))
$gFg.FillEllipse($dotBrushFg, 640, 360, 60, 60)
$outFg = Join-Path $PSScriptRoot 'app_icon_foreground.png'
$bmpFg.Save($outFg, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose(); $bmp.Dispose(); $gFg.Dispose(); $bmpFg.Dispose()
Write-Output "Generated: $out"
Write-Output "Generated: $outFg"
