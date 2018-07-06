; Jogo da Velha assembly 8086
data segment
	grid     			db 9  dup(0)
	name_p1  			db 25,?,'Player 1$',16 dup(0)
	name_p2  			db 25,?,'Player 2$',16 dup(0)
	skin_p1  			db 'X'
	skin_p2  			db 'O'
	colors   			db 0Fh, 0Fh, 0Fh
	player   			db 0
	win      			db 0
	str_name 			db "Nome do Jogador: $"
	string_inval	db "Nome de Jogador invalido!$"
	str_skin 			db "Escolha seu simbolo: $"
	simb_igual   	db "Simbolo igual do outro jogador!$"
	simb_inval		db "Simbolo invalido!$"
	str_cor  			db "Escolha a cor para seu simbolo",0Dh,0Ah,0Ah
	         			db "1 - Branca",  0Ah,0Dh
	         			db "2 - Vermelho",0Ah,0Dh
	         			db "3 - Verde",   0Ah,0Dh
	         			db "4 - Azul",    0Ah,0Dh
	         			db "5 - Amarelo", 0Ah,0Dh
	         			db "6 - Marrom",  0Ah,0Dh,0Ah
	         			db "Escolha sua cor: $"

	erro_cor     	db "Numero invalido!!",0Dh,0Ah,"Selecione a cor: $"
	tabuCor       db "Escolha a cor para o tabuleiro",0Dh,0Ah,0Ah
	              db "1 - Branca",  0Ah,0Dh
	              db "2 - Vermelho",0Ah,0Dh
	              db "3 - Verde",   0Ah,0Dh
	              db "4 - Azul",    0Ah,0Dh
	              db "5 - Amarelo", 0Ah,0Dh
	              db "6 - Marrom",  0Ah,0Dh,0Ah
	              db "Escolha a cor: $"

	newGameQuest  db "Jogar novamente ? (S ou s para sim, qualquer tecla para n�o ou...",0Dh,0Ah
								db " M ou m, para voltar ao menu): $"
	welcome       db "Jogo da Velha --- By Oz Elentok",0Dh,0Ah
	              db "Modificado por Julio Cesar, Caio Melo e Thales Lima$"

  newGamedraw   db "Aceita revanche ? (S para sim, qualquer tecla para n�o ou...",0Dh,0Ah
								db " M para voltar ao menu): $"
	tieMessage   	db "Ocorreu uma velha!$"
	winMessage   	db "O jogador vitorioso foi $"
	turnMessage 	db "Jogador $"
	turn         	db " sua vez: $"
	separator    	db "---|---|---$"
	enterLoc     	db "Selecione posicao para marcar (1-9)$"

	inDigitError 	db "ERROR!, Posicao ja foi marcada",0Dh,0Ah,"Nova posicao: $"
	inError      	db "ERROR!, Posicao nao definida",0Dh,0Ah,"Nova posicao: $"
	newline      	db 0Dh,0Ah,'$'
	menu         	db "------------   MENU   ------------",0Dh,0Ah,0Dh,0Ah,0Dh,0Ah
                db "1 - Inserir/Alterar nome do Jogador 1.",0Dh,0Ah
                db "2 - Inserir/Alterar nome do Jogador 2.",0Dh,0Ah
                db "3 - Escolher o simbolo e a cor do Jogador 1.",0Dh,0Ah
                db "4 - Escolher o simbolo e a cor do Jogador 2.",0Dh,0Ah
                db "5 - Escolher a cor do tabuleiro.",0Dh,0Ah
                db "6 - Iniciar jogo.",0Dh,0Ah
                db "7 - Sair.",0Dh,0Ah,0Dh,0Ah,"opcao: $"
ends
stack segment
	dw 128 dup(0)
ends

