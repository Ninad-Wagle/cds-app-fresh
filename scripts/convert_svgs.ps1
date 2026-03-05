# Convert all SVGs in assets/ to PNG using ImageMagick or Inkscape.
# Requires either: ImageMagick (`magick`) or Inkscape (`inkscape`) installed and on PATH.

$assets = Join-Path $PSScriptRoot "..\assets"
Get-ChildItem -Path $assets -Filter *.svg | ForEach-Object {
    $svg = $_.FullName
    $png = Join-Path $_.DirectoryName ($_ .BaseName + '.png')

    if (Get-Command magick -ErrorAction SilentlyContinue) {
        Write-Host "Converting $svg -> $png using ImageMagick (magick)"
        magick convert $svg $png
    } elseif (Get-Command inkscape -ErrorAction SilentlyContinue) {
        Write-Host "Converting $svg -> $png using Inkscape"
        inkscape $svg --export-type=png --export-filename=$png
    } else {
        Write-Host "Neither 'magick' nor 'inkscape' found on PATH. Install one to convert SVG->PNG."
    }
}
