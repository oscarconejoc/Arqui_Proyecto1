section .data						;Declaracion de variables conocidas
	inv: db "inventario.txt",0			;Variable para acceder a inventario.txt
	cfg: db "config.ini",0				;Variable para acceder a config.ini
	msg_error: db 'Error en Not Found', 0xa		;Mensaje de error
	msg_len: equ $-msg_error			;Longitud de mensaje de error
	;Partes para armar codigo de color
	esc: db 0x1b,'['				
	semi: db ';'
	end: db 'm'
	nl: db 10   ; '\n'
	frutas_count: equ 4				;Longitud de arreglo de punteros
	; Reset Code: Resets terminal colors to default
    	reset_color db 0x1b, "[0m"
    	reset_color_len equ $ - reset_color



section .bss
	buf_inv resb 2048 				;Variable a la que le cae el contenido de inventario.txt
	buf_cfg resb 1024				;Variable a la que le cae el contenido de config.ini

	bar_char resb 1					;Variable que almacena los caracteres ASCII del caracter de barra
	color_barra resb 2				;Variable que almacena el primer codigo de color
	color_fondo resb 2				;Variable que almacena el segundo codigo de color
	manzanas resb 10				;Guarda la palabra manzanas:
	peras resb 7					;Guarda la palabra peras:
	naranjas resb 10				;Guarda la palabra naranjas:
	kiwis resb 7					;Guarda la palabra kiwis:
	cantidad_manzanas resb 2			;Guarda la cantidad de manzanas en ASCII
	cantidad_peras resb 1				;Guarda la cantidad de peras en ASCII
	cantidad_naranjas resb 2			;Guarda la cantidad de naranjas en ASCII
	cantidad_kiwis resb 1				;Guarda la cantidad de kiwis en ASCII
	entero_manzanas resb 1				;Guarda la cantidad de manzanas en entero
	entero_peras resb 1				;Guarda la cantidad de peras en entero
	entero_naranjas resb 1				;Guarda la cantidad de naranjas en entero
	entero_kiwis resb 1				;Guarda la cantidad de kiwis en entero

	frutas resq 4					;Arreglo para punteros
	str_color resb 8  				;Variable de codigo de color completo

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
find_colon0:							;Esta rutina recorre el documento config.ini hasta encontrar ':'
	mov al, [rsi]						;Esto lo hace mediante [rsi] que apunta a la primera direccion de la variable buf_cfg que contiene toda ka informacion
	cmp al,0						;Compara a 0 para saber si la variable esta vacia. Error de lectura
	je not_found						;hace el salto si el documento esta vacio o se llega al final
	cmp al, ':'						;Compara a la posicion actual con ':'
	je found0						;Si se encuentra se llama a la rutina found0
	inc rsi							;De no encontrarse se aumenta rsi para ahora analizar la siguiente posicion
	jmp find_colon0						;Se salta al principio lograr el loop hasta encontrar ':'

found0: 							;Se encarga de obtener la informacion despues del ':' y almacenarla en la variable correcta
	inc rsi							;La informacion esta en la posicion despues de ':', se aumenta uno para estar en la informacion
	mov al, [rsi]
	mov [bar_char], al					;Se almacena el byte en bar_char que contiene la informacion del caracter de la barra
	inc rsi
	jmp find_colon1						;Una vez que se saca el byte. Se procede a la siguiente linea

not_found:							;Rutina en caso de error. Solamente imprime el mensaje de error
	mov rax,1
	mov rdi,1
	mov rsi, msg_error
	mov rdx, msg_len
	jmp done0

find_colon1:							;Esta rutina es igual a find_colon0. solo que ahora continua en la direccion que dejo found0.
	mov al, [rsi]						;Hace la misma logica solo que ahora se busca extraer el primer codigo de color
        cmp al,0
        je not_found
	cmp al, ':'
	je found1
        inc rsi
        jmp find_colon1

found1:								;Igual que found0
	inc rsi							;Ahora extrae dos bytes para el codigo de color
        mov al, [rsi]
        mov [color_barra], al
	inc rsi
        mov al, [rsi]
        mov [color_barra+1], al
	inc rsi
        jmp find_colon2						;Salta al analisis de la siguiente linea

