# Zoot
Zoot is a low-level bootloader for Nox (see TristenSeth/Nox). It is written with Zig. Right now both Zoot and Nox are being developed
for the RockPro64, which is an RK3399 based system. 

Normally, the RockPro64 bootrom expects to pass control over to a U-Boot SPL, which will 
run Arm TF (Trusted Firmware), call back into the bootrom, then the bootrom will call the U-Boot TPL which is more full-featured but could not fit 
within SRAM, and thus needed some other initialization done first, I.e. DDR Initialization. 

Zoot takes over the system from the first point the bootrom hands control over. Normally, this would be the U-Boot SPL. This means Zoot is first loaded and ran in SRAM, and must initialize DDR memory before we can load a program and jump to it.

TODO:
<ol>
<li>Initialize UART so we have serial debugging statements.</li>
<li>Initalize DDR Memory so we can read/write to and from it, as well as load programs into it and execute from it.</li>
<li>Extend zoot to listen for new binary files over UART2 on bootup, so we can send kernel images to it via UART rather than flashing the SD card.</li>
<li>Embed Zoot into an EMMC Flash module for better static storage. This will free the SD card to be able to hold the kernel image, and Zoot will then
be able to start the system, and load the kernel from SD storage into RAM and jump to it for execution.
</ol>
