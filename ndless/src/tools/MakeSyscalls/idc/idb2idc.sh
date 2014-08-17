#!/bin/sh

if [ $# -eq 0 ]; then 
	echo "Usage <os.idb>"
	echo "Converts an .idb IDA database file to an .idc"
	exit 0
fi
idb="$1"
idc="${idb%%.idb}.idc"
echo "$idc..."
idag -Sidb2idc.idc -A $idb | grep -v "Thank you"
./lighten_idc.sh < temp.idc > $idc
rm -f temp.idc

