@echo off

REM *
REM * This file is just an example of how ABASM and DSK/CDT utilities can be called to assemble programs
REM * and generate files that can be used in emulators or new hardware for the Amstrad CPC
REM *
REM * USAGE: make [clear]

@setlocal

set ABASM=.\abasm
set ASM=python3 %ABASM%\abasm.py
set DSK=python3 %ABASM%\dsk.py
set CDT=python3 %ABASM%\cdt.py

set LOADADDR=0x4000
set SOURCE=src\main
set TARGET=dist\cpcforth

set RUNASM=%ASM% %SOURCE%.asm -o %TARGET%.bin
set RUNDSK=%DSK% %TARGET%.dsk --new --put-bin %TARGET%.bin --load-addr %LOADADDR% --start-addr %LOADADDR%

IF not exist ".\dist\" mkdir dist

IF "%1"=="clear" (
    del %TARGET%.*
) ELSE (
    call %RUNASM% && call %RUNDSK%
)

@endlocal
@echo on