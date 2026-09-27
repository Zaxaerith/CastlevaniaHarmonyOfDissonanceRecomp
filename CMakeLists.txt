# Castlevania: Harmony of Dissonance (USA) — static recompilation host.
# Builds hod.exe from src/ + the GBARecomp runtime (external).

cmake_minimum_required(VERSION 3.20)
project(hod C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

set(GBARECOMP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../gbarecomp-main"
    CACHE PATH "Path to the GBARecomp framework (https://github.com/mstan/gbarecomp)")

if(NOT EXISTS "${GBARECOMP_ROOT}/CMakeLists.txt")
    message(FATAL_ERROR "GBARECOMP_ROOT not found: ${GBARECOMP_ROOT}\n"
        "Clone https://github.com/mstan/gbarecomp (with submodules) next to this project.")
endif()

# SDL2 (MinGW devel package). Override via -DSDL2_INCLUDE_DIR / -DSDL2_LIBRARY.
set(SDL2_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/third_party/SDL2-2.30.11/x86_64-w64-mingw32"
    CACHE PATH "SDL2 MinGW development prefix")
if(NOT SDL2_INCLUDE_DIR)
    set(SDL2_INCLUDE_DIR "${SDL2_ROOT}/include/SDL2")
endif()
if(NOT SDL2_LIBRARY)
    set(SDL2_LIBRARY "${SDL2_ROOT}/lib/libSDL2.dll.a")
endif()

add_subdirectory("${GBARECOMP_ROOT}" gbarecomp-build EXCLUDE_FROM_ALL)

add_executable(hod
    src/main.cpp
    src/game/cart_recompiled_core.cpp
    src/game/cart_recompiled_engine.cpp
    src/game/cart_recompiled_system.cpp
    src/game/cart_recompiled_support.cpp
    src/game/cart_dispatch_table.cpp
    src/game/cart_symbol_map.cpp
)

target_include_directories(hod PRIVATE
    "${GBARECOMP_ROOT}/src/armv4t"
    "${GBARECOMP_ROOT}/src/gba"
    "${GBARECOMP_ROOT}/src/runtime"
    "${GBARECOMP_ROOT}/src/debug"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/game"
)

target_compile_definitions(hod PRIVATE
    GBARECOMP_WINDOW_TITLE="Castlevania Harmony of Dissonance"
    GBARECOMP_DEFAULT_GAME_CONFIG="game.toml"
)

target_link_libraries(hod PRIVATE
    -Wl,--start-group
    gbarecomp_armv4t
    gbarecomp_gba
    gbarecomp_runtime
    gbarecomp_debug
    -Wl,--end-group
)

if(WIN32)
    # GUI subsystem: no console window.
    target_link_options(hod PRIVATE
        "LINKER:--subsystem,windows"
        "LINKER:--stack,16777216"
        "LINKER:--allow-multiple-definition"
    )
    target_link_libraries(hod PRIVATE shell32 user32 gdi32 winmm)
endif()

if(EXISTS "${SDL2_ROOT}/bin/SDL2.dll")
    add_custom_command(TARGET hod POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${SDL2_ROOT}/bin/SDL2.dll"
            "$<TARGET_FILE_DIR:hod>/SDL2.dll"
    )
endif()

