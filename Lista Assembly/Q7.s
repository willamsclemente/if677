org 0x7c00 
jmp 0x0000:start

msg db " (Programa encerrado com sucesso!)"
	msgL equ $-msg

start:
	
	xor ax, ax 	; zerando o ds pq eh a partir dele q o processador busca os dados utilizados no prog
	mov ds, ax 

	xor cx, cx 	; limpando o contador de zero
	xor si, si 	; limpando o contador de um
	


	xor bx, bx 	; limpando o reg q sera um aux
	
loop:
	mov ah, 0h 	; ler caracter
	int 16h 
	
	mov ah, 0Eh 	; esta aqui para aparecer na tela (preta) o que a pessoa esta digitando
	int 10h	

	cmp al, 13 	; saber se eh enter
	je enter

	cmp al, 8 	; saber se eh backspace
	je apagar
	
	cmp al, 17 	; saber se a pessoa vai finalizar o programa
	je finito

	jmp loop

enter:
	mov al, 10 	; pulando uma linha
	mov ah, 0Eh
	int 10h
	
	mov al, 13 	; comecar no inicio da nova linha
	mov ah, 0Eh
	int 10h

jmp loop

apagar:
	mov al, 32 	; imprimindo um espaco p apgar a letra q quer apagar
	mov ah, 0Eh
	int 10h

	mov al, 8 	; voltando o cursor para ficar onde apagagou
	mov ah, 0Eh
	int 10h

jmp loop


finito:
	xor bx, bx 	; limpando o reg q sera um aux
	
fimzinho: 		; imprimindo char por char da string 
	mov al, [msg+bx]; passando a letra q vou imprimir na hora do loop, usando bx como o q vai indicar ql das letras de msg eh
	mov ah, 0Eh
	int 10h
	inc bx 		; incrementando o aux q tmb servira p dizer se a string terminou ou n
	cmp bx, msgL
	jne fimzinho 	; enquanto n for igual o tam, ele vai imprimir a string	


times 510-($-$$) db 0	
dw 0xaa55
