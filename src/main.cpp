// Castlevania: Harmony of Dissonance (USA) — native static recomp host.
// Windows GUI subsystem entry; no automatic input or demo playback.

#include "runtime.h"

#ifdef _WIN32
#include <windows.h>
#include <shellapi.h>
#endif

static int run(int argc, char** argv) {
    gbarecomp::RunOptions opts;
    opts.builtin_game_name = "Castlevania: Harmony of Dissonance (USA)";
    opts.builtin_rom_sha1  = "b90da0d9be0b3a0893cd9e2c399056bcf9579e21";
    opts.builtin_rom_crc32 = 0x88C1B562;
    opts.max_view_width = 240;
    opts.max_resize_view_width = 240;
    return gbarecomp::run_game(argc, argv, opts);
}

#ifdef _WIN32
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int) {
    int argc = 0;
    LPWSTR* argv_w = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (!argv_w) return 1;
    char** argv = static_cast<char**>(HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY,
                                               sizeof(char*) * (argc + 1)));
    if (!argv) {
        LocalFree(argv_w);
        return 1;
    }
    int rc = 1;
    if (argv) {
        for (int i = 0; i < argc; ++i) {
            int n = WideCharToMultiByte(CP_UTF8, 0, argv_w[i], -1, nullptr, 0, nullptr, nullptr);
            argv[i] = static_cast<char*>(HeapAlloc(GetProcessHeap(), 0, n ? n : 1));
            if (argv[i] && n > 0)
                WideCharToMultiByte(CP_UTF8, 0, argv_w[i], -1, argv[i], n, nullptr, nullptr);
        }
        rc = run(argc, argv);
        for (int i = 0; i < argc; ++i)
            if (argv[i]) HeapFree(GetProcessHeap(), 0, argv[i]);
        HeapFree(GetProcessHeap(), 0, argv);
    }
    LocalFree(argv_w);
    return rc;
}
#else
int main(int argc, char** argv) {
    return run(argc, argv);
}
#endif
