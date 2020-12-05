section .data
va db 0AH
vaL equ $-va
pula db 0AH
pulal equ $-pula

section .bss
num: resd 1	; numero que a pessoa vai digitar
finito: resd 1

section .text
global _start
_start:

mov eax, 3	; lendo do teclado a string
mov ebx, 1
mov ecx, num
mov edx, 10
int 80h

sub eax, 1	; deixando o tamanho exato da string
mov esi, eax	; colocando no contador o tam da string
mov ecx, 1	; vai ser o rapaz que vai se tornar 10, 100....
mov edx, 0	; limpando acumulador
mov ebx, 0	; limpando auxiliar

mov ebx, eax 	; passando o que tem no eax para ebx


ida: 			; convertendo de string para int
dec ebx 		; decremento eax para ficar do tamanho certo
xor eax, eax 		; limpando o registrador
mov al, [num + ebx] 	; pegando o bit mais a direita
sub eax, '0' 		; convertendo
imul eax, ecx 		; multiplicando o numero convertido por 1, 10, 100...
add edx, eax 		; somando o que tem no acumulador com o novo numero convertido
imul ecx, 10 		; multiplicando por 10 para mudar a casa da string
dec esi 		; decremento o contador
cmp esi, 0 		; comparando pq qnd o contador chegar a zero, acabou os numeros
jne ida

mov eax, edx 		; passando para eax o int convertido que estava em edx
mov esi, 0 		; limpando o contador



mov ebx, eax 	; movendo o int de eax pra ebx
loop:
inc esi 	; incrementa o contador
mov eax, 0
mov eax, esi 	; move esi para eax
mul esi 	; multiplica eax por esi (esi ao quadrado) e guarda em eax
cmp eax, ebx 	; compara eax com ebx
jle loop 	; se eax for menor ou igual a ebx, volta pro loop.
sub esi, 1 	; se eax for maior, subtrai 1 do contador (pra chegar a menor raiz quadrada mais próxima e não a maior)
mov eax, 0
mov eax, esi 	; move o valor de esi (raiz quadrada) pra eax para ser convertido de volta em string
mov esi, 0



voltaida: 	; colocando na pilha os valores
mov ecx, 10 	; colocando no divisor 10
mov edx, 0 	; resto
idiv ecx 	; dividindo eax por ecx
push edx 	; colocando o resto na pilha
inc esi 	; incrementando o contador
cmp eax, 0 	; enquanto o eax n for zero continua o loop
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

;pular linha no fim

mov eax, 4
mov ebx, 1
mov ecx, pula
mov edx, pulal
int 80h

mov eax, 1
mov ebx, 0
int 80h
