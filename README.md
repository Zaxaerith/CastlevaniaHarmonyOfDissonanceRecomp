# CastlevaniaHarmonyOfDissonanceRecomp

[![Platform](https://img.shields.io/badge/platform-Windows-blue)](#prerequisites)
[![Language](https://img.shields.io/badge/language-C%2B%2B20-orange)](#what-static-recompilation-means-here)
[![License](https://img.shields.io/badge/license-PolyForm--Noncommercial--1.0.0-blue)](LICENSE)

Native C++ static recompilation of **Castlevania: Harmony of Dissonance (GBA, USA)** into a standalone Windows executable using the [GBARecomp](https://github.com/mstan/gbarecomp) framework.

---

## What "static recompilation" means here

The ARM7TDMI (ARM/Thumb) machine code from the original cartridge is statically translated to native C++ — every discovered guest function is compiled as real C++ translation units in `src/game/`.

**The rest of the GBA is modelled hardware** (not recompiled):
* **PPU** backgrounds, sprites (OAM), blending, and windowing
* **APU** PSG + Direct Sound FIFO
* **DMA / Timers / IRQ / Flash save** chip protocol
* **GBA BIOS** is recompiled from a user-supplied dump and dispatched through the same table as cart code

Architecture: **recompile the CPU, emulate the silicon**.

---

## Current Status

- [x] **Boots to title** — Konami logo → Castlevania title screen
- [x] **New Game / castle intro** — story, menus, and equipment UI
- [x] **Flash save support** — 512 Kbit flash chip (`CASTLEVANIA1.00` signature)
- [x] **FULLY STATIC coverage** on the boot → title → new-game path (zero dispatch misses)
- [x] **No console window** — built as a Windows GUI application
- [x] **No automatic input / demo playback** — the player has full control

---

## Quick Start (you provide the ROM)

> [!IMPORTANT]
> **Legal Notice**: This repository does **NOT** contain any copyrighted ROM data, BIOS images, game assets, or proprietary Konami/Nintendo code. You must provide your own legally obtained ROM dump and GBA BIOS dump to run the game.

### Verified ROM

| Field | Value |
| :--- | :--- |
| **Game** | Castlevania: Harmony of Dissonance (USA) |
| **Game code** | `ACHE` |
| **File name** | `Castlevania - Harmony of Dissonance(US)(Konami)(64Mb).gba` |
| **Size** | `8,388,608` bytes |
| **CRC32** | `88C1B562` |
| **SHA1** | `b90da0d9be0b3a0893cd9e2c399056bcf9579e21` |

### BIOS

A GBA BIOS dump (`gba_bios.bin`, 16,384 bytes) is required at runtime. SHA1 of the common dump: `300c20df6731a33952ded8c436f7f186d25d3492`.

---

## Prerequisites

* Windows 10/11
* CMake 3.20+
* MinGW-w64 (g++ 13+) or MSVC
* [GBARecomp framework](https://github.com/mstan/gbarecomp) checked out **with submodules** as a sibling folder:

```text
GameRecomp/
  gbarecomp-main/          # git clone --recurse-submodules https://github.com/mstan/gbarecomp.git
  CastlevaniaHarmonyOfDissonanceRecomp/
```

* SDL2 MinGW development package under `third_party/SDL2-2.30.11/` (see `scripts/setup_sdl2.ps1`)

---

## Building from source

### One-click (PowerShell)

```powershell
.\scripts\build.ps1
```

This configures CMake, builds `hod.exe`, and copies `SDL2.dll` next to it.

### Manual

```powershell
cmake -S . -B build -G "MinGW Makefiles" `
  -DCMAKE_BUILD_TYPE=Release `
  -DGBARECOMP_ROOT=..\gbarecomp-main
cmake --build build --target hod --parallel
```

Output: `build\hod.exe`

---

## Regenerating cart code (optional)

The translated C++ in `src/game/` is generated from your ROM. To regenerate after changing `game.toml`:

```powershell
.\scripts\recompile.ps1 -Rom "path\to\your.gba"
```

This runs `gba_recompile` from the GBARecomp tree and refreshes `src/game/`.

---

## Running

```powershell
.\build\hod.exe --rom "path\to\Castlevania - Harmony of Dissonance(US)(Konami)(64Mb).gba" --bios "path\to\gba_bios.bin"
```

Optional: `--config game.toml` (save type, BIOS path defaults).  
Optional: `--save "path\to\file.sav"`.

---

## Controls

| Action | Keyboard | GBA |
| :--- | :--- | :--- |
| Move | Arrow keys / WASD | D-pad |
| Attack (whip) | `X` or `A` (gamepad) | A |
| Jump | `Z` or `B` (gamepad) | B |
| Sub-weapon | `S` | R |
| Confirm / advance | `X` / `Enter` | A / Start |
| Pause / menu | `Enter` | Start |
| Select | `Right Shift` | Select |
| Fullscreen | `F11` / `Alt+Enter` | — |
| Quit | `Esc` | — |

---

## Project layout

```text
src/
  main.cpp                 # Windows GUI host (no console, no demo input)
  game/
    recompiled_cart.h      # generated: cart function declarations
    cart_recompiled_*.cpp  # generated: ARM/Thumb → C++ translation
    cart_dispatch_table.cpp
    cart_symbol_map.cpp
game.toml                  # ROM identity, Flash save, coverage seeds
scripts/
  build.ps1                # one-click native build
  recompile.ps1            # regenerate src/game from your ROM
  setup_sdl2.ps1           # fetch SDL2 MinGW devel package
CMakeLists.txt
LICENSE                    # PolyForm Noncommercial 1.0.0
```

---

## Legal

* PolyForm Noncommercial License 1.0.0 — see [LICENSE](LICENSE).
* This project is not affiliated with Konami or Nintendo.
* Do **not** commit ROMs, BIOS dumps, or save files. They are listed in `.gitignore`.
