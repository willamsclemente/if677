section .data
m db 'Digite', 0AH
mL equ $-m
m2 db 'Resultado: '
m2L equ $-m2
m3 db 'Numero invalido'
m3L equ $-m3
pula db 0AH
pulaL equ $-pula


section .bss
num: resd 1
finito: resd 1

section .text
global _start
_start:

    mov eax, 4 		; pedindo para a pessoa digitar um numero
    mov ebx, 1
    mov ecx, m
    mov edx, mL
    int 80h

   comecando: 		; laco para que so feche o programa caso seja digitado q. A comparacao eh feita em conv
    call lendo 		; leio do teclado o q a pessoa digitar
    call conv 		; coverto para decimal e imprimo na tela
    call pulaLinha 	; pular linha
    jmp comecando

lendo:
    mov eax, 3 		; lendo do teclado a string
    mov ebx, 1
    mov ecx, num
    mov edx, 10
    int 80h
ret


iresul:
    mov eax, 4 		; imprimir resultado: na tela
    mov ebx, 1
    mov ecx, m2
    mov edx, m2L
    int 80h
ret

iinvalido: 
    mov eax, 4 		; imprimir numero invalido na tela
    mov ebx, 1
    mov ecx, m3
    mov edx, m3L
    int 80h
ret

pulaLinha:
    mov eax, 4 		; pular linha
    mov ebx, 1
    mov ecx, pula
    mov edx, pulaL
    int 80h
ret


conv:
    sub eax, 1 		; deixando o tamanho exato da string
    mov esi, eax 	; colocando no contador o tam da string
    mov ecx, 1 		; vai ser o rapaz que vai se tornar 10, 100....
    mov edx, 0 		; limpando acumulador
    mov ebx, 0 		; limpando auxiliar

    mov ebx, eax 	; passando o que tem no eax para ebx


    ida:  			; convertendo de string para int
        dec ebx 		; decremento eax para ficar do tamanho certo
        xor eax, eax 		; limpando o registrador
        mov al, [num + ebx] 	; pegando o bit mais a direita               
	sub eax, '0'                       
	cmp eax, 65 		; comparo para saber se eh q 
		je fim        	; se for, ja sai
	cmp eax, 22 		; se der maior que 15 eh pq eh uma letra invalida
            ja iinvalido 	; vai para invalido
        cmp eax, 17 		; se for um numero
           jb cont
        sub eax, 7 		; diminuindo 7 para ficar o numero exato da letra do hexadecimal
        cont:
        imul eax, ecx 		; multiplicando o numero convertido por 1, 16,...
        add edx, eax 		; somando o que tem no acumulador com o novo numero convertido
        imul ecx, 16 		; multiplicando por 16 para ficar a parte de 16^x
        dec esi 		; decremento o contador
    cmp esi, 0 			; comparando pq qnd o contador chegar a zero, acabou os numeros
    jne ida

    mov eax, edx 		; passando para eax o int convertido que estava em edx
    mov esi, 0 			; limpando o contador

	   push eax 	; salvando o valor de eax
 	   call iresul 	; imprimindo resultado: na tela
 	   pop eax 	; recuperando o valor de eax

    voltaida: 		; colocando na pilha os valores
        mov ecx, 10 	; colocando no divisor 10
        mov edx, 0 	; resto
        idiv ecx 	; dividindo eax por ecx
        push edx 	; colocando o resto na pilha
        inc esi 	; incrementando o contador
    cmp eax, 0 		; enquanto o eax n for zero continua o loop
    jne voltaida


    volta: 			; tirando da pilha para converter
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


fim:
mov eax, 1
mov ebx, 0
int 80h
