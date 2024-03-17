

section .data
	pathname 	db "./test.txt", 0


section .bss

section .text
	global _start

%include "files.asm" 


_start: GXOR
	call main

_exit:	mov rax, 60
	mov rdi, rax
	syscall


main: 	push 	rbp
	mov 	rbp, rsp

	push pathname
	call write

	push pathname
	call read

	leave
	ret

