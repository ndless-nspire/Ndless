+----------------------+
|    Nspire I/O 3.0    |
+----------------------+


Installation
------------
Just copy the "lib" and "include" directories over
to your .ndless directory located at the userpath, for example
C:\Users\Name\.ndless or /home/name/.ndless

Building the code
-----------------
make lib 	- Compiles Nspire I/O
make demo 	- Compiles demos (Install first!)
make install 	- Install Nspire I/O
make uninstall 	- Uninstall Nspire I/O

Usage
-----
Add "-lnspireio" to LDFLAGS in your Makefile and include
"nspireio.h" in your code.

A color support for CX is currently not implemented, but it
will work fine on CXes with the LCD set to grayscale mode
by using "lcd_ingray()".

Migrate from 2.0 to 3.0
-----------------------
For the lazy people:
Change "-lnspireio2" in you Makefile to "-lnspireio".
Programs that include nspireio2.h will compile in compatibility mode (old syntax).

To use the new syntax, include nspireio.h instead nspireio2.h and
replace the function calls with their new names.

Nspire I/O is not compatible to versions < 2.0.

Documentation
-------------
An auto-generated documentation can be found in the "doc/html"
directory, just open "index.html" (if something is unclear,
please contact me and I will try to help you ;)
The code of the demo application can be found in "src/demo".

Contact
-------
Julian Mackeben aka compu
E-Mail: compujuckel@googlemail.com
Discussion topic: http://www.omnimaga.org/index.php?topic=6871.0