find_colon2:							;Hace lo mismo que find_colon1
        mov al, [rsi]						;Ahora busca el segundo codigo de color
        cmp al,0
        je not_found
        cmp al, ':'
        je found2
        inc rsi
        jmp find_colon2

found2:								;Igual que found1
        inc rsi							;Extrae 2 bytes correspondientes al segundo codigo de color
        mov al, [rsi]
        mov [color_fondo], al
        inc rsi
        mov al, [rsi]
        mov [color_fondo+1], al
        inc rsi
        jmp done0

copy_z:								;Rutina para copiar una variable a otra
  .loop:
        mov al, [rsi]						;Extrae el valor de la primera posicion de rsi
        mov [rdi], al						;Guarda el valor extraido en la primera posicion de rdi
        inc rsi							;incrementa a la siguiente posicion rsi y rdi
        inc rdi
        dec rcx							;Decrementa el valor de rcx
        jnz .loop						;hace si no es cero. Asi se pasa completamente la informacion de rsi a rdi
    ret




fruta_encontrada0: 						;Busca la primera fruta para extraer el nombre y guardarlo en una variable
 .loop:
	mov al, [rsi]
        cmp al,0
        je not_found
        cmp al, ':'						;Similarmente a find_colon esta funcion compara el valor actual a ':'
        je .fin							;Solamente que en este caso se quiere lo que esta antes de ';'
        mov [manzanas + r12], al				;Guarda los valores en la posicion actual siempre y cuando no sea ':'
        inc r12							;Si se encuentra un ':' se salta a .fin
        inc rsi
        jmp .loop

 .fin:								;Termina de acomodar la variable
        mov byte[manzanas + r12], ':'				;Le agrega ':' para mantener formato
        inc r12
	mov byte[manzanas + r12], 0				;Le agrega un 0 al final para demarcar el final de la variable
        inc rsi
        jmp .cambiar_linea					;Se va al final de linea

 .cambiar_linea:						;Aqui se busca continuar hasta cambiar de linea al encontrar un '\n'
        mov al, [rsi]						
	cmp al,0
        je .salir
        cmp al, 10          ; '\n'
        je  .salir
        inc rsi
        jmp .cambiar_linea					;loop hasta llegar al cambio de linea

 .salir:
        inc rsi							;Se incrementa en uno la direccion para estar despues del cambio de linea
        ret



fruta_encontrada1:						;Funciona igual que fruta_encontrada0
 .loop:								;Solamente que continua en la direccion rsi que dejo la rutina pasada
        mov al, [rsi]
        cmp al,0
        je not_found
        cmp al, ':'
        je .fin
        mov [peras+ r12], al					;Extrae la segunda fruta
        inc r12
        inc rsi
        jmp .loop

 .fin:								;Termina formato de variable
        mov byte[peras + r12], ':'
	inc r12
	mov byte[peras + r12], 0
	inc rsi
        jmp .cambiar_linea

 .cambiar_linea:						;Cambia de linea
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


fruta_encontrada2:						;Funciona igual que fruta_encontrada0
 .loop:								;Solamente que continua en la direccion rsi que dejo la rutina pasada
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



fruta_encontrada3:						;funciona igual que fruta_encontrada0
 .loop:								;Solamente que continua en la direccion rsi que dejo la rutina pasada
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


find_cantidad0:							;Recorre el contenido de inventario.txt pero ahora busca la cantidad de frutas en ASCII
 .loop:								;Misma logica que find_colon
        mov al, [rsi]
        cmp al,0						;Compara hasta encontrar ':'
        je not_found
        cmp al, ':'
        je .found						;Cuando lo hace salta a .found
        inc rsi
        jmp .loop

 .found:							;found guarda los datos de cantidad en ASCII de la misma manera que se hizo en found0
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

find_cantidad1:							;Igual que find_cantidad0 
 .loop:								;Continua en la direccion que deja la rutina pasada de rsi
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

find_cantidad2:							;Igual que find_cantidad0
 .loop:								;Continua en la direccion que deja la rutina pasada de rsi
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


