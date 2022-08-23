#!/bin/zsh
CARD=/dev/rdisk5
sudo mkrock zig-out/bin/zoot compiled/images/zoot.img && \
diskutil eraseDisk FAT32 SDCARD MBRFormat $CARD && \
diskutil unmountDisk $CARD && sudo dd if=/dev/zero of=$CARD count=64 && \
diskutil unmountDisk $CARD && \
sudo dd if=compiled/images/zoot.img of=$CARD seek=64 conv=notrunc && sync
