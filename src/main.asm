%include "common.inc"

EXTERN PRINT
EXTERN STRING_TO_UINTEGER
EXTERN REVERSE
EXTERN MEMORY_COPY

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
	XOR		R15, R15	;Clear R15, will be used to track the size of the stack

	[SECTION .data]
	.prmt db "> "	;Must be in data section
	[SECTION .text]
	MOV		RDI, .prmt
	MOV		RSI, 0x2
	CALL	PRINT

	;char[255]
	SUB		RSP, 0xFF
	ADD		R15, 0xFF

	MOV		RAX, SYSCALL_READ	
	MOV		RDI, 0x0		;0 == stdin
	MOV		RSI, RSP		;Input buffer
	MOV		RDX, 0xFF
	SYSCALL

	SUB		RSP, RAX		;Create a new buffer for the input
	ADD		R15, RAX

	; I am aware that is a VLA ; 
	MOV		RDI, RSP		;Input buffer - destination
	MOV		RSI, RAX		;Input buffer - destination length
	LEA		RDX, [RSP + RAX];Input buffer - source
	MOV		RCX, 0xFF		;Input buffer - source length
	CALL	MEMORY_COPY

	MOV		RDI, RSP		;Load input buffer into RDI
	MOV		RSI, 0xFF		;Load input buffer length into RSI
	CALL 	REVERSE

	MOV		RDI, RSP
	MOV		RSI, 0xFF
	CALL	PRINT

	ADD		RSP, R15	;Free the stack
	POP		RBP
	;Return value is in STRING_TO_INTEGER's return value (RAX)
	RET
	

[SECTION .data]
DEFSTR startupmsg, "STARTED PROGRAM", 0xA
DEFSTR msg, "Hello, World!", 0xA
DEFSTR large, "****************************************************************************", 0xA