code segment
start:
	mov AX, data
	mov ds, AX
	mov es, AX
	print_menu:
    	call clearScreen
			; Printa o Menu
    	lea  DX, menu
    	call printString
			; Chama função para pegar opção do Menu e trata-la
      call arg_menu
	newGame:
    	call initiateGrid
    	mov player, 10b; 2dec
    	mov win, 0
    	mov CX, 9
	gameAgain:
			call clearScreen
			lea DX, welcome
			call printString
			lea DX, newline
			call printString
			call printString
			lea DX, enterLoc
			call printString
			lea DX, newline
			call printString
			call printString
			call printGrid
			mov AL, player
			cmp AL, 1
			je p2turn
			; previous player was 2
			shr  player, 1b; 0010b --> 0001b;
			lea  DX, newline
			call printString
			lea  DX, turnMessage
			call printString
			lea  DX, name_p1
			add  DX, 2
			call printString
			lea  DX, turn
			call printString
			jmp  endPlayerSwitch
	p2turn:; previous player was 1
			shl  player, 1b; 0001b --> 0010b;
			lea  DX, newline
			call printString
			lea  DX, turnMessage
			call printString
			lea  DX, name_p2
			add  DX, 2
			call printString
			lea  DX, turn
			call printString

	endPlayerSwitch:
			call getMove; bx will point to the right board postiton at the end of getMove
			mov DL, player
			cmp DL, 1
			jne p2move
			mov DL, skin_p1
			jmp contMoves
	p2move:
			mov DL, skin_p2
	contMoves:
			mov [bx], DL
			cmp CX, 5 ; no need to check before the 5th turn
			jg  noWinCheck
			call checkWin
			cmp win, 1
			je won
	noWinCheck:
			loop gameAgain
	    ;tie, CX = 0 at this point and no player has won
    	call clearScreen
    	lea DX, welcome
    	call printString
    	lea DX, newline
    	call printString
    	call printString
    	call printString
    	call printGrid
    	lea DX, newline
    	call printString
    	lea DX, tieMessage
    	call printString
    	lea DX, newline
    	call printString
    	call printString
    	jmp  empate

	won:; current player has won
    	call clearScreen
    	lea  DX, welcome
    	call printString
    	lea  DX, newline
    	call printString
    	call printString
    	call printString
    	call printGrid
    	lea  DX, newline
    	call printString
    	lea  DX, winMessage
    	call printString
    	mov  DL, player
    	cmp  DL, 1b
      jne  Wp2
      lea  DX, name_p1
      add  DX, 2
      call printString
      jmp  out_wins
	Wp2:
      lea  DX, name_p2
      add  DX, 2
      call printString
	out_wins:
    	lea  DX, newline
	    call printString
	    call printString

	askForNewGame:
    	lea DX, newGameQuest; ask for another game
    	call printString
    	jmp  new_out
  empate:
      lea  DX, newGamedraw
      call printString
  new_out:
    	call getChar
    	cmp AL, 's'; play again if 's' or 's' is pressed
    	je newGame
    	
    	cmp AL, 'S'
    	je newGame
    	
		cmp AL, 'M'; play again if 's' or 's' is pressed
    	je chama_memSet
    	    	
    	cmp AL, 'm'
    	je chama_memSet
    	
    	jmp sof

	sof:
    	mov AX, 4c00h
    	int 21h
                
chama_memSet:
    call memset
    jmp   print_menu                
                
;-------------------------------------------;
;
; Seta AH = 01h
; Salva char no AL
;
	getChar:
		;call bfush
		mov  AH, 01h
		int  21h
	ret
;-------------------------------------------;
;
; Seta AH = 02
; Printa oque esta em DL
; Apos print AL = DL
;
putChar:
		mov AH, 02
		int 21h
ret
;-------------------------------------------;
;
; Sets AH = 09
; Outputs string from DX
; Sets AL = 24h
;
	printString:
		mov AH, 09h
		int 21h
	ret
