section .data
	newline db "", 0xa, 0x0
	min db "min:", 0x0
	max db "max:", 0x0
section .bss
	input resb 1024
section .text
	global _start
_start:
	mov rbp, rsp	
	sub rsp, 0x18
	
	push input
	call gets
	add rsp, 8
		
	mov rsi, input		
	jmp _start_1		
_start_1: ; convert string to arrary of int
	push rsi
	call atoi
	add rsp,8	
	add [rbp-8],byte 1
	
	push rax
	jmp _start_2
_start_3:
	inc rsi
_start_2:
	cmp [rsi], byte 0
	je _start_4
	cmp [rsi], byte '0'
	jb _start_3	
	cmp [rsi], byte '9'
	jg _start_3 
	jmp _start_1
_start_4:
	mov rax, [rbp-0x20]		
	mov [rbp-0x10], rax
	mov [rbp-0x18], rax	 
	lea r8, [rbp-0x20]
	mov rcx, [rbp-0x8]
_start_5:
	mov rax, [r8]
	; compare rax vs min 
	sub rax, [rbp-0x10]
	jns _start_6
	mov rax, [r8]
	mov [rbp-0x10], rax
_start_6:
	mov rax, [r8]
	; compare rax vs max 
	sub rax, [rbp-0x18]					
	js _start_7	
	mov rax, [r8]
	mov [rbp-0x18], rax
_start_7:
	sub r8, 8
	loopnz _start_5
	push min
	call printf
	add rsp, 0x8
	; print min 
	mov rax, [rbp-0x10]
	push rax
	call printn
	; print new line
	push newline
	call printf
	add rsp, 0x8
	
	push max
	call printf
	add rsp, 0x8
	; print max 
	mov rax, [rbp-0x18]
	push rax
	call printn
	
	; print new line
	push newline
	call printf
	add rsp, 0x8

	call exit
	
exit:  ; exit(0)
	mov rax, 60 
	xor rdi, rdi
	syscall		

strlen: ; strlen(s) return length of s
	push rbp
	mov rbp, rsp
	sub rsp, 0x8
	mov rsi, [rbp+0x10]
	mov qword [rbp-0x8], 0
	jmp strlen_1						
strlen_2:
	add [rbp-0x8], byte 1  				
	inc rsi 
strlen_1:
	cmp [rsi], byte 0
	jne strlen_2 
	mov rax, [rbp-0x8]
	leave
	ret

malloc: ; malloc(size)
	push rbp
	mov rbp, rsp
	mov rax, 12
	xor rdi, rdi
	syscall
	mov r8, rax	
	mov rdi, rax		
	add rdi, [rbp+0x10]
	mov rax, 12
	syscall
	mov rax, r8		
	leave
	ret

itoa:   ;itoa(i) integer to string
	push rbp
	mov rbp, rsp
	;malloc(20)
	push 20
	call malloc
	add rsp, 0x8 	
	mov r8, rax
	add r8, 20 
	mov rax, [rbp+0x10]	
itoa_1:	
	mov rcx, 10
	xor rdx, rdx
	div rcx 
	mov [r8], dl
	add [r8], byte '0'		
	dec r8
	test rax, rax	
	jnz itoa_1
	mov rax, r8 
	leave 
	ret	
printn:	;printn(number) print integer
	push rbp
	mov rbp, rsp
	mov rax, [rbp+0x10]
	push rax
	call itoa
	mov rsi, rax	
	mov rax, 1
	mov rdi, 1
	mov rdx, 20
	syscall	
	leave
	ret	
atoi:	;atoi(s) string to integer
	push rbp
	mov rbp, rsp
	mov rsi, [rbp + 0x10]
	xor rax, rax
atoi_1:
	cmp [rsi],byte '0'
	jb atoi_2	
	cmp [rsi],byte '9'
	ja atoi_2
	mov rcx, 10	
	mul rcx 
	mov cl, [rsi]
	sub cl, '0'	
	add rax, rcx
	inc rsi
	jmp atoi_1	
atoi_2:
	mov rsp, rbp
	pop rbp
	ret	; value store in rax
gets:	;gets(s) 
	push rbp
	mov rbp, rsp
	mov rsi, [rbp+0x10]			
	;get char from input		
gets_1:	
	mov rax, 0
	mov rdi, 0
	mov rdx, 1
	syscall	
	;kiem tra ki tu xuong dong		
	mov al, [rsi]
	inc rsi
	cmp al, byte 0xa			
	jne gets_1

	mov rsp, rbp
	pop rbp	
	ret			
		
printf: ;printf(s)
	push rbp
	mov rbp, rsp
	; tinh do dai xau s
	mov rax, [rbp+0x10]		
	push rax				
	call strlen
	add rsp, 0x8
	;sys_write	
	mov rdx, rax 
	mov rax, 1
	mov rdi, 1 
	mov rsi, [rbp+0x10]
	syscall

	mov rsp, rbp
	pop rbp
	ret
