# Gera os ícones do TaskFlow (web e instalador) a partir do mesmo desenho do
# logo do app: um "check" branco num quadrado arredondado na cor primária.
# Uso: powershell -ExecutionPolicy Bypass -File tool/generate_icons.ps1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$primary = [System.Drawing.Color]::FromArgb(255, 0x3D, 0x33, 0xD6)

function New-IconBitmap([int]$size, [bool]$maskable) {
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.Clear([System.Drawing.Color]::Transparent)
    $brush = New-Object System.Drawing.SolidBrush $primary
    if ($maskable) {
        # Ícone "maskable": fundo inteiro, o sistema recorta o formato.
        $g.FillRectangle($brush, 0, 0, $size, $size)
        $scale = 0.62
    } else {
        $radius = [single]($size * 0.22)
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $d = $radius * 2
        $path.AddArc(0, 0, $d, $d, 180, 90)
        $path.AddArc($size - $d, 0, $d, $d, 270, 90)
        $path.AddArc($size - $d, $size - $d, $d, $d, 0, 90)
        $path.AddArc(0, $size - $d, $d, $d, 90, 90)
        $path.CloseFigure()
        $g.FillPath($brush, $path)
        $scale = 0.78
    }
    $inner = $size * $scale
    $offset = ($size - $inner) / 2
    $stroke = [Math]::Max(1.5, $inner * 0.11)
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), ([single]$stroke)
    $pen.StartCap = 'Round'
    $pen.EndCap = 'Round'
    $pen.LineJoin = 'Round'
    $ring = $inner * 0.82
    $ringOffset = $offset + ($inner - $ring) / 2
    # Anel aberto no canto superior direito, como o ícone task_alt.
    $g.DrawArc($pen, [single]$ringOffset, [single]$ringOffset, [single]$ring, [single]$ring, -10, 290)
    $points = @(
        (New-Object System.Drawing.PointF ([single]($offset + $inner * 0.28)), ([single]($offset + $inner * 0.50))),
        (New-Object System.Drawing.PointF ([single]($offset + $inner * 0.46)), ([single]($offset + $inner * 0.66))),
        (New-Object System.Drawing.PointF ([single]($offset + $inner * 0.84)), ([single]($offset + $inner * 0.15)))
    )
    $g.DrawLines($pen, $points)
    $g.Dispose()
    return $bmp
}

function Save-Png([int]$size, [bool]$maskable, [string]$file) {
    $bmp = New-IconBitmap $size $maskable
    $bmp.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

function Get-PngBytes([int]$size) {
    $bmp = New-IconBitmap $size $false
    $stream = New-Object System.IO.MemoryStream
    $bmp.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    return $stream.ToArray()
}

# Entrada DIB (BMP 32 bits) de um .ico, compatível com qualquer versão do
# Windows e com o compilador do Inno Setup.
function Get-DibBytes([int]$size) {
    $bmp = New-IconBitmap $size $false
    $stream = New-Object System.IO.MemoryStream
    $w = New-Object System.IO.BinaryWriter $stream
    $w.Write([int]40); $w.Write([int]$size); $w.Write([int]($size * 2))
    $w.Write([int16]1); $w.Write([int16]32); $w.Write([int]0)
    $w.Write([int]0); $w.Write([int]0); $w.Write([int]0); $w.Write([int]0); $w.Write([int]0)
    for ($y = $size - 1; $y -ge 0; $y--) {
        for ($x = 0; $x -lt $size; $x++) {
            $c = $bmp.GetPixel($x, $y)
            $w.Write([byte]$c.B); $w.Write([byte]$c.G); $w.Write([byte]$c.R); $w.Write([byte]$c.A)
        }
    }
    # Máscara AND (toda zero: a transparência vem do canal alfa).
    $maskRow = [int]([Math]::Ceiling($size / 32.0) * 4)
    $w.Write((New-Object byte[] ($maskRow * $size)))
    $w.Flush()
    $bmp.Dispose()
    return $stream.ToArray()
}

function Save-Ico([string]$file) {
    $entries = @(
        @{ Size = 16; Data = (Get-DibBytes 16) },
        @{ Size = 32; Data = (Get-DibBytes 32) },
        @{ Size = 48; Data = (Get-DibBytes 48) },
        @{ Size = 256; Data = (Get-PngBytes 256) }
    )
    $stream = [System.IO.File]::Create($file)
    $w = New-Object System.IO.BinaryWriter $stream
    $w.Write([int16]0); $w.Write([int16]1); $w.Write([int16]$entries.Count)
    $offset = 6 + 16 * $entries.Count
    foreach ($e in $entries) {
        $dim = if ($e.Size -ge 256) { 0 } else { $e.Size }
        $w.Write([byte]$dim); $w.Write([byte]$dim); $w.Write([byte]0); $w.Write([byte]0)
        $w.Write([int16]1); $w.Write([int16]32)
        $w.Write([int]$e.Data.Length); $w.Write([int]$offset)
        $offset += $e.Data.Length
    }
    foreach ($e in $entries) { $w.Write([byte[]]$e.Data) }
    $w.Close()
}

Save-Png 32 $false (Join-Path $root 'web/favicon.png')
Save-Png 192 $false (Join-Path $root 'web/icons/Icon-192.png')
Save-Png 512 $false (Join-Path $root 'web/icons/Icon-512.png')
Save-Png 192 $true (Join-Path $root 'web/icons/Icon-maskable-192.png')
Save-Png 512 $true (Join-Path $root 'web/icons/Icon-maskable-512.png')
New-Item -ItemType Directory -Force (Join-Path $root 'installer') | Out-Null
Save-Ico (Join-Path $root 'installer/taskflow.ico')
Write-Host 'Ícones gerados.'
