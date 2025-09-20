section .data
	inv: db "inventario.txt",0
	cfg: db "config.ini",0
	msg_error: db 'Error en Not Found', 0xa
	msg_len: equ $-msg_error
	esc: db 0x1b,'['
	semi: db ';'
	end: db 'm'


section .bss
	buf_inv resb 2048
	buf_cfg resb 1024
	ntt	resb 32
	bar_char resb 3
	color_barra resb 2
	color_fondo resb 2

	pos_uno resq 1
	pos_dos resq 1
	str_color resb 8  

section .text
	global _start

_start:
	;Abrir config.ini 
	mov rax, 2
	mov rdi, cfg
	mov rsi, 0
	mov rdx,0
	syscall

	;Leer config.ini
	push rax
	mov rdi, rax
	mov rax, 0
	mov rsi, buf_cfg
	mov rdx, 1024
	syscall

	;cerrar config.ini
	mov rax, 3
	pop rdi
	syscall



	;Abrir inventario.txt 
        mov rax, 2
        mov rdi, inv
        mov rsi, 0
        mov rdx,0
        syscall

        ;Leer inventario.txt
        push rax
        mov rdi, rax
        mov rax, 0
        mov rsi, buf_inv
        mov rdx, 2048
        syscall

        ;cerrar inventario.txt
        mov rax, 3
        pop rdi
        syscall




	;Procesamiento de config.ini
	mov rsi, buf_cfg
find_colon0:
	mov al, [rsi]
	cmp al,0
	je not_found
	cmp al, ':'
	je found0
	inc rsi
	jmp find_colon0

found0: 
	inc rsi
	mov al, [rsi]
	mov [bar_char], al
	inc rsi
	mov al, [rsi]
	mov [bar_char+1], al
	inc rsi
	mov al, [rsi]
	mov [bar_char+2], al
	inc rsi
	jmp find_colon1

not_found:
	mov rax,1
	mov rdi,1
	mov rsi, msg_error
	mov rdx, msg_len
	jmp done0

find_colon1:
	mov al, [rsi]
        cmp al,0
        je not_found
	cmp al, ':'
	je found1
        inc rsi
        jmp find_colon1

found1:
	inc rsi
        mov al, [rsi]
        mov [color_barra], al
	inc rsi
        mov al, [rsi]
        mov [color_barra+1], al
	inc rsi
        jmp find_colon2

find_colon2:
        mov al, [rsi]
        cmp al,0
        je not_found
        cmp al, ':'
        je found2
        inc rsi
        jmp find_colon2

found2:
        inc rsi
        mov al, [rsi]
        mov [color_fondo], al
        inc rsi
        mov al, [rsi]
        mov [color_fondo+1], al
        inc rsi
        jmp done0

copy_z:
  .loop:
        mov al, [rsi]
        mov [rdi], al
        inc rsi
        inc rdi
        dec rcx
        jnz .loop
    ret

strlen:
    mov rax, rdi
  .len_loop:
    cmp byte [rax], 0
    je  .len_done
    inc rax
    jmp .len_loop
  .len_done:
    sub rax, rdi
    ret





done0:
	;PRUEBAS de IMPRESION
	;mov rax,1
	;mov rdi,1
	;mov rsi,buf_cfg
	;mov rdx, 1024
	;syscall

	;PRUEBAS de IMPRESION
        ;mov rax,1
        ;mov rdi,1
        ;mov rsi,buf_inv
        ;mov rdx,2048
        ;syscall





	;Concatenacion de str para color
	lea rdi, [str_color]
	mov rsi, esc
	mov rcx, 2
	call copy_z
	mov rsi, color_barra
	mov rcx, 2
	call copy_z
	mov byte [rdi], ';'
	inc rdi
	mov rsi, color_fondo
	mov rcx, 2
	call copy_z
	mov byte [rdi], 'm'	













	;Cambio de Color
        mov rax,1
        mov rdi,1
        mov rsi,str_color
        mov rdx,8
        syscall
	

 	;Prueba de extraccion de dato
	mov rax,1
	mov rdi,1
	mov rsi,bar_char
	mov rdx,3
	syscall

	;Prueba de extraccion de dato
        mov rax,1
        mov rdi,1
        mov rsi,color_barra
        mov rdx,2
        syscall

	;Prueba de extraccion de dato
	mov rax,1
	mov rdi,1
	mov rsi,color_fondo
	mov rdx,2
	syscall

	

	;FIN
	mov rax,60
	mov rdi,0
	syscall

