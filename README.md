# Super Bomberman 2 Recomp

A native Windows x64 recompilation of **Super Bomberman 2** (USA), built on [SNESRecomp](https://github.com/RetroPortingToolKit/snesrecomp) and [recomp-ui](https://github.com/RetroPortingToolKit/recomp-ui).

> [!IMPORTANT]
> **Legal Notice & Disclaimer**: This project is an unofficial, noncommercial static recompilation intended for personal study, preservation, and experimentation. It is **not** endorsed by, affiliated with, or licensed by Hudson Soft, Konami, or Nintendo. No commercial ROM data, copyrighted assets, or ROM-derived C source code are included in this repository or in any release package. You must provide your own legally obtained ROM dump.

---

## Features

- **Ahead-of-Time (AOT) Recompilation**: 65816 machine code statically recompiled into native C / x64 machine code, running natively on Windows without standard CPU emulation overhead.
- **Story Mode (Normal Game)**: Complete single-player campaign featuring 5 distinct worlds, stage mechanics, destructible soft blocks, enemy behaviors, exit gates, boss battles, and full password resumption.
- **4-Player Battle Mode**: Classic 4-player competitive battle arena utilizing native SNES Multitap architecture on Console Port 2, featuring independent player inputs, item pickups, bomb kicking/throwing, blast propagation, player eliminations, victory tally, and round cycling.
- **recomp-ui Launcher**: Modern graphical launcher powered by Dear ImGui with ROM verification, display scaling (1x~10x, 4:3 aspect ratio, fullscreen), audio configuration, keyboard/gamepad mapping, and live settings.
- **Savestates & Rewind**:
  - **F7**: Visual save state browser and multi-slot management (`F1`~`F10` quick load, `Shift+F1`~`Shift+F10` quick save).
  - **F8**: Live circular buffer rewind (gamepad gesture: `Select + R3`).
  - Cold-boot state loading support.
- **Authentic Audio & Timing**: Cycle-accurate SNES APU / SPC700 emulation via beam-aligned driver at authentic SNES NTSC field rate (~60.0988 Hz) with WASAPI / SDL audio output.

---

## ROM Identity

The recompilation requires the original, unaltered North American release of Super Bomberman 2:

| Property | Value |
|---|---|
| **ROM File** | `Super Bomberman 2 (USA).sfc` |
| **Region** | USA (NTSC) |
| **ROM Size** | 1,048,576 bytes (1 MiB / 8 Mbit, 16 Banks) |
| **Cartridge Layout** | HiROM ($00-$1F / $80-$9F: $8000-$FFFF) |
| **Coprocessor** | None (pure 65816 + SPC700) |
| **Battery SRAM** | None (Original game utilizes a 4-character password system) |
| **CRC32** | `9C1F11E4` |
| **SHA-256** | `0A4B4A783A7FAF6ADA3E1326ECF85DE77E8C2A171659B42A78A1FAE43F806CA6` |

> [!NOTE]
> **Cartridge Architecture Note**: Both *Super Bomberman 1* and *Super Bomberman 2* are HiROM cartridges (SB1 is 512 KiB HiROM; SB2 is 1 MiB HiROM). Neither uses LoROM mapping.

---

## 4-Player Multitap Configuration

Super Bomberman 2 natively supports up to 4 simultaneous players via the SNES Multitap connected to **Controller Port 2**:

| Multitap Seat | Target Player | Default Source | Supported Devices |
|---|---|---|---|
| **Seat 0** | **Player 1 (White Bomberman)** | Keyboard / Gamepad 1 | Keyboard or XInput/DirectInput Gamepad |
| **Seat 1** | **Player 2 (Black Bomberman)** | Gamepad 2 / Keyboard | Gamepad (or secondary keyboard keys) |
| **Seat 2** | **Player 3 (Red Bomberman)** | Gamepad 3 / Keyboard | Gamepad (or keypad controls) |
| **Seat 3** | **Player 4 (Blue Bomberman)** | Gamepad 4 / Keyboard | Gamepad (or alternate keys) |
| **Seat 4** | *Disconnected* | None | Reserved for future expansion |

Each player slot is independently configured in `config.ini` (`SourceP1`..`SourceP4`) and `keybinds.ini`. The GUI launcher allows assigning different controllers or keyboards to each seat without input crosstalk.

---

## Controls & Keybinds

### Default Keyboard Mapping

| Action | Player 1 | Player 2 | Player 3 | Player 4 |
|---|---|---|---|---|
| **D-Pad Up** | `Up Arrow` | `W` | `Keypad 8` | `I` |
| **D-Pad Down** | `Down Arrow` | `S` | `Keypad 5` | `K` |
| **D-Pad Left** | `Left Arrow` | `A` | `Keypad 4` | `J` |
| **D-Pad Right** | `Right Arrow` | `D` | `Keypad 6` | `L` |
| **B (Drop Bomb)** | `Z` | `J` | `Keypad 1` | `B` |
| **A (Detonate / Kick / Throw)**| `X` | `K` | `Keypad 2` | `N` |
| **Y (Special)** | `A` | `U` | `Keypad 4` | `G` |
| **X (Special)** | `S` | `I` | `Keypad 5` | `H` |
| **Start** | `Return` | `1` | `Keypad Enter` | `9` |
| **Select** | `Right Shift` | `2` | `Keypad +` | `0` |

### System Hotkeys

- **F7**: Open Save State Visual Menu
- **F8**: Rewind Gameplay
- **F1 ~ F10**: Quick Load Slot 1 ~ 10
- **Shift + F1 ~ Shift + F10**: Quick Save Slot 1 ~ 10
- **Alt + Enter**: Toggle Fullscreen
- **Ctrl + R**: Soft Reset
- **Shift + P**: Pause Gameplay
- **P**: Dimmed Pause
- **Keypad + / -**: Adjust Volume
- **F**: Toggle Performance / FPS Overlay

---

## Original Password System

The original cartridge uses a 4-character password system rather than battery-backed SRAM. The password menu can be accessed directly from the main menu:

- **World 2 Resumption**: `1111`
- **World 3 Resumption**: `2222`
- **World 4 Resumption**: `3333`
- **World 5 Resumption**: `5555`

---

## Building from Source

### Prerequisites

- 64-bit Windows (10 or 11)
- GCC with C11 and C++17 support (e.g. MinGW-w64 x86_64)
- CMake 3.20 or newer
- Ninja build system
- Python 3.10 or newer

### Build Instructions

```powershell
# 1. Clone repository and initialize submodules
git submodule update --init --recursive

# 2. Place your valid Super Bomberman 2 (USA).sfc in the project root

# 3. Generate AOT C sources from ROM
bash tools/regen.sh --rom "Super Bomberman 2 (USA).sfc"

# 4. Configure with CMake
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release

# 5. Compile binary (using 2 parallel jobs)
ninja -C build -j2
```

The resulting executable will be located at `build/SuperBomberman2SNESRecomp.exe`.

---

## Known Limitations & Verification Status

- **Automated Verification (PASS)**: ROM hash verification, cold boot, Story 1-1 initialization, password recovery to Worlds 2 & 5, Battle mode 4P spawn and elimination lifecycle, savestates, rewind ring buffer, and launcher GUI.
- **Physical 4-Gamepad Session (PENDING User Acceptance)**: The Multitap architecture and GUI configuration for 4 controllers are verified and active; physical multi-gamepad verification with 4 physical USB/Bluetooth controllers is left for user hands-on testing.