;-------------------------------------------;
;
;	Limpa tela e cria tela
; AH = 0
;
clearScreen:
		;mov AH, 0Fh
		;int 10h
		mov AX, 0003h
		int 10h
ret

;-------------------------------------------;
;
; Pega Movimento
; E coloca na posição de memoria
; AL deve estar entre 0 - 8
; BX verifica se existe jogada no local escolhido
;
	getMove:
		call getChar; AL = getchar()
		call isValidDigit
		cmp AH, 1
		je contCheckTaken
		mov DL, 0dh
		call putChar
		lea DX, newline
		call printString
		lea DX, inError
		call printString
		jmp getMove

		contCheckTaken: ; Checks this: if(grid[AL] > '9'), grid[AL] == 'O' or 'X'
	        lea bx, grid
	        sub AL, '1'
	        mov AH, 0
	        add bx, AX
	        mov AL, [bx]
	        cmp AL, '9'  ; confere se ja existe marcação nesse local
	        jng finishGetMove
	        mov DL, 0dh
	        call putChar
	        lea DX, newline
	        call printString
	        lea DX, inDigitError
	        call printString
	        jmp getMove
		finishGetMove:
	    	lea DX, newline
	    	call printString
	ret

;-------------------------------------------;
;
; Inicia grid de 1 a 9
; Usa BX, AL, CX
;
initiateGrid:
		lea BX, grid
		mov AL, '1'
		mov CX, 9
		initNextTa:
		mov [bx], AL
		inc AL
		inc bx
		loop initNextTa
ret

;-------------------------------------------;
;
; Chega se digito de posição e valido
; Se correto retorna AH = 0, se não AH = 1
;
isValidDigit:
		mov AH, 0
		cmp AL, '1'
		jl sofIsDigit

		cmp AL, '9'
		jg sofIsDigit

		mov AH, 1
		sofIsDigit:
ret

;-------------------------------------------;
;
; Returns 1 in AL if a player won
; 1 for win, 0 for no win
; Changes bx
;
checkWin:
		lea si, grid
		call checkDiagonal
		cmp win, 1
		je endCheckWin

		call checkRows
		cmp win, 1
		je endCheckWin

		call CheckColumns
		endCheckWin:
ret

;-------------------------------------------;
checkDiagonal:
		;DiagonalLtR
		mov  bx, si
		mov  AL, [bx]
		add  bx, 4	;grid[0] ---> grid[4]
		cmp  AL, [bx]
		jne  diagonalRtL
		add  bx, 4	;grid[4] ---> grid[8]
		cmp  AL, [bx]
		jne  diagonalRtL
		mov  win, 1
		call printa_dp_vitoriosa
ret

diagonalRtL:
		mov  bx, si
		add  bx, 2	;grid[0] ---> grid[2]
		mov  AL, [bx]
		add  bx, 2	;grid[2] ---> grid[4]
		cmp  AL, [bx]
		jne  endCheckDiagonal
		add  bx, 2	;grid[4] ---> grid[6]
		cmp  AL, [bx]
		jne  endCheckDiagonal
		mov  win, 1       
		call printa_ds_vitoriosa
		endCheckDiagonal:
ret

;-------------------------------------------;
checkRows:
		;firstRow
		mov  bx, si; --->grid[0]
		mov  AL, [bx]
		inc  bx		;grid[0] ---> grid[1]
		cmp  AL, [bx]
		jne  secondRow
		inc  bx		;grid[1] ---> grid[2]
		cmp  AL, [bx]
		jne  secondRow
		mov  win, 1   
		mov  AL, 0h
		call printa_linha_vitoriosa
ret

secondRow:
		mov  bx, si; --->grid[0]
		add  bx, 3	;grid[0] ---> grid[3]
		mov  AL, [bx]
		inc  bx	;grid[3] ---> grid[4]
		cmp  AL, [bx]
		jne  thirdRow
		inc  bx	;grid[4] ---> grid[5]
		cmp  AL, [bx]
		jne  thirdRow
		mov  win, 1
		mov  AL, 3h
		call printa_linha_vitoriosa
