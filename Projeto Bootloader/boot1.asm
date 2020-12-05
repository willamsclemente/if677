org 0x7c00 			;define onde o programa espera ser carregado na memória

					;no modo real não há sections, o código começa a ser executado no começo do arquivo
					;só estão disponíveis os registradores de 16bits.

jmp 0x0000:start 

start:

	; nunca se esqueca de zerar o ds,
	; pois apartir dele que o processador busca os 
	; dados utilizados no programa.
	xor ax, ax
	mov ds, ax

	;Início do seu código

reset:
	mov ah,0		;resetar os drivers de disco
	mov dl,0		;floppy disk pq usou dd no script
	int 13h			;interrupção de acesso ao disco
	jc reset		;em caso de erro, tenta de novo

	mov ax,0x50		;0x50<<1 + 0 = 0x500, que eh o inicio do boot2.asm
	mov es,ax
	xor bx,bx		;posição = es<<1+bx 	

	;; carregar da memoria o boot2
load:
	mov ah, 0x02	;comando de ler setor do disco
	mov al,1		;quantidade de setores ocupados por boot2
	mov ch,0		;trilha 0
	mov cl,2		;setor 2
	mov dh,0		;cabeca 0
	mov dl,0		;drive 0
	int 13h
	jc load			;deu erro, tenta de novo

break:	
	jmp 0x500		;vai para o boot2
	;Fim do código. 
	

times 510-($-$$) db 0		; preenche o resto do setor com zeros 
dw 0xaa55					; coloca a assinatura de boot no final
							; do setor (x86 : little endian)
