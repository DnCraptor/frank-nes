#!/bin/bash
set -e

BUILD_DIR="build_pico"
CMAKE_OPTS="-DPICO_PLATFORM=rp2350"

# Optional: embed a ROM file
# Usage: NES_ROM=path/to/game.nes ./build.sh
if [ -n "$NES_ROM" ]; then
    # Resolve to absolute path
    NES_ROM_ABS="$(cd "$(dirname "$NES_ROM")" && pwd)/$(basename "$NES_ROM")"
    CMAKE_OPTS="$CMAKE_OPTS -DNES_ROM_PATH=$NES_ROM_ABS"
fi

# Optional: CPU speed (252, 378, 504)
if [ -n "$CPU_SPEED" ]; then
    CMAKE_OPTS="$CMAKE_OPTS -DCPU_SPEED=$CPU_SPEED"
fi

# Optional: video mode (240p or 480p)
if [ -n "$VIDEO_MODE" ]; then
    CMAKE_OPTS="$CMAKE_OPTS -DVIDEO_MODE=$VIDEO_MODE"
fi

# Optional drivers: PSRAM_ENABLED, SDCARD_ENABLED, PS2KBD_ENABLED, USB_HID_ENABLED
for OPT in PSRAM_ENABLED SDCARD_ENABLED PS2KBD_ENABLED USB_HID_ENABLED; do
    if [ "${!OPT}" = "ON" ] || [ "${!OPT}" = "1" ]; then
        CMAKE_OPTS="$CMAKE_OPTS -D${OPT}=ON"
    fi
done

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

cmake $CMAKE_OPTS ../pico
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo ""
echo "Build complete. Firmware: $BUILD_DIR/murmnes.uf2"
