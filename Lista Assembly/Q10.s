org 0x7c00 
jmp 0x0000:start

start:
	
	xor ax, ax 	; zerando o ds pq eh a partir dele q o processador busca os dados utilizados no prog
	mov ds, ax 

	xor cx, cx 	; limpando o contador
	
; vai funcionando assim q a pessoa escreve, entao se apagar, n da certo

pilhaIda:
	mov ah, 0h 	; ler caracter
	int 16h 
	
	mov ah, 0Eh 	; esta aqui para aparecer na tela (preta) o que a pessoa esta digitando - facilita a comparacao digitado - resposta
	int 10h	

	cmp al, 13 	; compara para saber se acabou a string - carriage return (\r em c)
	je comecoResp
	
	push ax		; se n for o fim, coloca na pilha
	inc cx 		; incrementando o contador
	
	jmp pilhaIda
	
	
comecoResp:
	mov al, 13 	; a resposta vai comecar no inicio da nova linha
	mov ah, 0Eh 	; escrevendo
	int 10h
	
	mov al, 10 	; a resposta vai comecar em uma nova linha - p facilitar a comparacao do q foi digitado com a resposta
	mov ah, 0Eh 	; escrevendo
	int 10h
 
impressao:	
	pop ax 		; tiro da pilha 	
	mov ah, 0eh 	; escrevendo
	int 10h
	dec cx 		; decrementando o contador
cmp cx, 0 		; enquanto n for igual a zero o contador, continua o loop
jne impressao


times 510-($-$$) db 0	
dw 0xaa55


