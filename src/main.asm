; CPCFORTH
; A Forth intepreter for the Amstrad CPC
; by Javier "Dwayne Hicks" García

; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation in its version 3.

; This program is distributed in the hope that it will be useful
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU General Public License for more details.

; The main inspiration and technical information sources used in this
; projects has been:
;
; Jonesforth By Richard W.M. Jones
; A sometimes minimal FORTH compiler and tutorial for Linux / i386 systems.
; 
; Moving Forh By Bradford J. Rodriguez
; A series of articles appeared in The Computer Journal magazine.
;
; Threaded Interpretive Langiages By R.G. Loeliger
; ISBN 0-07-038360-X, 1981 BYTE Publications Inc.

; This Forth implementation uses the following register assignments:
; W     DE  - Working Register    
; IP    BC  - Interpreter Pointer
; PSP   SP  - Parameter Stack Pointer
; RSP   IX  - Return Stack Pointer but we will use only the low byte IXL
	
org &4000

; will go down from &4000 to 3F01 (128 16 bit values)
RSP_STACK:

START:
    ld   ix,RSP_STACK

; EXIT or SEMICOLON
; POP RSP -> IP
; Continues into WORD_NEXT
WORD_EXIT:
    dw   $+2        ; Code Address
    ld   c,(ix+0)   ; Code
    inc  ixl        
    ld   b,(ix+0)
    inc  ixl

; NEXT WORD
; (IP) -> W
; IP+2 -> IP
; Continues into WORD_RUN
WORD_NEXT:
    ld   a,(bc)
    ld   l,a
    inc  bc
    ld   a,(bc) ; currently W is in HL
    ld   h,a    ; but that is only temporal
    inc  bc     ; RUN will change that to DE

; RUN WORD
; (W (HL)) -> X (DE)
; W+2 -> W
; JP (X)
WORD_RUN:
    ld   e,(hl) 
    inc  hl
    ld   d,(hl)
    inc  hl
    ex   de,hl  ; jump to address in X
    jp   (hl)   ; leave in DE the value of IP

; ENTER or DOCOLON
; PUSH IP -> RSP
; W -> IP
; JP NEXT
WORD_ENTER:
    dec  ixl
    ld   (ix+0),b
    dec  ixl
    ld   (ix+0),c
    ld   c,e
    ld   b,d
    jr   WORD_NEXT

; EXECUTE
    db  7,"EXECUTE"
    dw  &0000
WORD_EXECUTE:
    dw   $+2
    pop  hl
    jr   WORD_RUN



;
; LIST OF WORDS
;
; Each available Forth word is stored in this list
; HEADER:
;    2 bytes: addr to previous word
;    1 bytes: 4 bits name len, 4 bits for flags
;    n bytes: word name (1-15) characters

; Pointer to the lastes defined word
WORDS_LATEST: dw &0000

;DUP
; POP PSP -> X
; PUSH X -> PSP
; PUSH X -> PSP
dw   &FFFF
db   &F3
db   "DUP"
dw   $+2
pop  hl
push hl
push hl
jp   WORD_NEXT

;CONSTANT
; (W) -> X
; PUSH X -> PSP
dw   &FFFF
db   &F8
db   "CONSTANT"
dw   WORD_ENTER
dw   &FFFF   ; CREATE
dw   &FFFF   ; ,
dw   &FFFF   ; SCODE
ex   de,hl
ld   e,(hl)
inc  hl
ld   d,(hl)
inc  hl
ex   de,hl
push hl
jp   WORD_NEXT
