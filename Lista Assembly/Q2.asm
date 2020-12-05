section .data
	msg db 'Digite o primeiro numero', 0AH ; declarando e armazenando a frase
	msgL equ $-msg ; descobrindo o tam de msg
	msg2 db 'Digite o segundo numero', 0AH
	msgL2 equ $-msg2
	msg3 db 'Digite o operacao que deseja fazer', 0AH
	msgL3 equ $-msg3
	resul db 'Resultado: '
	resulL equ $-resul
	oresto db 'Resto: '
	orestoL equ $-oresto
	pula db 0AH
	pulaL equ $-pula

section .bss
	op1: resd 1 	; reservando 4 bytes 
	op2: resd 1 
	num: resd 1		
	ope: resd 1 
	finito: resd 1  
	resto: resd 1
	aux: resd 1

section .text
	global _start
	_start:
		mov eax, 4 	; escrevendo primeira mensagem
		mov ebx, 1 	; colocando no console
		mov ecx, msg 	; informacao de msg
		mov edx, msgL	; tam da informacao
		int 80h 	; invocando uma interrupcao

		mov eax, 3 	; lendo primeiro numero
		mov ebx, 1 	; pegando do teclado
		mov ecx, num
		mov edx, 10
		int 80h

		call convStrInt
		mov [op1], edx

		mov eax, 4 	; escrevendo segunda mensagem
		mov ebx, 1 	; colocando no console
		mov ecx, msg2 	; informacao de msg
		mov edx, msgL2	; tam da informacao
		int 80h 	; invocando uma interrupcao

		mov eax, 3 	; lendo segundo numero
		mov ebx, 1 	; pegando do teclado
		mov ecx, num
		mov edx, 10
		int 80h
		
		call convStrInt
		mov [op2],edx

		mov eax, 4 	; escrevendo terceira mensagem
		mov ebx, 1 	; colocando no console
		mov ecx, msg3 	; informacao de msg
		mov edx, msgL3	; tam da informacao
		int 80h 	; invocando uma interrupcao

		mov eax, 3 	; lendo primeiro numero
		mov ebx, 1 	; pegando do teclado
		mov ecx, ope
		mov edx, 1
		int 80h

		mov al, [ope] 	; colocando no reg esi a escolha do usuario
		cmp eax, '+' 	; compara para saber se + foi o que o usuario escolheu
		je soma 	; pula para o label soma se for igual
		cmp eax, '-' 	; o mesmo eh valido para o resto
		je sub
		cmp eax, '*'
		je mul
		cmp eax, '/'
		je div

				; soma
		soma:
		xor eax, eax
		xor edx, edx
		mov eax, [op1] 		; colocando no reg o operando
		mov edx, [op2]
		add edx, eax 		; somando - o resultado fica em edx
		push edx 		; salvando o valor de edx
		call iresul
		pop edx 		; recuperando o valor de edx
		call convIntStr 	; convertendo em string o inteiro
		call imprimirLinha 	; pulando uma linha

		jmp fim 		; pulando para onde finaliza o programa
		
	
				; subtracao

		sub:
		xor eax, eax
		xor edx, edx
		mov edx, [op1] 		; colocando no reg o operando
		mov eax, [op2]
		sub edx, eax 		; somando - o resultado fica em edx
		push edx 		; salvando o valor de edx
		call iresul	
		pop edx 		; recuperando o valor de edx
		call convIntStr 	; convertendo em string o inteiro
		call imprimirLinha 	; pulando uma linha

		jmp fim 		; pulando para onde finaliza o programa			
		
		

				; multiplicacao

		mul:
		xor eax, eax
		xor edx, edx
		mov eax, [op1] 		; colocando no reg o operando
		mov edx, [op2]
		imul edx, eax 		; multiplicando - o resultado fica em edx
		push edx 		; salvando o valor de edx
		call iresul
		pop edx 		; recuperando o valor de edx
		call convIntStr 	; convertendo em string o inteiro
		call imprimirLinha 	; pulando uma linha

		jmp fim 		; pulando para onde finaliza o programa



				; divisao

		div:
		xor eax, eax
		xor ecx, ecx
		xor edx, edx
		mov eax, [op1] 		; colocando no reg o operando
		mov ecx, [op2]
		idiv ecx 		; dividindo - o resultado fica em eax e o resto em edx
		mov [resto], edx 	; passando o resto para resto		
		push eax 		; salvando o valor de ecx
		call iresul
		pop eax 		; recuperando o valor de ecx
		mov edx, eax 		; passando para edx o resultado da divisao
		call convIntStr 	; convertendo em string o inteiro
		call imprimirLinha 	; pulando uma linha
		call iresto
		xor edx, edx
		mov edx, [resto]
		call convIntStr 	; convertendo em string o inteiro
		call imprimirLinha 	; pulando uma linha
	
		jmp fim 		; pulando para onde finaliza o programa


			; metodos/funcoes

imprimirLinha:
		mov eax, 4 	; escrevendo primeira mensagem
		mov ebx, 1 	; colocando no console
		mov ecx, pula 	; informacao de msg
		mov edx, pulaL	; tam da informacao
		int 80h 	; invocando uma interrupcao

ret


convStrInt:
	sub eax, 1 	; deixando o tamanho exato da string
	mov esi, eax 	; colocando no contador o tam da string
	mov ecx, 1 	; vai ser o rapaz que vai se tornar 10, 100....
	mov edx, 0 	; limpando acumulador
	mov ebx, 0 	; limpando auxiliar

	mov ebx, eax 	; passando o que tem no eax para ebx


	ida:  	; convertendo de string para int
		dec ebx 		; decremento eax para ficar do tamanho certo
		xor eax, eax 		; limpando o registrador
		mov al, [num + ebx] 	; pegando o bit mais a direita
		sub eax, '0' 		; convertendo
		imul eax, ecx 		; multiplicando o numero convertido por 1, 10, 100...
		add edx, eax 		; somando o que tem no acumulador com o novo numero convertido
		imul ecx, 10 		; multiplicando por 10 para mudar a casa da string
		dec esi 		; decremento o contador
	cmp esi, 0 			; comparando pq qnd o contador chegar a zero, acabou os numeros
	jne ida

ret

convIntStr:

	mov eax, edx 	; passando para eax o int convertido que estava em edx
	mov esi, 0 	; limpando o contador

	voltaida: 		; colocando na pilha os valores
		mov ecx, 10 	; colocando no divisor 10
		mov edx, 0 	; resto
		idiv ecx 	; dividindo eax por ecx
		push edx 	; colocando o resto na pilha
		inc esi 	; incrementando o contador
	cmp eax, 0 		; enquanto o eax n for zero continua o loop
	jne voltaida


	volta: 				; tirando da pilha para converter
		mov eax, 0 		; limpando o registrador
		pop eax 		; tirando da pilha e colocando em eax
		add eax, '0' 		; convertendo
		mov [finito], eax 	; colocando na variavel
		mov eax, 4 		; imprimindo a string
		mov ebx, 1
		mov ecx, finito
		mov edx, 1
		int 80h
		dec esi 		; decrementando o contador
		cmp esi, 0 		; enquanto o contador for diferente de zero
	jne volta

ret

iresul:
		mov eax, 4
		mov ebx, 1
		mov ecx, resul
		mov edx, resulL
		int 80h
ret


iresto:
		mov eax, 4
		mov ebx, 1
		mov ecx, oresto
		mov edx, orestoL
		int 80h


ret
		fim:	mov eax, 1
		mov ebx, 0
		int 80h
		

		

