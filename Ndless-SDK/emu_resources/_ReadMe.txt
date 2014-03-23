To be able to use the 'nspire_emu' TI-Nspire emulator integration with the 
NdlessEditor, you must first drop several resources to this directory and let 
the OS image install itself to a NAND image.

1) Download the OS corresponding to your calculator model from
   http://tiplanet.org/forum/archives_list.php?id=OS+Nspire (v3.6)

2) Drop it in this directory [emu_resources]

3) Use PolyDumper to dump your TI-Nspire classic/CX boot1 and boot2 images:
   a) Install Ndless on your TI-Nspire
   b) Transfer the file emu_resources/polydumper/polydumper.tns to your
      TI-Nspire
   c) Run polydumper.tns

4) Transfer the files boot1.img.tns and boot2.img.tns produced by PolyDumper 
   from your TI-Nspire to the directory emu_resources/ on the computer side

5) Set up the NAND image from the NdlessEditor with
   Tools > 'TI-Nspire emulator'. Let the OS reboot, then press 'I' when asked.
   The OS will install and boot up.
   
6) Install Ndless v3.6:
   Create a new folder called 'ndless' in 'My Documents'.
   Set the target folder with 'Link > Set Target Folder...' to 'ndless'.
   Transfer ('ndless_installer.tns' and 'ndless_resources_3.6.tns') with
   'Link > Connect' then 'Link > Send Document...'.
   Install Ndless with ''ndless_installer.tns'.

7) Save the NAND (flash) image with the File > 'Save Flash As...' option of 
   nspire_emu to a file named 'nand.img' in this directory.
   The image will be loaded the next time you launch the emulator from the 
   NdlessEditor (Tools > TI-Nspire emulator).
