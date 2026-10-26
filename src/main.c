/*
 * Super Bomberman 2 — desktop host shim.
 *
 * Identity and hooks, nothing else. The host itself is the framework's
 * (snesrecomp/runner/src/desktop/host_main.h): the pre-boot launcher, ROM
 * resolution and digest checks, config.ini and keybinds.ini, the window and
 * the SDL / OpenGL presenters, audio, gamepads, the in-game save-state
 * browser and rewind filmstrip, the OSD, the pacing clock, crash handlers and
 * the post-mortem report, mod packages, Generate & rebuild, and the netplay
 * barrier when the project is built with it. A fix there reaches this
 * project on a submodule pull; nothing in this file needs to change for it.
 *
 * This file used to BE the host -- a ~700-line copy made at scaffold time --
 * so every project scaffolded before a fix kept the bug. Two ports of the
 * same game, a week apart, had different hosts.
 *
 * Nothing here ever ships a ROM. The player supplies one; the host makes
 * that easy (launcher, then positional argument, then a copy beside the
 * executable, then the rom.cfg cache, then a file picker) and checks what it
 * is handed against the digests in rom_identity.txt.
 *
 * Grow this file only with what is specific to THIS title: a custom
 * presenter (prepare_frame / draw_frame), an SPC player, a pacing rule
 * (keep_pacing_debt), a Mods provider. See SnesDesktopHostGame for the
 * complete list of hooks and what each is for.
 */

#include "host_main.h"
#include "game_rtl.h"
#include "common_rtl.h"
#include "snesrecomp_rom_identity.h"  /* generated from rom_identity.txt */

#ifndef __ANDROID__
#define SDL_MAIN_HANDLED 1
#endif
#include "desktop/sdl_compat.h"
#ifdef __ANDROID__
/* SDLActivity loads libmain.so and dlsyms its SDL_main. */
#define main SDL_main
#endif

#ifndef SNES_GAME_VERSION
#define SNES_GAME_VERSION "dev"
#endif

static void SuperBomberman2_BeforeRunFrame(void)
{
    static int s_frame = 0;
    s_frame++;
    const char *test_4p = getenv("SB2_TEST_4P");
    if (test_4p) {
        /* Inject P3 and P4 inputs during battle gameplay (frames 1530-1560) */
        if (s_frame >= 1530 && s_frame <= 1560) {
            /* P3 (Seat 2): Down (0x0020) + A (0x0100) = 0x0120 */
            RtlSetPadState(2, 0x0120);
            /* P4 (Seat 3): Up (0x0010) + A (0x0100) = 0x0110 */
            RtlSetPadState(3, 0x0110);
        } else if (s_frame > 1560 && s_frame <= 1650) {
            RtlSetPadState(2, 0);
            RtlSetPadState(3, 0);
        }
    }
}

static const SnesDesktopHostGame kGameHost = {
    .display_name        = "Super Bomberman 2",
    .window_title        = "Super Bomberman 2",
    .region              = SNESRECOMP_ROM_REGION,
    .rom_file            = SNESRECOMP_ROM_FILE,
    .expected_sha256_hex = SNESRECOMP_ROM_EXPECTED_SHA256,
    .expected_crc32_hex  = SNESRECOMP_ROM_EXPECTED_CRC32,
    .game_id             = SNESRECOMP_ROM_GAME_ID,
    .build_version       = SNES_GAME_VERSION,
    .game_info           = &kGameInfo,
    .num_players         = 4,
    .before_run_frame    = &SuperBomberman2_BeforeRunFrame,
    /* Battery-backed SRAM shows the launcher's SAVES panel. Leave NULL for a
     * title without one. The path is exe-relative. */
    .sram_path           = NULL,
    .display_aspect_supported = 1,
    .shader_supported         = 1,
    .rewind_settings          = 1,
    .state_menu_hotkeys       = 1,
    .in_game_launcher         = 1,
    .rom_help                 = "Requires an unmodified retail ROM of Super Bomberman 2 (USA) (1 MB, .sfc).",
};

#ifndef __ANDROID__
#undef main   /* desktop: keep plain main() even if SDL_main.h remapped it */
#endif

int main(int argc, char **argv)
{
    return snesrecomp_desktop_main(&kGameHost, argc, argv);
}
