#!/bin/zsh

CARD=/dev/rdisk5
IMG=zoot-debug.img
BUILD=debug 

if [[ $1 == "-sm" ]]; then
    IMG=zoot-small.img
    BUILD=small
elif [[ $1 == "-f" ]]; then
    IMG=zoot-fast.img
    BUILD=fast
elif [[ $1 == "-s" ]]; then 
    IMG=zoot-safe.img
    BUILD=safe
elif [[ $1 == "-h" ]]; then
    echo "Builds the zoot binary, and loads it to the SD card for the RockPro64.\nPossible flags:\n\t-> -sm : passes zig build the -Drelease-small=true\n\t-> -f : passes zig build the flag for a 'fast' build. See Zig docs.\n\t-> -s : passes zig build the flag for a 'safe' build. See Zig docs for more info."
    exit -1
fi

if [[ $BUILD == debug ]]; then 
    zig build dump-elf > compiled/elfs/zoot-debug-elf.list && \
    zig build dump-bin > compiled/bins/zoot-debug-bin.list &&
    sudo mkrock zig-out/bin/zoot compiled/images/$IMG && \
    diskutil eraseDisk FAT32 SDCARD MBRFormat $CARD && \
    diskutil unmountDisk $CARD && sudo dd if=/dev/zero of=$CARD count=64 && \
    diskutil unmountDisk $CARD && \
    sudo dd if=compiled/images/$IMG of=$CARD seek=64 conv=notrunc && sync
else
    zig build -Drelease-$BUILD=true dump-elf > compiled/elfs/zoot-$BUILD-elf.list && \
    zig build -Drelease-$BUILD=true dump-bin > compiled/bins/zoot-$BUILD-bin.list && \
    sudo mkrock zig-out/bin/zoot compiled/images/$IMG && \
    diskutil eraseDisk FAT32 SDCARD MBRFormat $CARD && \
    diskutil unmountDisk $CARD && sudo dd if=/dev/zero of=$CARD count=64 && \
    diskutil unmountDisk $CARD && \
    sudo dd if=compiled/images/$IMG of=$CARD seek=64 conv=notrunc && sync
fi
