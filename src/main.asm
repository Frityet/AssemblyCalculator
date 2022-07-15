%include "common.inc"

EXTERN PRINT
EXTERN STRING_TO_UINTEGER

[SECTION .text]
[GLOBAL START]
START:
	MOV		RAX, SYSCALL_WRITE
	MOV		RDI, 0x1
	MOV		RSI, startupmsg
	MOV		RDX, startupmsg.length
	SYSCALL
	
	XOR 	RBP, RBP			;Clear RBP
	MOV 	RDI, [RSP]			;Load argc into RDI
	LEA		RSI, [RSP + 0x8]	;Load argv into RSI

	XOR		RAX, RAX			;Clear RAX
	CALL	MAIN				;Call main

	MOV		RDI, RAX			; Load return value into RDI
	MOV		RAX, SYSCALL_EXIT
	SYSCALL
	RET							; Exit

MAIN:
	PUSH	RBP
	MOV		RBP, RSP

	[SECTION .data]
	.prmt db "> "	;Must be in data section
	[SECTION .text]
	MOV		RDI, .prmt
	MOV		RSI, 0x2
	CALL	PRINT

	;char[255]
	SUB		RSP, 0xFF
	MOV		RAX, SYSCALL_READ	
	MOV		RDI, 0x0		;0 == stdin
	MOV		RSI, RSP		;Input buffer
	MOV		RDX, 0xFF
	SYSCALL

	MOV		RDI, RSP
	MOV		RSI, 0xFF
	CALL	PRINT

	LEAVE
	;Return value is in STRING_TO_INTEGER's return value (RAX)
	RET
	

[SECTION .data]
DEFSTR startupmsg, "STARTED PROGRAM", 0xA
DEFSTR msg, "Hello, World!", 0xA
DEFSTR large, "****************************************************************************", 0xA
