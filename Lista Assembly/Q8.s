org 0x7c00 
jmp 0x0000:start

	msg db "Entrada:"
	msgL equ $-msg
	msg2 db "Saida:"
	msg2L equ $-msg2

start:
	
	xor ax, ax 	; zerando o ds pq eh a partir dele q o processador busca os dados utilizados no prog
	mov ds, ax 

	xor cx, cx 	; limpando o contador de impar
	xor si, si 	; limpando o contador de par
	
; vai funcionando assim q a pessoa escreve, entao se apagar, n da certo
; o programa vai imprimir primeiramente os impares e depois os pares

	xor bx, bx 	; limpando o reg q sera um aux
	
entrada: 		; imprimindo char por char da string 
	mov al, [msg+bx]; passando a letra q vou imprimir na hora do loop, usando bx como o q vai indicar ql das letras de msg eh
	mov ah, 0Eh
	int 10h
	inc bx 		; incrementando o aux q tmb servira p dizer se a string terminou ou n
	cmp bx, msgL
	jne entrada 	; enquanto n for igual o tam, ele vai imprimir a string
	
	mov al, 10 	; pulando uma linha
	mov ah, 0Eh
	int 10h
	
	mov al, 13 	; comecar no inicio da nova linha
	mov ah, 0Eh
	int 10h

loop:
	mov ah, 0h 	; ler caracter
	int 16h 
	
	mov ah, 0Eh 	; esta aqui para aparecer na tela (preta) o que a pessoa esta digitando - facilita a comparacao digitado - resposta
	int 10h	

	cmp al, 13 	; compara para saber se acabou a string - carriage return (\r em c)
	je impressao
	
	xor dx, dx 	; limpando
cmp al, '0' 		; compara p saber se eh zero, pq se for, a gente vai ignorar
je loop
	sub ax, 48 	; convertendo para numero
	xor bx, bx 	; limpando
	mov bx, 2 
	div bx 		; dividindo por 2 o que tem em ax para saber se tem resto ou n
cmp dx, 0 		; se n tiver resto, eh par. Se n, eh impar
je par
jmp impar
	
; incrementa o contador a partir da divisao em cima
	par: inc si
jmp loop

	impar: inc cx
jmp loop

impressao:
	
	mov al, 10 	; pulando uma linha
	mov ah, 0Eh
	int 10h
	
	mov al, 13 	; comecar no inicio da nova linha
	mov ah, 0Eh
	int 10h

	xor bx, bx 	; limpando
	
saida:
	mov al, [msg2+bx] 	; imprimindo do msm jeito que entrada
	mov ah, 0Eh
	int 10h
	inc bx
	cmp bx, msg2L
	jne saida
	
	mov al, 10 		; pulando uma linha
	mov ah, 0Eh
	int 10h
	
	mov al, 13 		; comecar no inicio da nova linha
	mov ah, 0Eh
	int 10h
	
	
	add cx, '0' 		; convertendo p poder imprimir
	mov ax, cx 
	mov ah, 0Eh 		; imprimindo o contador de impar
	int 10h
	
	mov al, 10 		; pulando uma linha
	mov ah, 0Eh
	int 10h
	
	mov al, 13 		; comecar no inicio da nova linha
	mov ah, 0Eh
	int 10h
	
	add si, '0' 		; convertendo p poder imprimir
	mov ax, si
	mov ah, 0Eh 		; imprimindo o contador de par
	int 10h


times 510-($-$$) db 0	
dw 0xaa55
