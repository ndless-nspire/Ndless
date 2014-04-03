#!/bin/sh

rdebug_port=3334

print_usage() {
	echo "Usage: "`basename $0`" [option] <file.tns> [<destdir>]"
	echo "\t-p [port]: nspire_emu remote debug port (default: 3334)"
}

while getopts ":p:h" opt; do
	case $opt in
		p)
			rdebug_port="$OPTARG"
			;;
		h)
			print_usage
			exit 0
			;;
		\?)
			echo "Invalid option: -$OPTARG"
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument."
			print_usage
			exit 1
			;;
	esac
done
shift $((OPTIND-1))

if [ $# -ne 1 -a $# -ne 2 ]; then
	print_usage
	exit 0
fi
if [ ! -f "$1" ]; then
	echo "File not found: $1"
	exit 1
fi

if [ $# -ge 2 ]; then
	st_cmd="ln st $2"
fi

nc localhost "$rdebug_port" <<EOT
ln c
EOT
ret=$?

if [ $ret -ne 0 ]; then
	echo "Error: couldn't connect to nspire_emu remote debug service."
	exit 1
fi

sleep 1
nc localhost "$rdebug_port" <<EOT
$st_cmd
ln s $1
EOT
ret=$?