find_cantidad3:							;Igual que find_cantidad0
 .loop:								;Continua en la direccion que deja la rutina pasada de rsi
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

ascii_to_int:							;Como se menciono anteriormente las cantidades salen en ASCII
    	xor rax, rax            ; acumulador = 0		;Esta rutina busca cambiar el valor ASCII a entero
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


ordenar_frutas:							;Algoritmo de ordenamiento. Se utiliza el principio de Bubble Sort para comparar la primera letra de cada fruta
     	mov r8d, frutas_count    ; r8d = n			;Donde n es la cantidad de frutas diferente, n = 4
    	dec r8d                  ; outer = n-1
 .outer_loop:
    	xor edi, edi             ; i = 0
 .inner_loop:
    	mov rsi, [frutas + rdi*8]          ; frutas[i]		;Se toma la posicion i del arrelgo
    	mov rdx, [frutas + rdi*8 + 8]      ; frutas[i+1]	;Se toma la posicion i+1 del arreglo

    	mov al, [rsi]             ; primer letra de frutas[i]	;Se carga la primera letra de la variable a la que apunta el puntero
    	mov bl, [rdx]             ; primer letra de frutas[i+1]	;Se carga la primera letra de la variable pero ahora de la posicion i+1

    	cmp al, bl						;Compara las dos letras
    	jbe .no_swap						;Salta si son iguales o al es menor a bl 	;No se necesita intercambiar posiciones

    	; swap punteros
    	mov rax, rsi						;Si se hace el cambio se utiliza rax como registro intermedio para hacer el cambio
    	mov [frutas + rdi*8], rdx
    	mov [frutas + rdi*8 + 8], rax

.no_swap:
    	inc edi
    	cmp edi, r8d              				; mientras i < outer
    	jb .inner_loop

    	dec r8d
    	jnz .outer_loop
    	ret

strlen:								;Rutina que obtiene la longitud de una variable str
    	xor rax, rax						;Reset de valor rax
 .len_loop:
    	cmp byte [rsi+rax], 0					;Compara a 0
    	je  .done						;Si es cero ya se recorrio la variable completamente
    	inc rax							;Contiene el valor de la longitud
    	jmp .len_loop
 .done:
    	ret

print_z:							;Rutina imprime una variable que no se sabe actualmente. Es para imprimir los nombres dentro del arreglo de punteros
    	push rsi            					; guardar puntero
    	call strlen         					; calcula longitud en RAX
    	pop rsi             					; recupera puntero
    	mov rdx, rax        					; longitud
    	mov rax, 1          					; syscall write
    	mov rdi, 1          					; fd = stdout
    	syscall
    	ret

imprimir_frutas:						;Rutina de impresion final. Imprime las frutas y sus cantidades en el formato deseado
    	xor  ebx, ebx                				; i = 0
 .next:
    	cmp  ebx, frutas_count					;Compara ebx a frutas_count. Esto para saber cuantas veces hacerlo. Ya que frutas count = 4
    	jae  .done						;Cuando se llegue a la 4 iteracion se termina
    	mov  rsi, [frutas + rbx*8]				;Se pasa la direccion del puntero de interes a rsi
    	call print_z						;Se llama a print_z para imprimir. Como no se sabe cual variable va a ser. Se necesita hacer de esta manera
	call imprimir_cantidad					;Llama a imprimir_cantidad para imprimir la barra y la cantidad de la fruta de la iteracion actual
    	mov  eax,1						;Se imprime el cambio de linea '/n'
    	mov  edi,1
    	lea  rsi, [rel nl]
    	mov  edx,1
    	syscall
    	inc  ebx						;inc ebx para subir el numero de la iteracion
    	jmp  .next						;loop
 .done:
    	ret

