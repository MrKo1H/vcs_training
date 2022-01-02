section .data
	format1 db '%d', 0	
	nhapn db 'nhap n=',0
	format2 db '%d', 0

section .text
	global start
	extern _scanf
	extern _printf
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
