org 0x500 			;aqui a gente mudou o org pra onde começa esse programa. no boot1 a gente da jump pra ca
jmp 0x0000:start

mensagem1 db 'Carregando as operacoes do sistema...', 13, 10, 0 		;(carriage return, pula linha e 0 no fim)
mensagem2 db 'Concluindo uns ajustes...', 13, 10, 0
mensagem3 db 'Inicializando o sistema operacional...', 13, 10, 0
mensagem4 db 'Pronto!', 13, 10, 0

limpaTela:
	;; Codigo para limpar a tela
		mov dx, 0 ; Set the cursor to top left-most corner of screen
        mov bh, 0      
        mov ah, 0x2
        int 0x10
        mov cx, 2000 ; print 2000 chars
        mov bh, 0
        mov bl, 10 ; //black bg, light green fg
        mov al, 0x20 ; blank char
        mov ah, 0x9
        int 0x10
        mov dx, 0 ; Set cursor to top left-most corner of screen
        mov bh, 0      
        mov ah, 0x2
        int 0x10
ret

imprime:

	mov al,[si] 					;carrega si em al
	inc si
	cmp al, 0 						;se al=0, entao acabaram os digitos de si
	je fim 							;se acabou, entao acabamos de imprimir
	mov ah, 0eh 					;padrao para impressao
	int 10h 						;interrupcao de video para escrever na tela
	mov ah, 86h						;função de espera na BIOS, espera um intervalo de microsegundos
	mov cx, 1						;mudar pra 1
	mov dx, 2
	int 15h
	jmp imprime

fim:
	ret
	
start:

	xor ax, ax 
	mov ds, ax
	
reset:

	mov ah,0		;resetar os drivers de disco
	mov dl,0		;floppy disk pq usou dd no script
	int 13h			;interrupção de acesso ao disco
	jc reset		;em caso de erro, tenta de novo
	
	call delay
	
	call limpaTela
	
	xor si, si
	mov si, mensagem1
	call imprime 			;imprimindo mensagem1
	
	call delay
	
	xor si, si
	mov si, mensagem2
	call imprime 			;imprimindo mensagem2

	call delay
	
	xor si, si
	mov si, mensagem3
	call imprime			;imprimindo mensagem3
	
	call delay
	
	xor si, si
	mov si, mensagem4
	call imprime 			;imprimindo mensagem4

	mov ax,0x7e0	;inicio do kernel.asm
	mov es,ax
	xor bx,bx		;posição = es<<1+bx 	
	jmp load
	
delay:
	mov ah, 86h
	mov cx, 20		
	xor dx, dx
	mov dx, 40	
	int 15h	
	ret

	;				;carregar da memoria o kernel
load:
	mov ah, 0x02	;comando de ler setor do disco
	mov al, 20		;quantidade de setores ocupados por kernel
	mov ch,0		;trilha 0
	mov cl,3		;vai comecar a ler do setor 3
	mov dh,0		;cabeca 0
	mov dl,0		;drive 0
	int 13h			;interrupcao de disco
	jc load			;deu erro, tenta de novo

break:	
	jmp 0x7e00		;passa pro kernel
	
	;Fim do código. 	
	

