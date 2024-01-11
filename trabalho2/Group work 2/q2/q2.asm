#################################################################
# Questao 2 do trabalho 2 de Organizaçao de Computadores	#
# Mathias Recktenvald e Guilherme Brizzi			#
# Cálculo de cosseno a partir da série de Taylor		#
# Entrada em graus						#
#################################################################


.data
	zero_double: .double 0
	one_double: .double 1
	minus_one_double: .double -1
	
	pi_over_180: .double 0.0174532925
	
	input_prompt: .asciiz "Insira o valor, em graus, de um angulo para calcular seu cosseno: "
	output_prompt: .asciiz "O valor do cosseno do angulo inserido é: "

.text

main:
	la $a0, input_prompt
	li $v0, 4
	syscall		# imprime mensagem explicando entrada
	
	li $v0, 7	# carrega código para leitura de double
	syscall		# chamada do sistema para ler double
	
	# $f0 contém double
	l.d $f4, pi_over_180
	mul.d $f0, $f0, $f4
	
	mov.d $f12, $f0		# $f12 contém argumento x (ângulo em rad)
	jal cos
	mov.d $f12, $f20	# $f20 contém resultado
	
	la $a0, output_prompt
	li $v0, 4
	syscall			# imprime mensagem explicando saída
	
	li $v0, 3
	syscall			# imprime resultado na tela
	
	j end

	
# $f12 contém x	
cos:
	addiu $sp, $sp, -4	# ajusta a pilha
	sw $ra, 0($sp)		# salva $ra na pilha
	
	mov.d $f24, $f12 	# $f24 = x
	l.d $f20, zero_double	# acumulador = 0
	li $s0, 0 		# contador = 0
	
	next_term:
	bgt $s0, 7, skip_next_term
	
		l.d $f22, minus_one_double
		mov.d $f12, $f22
		move $a0, $s0
		
		jal pow
		# f0 contém retorno de pow(-1, contador)
		mov.d $f22, $f0	# $f22 = (-1)^n
		
		
		mov.d $f12, $f24	# $f12 = x
		addu $a0, $s0, $s0	# $a0 = 2*n
		
		jal pow
		# f0 contém retorno de pow(x, 2*n)
		mov.d $f26, $f0	# $f26 = (x)^2*n
		
		mul.d $f22, $f22, $f26	# $f22 = ((-1)^n) * ((x)^(2*n))
		
		addu $a0, $s0, $s0	# $a0 = 2*n
		jal factorial
		# $v0 contém retorno (2*n)!
		
		mtc1.d $v0, $f26
		cvt.d.w	$f26, $f26
		
		div.d $f22, $f22, $f26
		
		add.d $f20, $f20, $f22
		
		addiu $s0, $s0, 1
		
		j next_term
		
	skip_next_term:
	
	lw $ra, 0($sp)
	# retorno em $f20
	jr $ra

# $a0 contém argumento n, para n!
factorial:
	move $t2, $a0	# $t2 contém argumento
	
	li $t0, 1	# $t0 = contador = 1
	li $t1, 1	# $t1 = resultado = 1
	
	multiply_factorial:
	bge $t0, $t2, skip_multiply_factorial	
					# se contador maior ou igual a n,
					# pula loop.
	
	addiu $t0, $t0, 1	# atualiza contador
	mul $t1, $t0, $t1	# $t1 = $t0 (contador) * $t1 (resultado parcial)
	
	j multiply_factorial
	
	skip_multiply_factorial:
	
	move $v0, $t1
	# $v0 contém valor de retorno do fatorial
	# return $v0;
	jr $ra

# $f12 contém base, $a0 contém exponent
pow:
	mov.d $f0, $f12 # result em $f0
	mov.d $f4, $f12 # base em $f4
	move $t0, $a0	# exponent em $a0
	
	bne $t0, 0, exponent_isnt_zero
	
	# caso o exponent seja 0, retorna 1 (em double)
		l.d $f0, one_double
		jr $ra
	
	exponent_isnt_zero:
	
	li $t2, 1 	# $t2 = contador = 1
	
	multiply_pow:
	bge $t2, $t0, skip_multiply_pow
					# se contador maior ou igual a n,
					# pula loop.
	
	addiu $t2, $t2, 1	# atualiza contador
	mul.d $f0, $f0, $f4	# $f0 = $f0 * $f0 (resultado parcial)
	
	j multiply_pow
	
	skip_multiply_pow:
	
	# $f0 contém retorno
	# return $f0;

	
	jr $ra
	
end:
