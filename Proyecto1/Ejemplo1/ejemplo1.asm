section .data
	inv: db "inventario.txt",0
	cfg: db "config.ini",0
	msg_error: db 'Error en Not Found', 0xa
	msg_len: equ $-msg_error
	esc: db 0x1b,'['
	semi: db ';'
	end: db 'm'
	nl: db 10   ; '\n'
	frutas_count: equ 4
	; Reset Code: Resets terminal colors to default
    	reset_color db 0x1b, "[0m"
    	reset_color_len equ $ - reset_color



section .bss
	buf_inv resb 2048
	buf_cfg resb 1024
	ntt	resb 32
	bar_char resb 3
	color_barra resb 2
	color_fondo resb 2
	manzanas resb 10
	peras resb 7
	naranjas resb 10
	kiwis resb 7
	cantidad_manzanas resb 2
	cantidad_peras resb 1
	cantidad_naranjas resb 2
	cantidad_kiwis resb 1
	entero_manzanas resb 1
	entero_peras resb 1
	entero_naranjas resb 1
	entero_kiwis resb 1

	frutas resq 4
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




fruta_encontrada0: 
 .loop:
	mov al, [rsi]
        cmp al,0
        je not_found
        cmp al, ':'
        je .fin
        mov [manzanas + r12], al
        inc r12
        inc rsi
        jmp .loop

 .fin:
        mov byte[manzanas + r12], ':'
        inc r12
	mov byte[manzanas + r12], 0
        inc rsi
        jmp .cambiar_linea

 .cambiar_linea:
        mov al, [rsi]
	cmp al,0
        je .salir
        cmp al, 10          ; '\n'
        je  .salir
        inc rsi
        jmp .cambiar_linea

 .salir:
        inc rsi
        ret



fruta_encontrada1:
 .loop:
        mov al, [rsi]
        cmp al,0
        je not_found
        cmp al, ':'
        je .fin
        mov [peras+ r12], al
        inc r12
        inc rsi
        jmp .loop

 .fin:
        mov byte[peras + r12], ':'
	inc r12
	mov byte[peras + r12], 0
	inc rsi
        jmp .cambiar_linea

 .cambiar_linea:
        mov al, [rsi]
	cmp al,0
        je .salir
        cmp al, 10          ; '\n'
        je  .salir
        inc rsi
        jmp .cambiar_linea

 .salir:
	inc rsi
	ret


fruta_encontrada2:
 .loop:
        mov al, [rsi]
        cmp al,0
        je not_found
        cmp al, ':'
        je .fin
        mov [naranjas + r12], al
        inc r12
        inc rsi
        jmp .loop

 .fin:
        mov byte[naranjas + r12], ':'
        inc r12
	mov byte[naranjas + r12], 0
        inc rsi
        jmp .cambiar_linea

 .cambiar_linea:
        mov al, [rsi]
        cmp al,0
        je .salir
        cmp al, 10          ; '\n'
        je  .salir
        inc rsi
        jmp .cambiar_linea

 .salir:
        inc rsi
        ret



fruta_encontrada3:
 .loop:
        mov al, [rsi]
        cmp al,0
        je not_found
        cmp al, ':'
        je .fin
        mov [kiwis+ r12], al
        inc r12
        inc rsi
        jmp .loop

 .fin:
        mov byte[kiwis + r12], ':'
        inc r12
	mov byte[kiwis + r12], 0
        inc rsi
        jmp .cambiar_linea

 .cambiar_linea:
        mov al, [rsi]
        cmp al,0
        je .salir
        cmp al, 10          ; '\n'
        je  .salir
        inc rsi
        jmp .cambiar_linea

 .salir:
        inc rsi
        ret


find_cantidad0:
 .loop:
        mov al, [rsi]
        cmp al,0
        je not_found
        cmp al, ':'
        je .found
        inc rsi
        jmp .loop

 .found:
        inc rsi
        mov al, [rsi]
        mov [cantidad_manzanas], al
        inc rsi
        mov al, [rsi]
        mov [cantidad_manzanas+1], al
        inc rsi
        jmp .salir

 .salir:
	ret 

find_cantidad1:
 .loop:
        mov al, [rsi]
        cmp al,0
        je not_found
        cmp al, ':'
        je .found
        inc rsi
        jmp .loop

 .found:
        inc rsi
        mov al, [rsi]
        mov [cantidad_peras], al
        inc rsi
        jmp .salir

 .salir:
        ret

