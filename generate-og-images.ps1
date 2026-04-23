Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$imagesPath = Join-Path $root 'images'

function New-LinearBrush {
    param(
        [int]$Width,
        [int]$Height,
        [string]$StartColor,
        [string]$EndColor,
        [System.Drawing.Drawing2D.LinearGradientMode]$Mode = [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
    )

    $rect = New-Object System.Drawing.Rectangle 0, 0, $Width, $Height
    return New-Object System.Drawing.Drawing2D.LinearGradientBrush $rect, ([System.Drawing.ColorTranslator]::FromHtml($StartColor)), ([System.Drawing.ColorTranslator]::FromHtml($EndColor)), $Mode
}

function Draw-WrappedText {
    param(
        [System.Drawing.Graphics]$Graphics,
        [string]$Text,
        [System.Drawing.Font]$Font,
        [System.Drawing.Brush]$Brush,
        [float]$X,
        [float]$Y,
        [float]$MaxWidth,
        [float]$LineHeight
    )

    $words = $Text -split '\s+'
    $line = ''
    $currentY = $Y

    foreach ($word in $words) {
        $testLine = if ([string]::IsNullOrWhiteSpace($line)) { $word } else { "$line $word" }
        $size = $Graphics.MeasureString($testLine, $Font)
        if ($size.Width -gt $MaxWidth -and -not [string]::IsNullOrWhiteSpace($line)) {
            $Graphics.DrawString($line, $Font, $Brush, $X, $currentY)
            $line = $word
            $currentY += $LineHeight
        }
        else {
            $line = $testLine
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($line)) {
        $Graphics.DrawString($line, $Font, $Brush, $X, $currentY)
    }
}

function New-OgImage {
    param(
        [string]$OutputFile,
        [string]$BackgroundImage,
        [string]$Kicker,
        [string]$Title,
        [string]$Subtitle,
        [string]$Accent
    )

    $width = 1200
    $height = 630
    $bitmap = New-Object System.Drawing.Bitmap $width, $height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    if (Test-Path $BackgroundImage) {
        $bg = [System.Drawing.Image]::FromFile($BackgroundImage)
        $graphics.DrawImage($bg, 0, 0, $width, $height)
        $bg.Dispose()
    }
    else {
        $fallback = New-LinearBrush -Width $width -Height $height -StartColor '#3D2817' -EndColor '#8B2C2C'
        $graphics.FillRectangle($fallback, 0, 0, $width, $height)
        $fallback.Dispose()
    }

    $overlayTop = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(160, 25, 18, 12))
    $overlayBottom = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(130, 61, 40, 23))
    $graphics.FillRectangle($overlayTop, 0, 0, $width, [int]($height * 0.7))
    $graphics.FillRectangle($overlayBottom, 0, [int]($height * 0.45), $width, [int]($height * 0.55))

    $panelRect = New-Object System.Drawing.RectangleF 70, 55, 700, 500
    $panelBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(168, 250, 247, 242))
    $graphics.FillRectangle($panelBrush, $panelRect)

    $accentBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($Accent))
    $graphics.FillRectangle($accentBrush, 70, 55, 16, 500)

    $kickerFont = New-Object System.Drawing.Font 'Arial', 16, ([System.Drawing.FontStyle]::Bold)
    $titleFont = New-Object System.Drawing.Font 'Georgia', 34, ([System.Drawing.FontStyle]::Regular)
    $subtitleFont = New-Object System.Drawing.Font 'Arial', 17, ([System.Drawing.FontStyle]::Regular)
    $brandFont = New-Object System.Drawing.Font 'Arial', 18, ([System.Drawing.FontStyle]::Bold)

    $darkBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#3D2817'))
    $textBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#2C2C2C'))
    $lightBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#FAF7F2'))

    $graphics.DrawString($Kicker.ToUpperInvariant(), $kickerFont, $accentBrush, 110, 95)
    Draw-WrappedText -Graphics $graphics -Text $Title -Font $titleFont -Brush $darkBrush -X 110 -Y 145 -MaxWidth 610 -LineHeight 48
    Draw-WrappedText -Graphics $graphics -Text $Subtitle -Font $subtitleFont -Brush $textBrush -X 110 -Y 310 -MaxWidth 600 -LineHeight 30
    $graphics.DrawString('MAMA SA  |  KAMPOT, CAMBODIA', $brandFont, $lightBrush, 760, 560)

    $outlinePen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 255, 255, 255), 2)
    $graphics.DrawRectangle($outlinePen, 820, 52, 320, 526)

    $bitmap.Save($OutputFile, [System.Drawing.Imaging.ImageFormat]::Png)

    $outlinePen.Dispose()
    $lightBrush.Dispose()
    $darkBrush.Dispose()
    $textBrush.Dispose()
    $accentBrush.Dispose()
    $panelBrush.Dispose()
    $overlayTop.Dispose()
    $overlayBottom.Dispose()
    $kickerFont.Dispose()
    $titleFont.Dispose()
    $subtitleFont.Dispose()
    $brandFont.Dispose()
    $graphics.Dispose()
    $bitmap.Dispose()
}

New-OgImage -OutputFile (Join-Path $imagesPath 'og-home.png') -BackgroundImage (Join-Path $imagesPath 'og-home.jpg') -Kicker 'Cambodian Retreat' -Title 'Mama Sa Hotel & Restaurant' -Subtitle 'A peaceful Kampot escape with cozy rooms, rooftop dining, and warm Cambodian hospitality.' -Accent '#C4A962'
New-OgImage -OutputFile (Join-Path $imagesPath 'og-booking.png') -BackgroundImage (Join-Path $imagesPath 'image1.jpg') -Kicker 'Book Direct' -Title 'Reserve Your Stay At Mama Sa' -Subtitle 'Simple room booking in Kampot with direct confirmation, flexible stays, and a rooftop restaurant on site.' -Accent '#C4A962'
New-OgImage -OutputFile (Join-Path $imagesPath 'og-restaurant.png') -BackgroundImage (Join-Path $imagesPath 'og-restaurant.jpg') -Kicker 'Rooftop Restaurant' -Title 'Authentic Khmer Dining With A View' -Subtitle 'Panoramic Kampot dining, local dishes, and a rooftop setting made for sunset meals and relaxed evenings.' -Accent '#C4A962'
New-OgImage -OutputFile (Join-Path $imagesPath 'og-offers.png') -BackgroundImage (Join-Path $imagesPath 'background.jpg') -Kicker 'Exclusive Offers' -Title 'Tourist.com Deals At Mama Sa' -Subtitle '20% off for premium members, 10% off for free users, and a romantic dinner plus 1-night stay for 2 at $29.' -Accent '#C4A962'