#!/bin/sh
#### CONFIG
GDB_PORT=3333
REMOTE_DEBUG_PORT=3334
#### END OF CONFIG - DON'T EDIT ANYTHING BELOW

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

if ! wine --version >/dev/null; then
	echo "Wine is required.\nInstall it with your system's packet manager."
	exit 1
fi

if [ ! -f "$SCRIPTPATH/nspire_emu.exe" ]; then
	echo "nspire_emu.exe hasn't been built.\nGet it from an SDK build or build it from Windows."
	exit 1
fi

cd "$SCRIPTPATH/../../emu_resources"

modelswitch=""
[ -f *.tco ] && modelswitch="/MX"
[ -f *.tcc ] && modelswitch="/MXC"
[ -f *.tno ] && modelswitch=""
[ -f *.tnc ] && modelswitch="/MC"
if [ "$modelswitch" = "" ]; then
	echo "Error: OS not found.\nYou should drop a *.tco, *.tcc, *.tno or *.tnc file into emu_resources/."
	exit 1
fi
txx="$(ls *.tco *.tcc *.tno *.tnc 2>/dev/null)"

if [ ! -f boot1.img.tns ]; then
	echo "Error: boot1 image not found.\nYou should dump it from your own calc with emu_resources/polydumper."
	exit 1
fi

if [ -f *.img ]; then
	img="$(ls *.img)"
	"$SCRIPTPATH/nspire_emu.exe" /R /N /1=boot1.img.tns /F="$img" $modelswitch /G=$GDB_PORT /C=$REMOTE_DEBUG_PORT
else
	if [ ! -f boot2.img.tns ]; then
		echo "Error: boot2 image not found.\nYou should either dump it from your calc with emu_resources/polydumper or unzip it from the OS file."
		exit 1
	fi
	"$SCRIPTPATH/nspire_emu.exe" /R /N \/1=boot1.img.tns /PO="$txx" /PB=boot2.img.tns $modelswitch
fi

