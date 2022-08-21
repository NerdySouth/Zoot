#!/bin/zsh

export CARD=/dev/rdisk5
export BUILD=zoot-fast

zig build -fno-stage1 -Drelease-fast=true dump-elf > compiled/elfs/no-stage1-fast && \
sudo mkrock zig-out/bin/zoot compiled/images/$BUILD.img && \
diskutil eraseDisk FAT32 SDCARD MBRFormat $CARD && \
diskutil unmountDisk $CARD && sudo dd if=/dev/zero of=$CARD count=64 && \
diskutil unmountDisk $CARD && \
sudo dd if=compiled/images/$BUILD.img of=$CARD seek=64 conv=notrunc && sync
