%pragma once

%macro DEFSTR 2+
	%1 DB %2
		.length EQU $ - %1
%endmacro

%define SYSCALL_WRITE 0x2000004
%define SYSCALL_READ 0x2000003
%define SYSCALL_EXIT 0x2000001

%define byte_t resb 1
%define word_t resw 1
%define dword_t resd 1
%define qword_t resq 1
%define pointer_t resq 1

%define TRUE 0x1
%define FALSE 0x0

%macro function 1
%1
	PUSH	RBP
	MOV		RBP, RSP
%endmacro

%macro end 0
	LEAVE
	RET
%endmacro
