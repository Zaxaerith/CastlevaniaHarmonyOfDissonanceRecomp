# One-click native build for CastlevaniaHarmonyOfDissonanceRecomp
param(
    [string]$BuildType = "Release",
    [string]$GbarecompRoot = "",
    [string]$Generator = "MinGW Makefiles"
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
if (-not $GbarecompRoot) {
    $GbarecompRoot = Join-Path (Split-Path -Parent $root) "gbarecomp-main"
}
if (-not (Test-Path (Join-Path $GbarecompRoot "CMakeLists.txt"))) {
    throw "GBARecomp not found at $GbarecompRoot. Clone https://github.com/mstan/gbarecomp (with submodules) as a sibling folder."
}

Write-Host "=== Castlevania: Harmony of Dissonance (GBARecomp) Builder ===" -ForegroundColor Cyan
Write-Host "GBARECOMP_ROOT = $GbarecompRoot"

# Prefer MinGW g++ when present
$gxx = (Get-Command g++.exe -ErrorAction SilentlyContinue).Source
$gcc = (Get-Command gcc.exe -ErrorAction SilentlyContinue).Source
$make = (Get-Command mingw32-make.exe -ErrorAction SilentlyContinue).Source

$cmakeArgs = @(
    "-S", $root,
    "-B", (Join-Path $root "build"),
    "-DCMAKE_BUILD_TYPE=$BuildType",
    "-DGBARECOMP_ROOT=$GbarecompRoot"
)
if (Test-Path $gxx) {
    $cmakeArgs += @("-G", $Generator)
    $cmakeArgs += @("-DCMAKE_C_COMPILER=$gcc", "-DCMAKE_CXX_COMPILER=$gxx")
    if (Test-Path $make) { $cmakeArgs += @("-DCMAKE_MAKE_PROGRAM=$make") }
}

& cmake @cmakeArgs
if ($LASTEXITCODE -ne 0) { throw "CMake configure failed" }

& cmake --build (Join-Path $root "build") --target hod --config $BuildType --parallel
if ($LASTEXITCODE -ne 0) { throw "Build failed" }

Write-Host "Build successful: build\hod.exe" -ForegroundColor Green

