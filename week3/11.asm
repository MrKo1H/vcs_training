section .data
	newline db "", 0xa, 0x0
	menu db 0xa, "1.ADD", 0xa, "2.SUB", 0xa, "3.MUL", 0xa, "4.DIV", 0xa, 0x0
	error db "error div 0",0xa, 0
section .bss
	input resb 1024
	choice resb 10
section .text
	global _start
_start:
	mov rbp, rsp	
	sub rsp, 8 
_start_1:
	; print menu	
	push menu	
	call printf
	add rsp, 0x8	
	; get choice 	
	push choice 
	call gets
	add rsp, 8
	; convert choice to integer
	push choice	 	
	call atoi
	add rsp, 8
	
	cmp rax, 1
	jne _start_3 
	call _add
	jmp _start_2
_start_3:
	cmp rax, 2
	jne _start_4
	call _sub
	jmp _start_2	
_start_4:	
	cmp rax, 3	
	jne _start_5	
	call _mul
	jmp _start_2
_start_5:	
	cmp rax, 4	
	jne _start_2
	call _div
_start_2:
	mov rcx, 2
	loopnz _start_1	
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
	sub rsp, 8
	;malloc(20)
	push 20
	call malloc
	add rsp, 0x8 	
	mov r8, rax
	add r8, 20 
	mov qword [rbp-8], 0
	mov rax, [rbp+0x10]	
	add rax, 0
	jns itoa_1
	mov qword [rbp-8], 1	
	mov r11, -1
	mul r11 
itoa_1:	
	mov rcx, 10
	xor rdx, rdx
	div rcx 
	mov [r8], dl
	add [r8], byte '0'		
	dec r8
	test rax, rax	
	jnz itoa_1
	cmp [rbp-8], byte 1
	jne itoa_2		
	mov byte [r8], '-'			
	dec r8
itoa_2:
	mov rax, r8 
	inc rax
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
	sub rsp, 8
	mov rsi, [rbp + 0x10]
	mov qword [rbp-8], 1
	cmp [rsi], byte '-'			
	jne atoi_3	
	mov qword [rbp-8], -1	
	inc rsi
atoi_3:	
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
	mov r8, [rbp-8]
	xor rdx, rdx
	mul r8		
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

_add:
	push rbp
	mov rbp, rsp
	sub rsp,0x10 
	push input
	call gets
	add rsp, 8
	
	push input
	call atoi
	add rsp, 8
	
	mov [rbp-0x8], rax	
	jmp add_1
add_2:
	inc rsi
add_1:
	mov r11b, [rsi]
	cmp r11b, '-'
	je add_3	
	sub r11b, '0'
	js add_2
	sub r11b, 10
	jns add_2
	
add_3:
	push rsi
	call atoi
	add rsp, 8

	add rax, [rbp-8]

	push rax 
	call printn
	add rsp,8
	leave
	ret
_sub:
	push rbp
	mov rbp, rsp
	sub rsp,0x10 
	push input
	call gets
	add rsp, 8
	
	push input
	call atoi
	add rsp, 8
	
	mov [rbp-0x8], rax	
	jmp sub_1 
sub_2:
	inc rsi
sub_1:
	mov r11b, [rsi]
	cmp r11b, '-'
	je sub_3
	sub r11b, '0'
	js sub_2 
	sub r11b, 10
	jns sub_2 
	
sub_3:
	push rsi
	call atoi
	add rsp, 8
	
	mov [rbp-0x10], rax	
	mov rax, [rbp-8]
	sub rax, [rbp-0x10]	
	
	push rax 
	call printn
	add rsp, 8
	leave
	ret
_mul:
	push rbp
	mov rbp, rsp
	sub rsp,0x10 
	push input
	call gets
	add rsp, 8
	
	push input
	call atoi
	add rsp, 8
		
	mov [rbp-0x8], rax	
	jmp mul_1 
mul_2:
	inc rsi
mul_1:
	mov r11b, [rsi]
	cmp r11b, '-'
	je mul_3
	sub r11b, '0'
	js mul_2 
	sub r11b, 10
	jns mul_2 
	
mul_3:
	push rsi
	call atoi
	add rsp, 8
	mov r8, rax
		
	xor rdx, rdx
	mov rax, [rbp-8]		
	mul r8
			
	push rax 
	call printn
	add rsp, 8
	leave
	ret
_div:
	push rbp
	mov rbp, rsp
	sub rsp,0x18 
	push input
	call gets
	add rsp, 8
	
	push input
	call atoi
	add rsp, 8
	
	mov [rbp-0x8], rax	
		
	jmp div_1 
div_2:
	inc rsi
div_1:
	mov r11b, [rsi]
	cmp r11b, '-'
	je div_5
	sub r11b, '0'
	js div_2
	sub r11b, 10
	jns div_2 
	
div_5:
	push rsi
	call atoi
	add rsp, 8
	
	test rax, rax			
	jnz div_4
	push error
	call printf
	jmp div_3
div_4:	
	mov r8, rax
	mov rax, [rbp-0x8]
	cqo
	idiv r8	
	push rax 
	call printn
	add rsp, 8
div_3:
	leave
	ret

