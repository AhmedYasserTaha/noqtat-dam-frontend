Add-Type -AssemblyName System.Drawing
$iconFolder = Join-Path $PSScriptRoot '../assets/branding'
New-Item -ItemType Directory -Force -Path $iconFolder | Out-Null
function Write-AppIcon([bool]$transparent, [string]$name) {
  $bitmap = New-Object System.Drawing.Bitmap 1024,1024
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $red = [System.Drawing.ColorTranslator]::FromHtml('#C8201A')
  $graphics.Clear($(if ($transparent) { [System.Drawing.Color]::Transparent } else { $red }))
  $drop = New-Object System.Drawing.Drawing2D.GraphicsPath
  $drop.AddBezier(512,190, 450,274, 300,454, 300,590)
  $drop.AddBezier(300,590, 300,870, 724,870, 724,590)
  $drop.AddBezier(724,590, 724,454, 574,274, 512,190)
  $drop.CloseFigure()
  $graphics.FillPath([System.Drawing.Brushes]::White,$drop)
  $heart = New-Object System.Drawing.Drawing2D.GraphicsPath
  $heart.AddBezier(512,568, 426,462, 346,604, 512,698)
  $heart.AddBezier(512,698, 678,604, 598,462, 512,568)
  $heart.CloseFigure()
  $brush = New-Object System.Drawing.SolidBrush $red
  $graphics.FillPath($brush,$heart)
  $bitmap.Save((Join-Path $iconFolder $name),[System.Drawing.Imaging.ImageFormat]::Png)
  $brush.Dispose(); $drop.Dispose(); $heart.Dispose(); $graphics.Dispose(); $bitmap.Dispose()
}
Write-AppIcon $false 'app_icon.png'
Write-AppIcon $true 'app_icon_foreground.png'
