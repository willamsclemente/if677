section .data
sort db "sort.txt", 0x0
la db 'oi', 0AH
laL equ $-la
isaida db 'Saida: '
isaidaL equ $-isaida
pula db 0AH
pulaL equ $-pula

section .bss
entrada: resb 500
tam: resb 100
qnt: resb 2
array: resd 32
aux: resb 10
num: resb 10
finito: resb 10
aux2: resb 2

section .text
global _start
_start:

; instrução para ler o arquivo "sort.txt"
	mov eax, 5
	mov ebx, sort
	mov ecx, 0
	mov edx, 0
	int 80h

; guardar o valor retirado do arquivo na variável entrada
	mov ebx, eax
	mov eax, 3
	mov ecx, entrada
	mov edx, 500
	int 80h

	dec eax  ; decrementando p ficar do tam certo	
	mov edx, eax ; mover o tamanho da string lida de eax para edx
		xor eax, eax ; limpando
		xor esi, esi ; inicia o contador com 0
		xor ecx, ecx ; limpando
		xor edi, edi ; limpando
	cmp edx, 1 ; compara p saber se eh zero, se for n tem nenhum numero p ordenar
	je zero

tamanho:
	mov cl, [entrada+esi] ; vamos pegar caracter por caracter da entrada
	cmp cl, 32 ; comparo se eh espaco, pq se for, acabou o numero
	je cont
	mov [qnt+esi], ecx ; passando p a variavel a qntdade de numeros q vai ter
	inc esi ; incrementa o contador
jmp tamanho 

cont:
	inc esi ; para sair do espaco
	
		xor ecx, ecx ; limpando
		xor ebx, ebx ; limpando
		xor edi, edi ; limpando o indice do array

numeros:

	cmp esi, edx ; compara o tamanho da string com o contador. Qnd for igual, terminou o ultimo numero
	je acabou ; so q como n tem espaco dps do ultimo numero, precisamos add ele no array

	mov cl, [entrada+esi] ; comparando p saber se eh espaco, pq se for, acabou o numero
	cmp cl, 32
	je acabou
	
	mov [aux+ebx], ecx ; passando caracter por caracter p a variavel caracter
	inc ebx ; incrementando o cusor de aux
	inc esi ; incrementa o contador
	
jmp numeros

acabou:
	push esi ; salvando o valor de esi
	push edx ; salvando o valor de edx

	mov esi, ebx ; passando o valor do cursor de aux p a conversao
	mov ecx, 1 ; passando 1 para a conversao (multiplica por 1, 10, 100...)
		xor edx, edx ; limpando
	call convStrInt ; convertendo para inteiro
	mov [array + edi], edx ; colocando no array o resultado da conversao
	add edi, 4 ; a gente anda de 4 em 3 no array
	
	pop edx ; recuperando o valor de edx
	pop esi ; recuperando o valor de esi
		xor ebx, ebx ; limpando
	inc esi ; incrementando o cursor de entrada
		xor ecx, ecx ; limpando
	mov [aux], ecx ; limpando aux
cmp esi, edx ; comparando p saber se acabou ou n a entrada
jge parteSort ; se acabou, posso ir ordenar
jmp numeros ; se nao acabou, volto a pegar numeros


parteSort:
		xor eax, eax ; limpando o indice i
		xor ebx, ebx ; limpando o indice j
		xor ecx, ecx ; limpando o auxiliar
		xor esi, esi ; limpando o auxiliar
		xor edx, edx ; limpando o tamanho do array para o for1
	mov edx, edi ; passando a quantidades de numeros q colocamos no array
	sub edx, 4 ; diminuo 4 para comparar length - 1
	sub eax, 4 ; diminuo 4 pq no primeiro for preciso add 4
	
	for1:
		add eax, 4 ; i++
		cmp eax, edx ; comparo i < length - 1 (>= o oposto), aki faremos com -4 pq andamos no array de 4 em 4 	
		jge impressao
	mov ebx, eax ; iniciando j = i
	add ebx, 4 ; terminando de iniciar j = i + 4
		for2:
			mov ecx, [array + eax] ; passando p ecx array[i]
			mov esi, [array	+ ebx] ; passando p esi array[j]
			cmp ecx, esi ; se for menor, troca - to fazendo na ordem decrescente p imprimir crescente
			jl change
			jmp comparacao
		change:
			mov [array + eax], esi ; trocando as posicoes
			mov [array + ebx], ecx ; trocando as posicoes
	
		comparacao:
			add ebx, 4 ; j++
			cmp ebx, edi ; comparo j < length
		jl for2
		jmp for1

impressao:
	call impressaoSaida ; imprimir saida
		xor ebx, ebx ; limpando
		xor ecx, ecx ; limpando
		xor edx, edx ; limpando
		xor esi, esi ; limpando
		sub edi, 4 ; como no fim sempre add 4, temos q decrementar
print:
		xor eax, eax ; limpando
	mov eax, [array + edi] ; passando p eax os valores do array (do ultimo p o primeiro)
	call convIntStr ; convertendo p string
	call espaco ; colocando um espaco entre os numeros
	sub edi, 4 ; decrementando o cursor do array
	cmp edi, -4 ; enquanto o cursor for maior q -4 tem coisa p imprimir, afinal existe numero na posicao 0
	jg print
	jmp fim

convStrInt:

	ida:  ; convertendo de string para int
		dec ebx ; decremento eax para ficar do tamanho certo
		xor eax, eax ; limpando o registrador
		mov al, [aux + ebx] ; pegando o bit mais a direita
		sub eax, '0' ; convertendo
		imul eax, ecx ; multiplicando o numero convertido por 1, 10, 100...
		add edx, eax ; somando o que tem no acumulador com o novo numero convertido
		imul ecx, 10 ; multiplicando por 10 para mudar a casa da string
		dec esi ; decremento o contador
	cmp esi, 0 ; comparando pq qnd o contador chegar a zero, acabou os numeros
	jne ida
ret

convIntStr:
	mov esi, 0 ; limpando o contador

	voltaida: ; colocando na pilha os valores
		mov ecx, 10 ; colocando no divisor 10
		mov edx, 0 ; resto
		idiv ecx ; dividindo eax por ecx
		push edx ; colocando o resto na pilha
		inc esi ; incrementando o contador
	cmp eax, 0 ; enquanto o eax n for zero continua o loop
	jne voltaida


	volta: ; tirando da pilha para converter
		mov eax, 0 ; limpando o registrador
		pop eax ; tirando da pilha e colocando em eax
		add eax, '0' ; convertendo
		mov [finito], eax ; colocando na variavel
		mov eax, 4 ; imprimindo a string
		mov ebx, 1
		mov ecx, finito
		mov edx, 10
		int 80h
		dec esi ; decrementando o contador
		cmp esi, 0 ; enquanto o contador for diferente de zero
	jne volta


ret

espaco:
	mov ecx, ' '
	mov [num], ecx

	mov eax, 4
	mov ebx, 1
	mov ecx, num
	mov edx, 1
	int 80h

ret

impressaoSaida:
	mov eax, 4
	mov ebx, 1
	mov ecx, isaida
	mov edx, isaidaL
	int 80h

ret

pulaLinha:

	mov eax, 4
	mov ebx, 1
	mov ecx, pula
	mov edx, pulaL
	int 80h

ret

zero:
call impressaoSaida ; imprime saida

fim:
call pulaLinha ; pula linha

mov eax, 1
mov ebx, 0
int 80h

