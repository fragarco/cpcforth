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

org &3F00

; This Forth implementation uses the following register assignments:
; W     DE  - Working Register    
; IP    BC  - Interpreter Pointer
; PSP   SP  - Parameter Stack Pointer
; RSP   IX  - Return Stack Pointer but we will use only the low byte IXL

; MACRO WORD HEADER
; Each Forth word includes a header with the following format:
; HEADER:
;    2 bytes: addr to previous word
;    1 bytes: 3 bits for flags + 5 bits name length
;    n bytes: word name (1-32) characters
macro W_HEADER _NAME_,_FLAGS_LEN_,_PREV_,_CAADDR_ 
    dw _PREV_       ; Address to previous work in the dictionary
    db _FLAGS_LEN_  ; Word's flags + name length
    db _NAME_       ; Word's name
endm

; RSP STACK
; will go down from &4000 to 3F01 (128 16 bit values)
defs 256
RSP_STACK_START:
    ld   ix,RSP_STACK_START

; EXIT or SEMICOLON
; POP RSP -> IP
; Continues into WORD_NEXT
EXIT_ADDR:
    dw   $+2        ; Code Address
EXIT_CODE:
    ld   c,(ix+0)   ; Code
    inc  ixl        
    ld   b,(ix+0)
    inc  ixl

; NEXT WORD
; (IP) -> W
; IP+2 -> IP
; Continues into WORD_RUN
NEXT_CODE:
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
RUN_CODE:
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
ENTER_CODE:
    dec  ixl
    ld   (ix+0),b
    dec  ixl
    ld   (ix+0),c
    ld   c,e
    ld   b,d
    jr   NEXT_CODE


;
; LIST OF WORDS
;
; Each available Forth word is stored in this list with the following
; format:
; HEADER        varies
; CODE ADDRESS  2 bytes
; CODE PARAMS   varis  (optional)
; CODE          varies (optional)

; Pointer to the lastes defined word
WORDS_LATEST: dw &0000

W_EXECUTE:
W_HEADER "EXECUTE",&07,&0000
W_EXECUTE_ADDR:
    dw   $+2
W_EXECUTE_CODE:
    pop  hl
    jr   RUN_CODE


;DUP
; POP PSP -> X
; PUSH X -> PSP
; PUSH X -> PSP
W_DUP:
W_HEADER "DUP",&03,W_EXECUTE
W_DUP_ADDR:
    dw   $+2
W_DUP_CODE:
    pop  hl
    push hl
    push hl
    jp   NEXT_CODE