imprimir_cantidad:						;Imprime la barra, el color y la cantidad de la fruta asociada 
	xor r8d, r8d						;reset de r8d
	mov al, [rsi]						;Se obtiene la primera letra de la fruta de la iteracion
	mov r12, rsi						;El valor de rsi se almacena en r12 para ser recuperado mas adelante
	cmp al, 'k'						;Compara a la primera letra con 'k'
	je .kiwis						;Si es 'k' se salta a la rutina para kiwis
	cmp al, 'm'						;Compara a la primera letra con 'm'
	je .manzanas						;Si es 'm' se salta a la rutina para manzanas
	cmp al, 'n'						;Compara a la primera letra con 'n'
	je .naranjas						;Si es 'n' se salta a la rutina de naranjas
	cmp al, 'p'						;Compara a la primera letra con 'p'
	je .peras						;Si es 'p' se salta a la rutina para peras

 .kiwis:
	;Cambio de Color
        mov rax,1
        mov rdi,1
        mov rsi,str_color
        mov rdx,8
        syscall

	;Se hace un bucle de impresion para la cantidad de kiwis
	mov ecx, 5
	cmp r8d, ecx
	je .donekiwis
	;Impresion de caracter de barra
        mov rax,1
        mov rdi,1
        mov rsi,bar_char
        mov rdx,1
        syscall
	inc r8d
	jmp .kiwis

 .donekiwis:							;reset de color e impresion de cantidad
	; --- Reset the terminal color to default ---
        mov rax, 1
        mov rdi, 1
        mov rsi, reset_color
        mov rdx, reset_color_len
        syscall

	;Impresion de numero de kiwis
        mov rax,1
        mov rdi,1
        mov rsi, cantidad_kiwis
        mov rdx,1
        syscall
	mov rsi, r12
	ret

.manzanas:
	;Cambio de Color
        mov rax,1
        mov rdi,1
        mov rsi,str_color
        mov rdx,8
        syscall

	;Se hace un bucle de impresion para la cantidad de manzanas
        mov ecx, 12
        cmp r8d, ecx
        je .donemanzanas
        ;Impresion de caracter de barra
        mov rax,1
        mov rdi,1
        mov rsi,bar_char
        mov rdx,1
        syscall
        inc r8d
        jmp .manzanas

 .donemanzanas:							;reset de color e impresion de cantidad
	; --- Reset the terminal color to default ---
        mov rax, 1
        mov rdi, 1
        mov rsi, reset_color
        mov rdx, reset_color_len
        syscall

        ;Impresion de numero de manzanas
        mov rax,1
        mov rdi,1
        mov rsi, cantidad_manzanas
        mov rdx,2
        syscall
	mov rsi, r12
        ret

.naranjas:
	;Cambio de Color
        mov rax,1
        mov rdi,1
        mov rsi,str_color
        mov rdx,8
        syscall

	;Se hace un bucle de impresion para la cantidad de naranjas
        mov ecx, 25
        cmp r8d, ecx
        je .donenaranjas
        ;Impresion de caracter de barra
        mov rax,1
        mov rdi,1
        mov rsi,bar_char
        mov rdx,1
        syscall
        inc r8d
        jmp .naranjas

 .donenaranjas:							;reset de color e impresion de cantidad
	; --- Reset the terminal color to default ---
        mov rax, 1
        mov rdi, 1
        mov rsi, reset_color
        mov rdx, reset_color_len
        syscall

        ;Impresion de numero de naranjas
        mov rax,1
        mov rdi,1
        mov rsi, cantidad_naranjas
        mov rdx,2
        syscall
	mov rsi, r12
        ret
.peras:
	;Cambio de Color
        mov rax,1
        mov rdi,1
        mov rsi,str_color
        mov rdx,8
        syscall

	;Se hace un bucle de impresion para la cantidad de peras
        mov ecx, 8
        cmp r8d, ecx
        je .doneperas
        ;Impresion de caracter de barra
        mov rax,1
        mov rdi,1
        mov rsi,bar_char
        mov rdx,1
        syscall
        inc r8d
        jmp .peras

 .doneperas:							;reset de color e impresion de cantidad
	; --- Reset the terminal color to default ---
        mov rax, 1
        mov rdi, 1
        mov rsi, reset_color
        mov rdx, reset_color_len
        syscall

        ;Impresion de numero de peras
        mov rax,1
        mov rdi,1
        mov rsi, cantidad_peras
        mov rdx,1
        syscall
	mov rsi, r12
        ret

	





done0:

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
	


	;FIN
	mov rax,60
	mov rdi,0
	syscall			;Retorno de memoria

