# BITMAP CONF
# 512 x 512 
# pixel unit 32x32
# initial memory address heap (0x10040000)

# autor: Lucas Burle (IlfGauhnith) lucasbburle@gmail.com
# Meu programa recebe como entrada uma sequência de inteiros de 1 a 4, cada número representando uma das cores do jogo.
# Trata-se do jogo de memória e percepção Genius. Implementado para um projeto da primeira parte da cadeira Arquitetura e Organização de Computadores da UFRPE.

.data
	#coolors
	darkGreen: .word 0x00104911
	lightGreen: .word 0x002BC52E
	darkYellow: .word 0x00F9A620
	lightYellow: .word 0x00F8D249
	darkBlue: .word 0x00044389
	lightBlue: .word 0x001B82F8
	darkRed: .word 0x00FE2A1B
	lightRed: .word 0x00FE6767
	
	#user iteration
	winMessage: .asciiz "Você venceu!"
	loseMessage: .asciiz "Você perdeu!"
	inputMessage: .asciiz "1 - VERMELHO\n2 - AMARELO\n3 - AZUL\n4 - VERDE\n Digite a sequencia de números correspondente as cores que piscaram (sem espaço)."
	userInput: .space 11
	
	#array of colors
	roundColors: .word 0 : 10
	
	gameScreen: .word 0x10040000 #heap