find_cantidad2:
 .loop:
        mov al, [rsi]
        cmp al,0
        je not_found
        cmp al, ':'
        je .found
        inc rsi
        jmp .loop

 .found:
        inc rsi
        mov al, [rsi]
        mov [cantidad_naranjas], al
        inc rsi
        mov al, [rsi]
        mov [cantidad_naranjas+1], al
        inc rsi
        jmp .salir

 .salir:
        ret


find_cantidad3:
 .loop:
        mov al, [rsi]
        cmp al,0
        je not_found
        cmp al, ':'
        je .found
        inc rsi
        jmp .loop

 .found:
        inc rsi
        mov al, [rsi]
        mov [cantidad_kiwis], al
        inc rsi
        jmp .salir

 .salir:
        ret

ascii_to_int:
    	xor rax, rax            ; acumulador = 0
 .siguiente_digito:
    	mov al, [rsi]           ; lee un byte
    	cmp al, 0               ; fin de string?
    	je  .done
    	cmp al, 10              ; '\n'?
    	je  .done

    	sub al, '0'             ; convierte ASCII a valor (ej. '9'->9)
    	imul rax, rax, 10       ; acum = acum * 10
    	add rax, rdx            ; acum = acum + dígito

    	inc rsi
    	jmp .siguiente_digito

 .done:
    	ret


ordenar_frutas:
     	mov r8d, frutas_count    ; r8d = n
    	dec r8d                  ; outer = n-1
 .outer_loop:
    	xor edi, edi             ; i = 0
 .inner_loop:
    	mov rsi, [frutas + rdi*8]          ; frutas[i]
    	mov rdx, [frutas + rdi*8 + 8]      ; frutas[i+1]

    	mov al, [rsi]             ; primer letra de frutas[i]
    	mov bl, [rdx]             ; primer letra de frutas[i+1]
    	cmp al, bl
    	jbe .no_swap

    	; swap punteros
    	mov rax, rsi
    	mov [frutas + rdi*8], rdx
    	mov [frutas + rdi*8 + 8], rax

.no_swap:
    	inc edi
    	cmp edi, r8d              ; mientras i < outer
    	jb .inner_loop

    	dec r8d
    	jnz .outer_loop
    	ret

strlen:
    	xor rax, rax
 .len_loop:
    	cmp byte [rsi+rax], 0
    	je  .done
    	inc rax
    	jmp .len_loop
 .done:
    	ret

print_z:
    	push rsi            ; guardar puntero
    	call strlen         ; calcula longitud en RAX
    	pop rsi             ; recupera puntero
    	mov rdx, rax        ; longitud
    	mov rax, 1          ; syscall write
    	mov rdi, 1          ; fd = stdout
    	syscall
    	ret

imprimir_frutas:
    	xor  ebx, ebx                ; i = 0
 .next:
    	cmp  ebx, frutas_count
    	jae  .done
    	mov  rsi, [frutas + rbx*8]
    	call print_z
	call imprimir_cantidad
    	mov  eax,1
    	mov  edi,1
    	lea  rsi, [rel nl]
    	mov  edx,1
    	syscall
    	inc  ebx
    	jmp  .next
 .done:
    	ret

imprimir_cantidad:
	xor r8d, r8d
	mov al, [rsi]
	mov r12, rsi
	cmp al, 'k'
	je .kiwis
	cmp al, 'm'
	je .manzanas
	cmp al, 'n'
	je .naranjas
	cmp al, 'p'
	je .peras

 .kiwis:
	mov ecx, 5
	cmp r8d, ecx
	je .donekiwis
	;Impresion de caracter de barra
        mov rax,1
        mov rdi,1
        mov rsi,bar_char
        mov rdx,3
        syscall
	inc r8d
	jmp .kiwis

 .donekiwis:
	;Impresion de numero de kiwis
        mov rax,1
        mov rdi,1
        mov rsi, cantidad_kiwis
        mov rdx,1
        syscall
	mov rsi, r12
	ret

.manzanas:
        mov ecx, 12
        cmp r8d, ecx
        je .donemanzanas
        ;Impresion de caracter de barra
        mov rax,1
        mov rdi,1
        mov rsi,bar_char
        mov rdx,3
        syscall
        inc r8d
        jmp .manzanas

 .donemanzanas:
        ;Impresion de numero de kiwis
        mov rax,1
        mov rdi,1
        mov rsi, cantidad_manzanas
        mov rdx,2
        syscall
	mov rsi, r12
        ret

