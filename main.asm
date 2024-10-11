;4- Fa?a uma rotina que receba um valor em AX 
;e calcule o seu fatorial. Retorne o valor em AX.
.model small

.stack 100H   ; define uma pilha de 256 bytes (100H)

.data 
    ; Constantes para pular linha
    CR EQU 13
    LF EQU 10
   
    memoria_video equ 0A000h

    ; Será que não é melhor guardar, nas primeiras duas posições de cada desenho, o seu tamanho?
     nave db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh, 0, 0, 0, 0
          db   0,   0, 0Fh, 0Fh, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          db   0,   0, 0Fh, 0Fh, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          db   0,   0, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0, 0, 0, 0, 0, 0
          db   0,   0, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh
          db   0,   0, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0Fh, 0, 0, 0, 0, 0, 0
          db   0,   0, 0Fh, 0Fh, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          db   0,   0, 0Fh, 0Fh, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
          db 0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh,0Fh, 0, 0, 0, 0
          
    posicao_nave dw ?
         
         
    logo_inicio db "       __ __    ______           ", CR, LF
                db "      / // /___/ __/ /____ _____ ", CR, LF
                db "     /    /___/\ \/ __/ _ `/ __/ ", CR, LF
                db "    /_/\_\   /___/\__/\_,_/_/    ", CR, LF
                db "          ___       __           __ ", CR, LF
                db "         / _ \___ _/ /________  / / ", CR, LF
                db "        / ___/ _ `/ __/ __/ _ \/ /  ", CR, LF
                db "       /_/   \_,_/\__/_/  \___/_/   $", CR, LF
                
    botao_start db "Start$"
.code  

; Funcao para desenhar os objetos
; SI: Posicao inicial desenho na memoria
; DI: Posicao do primeiro pixel do desenho na tela
; DX: Quantidade de linhas do elemento
; AX: Largura do elemento
DESENHA_ELEMENTO proc
    push dx
    push cx
    push di
    push si
    push ax
    push bx
    
DESENHA_ELEMENTO_LOOP:
    ; Devo armazenar a largura no AX pois o CX ? decrementado com o movsb, e eu preciso da largura 
    ; para cada linha desenhada.
    mov cx, ax
    rep movsb
    dec dx
    
    ; Aqui define quantas colunas deve pular para desenhar a pr?xima linha.
    xor bx, bx
    mov bx, 320
    sub bx, ax
    
    ; Pula a quantidade correta de colunas para come?ar o desenho da pr?xima linha.
    add di, bx
    cmp dx, 0
    jnz DESENHA_ELEMENTO_LOOP
    
    pop si
    pop di
    pop cx
    pop dx
    pop ax
    pop bx
    ret
endp

; DI: Posição do primeiro pixel do desenho na tela
; AH: Quantidade de colunas a apagar (largura do elemento)
; DX: Quantidade de linhas a apagar (altura do elemento)
APAGAR_ELEMENTO proc
    push dx
    push cx
    push di
    push si
    push ax
    push bx

    xor cx, cx
    mov al, 0h          
APAGAR_ELEMENTO_LOOP:
    mov cl, ah 
    rep stosb           

    ; Aqui define quantas colunas deve pular para desenhar a pr?xima linha.
    xor bx, bx
    mov bx, 320
    sub bx, 1
    
    ; Pula a quantidade correta de colunas para come?ar o desenho da pr?xima linha.
    add di, bx
    dec dx

    jnz APAGAR_ELEMENTO_LOOP

    pop si
    pop di
    pop cx
    pop dx
    pop ax
    pop bx
    ret
endp

INICIO:   
    mov ax, @data
    mov ds, ax
    mov ax, memoria_video
    mov es, ax
    mov DI, AX
    mov SI, AX
    
    mov AH, 00H
    mov AL, 13H
    int 10H
    
    xor ax, ax
    xor bx, bx

   ; Calcula a primeira posição da nave no meio da tela  
    mov bx, 100 ; Y
    mov ax, 320 ; Tamanho do vídeo
    mul bx
    add ax, 160 ; X
    
    mov [posicao_nave], AX
    MOV DI, AX
    
    mov SI, offset nave
    mov DX, 9
    mov AX, 15
    call DESENHA_ELEMENTO
    
    int 16h
    
    MOV DI, [posicao_nave]
    mov DX, 9
    mov AH, 15
    call APAGAR_ELEMENTO
    
    int 16h
    mov AH, 01H
    
end INICIO 
