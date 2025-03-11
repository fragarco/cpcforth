#!/bin/bash
# This file is just an example of how ABASM and DSK utilities can be
# used to assemble programs and generate files that can be used in
# emulators or new hardware for the Amstrad CPC

rm -Rf dist
mkdir dist

SRC=src/main.asm
DST=dist/forth.bin
DSK=dist/cpcforth.dsk
ADDR=0x3F00

python3 abasm/abasm.py $SRC -o $DST
python3 abasm/dsk.py -n $DSK --put-bin $DST --load-addr $ADDR --start-addr $ADDR