ret

thirdRow:
		mov bx, si; --->grid[0]
		add bx, 6;grid[0] ---> grid[6]
		mov AL, [bx]
		inc bx	;grid[6] ---> grid[7]
		cmp AL, [bx]
		jne endCheckRows
		inc bx	;grid[7] ---> grid[8]
		cmp AL, [bx]
		jne endCheckRows
		mov win, 1
		mov  AL, 6h
		call printa_linha_vitoriosa
		endCheckRows:
ret

;-------------------------------------------;
CheckColumns:
		;firstColumn
		mov  bx, si; --->grid[0]
		mov  AL, [bx]
		add  bx, 3	;grid[0] ---> grid[3]
		cmp  AL, [bx]
		jne  secondColumn
		add  bx, 3	;grid[3] ---> grid[6]
		cmp  AL, [bx]
		jne  secondColumn
		mov  win, 1      
		mov  AL, 0h
		call printa_coluna_vitoriosa
ret

secondColumn:
		mov bx, si; --->grid[0]
		inc bx	;grid[0] ---> grid[1]
		mov AL, [bx]
		add bx, 3	;grid[1] ---> grid[4]
		cmp AL, [bx]
		jne thirdColumn
		add bx, 3	;grid[4] ---> grid[7]
		cmp AL, [bx]
		jne thirdColumn
		mov win, 1
		mov  AL, 1h
		call printa_coluna_vitoriosa
ret

thirdColumn:
		mov bx, si; --->grid[0]
		add bx, 2	;grid[0] ---> grid[2]
		mov AL, [bx]
		add bx, 3	;grid[2] ---> grid[5]
		cmp AL, [bx]
		jne endCheckColumns
		add bx, 3	;grid[5] ---> grid[8]
		cmp AL, [bx]
		jne endCheckColumns
		mov win, 1
		mov  AL, 2h
		call printa_coluna_vitoriosa
		endCheckColumns:
ret

;-------------------------------------------------------;
;																												;
;             	   IMPLEMENTACOES												;
;																												;
;-------------------------------------------------------;
;
;		Printa o Grid com cor
;
;
printGrid:
	  push CX ; CX é usado no controle externo no numero de jogadas
		; Quebra linha para printar o tabuleiro
	  lea  DX, newline
		call printString
		call printString

	  mov  BH, 0h  ; Numero da pagina na int 10h
	  mov  CX, 1h	 ; Numero de caracter na int 10h
	  mov  DL, 0h	 ; Variavel de controle do printa da linha

		print_row:
		call moveCursorFront ; Desloga o curso para a direita

		mov  BL, DL  ; Usa BX colo deslocador dentro do GRID

		mov  AL , [grid+bx] ; Busca caracter pra printar
		call idColor				; Pega cor do jogador ou dos numeros
		call putCharColor			; Printa o caracter com cor (Não desloca cursor)
		call moveCursorFront

		call moveCursorFront  ; "Espaço"

		cmp  DL, 2h						; Fim da primeira linha
		je   print_separador  ; Coloca o separador de linhas
		cmp  DL, 5h						;	Fim da primeira linha
	  je   print_separador  ; Coloca o separador de linhas
	  cmp  DL, 8h						; Fim da primeira linha
	  je   print_separador  ; Coloca o separador de linhas

		mov  AL, '|'					; Separador de colunas
	  mov  BL, colors   		; Seta cor do tabuleiro
		call putCharColor				; Printa separador com cor
		call moveCursorFront	; Desloca cursor

		add  DL, 01h					; Incrimenta DL
		jmp  print_row				; Printa a proxima linha

		print_separador:
		add  DL, 01h					; Incrimenta DL
		cmp  DL, 9h						; Saida do print do grip
		je   printGrind_exit	; Pula pra saida

		push DX
		lea  DX, newline			; Cursor pra nova linha
		call printString
		call print_separator	; Printa o separador de linhas
		call printString
		pop  DX
		jmp  print_row				; Volta

		printGrind_exit:

		lea  DX, newline
		call printString
		call printString

		pop  CX

