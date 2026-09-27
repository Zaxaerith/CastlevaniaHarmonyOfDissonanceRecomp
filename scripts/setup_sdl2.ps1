# Fetch SDL2 MinGW development package into third_party/
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$tp = Join-Path $root "third_party"
$zip = Join-Path $tp "SDL2-devel-2.30.11-mingw.tar.gz"
$url = "https://www.libsdl.org/release/SDL2-devel-2.30.11-mingw.tar.gz"

New-Item -ItemType Directory -Force -Path $tp | Out-Null
if (-not (Test-Path (Join-Path $tp "SDL2-2.30.11"))) {
    Write-Host "Downloading SDL2..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $zip
    tar -xzf $zip -C $tp
    Remove-Item $zip -Force
}
Write-Host "SDL2 ready: $tp\SDL2-2.30.11" -ForegroundColor Green
