section .data
	inv: db "inventario.txt",0
	cfg: db "config.ini",0
	
	;Datos para config
	en_caracter: db "caracter_barra:",0
	en_colorB: db "color_barra:",0
	en_colorF: db "color_fondo:",0
	len_en_caracter: equ $-en_caracter
	len_en_colorB: equ $-en_colorB
	len_en_colorF: equ $-en_colorF



section .bss
	buf_inv resb 2048
	buf_cfg resb 1024
	ntt	resb 32

	bar_ptr resq 1              ; puntero al caracter (en buf_cfg)
	bar_len resd 1              ; longitud en bytes del caracter
 	fg_code resd 1              ; color_barra
 	bg_code resd 1              ; color_fondo

section .text
	global _start

_start:
	;Abrir config.ini 
	mov rax, 2
	mov rdi, cfg
	mov rsi, 0
	syscall
	mov r12, rax

	;Leer config.ini
	mov rax, 0
	mov rdi, r12
	mov rsi, buf_cfg
	mov rdx, 1024
	syscall

	;cerrar config.ini
	mov rax, 60
	pop rdi
	syscall

	mov rax,1
	mov rdi,1
	mov rsi,buf_cfg
	mov rdx, 1024