ret

;-------------------------------------------;
;
;   Escreve o separador com cor do tabuleiro
;
print_separator:
	  mov  si, 0h					; Deslocador da String
		mov  BL, colors			; Seta cor do tabuleiro
	  back_separator:
	  mov  AL, separator[si]	; Pega cada caracter da string
	  add  si, 1h					; Incrimenta deslocador
	  cmp  AL, '$'				; Verifica fim de String
	  je   exit_separator

		call putCharColor			; Printa caracter com cor
		call moveCursorFront	; Desloca cursror
	  jmp  back_separator		; Volta pra pegar proximo caracter

	  exit_separator:

ret

;-------------------------------------------;
;
;   Seta em BL a cor do jogador
;		Verifica se AL é simbolo de algum player
;			se sim colocar em BL a cor do Player
;			se não (Numeros do tabuleiro) coloca cor branca
;
idColor:
    cmp AL, skin_p1			; Verifica se caracter é do P1
    jne SCp2

    mov BL, colors[1]		; Se for coloca a cor de p1 em BL
    jmp out_idColor

    SCp2:
    cmp AL, skin_p2			; Verifica se caracter é do p2
    jne num_color

    mov BL, colors[2]		; Se for coloca a cor de p2 em BL
    jmp out_idColor

    num_color:
    mov BL, 0Fh					;	Se for um numero coloca cor branca

    out_idColor:

ret

;----------------------------------------------;
;
; Pega opçao do menu sala em AL e chama
;		a função tratante
;
arg_menu:
    call getChar 		; Pega entrda e salva em AL
    cmp  AL, '6'
    je   arg_out
    ;
    cmp  AL, '7'
    je   sof
    ;
    cmp  AL, '1'
    je   getName
    ;
    cmp  AL, '2'
    je   getName
    ;
    cmp  AL, '3'
    je   getSkin
    ;
    cmp  AL, '4'
    je   getSkin
    ;
    cmp  AL, '5'
    je  getTabuColor
    ;
    arg_out:
ret

;-------------------------------------------------------;
;
; Pega Nome do Jogador
;
getName:
	  mov  CH, AL					; Guarda opção do menu em CH, pois função
												;				printString modifica AL
		back_getName:
		lea  DX, newline
	  call printString		; Nova linha
	  lea  DX, str_name
	  call printString		;	Printa pedido de entrada do nome
	  cmp  CH, '1'				; Se for igual 1 é o p1, se não p2
	  jne  p2

	  lea  DX, name_p1		; Coloca em DX a string do nome de p1
	  jmp  name_out

	  p2:
	  lea  DX, name_p2		; Coloca em DX a string do nome de p2

	  name_out:
	  call gets						; Chama função que pega string
	  mov  bx, DX					; Coloca o endereço da string em bx
		cmp  [BX+1], 0h
		je   string_invalida
		mov  DH, 0h					; Zera DH
	  mov  DL, [bx+1]			; Coloca o tanto de bytes lido em DL
	  add  bx, DX					; Incrimenta em BX o que tem em "DL"
	  mov  [bx+2], '$'		; Adiciona no fim da string o '$'

jmp print_menu

		string_invalida:
		lea  DX, newline
		call printString
		call printString
		lea  DX, string_inval
		call printString

		jmp back_getName


