section .data
cifra db "cifra.txt", 0x0
decifra db "decifra.txt", 0x0

section .bss
	entrada: resb 20

section .text
global _start
_start:

; instrução para ler o arquivo "cifra.txt"
	mov eax, 5
	mov ebx, cifra
	mov ecx, 0
	mov edx, 0
	int 80h

; guardar o valor retirado do arquivo na variável entrada
	mov ebx, eax
	mov eax, 3
	mov ecx, entrada
	mov edx, 20
	int 80h

	mov edx, eax 	; mover o tamanho da string lida de eax para edx
	mov eax, 0 	; limpando
	mov esi, 0 	;inicia o contador com 0

loop:
	cmp esi, edx 			; compara o tamanho da string com o contador
	je gravar 			; se forem iguais, pula para gravar a string no arquivo "decifra.txt"
	cmp byte[entrada+esi], 109 	; compara o byte na posição esi da string entrada com o valor ASCII 109 (m)
	jg volta 			; se o byte for maior que 109 isso significa que ao aplicar a cifra de césar 13 ele vai dar a volta no alfabeto
	add byte[entrada+esi], 13 	; caso o byte seja menor ou igual a 109, basta apenas adicionar 13 ao valor do byte
	inc esi 			; incrementa o contador
jmp loop 

volta: 					; caso seja uma letra maior que m
	sub byte[entrada+esi], 109 	; subtrai 109 do byte
	add byte[entrada+esi], 96 	; adiciona 96 ao byte. Ao seguir essas duas ordens, o byte dá a volta no alfabeto
	inc esi 			; incrementa o contador
jmp loop 				; volta para o loop

gravar:
	; fecha o arquivo "cifra.txt"
	mov eax, 6
	int 80h

; guarda o tamanho da string na pilha pra ser usado depois
	push edx

; cria o arquivo "decifra.txt"
	mov eax, 8
	mov ebx, decifra
	mov ecx, 0
	mov edx, 0
	int 80h

; imprime a string entrada no arquivo "decifra.txt"
	mov ebx, eax
	mov eax, 4
	mov ecx, entrada
	pop edx ; recuperando o tamanho da string
	dec edx ; decrementando
	int 80h

; fecha o arquivo "decifra.txt"
	mov ebx, eax
	mov eax, 6
	int 80h

mov eax, 1
mov ebx, 0
int 80h