.text 
	.macro renderLine(%coolor, %pixel)
		add $t0, %pixel, $zero #contador
		addi $t1, $t0, 32 #limite
		
		columnFor:
			beq $t0, $t1, columnForEnd
			sw %coolor, 0($t0)
			addi $t0, $t0, 4
			j columnFor
		columnForEnd:
	.end_macro
	
	.macro renderSquare(%coolor, %pixel)
		addi $t2, %pixel, 0 #contador
		addi $t3, %pixel, 512 #limite
		
		lineFor:
			beq $t2, $t3, lineForEnd
			renderLine(%coolor, $t2)
			addi $t2, $t2, 64
			j lineFor
		lineForEnd:
	.end_macro
	
	.macro initScreen()
		lw $t5, gameScreen
		
		#darkYellow
		lw $t4, darkYellow
		renderSquare($t4, $t5)
		
		#darkRed
		lw $t4, darkRed
		addi $t6, $t5, 32
		renderSquare($t4, $t6)
		
		#darkBlue
		lw $t4, darkBlue
		addi $t6, $t5, 512
		renderSquare($t4, $t6)
		
		#darkGreen
		lw $t4, darkGreen
		addi $t6, $t5, 544
		renderSquare($t4, $t6)
	.end_macro
	
	.macro randomColorsGen(%amount)
		# Gera as cores da rodada e armazena na pilha do mips
		# 1 = vermelho
		# 2 = amarelo
		# 3 = azul
		# 4 = verde
		addi $t1, %amount, 0
		la $a2, roundColors #endereço do array
		addi $t0, $zero, 0
		addi $t2, $zero, 0 #incrementador de endereço no array
		for:
			beq $t0, $t1, forEnd
			
			#fonte -> https://stackoverflow.com/questions/30429097/generate-random-number-on-mips/40457147
    			li $a1, 4 #Here you set $a1 to the max bound.
    			li $v0, 42  #generates the random number.
    			syscall
    			add $a0, $a0, 1  #Here you add the lowest bound
				
			add $t3, $a2, $t2
			sw $a0, 0($t3)
			
			addi $t0, $t0, 1
			addi $t2, $t2, 4
			j for
		forEnd:
	.end_macro 
	
	.macro makeItWait(%miliseconds)
	#syscall 32 de acordo com http://courses.missouristate.edu/KenVollmar/MARS/Help/SyscallHelp.html
		addi $a0, %miliseconds, 0
		li $v0, 32
		syscall
	.end_macro
	
	.macro flickSquares(%amount)
		#Esta macro faz as cores dos quadrados piscarem de acordo com a quantidade
		#e cores escritas em memória pela macro randomColorsGen.
		addi $s0, $zero, 2000 # 1000 milisegundos
		li $s5, 250 # 250 milisegundos
		addi $s1, %amount, 0 #limite do laço
		addi $s2, $zero, 0 #contador do laço
		la $s3, roundColors #endereço do array
		
		flickeringFor:
			beq $s1, $s2, flickeringForEnd
			
			lw $t3, 0($s3) #carrega o inteiro que representa a cor
			
			addi $s3, $s3, 4 #incrementa endereço
			addi $s2, $s2, 1 #incrementa contador
			
			makeItWait($s5)
			
			beq $t3, 1, red
			beq $t3, 2, yellow
			beq $t3, 3, blue
			beq $t3, 4, green
			
			j flickeringFor
			
			green:
				lw $t6, gameScreen # endereço do bitmap
				lw $t7, lightGreen
				addi $t6, $t6, 544 # soma endereço do bitmap com 544, resultando no endereço do início da cor verde.
				renderSquare($t7, $t6)
				makeItWait($s0)
				lw $t7, darkGreen
				renderSquare($t7, $t6)
				j flickeringFor
		
			red:
				lw $t6, gameScreen # endereço do bitmap
				lw $t7, lightRed
				addi $t6, $t6, 32 # soma endereço do bitmap com 32, resultando no endereço do início da cor vermelha.
				renderSquare($t7, $t6)
				makeItWait($s0)
				lw $t7, darkRed
				renderSquare($t7, $t6)
				j flickeringFor
			blue:
				lw $t6, gameScreen # endereço do bitmap
				lw $t7, lightBlue
				addi $t6, $t6, 512 # soma endereço do bitmap com 512, resultando no endereço do início da cor azul.
				renderSquare($t7, $t6)
				makeItWait($s0)
				lw $t7, darkBlue
				renderSquare($t7, $t6)
				j flickeringFor
			yellow:
				lw $t6, gameScreen # endereço do bitmap. Cor amarela no caso.
				lw $t7, lightYellow
				renderSquare($t7, $t6)
				makeItWait($s0)
				lw $t7, darkYellow
				renderSquare($t7, $t6)
				j flickeringFor
		flickeringForEnd:
		
		
	.end_macro
	
	.macro cleanScreen()
		lw $t0, gameScreen
		addi $t1, $t0, 1024 #limite do laço => 512/32 * 512/32 = 256 pixels. 256*4 cada endereçamento.
		
		cleanFor:
			beq $t0, $t1, cleanForEnd
			
			sw $zero, 0($t0)
			
			addi $t0, $t0, 4
			j cleanFor
		cleanForEnd:
	.end_macro
	
	.macro asciiColorToInt(%asciiColor)
		# 1 = vermelho = 0x31
		# 2 = amarelo = 0x32
		# 3 = azul = 0x33
		# 4 = verde = 0x34
		addi $t9, %asciiColor, 0
		
		beq $t9, 0x31, red
		beq $t9, 0x32, yellow
		beq $t9, 0x33, blue
		beq $t9, 0x34, green
		red:
			addi $v1, $zero, 1
			j endMacro
		yellow:
			addi $v1, $zero, 2
			j endMacro
		blue:
			addi $v1, $zero, 3
			j endMacro
		green:
			addi $v1, $zero, 4
		endMacro:	
	.end_macro
	
	.macro checkInput(%amountOfColors)	
		la $a0, inputMessage
		la $a1, userInput
		la $a2, 11
		li $v0, 54
		syscall
		
		addi $t0, $zero, 0 #contador
		addi $t1, %amountOfColors, 0 #condição de parada
		
		la $t3, userInput
		la $t4, roundColors
		
		checkFor:
			beq $t0, $t1, checkForEnd
			
			lbu $t2, 0($t3) # carrega os 8 primeiros bytes da entrada do usuário em $t2 (um caracter ascii).
			lw $t6, 0($t3)
			srl $t6, $t6, 8 # descarta a parte que já foi lida.
			sw $t6, 0($t3) # atualiza na memória
			
			# check color equality
			lw $t5, 0($t4)
			asciiColorToInt($t2)
			addi $t8, $v1, 0
			bne $t5, $t8, lose
			
			addi $t0, $t0, 1 # incremento do laço
			addi $t4, $t4, 4 # incremento do endereço do array de cores
			
			beq $t0, 4, increment
			beq $t0, 8, increment
			j checkFor
			increment:
				addi $t3, $t3, 4
				j checkFor
		checkForEnd:
	.end_macro
	
	main:
		li $s6, 500 # 500 milisegundos
		addi $s7, $zero, 1 # Contador da partida
		gameFor:
			beq $s7, 11, gameForEnd
			initScreen() # renderiza apagado
			randomColorsGen($s7) # gera cores aleatórias na memória
			makeItWait($s6)
			flickSquares($s7) # pisca as cores de acordo com as cores em memória
			cleanScreen() # limpa a tela
			checkInput($s7) # checa input de usuário em relação as cores geradas
			
			addi $s7, $s7, 1 # incrementa quantidade de cores na sequencia
			
			j gameFor
			lose: 
				la $a0, loseMessage
				li $a1, 1
				li $v0, 55
				syscall
				
				li $v0, 10
				syscall
		gameForEnd:
		win: 
			la $a0, winMessage
			li $a1, 1
			li $v0, 55
			syscall
				
			li $v0, 10
			syscall	
