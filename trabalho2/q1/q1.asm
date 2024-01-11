#########################################
#	Quest�o 1 do trabalho 2		#
#	Alunos:				#
#	Mathias Recktenvald		#
#	Guilherme Brizzi		#
########			#########
# Para usar o divisor mude o valor das	#
# vari�veis globais x e y para o valor	#
# desejado e o ao rodar o programa 	#
# imprimir� o resultado da divis�o	#
#########################################

.data
	var_x: .word 0x12341234
	var_y: .word 0x90357274
	
	string_quocient: .asciiz "Quociente: x / y = "
	line_break: .asciiz "\n"
	string_remainder: .asciiz "Resto: x % y = "
	
	mask: .word 0x80000000

.text

# Carregamento de endere�os
la $s0, var_x
la $s1, var_y
la $s2, string_quocient
la $s3, string_remainder
la $s4, line_break

main:
	
	jal divisao
	
	
	move $s5, $v0
	move $s6, $v1
	jal imprime
	
	j exit


###	mapa da pilha	###
#	0($sp) = ra	  #
###			###
divisao:

	addiu $sp, $sp, -4	# ajusta a pilha
	sw $ra, 0($sp)		# guarda o valor de retorno
##

	# seja:
	# $t0 = contador
	# $t1 = resto high
	# $t2 = resto low
	# $t4 = divisor
	
	# carrega valores
	li $t0, 0
	li $t1, 0
	lw $t2, var_x
	lw $t4, var_y
	
	lw $t6, mask
	
	# shifta resto
	srl $t7, $t2, 31	# pega MSB do resto low $t2
	
	sll $t1, $t1, 1		# shifta high do resto
	or $t1, $t1, $t7	# faz or l�gico para setar LSB do high para MSB do low
	sll $t2, $t2, 1 	# shifta low do resto
	
	j loop_check_condition
		
	repeat_loop:
		bltu $t1, $t4, resto_h_ext_isnt_negative	# checa se resto � menor que divisor
		
		resto_h_ext_is_negative:
			subu $t1, $t1, $t4
			
			# shifta resto
			sll $t1, $t1, 1		# shifta high do resto
			srl $t7, $t2, 31	# pega MSB do resto low $t2
			or $t1, $t1, $t7	# faz or l�gico para setar LSB do high para MSB do low
			sll $t2, $t2, 1 	# shifta low do resto
			
			ori $t2, $t2, 1		# seta LSB do resto = 1
			
			j skip_condition_resto_h_ext
			
		resto_h_ext_isnt_negative:
		
			# shifta resto
			sll $t1, $t1, 1		# shifta high do resto
			srl $t7, $t2, 31	# pega MSB do resto low $t2
			or $t1, $t1, $t7	# faz or l�gico para setar LSB do high para MSB do low
			sll $t2, $t2, 1 	# shifta low do resto
			
			j skip_condition_resto_h_ext
		
		skip_condition_resto_h_ext:
	
	addiu $t0, $t0, 1
	loop_check_condition:
	blt $t0, 32, repeat_loop 	# fica no loop por n bits itera�oes (n�meros de 32 bits = 32 itera�oes)
	
	skip_loop:
	srl $t1, $t1, 1		# shifta resto high
	
	# coloca nos registradores de retorno as respostas
	move $v0, $t1
	move $v1, $t2
		
##	
	lw $ra, 0($sp)		# pega o valor de retorno
	addiu $sp, $sp, 4	# destroi a pilha
	jr $ra			# retorna


###	mapa da pilha	###
#	0($sp) = ra	  #
###			###
imprime:

	addiu $sp, $sp, -4	# ajusta a pilha
	sw $ra, 0($sp)		# guarda o valor de retorno
	sw $a0, 4($sp)		# guarda o resultado da divis�o
##
	
	li $v0, 4		# configura $v0 para a impress�o de strings
	la $a0, ($s2)		# carrega em a0 o valor da string (QUOCIENTE)
	syscall
	
	li $v0, 36		# configura $v0 para a impress�o de inteiros unsigned
	move $a0, $s6		# carrega em $a0 o resultado da divis�o
	syscall
	
	li $v0, 4		# configura $v0 para a impress�o de strings
	la $a0, ($s4)		# carrega em a0 o valor da string (\n)
	syscall	
	
	li $v0, 4		# configura $v0 para a impress�o de strings
	la $a0, ($s3)		# carrega em a0 o valor da string (RESTO)
	syscall
	
	li $v0, 36		# configura $v0 para a impress�o de inteiros unsigned
	move $a0, $s5		# carrega em $a0 o resultado da divis�o
	syscall
		
##
	lw $ra, 0($sp)		# pega o valor de retorno
	addiu $sp, $sp, 8	# destroi a pilha
	jr $ra			# retorna

exit:
