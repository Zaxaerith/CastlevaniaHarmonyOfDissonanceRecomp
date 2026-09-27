# Regenerate src/game/ cart code from your legally obtained ROM.
# Usage: .\scripts\recompile.ps1 -Rom "path\to\game.gba"
param(
    [Parameter(Mandatory = $true)][string]$Rom,
    [string]$GbarecompRoot = "",
    [string]$Config = "",
    [int]$Shards = 4
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
if (-not $GbarecompRoot) {
    $GbarecompRoot = Join-Path (Split-Path -Parent $root) "gbarecomp-main"
}
if (-not $Config) { $Config = Join-Path $root "game.toml" }
if (-not (Test-Path $Rom)) { throw "ROM not found: $Rom" }
if (-not (Test-Path $Config)) { throw "Config not found: $Config" }

$tool = Join-Path $GbarecompRoot "build-mingw\gba_recompile.exe"
if (-not (Test-Path $tool)) {
    $tool = Join-Path $GbarecompRoot "build\Release\gba_recompile.exe"
}
if (-not (Test-Path $tool)) {
    throw "gba_recompile.exe not found under $GbarecompRoot. Build the GBARecomp tool first."
}

$out = Join-Path $root "build\generated_tmp"
New-Item -ItemType Directory -Force -Path $out | Out-Null

Write-Host "=== Regenerating cart C++ from ROM ===" -ForegroundColor Cyan
& $tool --rom $Rom --config $Config --out $out --codegen-shards $Shards
if ($LASTEXITCODE -ne 0) { throw "gba_recompile failed" }

# Install into src/game/ with functional names
Copy-Item (Join-Path $out "recompiled.h") (Join-Path $root "src\game\recompiled_cart.h") -Force
Copy-Item (Join-Path $out "dispatch_table.cpp") (Join-Path $root "src\game\cart_dispatch_table.cpp") -Force
Copy-Item (Join-Path $out "symbol_map.cpp") (Join-Path $root "src\game\cart_symbol_map.cpp") -Force

$map = @{
    "recompiled_000.cpp" = "cart_recompiled_core.cpp"
    "recompiled_001.cpp" = "cart_recompiled_engine.cpp"
    "recompiled_002.cpp" = "cart_recompiled_system.cpp"
    "recompiled_003.cpp" = "cart_recompiled_support.cpp"
}
foreach ($k in $map.Keys) {
    $src = Join-Path $out $k
    if (Test-Path $src) {
        $dst = Join-Path $root ("src\game\" + $map[$k])
        Copy-Item $src $dst -Force
        $t = [System.IO.File]::ReadAllText($dst)
        $t = $t.Replace('#include "recompiled.h"', '#include "recompiled_cart.h"')
        [System.IO.File]::WriteAllText($dst, $t)
    }
}
Write-Host "src/game/ updated. Rebuild with .\scripts\build.ps1" -ForegroundColor Green
