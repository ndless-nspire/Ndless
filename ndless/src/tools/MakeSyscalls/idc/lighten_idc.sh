#!/bin/sh
# Usage: lighten_idc.sh <in >out
# Keeps what should be shared from an .idc file exported by IDA
egrep 'MakeName|MakeRptCmt' | egrep -v '"a[A-Z]' | egrep -v 'null|jumptable|default'
