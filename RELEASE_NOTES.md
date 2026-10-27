# Super Bomberman 2 Recomp v0.1.0-preview (Windows x64)

**Release Date:** October 27, 2026  
**Build Target:** Windows x64 Native  
**Framework Baseline:** snesrecomp `82b4acbf` + recomp-ui `eaf99cac`  

We are pleased to introduce the first technical preview release of **Super Bomberman 2 Recomp**, a native 64-bit Windows port of the classic Super Nintendo title *Super Bomberman 2 (USA)* statically recompiled into native C and x86_64 machine code.

---

## Highlights

- **Native Windows x64 Ahead-of-Time Recompilation:** Powered by the [SNESRecomp](https://github.com/RetroPortingToolKit/snesrecomp) engine, translating 65816 CPU code into native C / x86_64 instructions with no interpretive CPU emulation overhead.
- **Accurate 1 MiB HiROM Cartridge Support:** Faithful handling of Super Bomberman 2's 1 MiB HiROM mapping ($00-$1F / $80-$9F: $8000-$FFFF), cycle-accurate SPC700 audio DSP emulation, and beam-aligned PPU rasterization delivering authentic SNES visuals and sound at the native NTSC field rate (~60.0988 Hz).
- **Official recomp-ui Graphical Launcher:** Integrated Dear ImGui launcher providing intuitive ROM file picking, real-time SHA-256 / CRC32 integrity verification, window scaling (1x~10x, 4:3 aspect ratio, fullscreen), WASAPI/SDL audio configuration, and live controller assignment.
- **4-Player Battle Mode via Console Port 2 Multitap:** Faithful implementation of the SNES Multitap protocol on Controller Port 2, routing Seat 0~3 to Players 1~4. Supports simultaneous 4-player competitive arena action with independent movement, bomb placement, blast propagation, player eliminations, victory tallies, and round cycling.
- **Story Mode (Normal Game):** Single-player campaign featuring 5 themed worlds, destructible soft blocks, classic power-ups (bombs, fire, roller skates, kick, glove), mechanical enemy AI, stage exit gates, and boss encounters.
- **Authentic 4-Character Password System:** Accurately retains the original retail cartridge's 4-character password system without synthetic SRAM batteries (e.g., World 2: `1111`, World 5: `5555`).
- **Modern Savestates & Real-Time Rewind:**
  - **F7**: Visual save-state browser with 10 slots (`F1`~`F10` quick load, `Shift+F1`~`Shift+F10` quick save).
  - **F8**: Smooth circular-buffer gameplay rewind (`Select + R3` gamepad shortcut).
  - Cold-boot state resumption directly restoring guest CPU, APU, and PPU state.

---

## Retail Game ROM Requirements

This release does **not** bundle any commercial ROM data or copyrighted game assets. You must provide your own legally dumped retail ROM of **Super Bomberman 2 (USA)**:

| Property | Value |
|---|---|
| **ROM File** | `Super Bomberman 2 (USA).sfc` |
| **Region** | USA (NTSC) |
| **Format** | Unheadered HiROM |
| **File Size** | Exactly 1,048,576 bytes (1 MiB / 8 Mbit, 16 Banks) |
| **CRC32** | `9C1F11E4` |
| **SHA-256** | `0A4B4A783A7FAF6ADA3E1326ECF85DE77E8C2A171659B42A78A1FAE43F806CA6` |

*Mismatched dumps, non-US region releases, copier-headered dumps, or modified ROMs will be rejected by the launcher's verification badge.*

---

## Testing & Verification Coverage

To ensure complete transparency regarding test coverage:

- **Story Mode**: Verified Stage 1-1 gameplay, bomb mechanics, destructible soft blocks, enemy behaviors, exit door triggers, and password continuation into Worlds 2 and 5. Full 5-world single-player playthrough is open for user completion.
- **Battle Mode**: Verified 4-player arena spawn, independent input routing, bomb detonation, flame propagation, player elimination, victory scoreboard, and round 2 reset via automated end-to-end lifecycle verification.
- **Controller Coverage**: Multitap Seat 0~3 input routing, independent keybinds, and gamepad hotplugging verified. Physical testing confirmed with standard dual-gamepad configuration and keyboard mapping; simultaneous 4 physical gamepad verification is supported by design and open for community hands-on validation.
- **Host & System Stability**: Verified standalone execution in clean directories with sanitized PATH (Medium Integrity), audio output at 32040 Hz via WASAPI, pause/resume, and savestate cold boots.

---

## Packaging & File Verification

| Archive | File Size | SHA-256 Checksum |
|---|---|---|
| `SuperBomberman2Recomp-windows-x64-v0.1.0-preview.zip` | 4,855,777 bytes (4.63 MB) | `164A13043C7E4B11071FE90C9F4096842A653BD2C6A7FDFDE049578E2A47A30C` |

---

## Disclaimer & Licensing

- **Noncommercial Notice**: This project is an unofficial static recompilation developed strictly for preservation, education, and personal study. It is not affiliated with, endorsed by, or authorized by Hudson Soft, Konami Digital Entertainment, or Nintendo Co., Ltd.
- **Licensing**:
  - SNESRecomp framework components: [PolyForm Noncommercial License 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0/)
  - recomp-ui and Dear ImGui: MIT License
  - Simple DirectMedia Layer (SDL2): zlib License
  - Fonts: SIL Open Font License 1.1 (Lato, Noto) / CC BY-SA 4.0 (OpenMoji)
  - See `THIRD_PARTY_LICENSES.md` for full notices.
