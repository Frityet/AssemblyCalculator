%include "common.inc"

[SECTION .text]
[GLOBAL PRINT]
;int PRINT(RDI: char *buf, RSI: qword length)
PRINT:
	MOV		RDX, RSI				;String length
	MOV		RSI, RDI				;String pointer
	MOV		RAX, SYSCALL_WRITE
	MOV		RDI, 0x1
	SYSCALL
	RET

;bool IS_NUMBER(RDI: char c) 
IS_NUMBER:
	;DIL = RDI 
	CMP		DIL, '0'
	JL		.false
	CMP		DIL, '9'
	JG		.false

	MOV		RAX, TRUE
	RET

	.false:
	MOV		RAX, FALSE
	RET


[GLOBAL STRING_TO_UINTEGER]
;qword STRING_TO_UINTEGER(RDI: char str[len], RSI: qword len)
STRING_TO_UINTEGER:
	MOV		RDX, RDI	;RDI is the first argument of any function, so we must save the string address in RDX for scratch

	CMP		RSI, 0x1
	JG		.multichar

	; If the string is 1 char long, no need to do iterations
	MOV		DIL, BYTE [RDX]
	CALL	IS_NUMBER
	MOV		R9, 0x0 	;Return value
	CMP		RAX, 0x0
	JE		.return

	SUB		DIL, '0'	;Convert the character to a number by subtracting the ASCII code of '0'
	MOV		RAX, RDI 
	RET

	.multichar:
	XOR 	R9, R9		;Return value, we use R9 because AL is used as the lower byte of RAX
	XOR 	R8, R8		;Flag to check if the leading zeroes were already trimmed

	XOR		RCX, RCX	;Counter
	.0_l:	;for (RCX = 0; RCX < len; RCX++)
		MOV		DIL, BYTE [RDX]	;Get the current character
		
		;#region Validation and fixes
		CMP		DIL, ' '		;Check if the character is a space
		JE		.cont		;If it is, continue

		CMP		DIL, '0'		;Check if the character is 0
		JNE		.skip0		;If the character isn't 0, just jump past the check
		CMP		R8, 0x1		;Check if the leading zeroes were already trimmed
		JE		.cont		;If it is, continue, skipping 0

		.skip0:
		CMP		DIL, 0xA		;Check if the character is a new line
		JE		.return		;If it is, return

		CMP		DIL, 0x0		;Check if the character is a null terminator, you are damn retarded if you use a null term tho
		JE		.return

		;Char is already in DIL
		CALL	IS_NUMBER	;Check if the character is a number
		CMP		RAX, FALSE	;If it is not a number return
		JE		.return

		;#endregion

		IMUL	R9, 0xA		;Multiply the return value by 10
		SUB		DIL, '0' 	;Convert the character to a number by subtracting the ASCII code of '0'
		ADD		R9, RAX 

		.cont:
		INC		RDX			;Next character
		INC		RCX			;Counter
		CMP		RCX, RSI	;Check if we reached the end of the string (RSI contains the length)
		JLE		.0_l		;If not, do the loop again

	.return:
	MOV		RAX, R9
	RET


[GLOBAL UINTEGER_TO_STRING]
;int UINTEGER_TO_STRING(RDI: qword int, RSI: char str[len], RDX: qword len)
UINTEGER_TO_STRING:
	XOR		RCX, RCX ;Counter
	.0_l:
		

		INC		RCX
		CMP		RCX, RDX
		JLE 	.0_l

	
	MOV		RAX, RCX
	RET
