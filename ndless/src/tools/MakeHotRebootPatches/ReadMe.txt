Hot rebooting an OS is not possible as is, as some OS global variables have lost their initial values.

This utility generates patch commands to reset these variables by comparing an 
original decrypted OS image with a post-boot image (0x10000000-end_of_os, i.e. 
before the BSS).

nspire_emu's commands for the OS RAM image dump:
[use the calc as a user do - also initiate USB transfers]
k [stage1 base address]
c
[run the Ndless installer]
wm C:\temp\os-post-boot.img 0x10000000 [end_of_os-0x10000000]
k 10000000
c
[reset]
wm C:\temp\os-pre-boot.img 0x10000000 [end_of_os-0x10000000]

end_of_os is just before the BSS.

Then:
- MakeHotRebootPtch.exe 0x10000000 os-pre-boot.img os-post-boot.img hrpatches-os-cascx-3.6.0.h

Comparing an OS image produced by nspire_emu doesn't seem always to be enough, the 
post-boot image should be produced from real HW.