;-------------------------------------------------------
;
;		 Pega simbolo do Jogador
;
getSkin:
		 mov  CH, AL					; Guarda opção do menu em CH, pois função
 													;				printString modifica AL
		 lea  DX, newline
		 back_skin:
		 call printString
		 lea  DX, str_skin		; Printa mensagem pedindo pra inserir um simbolo
		 call printString
		 call getChar					; Pega um char e coloca em AL
		 cmp  AL, 0Dh					; Verifica entrada invalida
		 je  	skin_invalida
		 cmp  CH, '3'					; Se CH = 3 entao é simbolo de p1, se nao de p2
		 jne  Sp2

		 cmp  skin_p2, AL     ; Trata simbolo igual do adiversario
		 je   igual_skin

		 mov  skin_p1, AL			; Coloca o simbolo na posição de memoria
		 jmp  out_skin

		 Sp2:
		 cmp  skin_p1, AL
		 je   igual_skin

		 mov  skin_p2, AL
		 jmp  out_skin:

		 skin_invalida:			  ; enter sem caracter
		 lea  DX, newline
		 call printString
		 call printString
		 lea  DX, simb_inval
		 call printString
		 lea  DX, newline
		 jmp  back_skin

		 igual_skin:					; Trata simbolo igual
		 lea  DX, newline
		 call printString
		 call printString
		 lea  DX, simb_igual	; Msg de erro, simbolo iguais
		 call printString
		 lea  DX, newline
		 jmp  back_skin

		 out_skin:

		 call setColor       ; chama para pegar cor do simbolo do jogador

jmp print_menu


;-------------------------------------------------------;
;
;   Pega Cor do jogador
;
setColor:
		call clearScreen
		lea  DX, str_cor				; Menu de cor ao usuario
		call printString

		back_color1:
		call getChar						; Pega numero do teclado salva em AL
		call validaCor					; Valida se numero correto AH = 0, se não AH = 1
		cmp  AH, 0h							; Verfica a integridade da entrada
		je   valid1

		; Trata erro na entrada
		lea  DX, newline
		call printString
		call printString
		lea  DX, erro_cor
		call printString
		jmp  back_color1

		valid1:
		call decosCor					; Decodifica entrada em numero da cor valida
		cmp  CH, '3'					; Verifica qual jogador esta mudando a cor P1 se CH = 3
		jne  Cp2              ; Pula para o P2 mudar a cor

		mov  colors[1], CL    ; Seta cor na memoria da cor do jogador
		jmp  out_color

		Cp2:
		mov  colors[2], CL		; Seta cor na memoria da cor do jogador

		out_color:

ret

;-------------------------------------------------------
;
;   Valida entrada de cores
;			se entrada enta entre [1..6]
;		Entrada do digito recebido em AL
;		Se valia retorna AH = 0h, se não AH = 1h
;
validaCor:
		mov  AH, 0h				; Seta como valido
		cmp  AL, '1'			; Verifica se menor que 6
		jl   noValid			; Se menor q 6 seta AH = 1h, e sai da função

		cmp  AL, '6'			; Verifica se maior que 6
		jg   noValid			; Se maior q 6 seta AH = 1h, e sai da função

ret

		noValid:
		mov  AH, 1h
ret

;-------------------------------------------------------
;
;   Decodifica cor entrada pelo usuario em cor C-RGB
;			Entrada cor digitada em AL
;			Retorna cor no padrao em CL
;			OBS: BACK GROUND cor preta
;
decosCor:
    cmp AL, '1'
    jne naoBranco

    mov CL, 0Fh
    jmp out_decod

    naoBranco:
    cmp AL, '2'
    jne naoVermelho

    mov CL, 04h
    jmp out_decod

    naoVermelho:
    cmp AL, '3'
    jne naoVerde

    mov CL, 02h
    jmp out_decod

    naoVerde:
    cmp AL, '4'
    jne naoAzul

    mov CL, 01h
    jmp out_decod

    naoAzul:
    cmp AL, '5'
    jne naoAmarelo

    mov CL, 0Eh
    jmp out_decod

    naoAmarelo:
    mov CL, 06h

    out_decod:

ret

