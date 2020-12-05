section .data
pula db 0AH
pulaL equ $-pula

section .data
msg db 'Digite o valor de x numero (para finalizar o programa, digite s)', 0AH
msgL equ $-msg
msg2 db 'Digite o valor de y numero (para finalizar o programa, digite s)', 0AH
msg2L equ $-msg2
msg3 db 'Resposta: ', 0AH
msg3L equ $-msg3

section .bss
num: resd 1
finito: resd 1
op1: resb 10
op2: resb 10

section .text
global _start
_start:

		xor eax, eax ; limpando
		xor ebx, ebx ; limpando
		xor ecx, ecx ; limpando
		xor edx, edx ; limpando

	mov eax, 4
	mov ebx, 1
	mov ecx, msg
	mov edx, msgL
	int 80h

	call lendoTeclado
	
	cmp byte[num+0], 115 ; comparo p saber se eh s, pq se for finaliza o prog
	je fim
	call convStrInt ; converto
	mov [op1], edx ; passo o resultado p op1
	
	mov eax, 4
	mov ebx, 1
	mov ecx, msg2
	mov edx, msg2L
	int 80h

	call lendoTeclado ; faco o msm p o segundo numero
	
	cmp byte[num+0], 115
	je fim
	call convStrInt
	mov [op2], edx
	

	mov eax, 4
	mov ebx, 1
	mov ecx, msg3
	mov edx, msg3L
	int 80h

		xor eax, eax ; limpando
		xor ebx, ebx ; limpando
		xor ecx, ecx ; limpando
		xor edx, edx ; limpando

	mov eax, [op1] ; passando o valor de x
	mov ecx, [op2] ; passando o valor de y


mdc:
	idiv ecx ; dividindo eax (x) por ecx (y) e colocando o resto em edx (n)
	xor eax, eax
	mov eax, ecx ; movendo o que tem em ecx para eax (x = y)
	xor ecx, ecx
	mov ecx, edx ; movendo o que tem em edx para ecx (y = n)
	xor edx, edx

cmp ecx, edx ; comparando se ecx = 0 (enquanto ecx nao for 0 -> y > 0, ja q n tem resto negativo)
jne mdc ; pular se n for zero

	call convIntStr
	call pulaLinha
	jmp _start


convStrInt:

	ida:  ; convertendo de string para int
		dec ebx ; decremento eax para ficar do tamanho certo
		xor eax, eax ; limpando o registrador
		mov al, [num + ebx] ; pegando o bit mais a direita
		cmp al, 45
		je cabei
		sub eax, '0' ; convertendo
		imul eax, ecx ; multiplicando o numero convertido por 1, 10, 100...
		add edx, eax ; somando o que tem no acumulador com o novo numero convertido
		imul ecx, 10 ; multiplicando por 10 para mudar a casa da string
		dec esi ; decremento o contador
		jmp cont

cabei:
	dec esi
cont:
	cmp esi, 0 ; comparando pq qnd o contador chegar a zero, acabou os numeros
	jne ida

ret



convIntStr:
	
	xor esi, esi ; limpando o contador

	voltaida: ; colocando na pilha os valores
		mov ecx, 10 ; colocando no divisor 10
		mov edx, 0 ; resto
		idiv ecx ; dividindo eax por ecx
		push edx ; colocando o resto na pilha
		inc esi ; incrementando o contador
	cmp eax, 0 ; enquanto o eax n for zero continua o loop
	jne voltaida


	volta: ; tirando da pilha para converter
		xor eax, eax ; limpando o registrador
		pop eax ; tirando da pilha e colocando em eax
		add eax, '0' ; convertendo
		mov [finito], eax ; colocando na variavel
		mov eax, 4 ; imprimindo a string
		mov ebx, 1
		mov ecx, finito
		mov edx, 1
		int 80h
		dec esi ; decrementando o contador
		cmp esi, 0 ; enquanto o contador for diferente de zero
	jne volta

ret

lendoTeclado: ; leio e ja preparo p a conversao

	mov eax, 3
	mov ebx, 1
	mov ecx, num
	mov edx, 10
	int 80h

	sub eax, 1 ; deixando o tamanho exato da string
	mov esi, eax ; colocando no contador o tam da string
	mov ecx, 1 ; vai ser o rapaz que vai se tornar 10, 100....
	mov edx, 0 ; limpando acumulador
	mov ebx, 0 ; limpando auxiliar

	mov ebx, eax ; passando o que tem no eax para ebx

ret

pulaLinha:
		mov eax, 4
		mov ebx, 1
		mov ecx, pula
		mov edx, pulaL
		int 80h
ret

fim:

mov eax, 1
mov ebx, 0
int 80h
