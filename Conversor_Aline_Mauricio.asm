# Teste: https://www.embarcados.com.br/conversao-entre-sistemas-de-numeracao/
# 	BIN: 45 -> 101101 
# 	HEX: 438 -> 1B6
# 	OCTAL: 246 -> 366

.data
	introA: .asciiz "----------------------------------------------------------------\n"
	introB: .asciiz "\t[ Conversor de Sistemas de Numeração ]\n"
	
	#s_ : scan
	s_choice: .asciiz "Insira uma opcao: "
	s_num: .asciiz "Insira um numero: "
	
	#p_ : print
	p_a: .asciiz "A"
	p_b: .asciiz "B"
	p_c: .asciiz "C"
	p_d: .asciiz "D"
	p_e: .asciiz "E"
	p_f: .asciiz "F"
	p_space: .asciiz " "
	p_newLine: .asciiz "\n"
	p_result: .asciiz "Resultado: "
	p_menu: .asciiz "1. Dec -> Bin\n2. Dec -> Octal\n3. Dec -> Hex\n4. Mostra Resultados\n0. Sair\n"
	
	#Guarda Resultados
	array: .word -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	
.text

	la $s0, array	# array[0]
	li $s1, 49 	# array.size() - 1
	li $s7, -1

	jal restart

	main:
		# Exibe o main
		la $a0, introA
		jal printString
		
		la $a0, introB
		jal printString
		
		la $a0, p_menu
		jal printString
		
		la $a0, introA
		jal printString
		
		# Escaneia a opçao
		la $a0, s_choice
		jal printString
		jal getNumber
		move $t0, $v0
		
		# Valida a opcao
		slti $t1, $t0, 0	# (s_choice < 0) ? $t1 = 1 : $t1 = 0
		bne $t1, $0, main	# ($t1 != 0) ? main : continue
		slti $t1, $t0, 5	# (s_choice < 5) ? $t1 = 1 : $t1 = 0
		beq $t1, $0, main 	# ($t1 == 0) ? main : continue
		beq $t0, $0, exit	# (s_choice == 0) ? exit : continue
		beq $t0, 4, printArray	# (s_choice == 4) ? printArray : continue	
		
		# Escaneia o numero a ser transformado
		la $a0, s_num
		jal printString
		jal getNumber
		move $t1, $v0
	
		# Acessa as opcoes
		beq $t0, 1, bin		# (s_choice == 1) ? bin : continue
		beq $t0, 2, oct		# (s_choice == 2) ? oct : continue
		beq $t0, 3, hex		# (s_choice == 3) ? hex : continue
		
	restart:
		li $s2, 0	# k = 0
		move $s3, $s0	# $s3 = &array[0]
		jr $ra

	printString: # Printa a string que foi carregada e retorna
		li $v0, 4		
		syscall
		jr $ra
		
	getNumber: # Escaneia o valor de um inteiro e retorna
		li $v0, 5
		syscall
		jr $ra
		
	printArray: # Printa os resultados armazenados no vetor
		jal restart
	showArray:	
		lw $s4, 0($s3)
		beq $s4, $s7, printSpace
		li $v0, 1
		move $a0, $s4
		syscall
	jump:	
		addi $s3, $s3, 4
		addi $s2, $s2, 1
		bne $s2,$s1, showArray 
		
		la $a0, p_newLine	
		jal printString	
		jal restart		# Reseta os registradores do tipo $s
		j while
	
	printSpace:
		la $a0, p_space
		jal printString
		j jump
		
	bin:
		ori $t2, $zero, 2	# Carrega o divisor
		ori $t3, $zero, 0	# i = 0 (contador)
		la $a0, p_result
		jal printString
		
	calcBin: # Push na pilha
		div $t1, $t2		
		mfhi $t4		# Move o resto para $t4
		mflo $t1		# Move o resultado para $t1
		addiu $sp, $sp, -4	# "Aloca espaço na pilha"
		sw $t4, ($sp)		# Guarda na Pilha
		addi $t3, $t3, 1	
		bne $t1, $0, calcBin	# (quociente != 0) ? calcBin : continue
		j showResult
		
	oct:
		ori $t2, $zero, 8	# Carrega o divisor
		ori $t3, $zero, 0	# i = 0 (contador)
		la $a0, p_result
		jal printString		
		
	calcOct: # Push na pilha
		div $t1, $t2		
		mfhi $t4		# Move o resto para $t4
		mflo $t1		# Move o resultado para $t1
		addiu $sp, $sp, -4	
		sw $t4, ($sp)		
		addi $t3, $t3, 1	
		bne $t1, $0, calcOct	# (quociente != 0) ? calcBin : continue
		j showResult
		
	hex:	
		ori $t2, $zero, 16	# Carrega o divisor
		ori $t3, $zero, 0	# i = 0 (contador)
		la $a0, p_result
		jal printString
	
	calcHex: # Push na pilha
		div $t1, $t2		
		mfhi $t4		# Move o resto para $t4
		mflo $t1		# Move o resultado para $t1
		addiu $sp, $sp, -4	
		sw $t4, ($sp)		
		addi $t3, $t3, 1	
		bne $t1, $0, calcHex	# (quociente != 0) ? calcBin : continue
	
	auxHex: # Pop na Pilha
		lw $t4, ($sp)
		addiu $sp, $sp, 4
		slti $t1, $t4, 10		# ($t4 < 10) ? $t1 = 1 (Int): $t1 = 0 (Char)
		beq  $t1, $0, intToChar		# ($t1 == 0) ? intToChar : continue

	showHexInt: 
		li $v0, 1		
		move $a0, $t4		
		syscall			# Printa o valor
		addi $t3, $t3, -1	
		bne $t3, 0, auxHex	# Looping exibicao

		la $a0, p_newLine	
		jal printString	
		j main			# Volta para o main
	
	intToChar:
		beq $t4, 10, aChar
		beq $t4, 11, bChar
		beq $t4, 12, cChar
		beq $t4, 13, dChar
		beq $t4, 14, eChar
		beq $t4, 15, fChar
	
	aChar: 
		la $a0, p_a
		j showHexChar					
	bChar: 
		la $a0, p_b
		j showHexChar
	cChar: 
		la $a0, p_c
		j showHexChar
	dChar: 
		la $a0, p_d
		j showHexChar
	eChar: 
		la $a0, p_e
		j showHexChar
	fChar: 
		la $a0, p_f
		j showHexChar

	showHexChar:
		jal printString
		addi $t3, $t3, -1	
		bne $t3, 0, auxHex	# Looping exibicao

		la $a0, p_newLine	
		jal printString	
		j main			# Volta para o main
		
	showResult: # Pop na pilha			
		lw $t4, ($sp)		# Ler da pilha
		addiu $sp, $sp, 4	# "Desalocando a pilha"
		li $v0, 1		
		move $a0, $t4		
		syscall			# Printa o valor
		addi $t3, $t3, -1
		sw $t4, 0($s3)
		addi $s3, $s3, 4		
		bne $t3, 0, showResult	# Looping exibicao

		la $a0, p_newLine	
		jal printString	
		sw $s7, 0($s3)
		addi $s3, $s3, 4
		addi $s2, $s2, 1
		beq $s2, 10, reset
		j main			# Volta para o main

	reset:
		jal restart
	while:
		sw $s7, 0($s3)
		addi $s3, $s3, 4
		addi $s2, $s2, 1
		bne $s2, $s1, while
		jal restart
		j main
		
	exit: # Finaliza o programa
		li, $v0, 10
		syscall