;-------------------------------------------------------;
;
;   Pega e seta cor do tabuleiro
;		Salva na posicao de memoria
;
getTabuColor:
    call clearScreen
    lea  DX, tabuCor				; Menu de cores do tabuleiro
    call printString

    back_color2:
    call getchar						; Pega entrada e salva em AL
    call validaCor					; Valida entrada, se valida retorna AH = 0h
    cmp  AH, 0h							; Verifica integridade
    je   valid2							; Pula para setar a cor na memoria

		; Tratamento de erro, entrada invalida
    lea  DX, newline
    call printString
    call printString
    lea  DX, erro_cor
    call printString
    jmp  back_color2				; Volta pra pegar e validar

    valid2:
    call decosCor						; Decodifica cor em padaro C-RGB, retorna em CL
    mov  colors, CL					; Seta na posição de memoria

jmp print_menu

;-------------------------------------------------------
;
;   Pega String da stdin   DS:DX -> vetor  n,x, n-dup()
;
gets:
    push AX
    mov  AH, 0Ah
    int  21h
    pop  AX
ret

;-------------------------------------------------------
;
;   Limpa Buffer do stdin
;
bfush:
    push AX
    mov  AH, 0Ch
    int  21h
    pop  AX
ret

;-------------------------------------------------------
;
;   Imprime caracter com cor
;			Entrada em DL
;			Apos operação AL = DL
;
putCharColor:
    push AX
    mov  AH, 09h
    int  10h
    pop  AX
ret

;-------------------------------------------------------;
;
;   Move cursor para direita
;			Seta o cursor a direita da posicao atual
;			BH = pagina
;			Utiliza DX (DH=linha,DL=Coluna)
;
moveCursorFront:
   push DX
   push CX
   mov  AH, 03h
   int  10h				; Pega posição atual do cursror
   add  DL, 01h		; Desloca para Direita (inc Coluna)
   mov  AH, 02h
   int  10h				; Seta cursor nessa nova posicao
   pop  CX
   pop  DX
ret         

;-------------------------------------------------------;
;
    ;   Printa a linha vitoriosa
;       recebe AL 
;
printa_linha_vitoriosa:    
    mov  BX, SI 
    push CX
    mov  CX, 3h
    mov  AH, 0h
    add  BX, AX 
    
    print_linha:
    mov  [BX], '-'
    add  BX, 1h
    loop print_linha 
    pop  CX        
ret

;-------------------------------------------------------;
;
;   Printa a coluna vitoriosa
;       recebe AL 
;
printa_coluna_vitoriosa:    
    mov  BX, SI 
    push CX
    mov  CX, 3h
    mov  AH, 0h
    add  BX, AX 
    
    print_coluna:
    mov  [BX], '|'
    add  BX, 3h
    loop print_coluna
    pop  CX    
ret

;-------------------------------------------------------;
;
;   Printa a diagonal principal 
;       recebe AL 
;
printa_dp_vitoriosa:    
    mov  BX, SI 
    push CX
    mov  CX, 3h
    mov  AX, 0h
    add  BX, AX 
    
    print_dp:
    mov  [BX], '\'
    add  BX, 4h
    loop print_dp
    pop  CX    
ret   
   
;-------------------------------------------------------;
;
;   Printa a diagonal segundaria 
;       recebe AL 
;
printa_ds_vitoriosa:    
    mov  BX, SI 
    push CX
    mov  CX, 3h
    mov  AX, 2h
    add  BX, AX 
    
    print_ds:
    mov  [BX], '/'
    add  BX, 2h
    loop print_ds
    pop  CX    
ret   


;-------------------------------------------------------;
;
;   
;   seta uma regiao de memoria 
;   
memset:
    push  DS
    mov   AX, 0B80h
    mov   DS, AX     
    mov   CX, 01E0h
    mov   BX, 500h
    
    set_mem:     
    mov   [BX], 0h   
    add   BX,   1h
    loop  set_mem
    
    pop   DS
ret
   
ends
end start