.naranjas:
        mov ecx, 25
        cmp r8d, ecx
        je .donenaranjas
        ;Impresion de caracter de barra
        mov rax,1
        mov rdi,1
        mov rsi,bar_char
        mov rdx,3
        syscall
        inc r8d
        jmp .naranjas

 .donenaranjas:
        ;Impresion de numero de kiwis
        mov rax,1
        mov rdi,1
        mov rsi, cantidad_naranjas
        mov rdx,2
        syscall
	mov rsi, r12
        ret
.peras:
        mov ecx, 8
        cmp r8d, ecx
        je .doneperas
        ;Impresion de caracter de barra
        mov rax,1
        mov rdi,1
        mov rsi,bar_char
        mov rdx,3
        syscall
        inc r8d
        jmp .peras

 .doneperas:
        ;Impresion de numero de kiwis
        mov rax,1
        mov rdi,1
        mov rsi, cantidad_peras
        mov rdx,1
        syscall
	mov rsi, r12
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

	

	;procesamiento de datos de inventario.txt
	mov rsi, buf_inv
	xor r12, r12
	call fruta_encontrada0

	xor r12, r12
	call fruta_encontrada1

	xor r12, r12
        call fruta_encontrada2

	xor r12, r12
        call fruta_encontrada3

	mov rsi, buf_inv
	call find_cantidad0
	
	call find_cantidad1
	call find_cantidad2
	call find_cantidad3
	
	;Ascii a enteros
	mov rsi, cantidad_manzanas
	call ascii_to_int
	mov [entero_manzanas], rax
	mov rsi, cantidad_peras
        call ascii_to_int
        mov [entero_peras], rax
	mov rsi, cantidad_naranjas
        call ascii_to_int
        mov [entero_naranjas], rax
	mov rsi, cantidad_kiwis
        call ascii_to_int
        mov [entero_kiwis], rax


	;Creando arreglo de punteros
	mov rax, manzanas
	mov [frutas + 0*8],rax

	mov rax, peras
        mov [frutas + 1*8],rax

	mov rax, naranjas
        mov [frutas + 2*8],rax

	mov rax, kiwis
        mov [frutas + 3*8],rax

	;Llamando a ordenar de forma alfabetica los punteros
	call ordenar_frutas
	
	;Imprimir inventario ordenado
	call imprimir_frutas
	

 	;Prueba de extraccion de dato
	;mov rax,1
	;mov rdi,1
	;mov rsi,bar_char
	;mov rdx,3
	;syscall

	;Prueba de extraccion de dato
        ;mov rax,1
        ;mov rdi,1
        ;mov rsi,color_barra
        ;mov rdx,2
        ;syscall

	;Prueba de extraccion de dato
	;mov rax,1
	;mov rdi,1
	;mov rsi,color_fondo
	;mov rdx,2
	;syscall

	;Prueba de extraccion de fruta
	;mov rax,1
	;mov rdi,1
	;mov rsi,manzanas
	;mov rdx,10
	;syscall

	;Prueba de extraccion de fruta
        ;mov rax,1
        ;mov rdi,1
        ;mov rsi,peras
        ;mov rdx,7
        ;syscall

	;Prueba de extraccion de fruta
        ;mov rax,1
        ;mov rdi,1
        ;mov rsi,naranjas
        ;mov rdx,10
        ;syscall

        ;Prueba de extraccion de fruta
        ;mov rax,1
        ;mov rdi,1
        ;mov rsi,kiwis
        ;mov rdx,7
        ;syscall

	;Prueba de Extraccionde de cantidad
	;mov rax,1
	;mov rdi,1
	;mov rsi, cantidad_manzanas
	;mov rdx,2
	;syscall

	;Prueba de Extraccionde de cantidad
        ;mov rax,1
        ;mov rdi,1
        ;mov rsi, cantidad_peras
        ;mov rdx,1
        ;syscall

	;Prueba de Extraccionde de cantidad
        ;mov rax,1
        ;mov rdi,1
        ;mov rsi, cantidad_naranjas
        ;mov rdx,2
        ;syscall

	;Prueba de Extraccionde de cantidad
        ;mov rax,1
        ;mov rdi,1
        ;mov rsi, cantidad_kiwis
        ;mov rdx,1
        ;syscall

	; --- Reset the terminal color to default ---
   	mov rax, 1
    	mov rdi, 1
    	mov rsi, reset_color
    	mov rdx, reset_color_len
    	syscall




	;FIN
	mov rax,60
	mov rdi,0
	syscall

