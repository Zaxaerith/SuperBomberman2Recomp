# Super Bomberman 2 Recomp — Release Notes

## Version v0.1.0-preview-rc1 (Windows x64)

### Overview
We are excited to present the first Preview Release Candidate (**v0.1.0-preview-rc1**) of **Super Bomberman 2 Recomp**, a native 64-bit Windows port of the classic SNES title *Super Bomberman 2 (USA)* statically recompiled into native C / x64 machine code using the [SNESRecomp](https://github.com/RetroPortingToolKit/snesrecomp) framework.

This release integrates the modern [recomp-ui](https://github.com/RetroPortingToolKit/recomp-ui) launcher, providing an intuitive graphical interface for ROM management, display, audio, and controller settings, alongside complete 4-player Multitap support and modern convenience features such as visual savestate browsing and live gameplay rewind.

---

### Highlights & Key Features

1. **Native HiROM 64-bit Recompilation**:
   - Statically transpiled 65816 CPU code executing as native Windows x64 binary without interpretive emulation overhead.
   - Cycle-accurate SPC700 sound processing and beam-aligned PPU rendering delivering authentic SNES audio and visuals at the native field rate (~60.0988 Hz).
   - Accurately addresses the 1 MiB HiROM cartridge architecture.

2. **Full Story Mode Campaign**:
   - Play through all 5 themed worlds, destroying soft blocks, collecting classic power-ups (bombs, fire, roller skates, kick, glove), battling unique mechanical enemies, defeating world bosses, and advancing through stage exit gates.
   - Preserves the original 4-character password system (e.g. World 2: `1111`, World 5: `5555`).

3. **4-Player Battle Mode via Console Port 2 Multitap**:
   - Full 4-player simultaneous arena action supported through SNES Multitap mapping (Seat 0~3 routed to Players 1~4).
   - Independent player movement, bomb placement, blast propagation, chain reactions, player eliminations, victory tallies, and clean round-to-round resets.
   - Supports any combination of keyboards and DirectInput/XInput controllers with independent button binding and hotplugging.

4. **Modern Graphical Launcher (recomp-ui)**:
   - Built-in Dear ImGui launcher interface with automatic ROM validation (SHA-256 and CRC32 checks).
   - Automatic ROM path caching in `rom.cfg` and option to "Skip launcher on boot".
   - Video scaling (1x to 10x, standard 4:3 aspect ratio, windowed and fullscreen modes, VSync).
   - WASAPI / SDL audio output configuration with adjustable volume and sampling frequency.
   - Comprehensive controller and keyboard binding panels supporting up to 4 local players simultaneously.

5. **Visual Save States & Live Rewind**:
   - **F7**: Visual save state menu with thumbnail preview and 10 state slots (`F1`~`F10` quick load, `Shift+F1`~`Shift+F10` quick save).
   - **F8**: Smooth gameplay rewind backed by a high-resolution circular frame buffer.
   - Cold-boot state resumption directly restoring guest CPU, APU, and PPU state.

---

### Package Contents
The preview archive (`SuperBomberman2Recomp-windows-x64-v0.1.0-preview-rc1.zip`) includes:
- `SuperBomberman2SNESRecomp.exe`: Native Windows x64 executable (Release build, test harnesses disabled).
- `SDL2.dll`, `libgcc_s_seh-1.dll`, `libstdc++-6.dll`, `libwinpthread-1.dll`: Required runtime dependencies.
- `assets/fonts/` & `assets/img/`: recomp-ui interface assets and typography.
- `config.ini` & `keybinds.ini`: Production default configuration files configured for 4-player action.
- `mods/preloaded/packages/`: Mod directory structure.
- `README.md`, `LICENSE`, `THIRD_PARTY_LICENSES.md`: Documentation and licensing.

*Note: No commercial ROM files or copyrighted game assets are included.*

---

### Verification & Testing Status
- **Automated Verification**: PASS (ROM verification, GUI launcher, Story 1-1, password resumption, Battle 4P arena, savestate cold boot, rewind).
- **Physical 4-Gamepad Session**: PENDING user hands-on verification.

---

### Disclaimer
*Super Bomberman 2 Recomp is an unofficial, community-developed reverse engineering project. It is not affiliated with, endorsed by, or authorized by Hudson Soft, Konami Digital Entertainment, or Nintendo Co., Ltd.*
