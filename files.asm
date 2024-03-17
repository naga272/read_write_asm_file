
section .data
	; variabili usate per la scrittura su file 
	testa 		db "ciaoooo", 0
	len_test 	equ $ - testa

	new_line db 10
	
	; comunica messaggi di errore
	read_error 	db "errore durante la lettura del file", 0
	len_msg_read	equ $ - read_error

	write_error 	db "errore durante la scrittura del file", 0
	len_msg_write	equ $ - write_error


section .bss
	buffer resq 100

section .text


; MACRO DECLARATION
%macro GXOR 0
	xor rax, rax
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
%endmacro


%macro NEWLINE 0
	mov rax, 1
	mov rdx, 1
	mov rsi, new_line
	mov rdi, 1
	syscall
%endmacro


%macro OPEN 3
	mov rax, 2  ; syscall code open
	mov rdi, %1 ; pathname
	mov rsi, %2 ; 0o101 modalita di apertura (O_WRONLY | O_RDONLY | O_TRUNC) -> base ottale
	mov rdx, %3 ; 0o666 permessi del file (rw-rw-rw-)			 -> base ottale
	syscall
%endmacro


%macro FWRITE 2
	mov rax, 1
	mov rsi, %1	; messaggio da scrivere nel file
	mov rdx, %2	; lunghezza del messaggio
	syscall
%endmacro


%macro FCLOSE 0
	mov rax, 3
	syscall
%endmacro


read:	push 	rbp
	mov 	rbp, rsp

	OPEN	[rbp + 16], 0o100, 0o000
	test 	rax, rax
	js	errore_read

	mov 	rdi, rax ; in rax viene restituito il file descriptor del file aperto (univoco per quel file)

	; ora ottengo tutti i caratteri del file e li assegno a un vettore di char
	mov 	rax, 0
	mov 	rsi, buffer
	mov 	rdx, 99
	syscall

	; stampo a schermo il vettore di caratteri
	mov rax, 1
	mov rdx, 99
	mov rsi, buffer
	mov rdi, 1
	syscall

	NEWLINE	

	FCLOSE

	mov rax, 0
	leave
	ret

	errore_read:
		push read_error
		push len_msg_read
		call error


write: 	push rbp
	mov rbp, rsp
	
	; apertura file 
	OPEN 	[rbp + 16], 0o101, 0o666
	test 	rax, rax		; controllo se esiste errore nell'apertura file
	js 	errore_write

	mov 	rdi, rax 		; file descriptor resistuito da open (modalita w) in rax, glie lo do a rdi per la chiamata di sistema successiva	

	; scrivo su file
	FWRITE 	testa, len_test - 1
	test 	rax, rax
	js	errore_write

	FCLOSE

	mov 	rax, 0
	leave
	ret	

	errore_write:
		push write_error
		push len_msg_write
		call error


error:	push 	rbp
	mov 	rbp, rsp
		
	mov 	rax, 1
	mov	rdi, 1
	mov	rdx, [rbp + 16]
	mov 	rsi, [rbp + 24] 
	syscall

	leave
	ret

