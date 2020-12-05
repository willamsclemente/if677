org 0x7c00 
jmp 0x0000:start

	msg db "Entrada: "
	msgL equ $-msg
	msg2 db "Saida: "
	msg2L equ $-msg2
	msg3 db " '0' e "
	msg3L equ $-msg3
	msg4 db " '1'"
	msg4L equ $-msg4

start:
	
	xor ax, ax 	; zerando o ds pq eh a partir dele q o processador busca os dados utilizados no prog
	mov ds, ax 

	xor cx, cx 	; limpando o contador de zero
	xor si, si 	; limpando o contador de um
	
; vai funcionando assim q a pessoa escreve, entao se apagar, n da certo

	xor bx, bx 	; limpando o reg q sera um aux
	
entrada:		; imprimindo char por char da string 
	mov al, [msg+bx]; passando a letra q vou imprimir na hora do loop, usando bx como o q vai indicar ql das letras de msg eh
	mov ah, 0Eh
	int 10h
	inc bx 		; incrementando o aux q tmb servira p dizer se a string terminou ou n
	cmp bx, msgL
	jne entrada 	; enquanto n for igual o tam, ele vai imprimir a string
	
	
loop:
	mov ah, 0h 	; ler caracter
	int 16h 
	
	mov ah, 0Eh 	; esta aqui para aparecer na tela (preta) o que a pessoa esta digitando - facilita a comparacao digitado - resposta
	int 10h	

	cmp al, 13 	; compara para saber se acabou a string - carriage return (\r em c)
	je impressao
	
	xor dx, dx 	; limpando
cmp al, '0' 		; compara p saber se eh zero, para incrementar o certo
je zero
cmp al, '1' 		; compara p saber se eh um, para incrementar o certo
je um
jmp impressao
	
; incrementa o contador a partir da divisao em cima
	um: inc si
jmp loop

	zero: inc cx
jmp loop

impressao:
	
	mov al, 10 	; pulando uma linha
	mov ah, 0Eh
	int 10h
	
	mov al, 13	; comecar no inicio da nova linha
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
	
	push si 		; salvando o valor se si
	mov ax, cx
	call convIntStr 	; imprimindo o contador de zero
	
	xor bx, bx 		; limpando
izero:
	mov al, [msg3+bx] 	; imprimindo do msm jeito que entrada
	mov ah, 0Eh
	int 10h
	inc bx
	cmp bx, msg3L
	jne izero

	pop si 			; recuperando o valor de si
	mov ax, si
	call convIntStr 	; imprimindo o contador de um

	xor bx, bx 		; limpando
ium:
	mov al, [msg4+bx] 	; imprimindo do msm jeito que entrada
	mov ah, 0Eh
	int 10h
	inc bx
	cmp bx, msg4L
	jne ium
jmp fim

convIntStr:

	mov si, 0 		; limpando o contador

	voltaida: 		; colocando na pilha os valores
		mov cx, 10 	; colocando no divisor 10
		mov dx, 0 	; resto
		idiv cx 	; dividindo eax por ecx
		push dx 	; colocando o resto na pilha
		inc si 		; incrementando o contador
	cmp ax, 0 		; enquanto o eax n for zero continua o loop
	jne voltaida


	volta: 			; tirando da pilha para converter
		mov ax, 0 	; limpando o registrador
		pop ax 		; tirando da pilha e colocando em eax
		add ax, '0' 	; convertendo
		mov ah, 0Eh
		int 10h
		dec si 		; decrementando o contador
		cmp si, 0 	; enquanto o contador for diferente de zero
	jne volta
ret

fim:

times 510-($-$$) db 0	
dw 0xaa55
