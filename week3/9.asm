section .data
	format1 db '%d', 0	
	nhapn db 'nhap n=',0
	format2 db '%d', 0

section .text
	global start
start:
	xor rbp, rbp
		
	; printf('nhap n=');
	push format1	
	call _printf
	add rsp, 0x8

	; scanf('%d');
	push format2	  
	call _scanf

	call exit
	
exit:
	mov rax, 1
	syscall		

strlen: ; strlen(s) return length of s
	push rbp
	mov rbp, rsp
	sub rsp, 0x8
	mov rsi, [rbp+0x10]
	jmp strlen_1						
strlen_2:
	add [rbp-0x8], byte 1  				
	inc rsi 
strlen_1:
	cmp [rsi], byte 0
	jne strlen_2 
	mov rax, [rbp+0x8]
	mov rsp, rbp
	pop rbp
	ret

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
	cmp [rsi], byte 0xa			
	je gets_2
	inc rsi		
gets_2: 
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
