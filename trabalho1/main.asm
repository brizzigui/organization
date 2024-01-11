# Trabalho 1 da disciplina de Organiza��o de Computadores
# Implementou-se aqui a fun�ao de ler arquivo

# Ainda falta:
# - procedimentos de conversao num�rica em ascii
# - separa�ao de opcode e demais instrucoes
# - comparacao de opcodes e instrucoes
# - escrita em arquivo

.data
	file_address: .asciiz "dados_provisorio/ex-000-012.bin"
	output_file_address: .asciiz "output.txt"
	input_buffer: .word 0
	output_buffer: .word 0
	file_descriptor_read: .word 0
	file_descriptor_write: .word 0
	current_address: .word 0x0040000
	unknown_instruction: .ascii "Instru��o desconhecida."
	
	hex_prefix: .ascii "0x"

	space_suffix: .ascii "     "
	line_break: .ascii "\n"
	comma: .ascii ", "

	mask_4_bits: .word 0x0000000F
		
	op_code_mask: .word 0xFC000000
	rs_mask: .word 0x03E00000
	rt_mask: .word 0x001F0000
	rd_mask: .word 0x0000F800
	shamt_mask: .word 0x000007C0
	funct_mask: .word 0x0000003F
	imm_mask: .word 0x0000FFFF
	target_mask: .word 0x03FFFFFF
	
	current_op: .word 0
	current_rs: .word 0
	current_rt: .word 0
	current_rd: .word 0
	current_shamt: .word 0
	current_funct: .word 0
	current_imm: .word 0
	current_target: .word 0
	
	#	opcodes 	#
	text_op_0_add: .ascii "add"
	text_op_0_addu: .ascii "addu"
	text_op_2: .ascii "j"
	text_op_3: .ascii "jal"
	text_op_5: .ascii "bne"
	text_op_8: .ascii "addi"
	text_op_9: .ascii "addiu"
	text_op_13: .ascii "ori"
	text_op_15: .ascii "lui"
	text_op_28_mul: .ascii "mul"
	text_op_28_madd: .ascii "madd"
	text_op_28_maddu: .ascii "maddu"
	text_op_28_msub: .ascii "msub"
	text_op_35: .ascii "lw"
	text_op_43: .ascii "sw"
	text_op_sys: .ascii "syscall"
	text_op_jr: .ascii "jr"
	
	#	registers	#
	text_reg_0: .ascii "$zero"
	text_reg_1: .ascii "$at"
	text_reg_2: .ascii "$v0"
	text_reg_3: .ascii "$v1"
	text_reg_4: .ascii "$a0"
	text_reg_5: .ascii "$a1"
	text_reg_6: .ascii "$a2"
	text_reg_7: .ascii "$a3"
	text_reg_8: .ascii "$t0"
	text_reg_9: .ascii "$t1"
	text_reg_10: .ascii "$t2"
	text_reg_11: .ascii "$t3"
	text_reg_12: .ascii "$t4"
	text_reg_13: .ascii "$t5"
	text_reg_14: .ascii "$t6"
	text_reg_15: .ascii "$t7"
	text_reg_16: .ascii "$s0"
	text_reg_17: .ascii "$s1"
	text_reg_18: .ascii "$s2"
	text_reg_19: .ascii "$s3"
	text_reg_20: .ascii "$s4"
	text_reg_21: .ascii "$s5"
	text_reg_22: .ascii "$s6"
	text_reg_23: .ascii "$s7"
	text_reg_24: .ascii "$t8"
	text_reg_25: .ascii "$t9"
	text_reg_26: .ascii "$k0"
	text_reg_27: .ascii "$k1"
	text_reg_28: .ascii "$gp"
	text_reg_29: .ascii "$sp"
	text_reg_30: .ascii "$fp"
	text_reg_31: .ascii "$ra"

.text

.globl main

main:
	jal open_read_file               # chama procedimento de abertura do arquivo de leitura
	
	jal open_write_file              # chama procedimento de abertura do arquivo de escrita
	
	

	redo:
		
	jal read_instruction             # chama procedimento de leitura da instru�ao completa
					 # $v0 = quantia de chars lidos
	move $s0, $v0			 # mode quantia de chars lidos para $s0 (preserva entre chamadas)
	
	ble $s0, 0, skip	 	 # se est� no end of file, quebra loop (se chars < 0, entao end of file ou erro)
	
	jal write_address
	jal print_space
	
	jal write_hex_instruction
	jal print_space
	
	jal isolate_fields
	
	jal decode_instruction
	jal print_line_break
	
	j redo
	skip:
	
	jal close_file
	
	j exit

open_read_file:
	# nao altera pilha
	
	# chamada para abertura do arquivo
	# cujo path est� no endere�o de file_address
	
	li $v0, 13               # carrega c�digo da syscall de abertura de arquivo
	la $a0, file_address     # carrega endere�o da string do caminho do arquivo
	li $a1, 0                # flags = 0, read-only
	li $a2, 0                # mode = 0
	syscall
	
	sw $v0, file_descriptor_read  # salva na mem�ria o file descriptor
	
	jr $ra

open_write_file:
	# nao altera pilha
	
	# chamada para abertura do arquivo
	# cujo path est� no endere�o de file_address
	
	li $v0, 13               # carrega c�digo da syscall de abertura de arquivo
	la $a0, output_file_address     # carrega endere�o da string do caminho do arquivo
	li $a1, 1                # flags = 9, write and append
	li $a2, 0                # mode = 0
	syscall
	
	sw $v0, file_descriptor_write  # salva na mem�ria o file descriptor
	
	jr $ra

read_instruction:
	# chamada para ler do arquivo uma instru�ao
	lw $a0, file_descriptor_read   # descritor do arquivo em a0
	la $a1, input_buffer      # endere�o do buffer em a1
	li $a2, 4                 # numero de caracteres a serem lidos (4 bytes = 32 bits = 1 instru�ao)
	li $v0, 14                # c�digo da syscall de leitura de arquivo
	syscall
	
	# $v0 guarda quantos chars lemos
	
	jr $ra	
	
	
#   Mapa da pilha   #
# $ra   =   $sp + 0 #	
print_hex_switch:
	addiu $sp, $sp, -4    	# cria uma pilha para uma word
	sw $ra, 0($sp)	     	# guarda o endere�o de retorno na pilha
	
	#	recebe em t2 o parametro	#
	move $t2, $a0		# t2 = a0
	
	#	preparando impressao	#
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write   # carrega descritor do arquivo de output
	la $a1, output_buffer	        # carrega endere�o do buffer de output
	li $a2, 1                       # quantidade de chars a serem escritos
	
	# 	switch($t2) 	#
	beq $t2, 0, print0
	beq $t2, 1, print1
	beq $t2, 2, print2
	beq $t2, 3, print3
	beq $t2, 4, print4
	beq $t2, 5, print5
	beq $t2, 6, print6
	beq $t2, 7, print7
	beq $t2, 8, print8
	beq $t2, 9, print9
	beq $t2, 10, print10
	beq $t2, 11, print11
	beq $t2, 12, print12
	beq $t2, 13, print13
	beq $t2, 14, print14
	beq $t2, 15, print15	
	j end_switch_hex_print

	print0:
		li $t3, '0'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print1:
		li $t3, '1'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print2:
		li $t3, '2'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print3:
		li $t3, '3'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print4:
		li $t3, '4'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print5:
		li $t3, '5'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print6:
		li $t3, '6'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print7:
		li $t3, '7'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print8:
		li $t3, '8'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print9:
		li $t3, '9'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print10:
		li $t3, 'A'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print11:
		li $t3, 'B'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print12:
		li $t3, 'C'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print13:
		li $t3, 'D'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print14:
		li $t3, 'E'
		sw $t3, output_buffer
		syscall
		j end_switch_hex_print
	print15:
		li $t3, 'F'
		sw $t3, output_buffer
		syscall
	
	end_switch_hex_print:
	
	lw $ra, ($sp)         # carrega o endere�o de retorno em $ra
	addiu $sp, $sp, 4     # destroi a pilha
	jr $ra		      # volta para a fun��o chamadora

#   Mapa da pilha   #
# $ra   =   $sp + 0 #
print_0x:
	########################
	# imprime "0x" na frente
	addiu $sp, $sp, -4    # cria uma pilha para uma word
	sw $ra, 0($sp)	      # guarda o endere�o de retorno na pilha
	
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write   # carrega descritor do arquivo de output
	la $a1, hex_prefix              # carrega endere�o do buffer de output
	li $a2, 2                       # quantidade de chars a serem escritos
	syscall
	
	lw $ra, ($sp)         # carrega o endere�o de retorno em $ra
	addiu $sp, $sp, 4     # destroi a pilha
	jr $ra		      # volta para a fun��o chamadora
	

print_space:
	########################
	# imprime espa�o " "
	
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write    # carrega descritor do arquivo de output
	la $a1, space_suffix             # carrega endere�o do buffer de output
	li $a2, 5                        # quantidade de chars a serem escritos
	syscall
	
	jr $ra
	

print_single_space:
	########################
	# imprime espa�o " "
	
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write    # carrega descritor do arquivo de output
	la $a1, space_suffix             # carrega endere�o do buffer de output
	li $a2, 1                        # quantidade de chars a serem escritos
	syscall
	
	jr $ra
	
print_line_break:
	########################
	# imprime quebra linha "\n"
	
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write    # carrega descritor do arquivo de output
	la $a1, line_break               # carrega endere�o do buffer de output
	li $a2, 1                        # quantidade de chars a serem escritos
	syscall
	
	jr $ra
	
print_comma:
	########################
	# imprime quebra linha "\n"
	
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write		# carrega descritor do arquivo de output
	la $a1, comma				# carrega endere�o do buffer de output
	li $a2, 2				# quantidade de chars a serem escritos
	syscall
	
	jr $ra
	
print_unknown:
	########################
	# imprime espa�o " "
	
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write    # carrega descritor do arquivo de output
	la $a1, unknown_instruction      # carrega endere�o do buffer de output
	li $a2, 23                       # quantidade de chars a serem escritos
	syscall
	
	jr $ra
	

#   Mapa da pilha   #
# $ra   =   $sp + 0 #
write_address:
	# chamada para escrever endereco em hexadecimal	
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal print_0x			# chama a fun��o para imprimir "0x"
	
	lw $t0, current_address		# carrega o endere�o atual em $t0
	lw $t1, mask_4_bits   		# carrega mascara em $t1
	li $t4, 32
	
	j check_loop_endereco
	
	loop_endereco:
	
	addiu $t4, $t4, -4		# $t4 = $t4 - 4
	
	srlv $t2, $t0, $t4     	# $t2 = $t0 shiftado a direita por $t4 bits
	and $t2, $t2, $t1      	# isola �ltimos 4 bits
	
	move $a0, $t2		# define o valor em $t2 como parametro passado 
	jal print_hex_switch	# chama a fun��o para imprimir um hexa
	
	check_loop_endereco:
	bge $t4, 4, loop_endereco
		
	
	lw $t0, current_address		# carrega em $t0 o valor do endere�o
	addiu $t0, $t0, 4		# adiciona 4 para o endere�o
	sw $t0, current_address		# guarda o novo valor de $t0 no endere�o
	
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra
	
#   Mapa da pilha   #
# $ra   =   $sp + 0 #			
write_hex_instruction:
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal print_0x 
	
	########################
	# imprime restante da instru�ao em hexadecimal

	lw $t0, input_buffer   # carrega instrucao em $t0
	lw $t1, mask_4_bits    # carrega mascara em $t1
	
	li $t4, 32             # $t4 = 32 (deslocamento inicial)

	j check_condition_hex_instruction
	
	loop_hex_instruction:
	
	addiu $t4, $t4, -4     # diminui em 4 bits a quantidade shiftada
		
	srlv $t2, $t0, $t4     # $t2 = $t0 shiftado a direita por $t4 bits
	and $t2, $t2, $t1      # isola �ltimos 4 bits
		
	move $a0, $t2		# define o valor em $t2 como parametro passado 
	jal print_hex_switch	# chama a fun��o para imprimir um hexa
	
	check_condition_hex_instruction:
	bge $t4, 4, loop_hex_instruction
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra
	
	
# Mapa da pilha #
# $ra = &sp + 0 #
print_register:
	# fun��o que recebe o valor em bin�rio do registrador e printo o equivalente
	addiu $sp, $sp, -4
	sw $ra, 0($sp)

	move $t9, $a0		# $t0 recebe o valor em $a0 (registrador parametro)
	
	#	preparando impressao	#
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write   # carrega descritor do arquivo de output
	li $a2, 3                       # quantidade de chars a serem escritos
	
	#	switch da impressao	#
	
	beq $t9, 0, print_zero
	beq $t9, 1, print_at
	beq $t9, 2, print_v0
	beq $t9, 3, print_v1
	beq $t9, 4, print_a0
	beq $t9, 5, print_a1
	beq $t9, 6, print_a2
	beq $t9, 7, print_a3
	beq $t9, 8, print_t0
	beq $t9, 9, print_t1
	beq $t9, 10, print_t2
	beq $t9, 11, print_t3
	beq $t9, 12, print_t4
	beq $t9, 13, print_t5
	beq $t9, 14, print_t6
	beq $t9, 15, print_t7
	beq $t9, 16, print_s0
	beq $t9, 17, print_s1
	beq $t9, 18, print_s2
	beq $t9, 19, print_s3
	beq $t9, 20, print_s4
	beq $t9, 21, print_s5
	beq $t9, 22, print_s6
	beq $t9, 23, print_s7
	beq $t9, 24, print_t8
	beq $t9, 25, print_t9
	beq $t9, 26, print_k0
	beq $t9, 27, print_k1
	beq $t9, 28, print_gp
	beq $t9, 29, print_sp
	beq $t9, 30, print_fp
	beq $t9, 31, print_ra
	
	j end_switch_register
	
	print_zero:
		la $a1, text_reg_0	# carrega em $t1 a string "$zero"
		li $a2, 5  		# define a quantidade de caracteres a serem impressos como 5 (unico registrador com nome diferente de 3 char)
		syscall
		j end_switch_register
		
	print_at:
		la $a1, text_reg_1	# carrega em $t1 a string "$at"
		syscall
		j end_switch_register
		
	print_v0:
		la $a1, text_reg_2	# carrega em $t1 a string "$v0"
		syscall
		j end_switch_register
		
	print_v1:
		la $a1, text_reg_3	# carrega em $t1 a string "$v1"
		syscall
		j end_switch_register
		
	print_a0:
		la $a1, text_reg_4	# carrega em $t1 a string "$a0"
		syscall
		j end_switch_register
		
	print_a1:
		la $a1, text_reg_5	# carrega em $t1 a string "$a1"
		syscall
		j end_switch_register
		
	print_a2:
		la $a1, text_reg_6	# carrega em $t1 a string "$a2"
		syscall
		j end_switch_register
		
	print_a3:
		la $a1, text_reg_7	# carrega em $t1 a string "$a3"
		syscall
		j end_switch_register
		
	print_t0:
		la $a1, text_reg_8	# carrega em $t1 a string "$t0"
		syscall
		j end_switch_register
		
	print_t1:
		la $a1, text_reg_9	# carrega em $t1 a string "$t1"
		syscall
		j end_switch_register
		
	print_t2:
		la $a1, text_reg_10	# carrega em $t1 a string "$t2"
		syscall
		j end_switch_register
		
	print_t3:
		la $a1, text_reg_11	# carrega em $t1 a string "$t3"
		syscall
		j end_switch_register
		
	print_t4:
		la $a1, text_reg_12	# carrega em $t1 a string "$t4"
		syscall
		j end_switch_register
		
	print_t5:
		la $a1, text_reg_13	# carrega em $t1 a string "$t5"
		syscall
		j end_switch_register
		
	print_t6:
		la $a1, text_reg_14	# carrega em $t1 a string "$t6"
		syscall
		j end_switch_register
		
	print_t7:
		la $a1, text_reg_15	# carrega em $t1 a string "$t7"
		syscall
		j end_switch_register
		
	print_s0:
		la $a1, text_reg_16	# carrega em $t1 a string "$s0"
		syscall
		j end_switch_register
		
	print_s1:
		la $a1, text_reg_17	# carrega em $t1 a string "$s1"
		syscall
		j end_switch_register
		
	print_s2:
		la $a1, text_reg_18	# carrega em $t1 a string "$s2"
		syscall
		j end_switch_register
		
	print_s3:
		la $a1, text_reg_19	# carrega em $t1 a string "$s3"
		syscall
		j end_switch_register
		
	print_s4:
		la $a1, text_reg_20	# carrega em $t1 a string "$s4"
		syscall
		j end_switch_register
		
	print_s5:
		la $a1, text_reg_21	# carrega em $t1 a string "$s5"
		syscall
		j end_switch_register
		
	print_s6:
		la $a1, text_reg_22	# carrega em $t1 a string "$s6"
		syscall
		j end_switch_register
		
	print_s7:
		la $a1, text_reg_23	# carrega em $t1 a string "$s7"
		syscall
		j end_switch_register
		
	print_t8:
		la $a1, text_reg_24	# carrega em $t1 a string "$t8"
		syscall
		j end_switch_register
		
	print_t9:
		la $a1, text_reg_25	# carrega em $t1 a string "$t9"
		syscall
		j end_switch_register
		
	print_k0:
		la $a1, text_reg_26	# carrega em $t1 a string "$k0"
		syscall
		j end_switch_register
		
	print_k1:
		la $a1, text_reg_27	# carrega em $t1 a string "$k1"
		syscall
		j end_switch_register
		
	print_gp:
		la $a1, text_reg_28	# carrega em $t1 a string "$gp"
		syscall
		j end_switch_register
		
	print_sp:
		la $a1, text_reg_29	# carrega em $t1 a string "$sp"
		syscall
		j end_switch_register
		
	print_fp:
		la $a1, text_reg_30	# carrega em $t1 a string "$fp"
		syscall
		j end_switch_register
		
	print_ra:
		la $a1, text_reg_31	# carrega em $t1 a string "$ra"
		syscall
		
		
	end_switch_register:

	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra

reverse_string:
	# a0 = &string[0]
	# a1 = len(string)
	
	# define sizeof(char) = 4 bytes -> arbitr�rio p/ alinhamento
	
	move $t0, $a0
	move $t1, $a1
	
	j check_condition_string
	
	loop_string:
		
		addiu $t1, $t1, -1	# diminui indice em 1
		sll $t2, $t1, 2		# multiplica por 4 para alinhar na memoria
		add $t2, $t2, $t0	# soma &string[0] + indice*4, ou seja $t2 = &string[indice]
		
		li $v0, 15                         # carrega c�digo da syscall de escrita em arquivo

		lw $a0, file_descriptor_write	   # carrega descritor do arquivo de output
		
		move $a1, $t2		           # carrega endere�o do buffer de output
		li $a2, 1			   # quantidade de chars a serem escritos
	
		syscall
	
	check_condition_string:
	
	bgt $t1, 0, loop_string
	
	jr $ra
	

#   Mapa da pilha:
# string[0] = $sp + 0
# string[1] = $sp + 4
# ...
# string[9] = $sp + 36
# $ra = $sp + 40	

binary_to_decimal:	
	# converte o n�mero em bin�rio para decimal em ASCII
	# recebe valor em $a0
	move $t1, $a0
	
	li $t5, 0       # $t5 = indice da string para salvar
	
	# ajusta a pilha, cria vetor da string
	addiu $sp, $sp, -44
	sw $ra, 40($sp)
	
	
	## caso seja 0:
	bne $t1, 0, skip_zero_adjustment
	
	## caso seja 0 o imm: #####
	li $t2, '0'
	sw $t2, output_buffer
	
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write		# carrega descritor do arquivo de output
	la $a1, output_buffer			# carrega endere�o do buffer de output
	li $a2, 1				# quantidade de chars a serem escritos
	syscall
	
	lw $ra, 40($sp)
	addiu $sp, $sp, 44
	jr $ra  # return;
	
	###########################
	
	skip_zero_adjustment:
	li $t4, 0x00008000                       # mascara que isola primeiro bit dos 16 bits do imm
	and $t4, $t1, $t4                        # isola o primeiro bit
	beq $t4, 0, condition_check_conversion   # pula c�digo caso 0 (imm positivo)
	
	## caso seja negativo ##
	
	li $t4, 0xFFFF0000  
	or $t1, $t1, $t4
	not $t1, $t1
	addiu $t1, $t1, 1
	
	# imprime tra�o, indicando n�mero negativo
	addiu $t2, $zero, '-'
	sw $t2, output_buffer
	
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write		# carrega descritor do arquivo de output
	la $a1, output_buffer			# carrega endere�o do buffer de output
	li $a2, 1				# quantidade de chars a serem escritos
	syscall
	
	#####################################
	# CONVERSAO NUMERICA REAL COME�A AQUI
	j condition_check_conversion
	
	loop_back_conversion:
	
	li $t3, 10
	div $t1, $t3    # divide $t1 por 10
	mfhi $t2        # $t2 = resto
	mflo $t1        # $t1 = quociente
	
	addiu $t2, $t2, '0'
	
	# multiplica o �ndice contido em $t5 por 4
	sll $t6, $t5, 2
	add $t6, $sp, $t6  # $t6 = string[indice]
	sw $t2, ($t6)      # string[indice] = digito atual (contido em $t2)
	
	addiu $t5, $t5, 1  # indice++
	
	condition_check_conversion:
		
	bgt $t1, 0, loop_back_conversion  # se o numero continuar maior que 0, loop
	
	move $a0, $sp
	move $a1, $t5
	jal reverse_string   	# chama fun�ao que imprime string invertida
				# argumentos: $a0 = &string[0] e $a1 = len(string)
	
	lw $ra, 40($sp)         # restaura $ra
	addiu $sp, $sp, 44      # destroi a pilha
	jr $ra                  # return;
	
# Mapa da pilha #
# $ra = &sp + 0 #	
print_numerical_imm:
	# chamada para printar valor num�rico do imediato
	# usado para as instru�oes addi, addiu
	
	addiu $sp, $sp, -4      # ajusta a pilha
	sw $ra, 0($sp)          # salva $ra na pilha
	
	lw $a0, current_imm
	jal binary_to_decimal
	
	lw $ra, 0($sp)          # restaura $ra
	addiu $sp, $sp, 4	# destroi a pilha
	jr $ra			# return;
	
# Mapa da pilha #
# $ra = &sp + 0 #	
print_address_from_imm:
	# chamada para printar valor do imediato
	
	addiu $sp, $sp, -4      # ajusta a pilha
	sw $ra, 0($sp)          # salva $ra na pilha
	
	jal print_0x
	
	lw $t0, current_imm	# carrega imm
	sll $t0, $t0, 2		# shifta imm em 2 bits
	
	lw $t1, mask_4_bits
	
	lw $t2, current_address # carrega endere�o atual
	addu $t0, $t2, $t0	# adiciona os valores para ter endere�o efetivo
	
	li $t4, 32
	
	j check_loop_endereco_imm
	
	loop_endereco_imm:
	
	addiu $t4, $t4, -4		# $t4 = $t4 - 4
	
	srlv $t2, $t0, $t4     	# $t2 = $t0 shiftado a direita por $t4 bits
	and $t2, $t2, $t1      	# isola �ltimos 4 bits
	
	move $a0, $t2		# define o valor em $t2 como parametro passado 
	jal print_hex_switch	# chama a fun��o para imprimir um hexa
	
	check_loop_endereco_imm:
	
	bge $t4, 4, loop_endereco_imm
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra


print_open_parentheses:
	li $t0, '('
	sw $t0, output_buffer
	
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write		# carrega descritor do arquivo de output
	la $a1, output_buffer			# carrega endere�o do buffer de output
	li $a2, 1				# quantidade de chars a serem escritos
	syscall
	
	jr $ra
	
print_close_parentheses:
	li $t0, ')'
	sw $t0, output_buffer
	
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo

	lw $a0, file_descriptor_write		# carrega descritor do arquivo de output
	la $a1, output_buffer			# carrega endere�o do buffer de output
	li $a2, 1				# quantidade de chars a serem escritos
	syscall
	
	jr $ra
	
	
# Mapa da pilha #
# $ra = &sp + 0 #	
print_shift_address_from_imm:
	# chamada para printar valor do imediato
	
	addiu $sp, $sp, -4      # ajusta a pilha
	sw $ra, 0($sp)          # salva $ra na pilha
	
	lw $a0, current_imm
	jal binary_to_decimal
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra				
	

# Mapa da pilha #
# $ra = &sp + 0 #	
print_address_from_target:
	# chamada para printar valor do target
	
	addiu $sp, $sp, -4      # ajusta a pilha
	sw $ra, 0($sp)          # salva $ra na pilha
	
	jal print_0x
	
	lw $t0, current_target	# carrega imm
	sll $t0, $t0, 2		# shifta imm em 2 bits
	
	lw $t1, mask_4_bits	# carrega m�scara para isolar grupos de 4 em 4 bits
	li $t4, 32		# contador para impressao
	
	j check_loop_endereco_target
	
	loop_endereco_target:
	
	addiu $t4, $t4, -4		# $t4 = $t4 - 4
	
	srlv $t2, $t0, $t4     	# $t2 = $t0 shiftado a direita por $t4 bits
	and $t2, $t2, $t1      	# isola �ltimos 4 bits
	
	move $a0, $t2		# define o valor em $t2 como parametro passado 
	jal print_hex_switch	# chama a fun��o para imprimir um hexa
	
	check_loop_endereco_target:
	
	bge $t4, 4, loop_endereco_target
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	
	jr $ra			


isolate_fields:
	# chamada para decodificar uma instru�ao lida
	
	# $t1 mant�m instru�ao completa at� o fim do procedimento
	
	##### opcode
	lw $t0, op_code_mask  # carrega em $t0 a m�scara que isola 6 bits da intrucao
	lw $t1, input_buffer  # carrega instrucao completa
	
	and $t2, $t0, $t1     # faz and l�gico entre m�scara e instru�ao lida
			      # isolando apenas op code (contido agora em $t2)
	
	srl $t2, $t2, 26      # desloca opcode  
	sw $t2, current_op    # salva opcode em vari�vel global

	##### rs
	lw $t0, rs_mask       # carrega em $t0 a m�scara que isola o campo rs
	and $t2, $t0, $t1     # faz and l�gico entre m�scara e instru�ao lida
			      # isolando apenas campo rs (contido agora em $t2)
	
	srl $t2, $t2, 21      # desloca rs  
	sw $t2, current_rs    # salva rs em vari�vel global
	
	##### rt
	lw $t0, rt_mask       # carrega em $t0 a m�scara que isola o campo rt
	and $t2, $t0, $t1     # faz and l�gico entre m�scara e instru�ao lida
			      # isolando apenas campo rt (contido agora em $t2)
	
	srl $t2, $t2, 16      # desloca rt  
	sw $t2, current_rt    # salva rt em vari�vel global
	
	##### rd
	lw $t0, rd_mask       # carrega em $t0 a m�scara que isola o campo rd
	and $t2, $t0, $t1     # faz and l�gico entre m�scara e instru�ao lida
			      # isolando apenas campo rd (contido agora em $t2)
	
	srl $t2, $t2, 11      # desloca rd  
	sw $t2, current_rd    # salva rd em vari�vel global
	
	##### shamt
	lw $t0, shamt_mask    # carrega em $t0 a m�scara que isola o campo shamt
	and $t2, $t0, $t1     # faz and l�gico entre m�scara e instru�ao lida
			      # isolando apenas campo shamt (contido agora em $t2)
	
	srl $t2, $t2, 6       # desloca shamt 
	sw $t2, current_shamt # salva shamt em vari�vel global
	
	
	##### funct
	lw $t0, funct_mask    # carrega em $t0 a m�scara que isola o campo funct
	and $t2, $t0, $t1     # faz and l�gico entre m�scara e instru�ao lida
			      # isolando apenas campo funct (contido agora em $t2)
	
	sw $t2, current_funct # salva funct em vari�vel global
	
	
	##### imm
	lw $t0, imm_mask      # carrega em $t0 a m�scara que isola o campo imm
	and $t2, $t0, $t1     # faz and l�gico entre m�scara e instru�ao lida
			      # isolando apenas campo imm (contido agora em $t2)
	 
	sw $t2, current_imm   # salva imm em vari�vel global


	##### target
	lw $t0, target_mask    # carrega em $t0 a m�scara que isola o campo target
	and $t2, $t0, $t1      # faz and l�gico entre m�scara e instru�ao lida
			       # isolando apenas campo target (contido agora em $t2)
	 
	sw $t2, current_target # salva target em vari�vel global
	
	jr $ra



#	mapa da pilha		#
#	$ra = sp + 0		#
decode_instruction:
	lw $t0, current_op
	
	addiu $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $v0, 15            # carrega c�digo da syscall de escrita em arquivo
	lw $a0, file_descriptor_write   # carrega descritor do arquivo de output
	
	# switch(current_op)
	beq $t0, 0, op_0
	beq $t0, 2, op_2
	beq $t0, 3, op_3
	beq $t0, 5, op_5
	beq $t0, 8, op_8
	beq $t0, 9, op_9
	beq $t0, 13, op_13
	beq $t0, 15, op_15
	beq $t0, 28, op_28
	beq $t0, 35, op_35
	beq $t0, 43, op_43
	j default
	
	op_0:
		# further decoding needed for opcodes 0 (many possibilities)
		lw $t1, current_funct 		# carrega em t1 a funct (tem mais de uma possibilidade para opcode 0)
		beq $t1, 32, op_add		# se funct = 0x20, goto op_add
		beq $t1, 33, op_addu		# se funct = 0x21, goto op_addu
		beq $t1, 12, op_syscall		# se funct = 0xC, goto op_syscall
		beq $t1, 8, op_jr
		j default
		
		op_add:
		
			la $a1, text_op_0_add	# printa "add"
			li $a2, 3
			syscall
			jal print_single_space
			
			lw $a0, current_rd	# carrega o rd
			jal print_register	# chama a fun��o para printar o rd
			jal print_comma		# adiciona a virgula
			
			lw $a0, current_rs	# carrega o rs
			jal print_register	# chama a fun��o para printar o rs
			jal print_comma		# adiciona a virgula
			
			lw $a0, current_rt	# carrega o rt
			jal print_register	# chama a fun��o para printar o rt
			
			j end_ops_switch
		
		op_addu:
		
			la $a1, text_op_0_addu	# printa "add"
			li $a2, 4
			syscall
			jal print_single_space
			
			lw $a0, current_rd	# carrega o rd
			jal print_register	# chama a fun��o para printar o rd
			jal print_comma		# adiciona a virgula
			
			lw $a0, current_rs	# carrega o rs
			jal print_register	# chama a fun��o para printar o rs
			jal print_comma		# adiciona a virgula
			
			lw $a0, current_rt	# carrega o rt
			jal print_register	# chama a fun��o para printar o rt
		
			j end_ops_switch
			
		op_syscall:
			la $a1, text_op_sys	# printa "syscall"
			li $a2, 7
			syscall
			
			j end_ops_switch
			
		op_jr:
			la $a1, text_op_jr	# printa "jr"
			li $a2, 2
			syscall
			jal print_single_space
			
			lw $a0, current_rs	# carrega o rs
			jal print_register	# chama a fun��o para printar o rs
			
			j end_ops_switch
		
	op_2:
		la $a1, text_op_2               # carrega endere�o do buffer de output
		li $a2, 1                       # quantidade de chars a serem escritos
		syscall
		
		jal print_single_space
		jal print_address_from_target
		
		j end_ops_switch
		
	op_3:
		la $a1, text_op_3               # carrega endere�o do buffer de output
		li $a2, 3                       # quantidade de chars a serem escritos
		syscall
		
		jal print_single_space
		jal print_address_from_target
	
		j end_ops_switch
		
	op_5:
		la $a1, text_op_5               # carrega endere�o do buffer de output
		li $a2, 3                       # quantidade de chars a serem escritos
		syscall
		jal print_single_space
		
		lw $a0, current_rs		# carrega o rs
		jal print_register		# chama a fun��o para printar o rs
		jal print_comma			# adiciona a virgula
		
		lw $a0, current_rt		# carrega o rt
		jal print_register		# chama a fun��o para printar o rt
		jal print_comma			# adiciona a virgula
			
		jal print_address_from_imm
		
		j end_ops_switch
		
	op_8:
		la $a1, text_op_8               # carrega endere�o do buffer de output
		li $a2, 4                       # quantidade de chars a serem escritos
		syscall
		jal print_single_space
		
		lw $a0, current_rt	# carrega o rt
		jal print_register	# chama a fun��o para printar o rt
		jal print_comma		# adiciona a virgula
			
		lw $a0, current_rs	# carrega o rs
		jal print_register	# chama a fun��o para printar o rs
		
		jal print_comma		# adiciona a virgula
		jal print_numerical_imm # chama a fun��o para printar o imm
		
		j end_ops_switch
	
	op_9:
		la $a1, text_op_9               # carrega endere�o do buffer de output
		li $a2, 5                       # quantidade de chars a serem escritos
		syscall
		jal print_single_space
		
		lw $a0, current_rt	# carrega o rt
		jal print_register	# chama a fun��o para printar o rt
		jal print_comma		# adiciona a virgula
			
		lw $a0, current_rs	# carrega o rs
		jal print_register	# chama a fun��o para printar o rs
		
		jal print_comma		# adiciona a virgula
		jal print_numerical_imm # chama a fun��o para printar o imediato
		
		j end_ops_switch
		
	op_13:
		la $a1, text_op_13              # carrega endere�o do buffer de output
		li $a2, 3                       # quantidade de chars a serem escritos
		syscall
		jal print_single_space
		
		lw $a0, current_rt	# carrega o rt
		jal print_register	# chama a fun��o para printar o rs
		jal print_comma		# adiciona a virgula

		lw $a0, current_rs	# carrega o rs
		jal print_register	# chama a fun��o para printar o rs
		
		jal print_comma		# adiciona a virgula
		jal print_numerical_imm # chama a fun�ao para printar o imediato
		
		j end_ops_switch
		
	op_15:
		la $a1, text_op_15              # carrega endere�o do buffer de output
		li $a2, 3                       # quantidade de chars a serem escritos
		syscall
		jal print_single_space
		
		lw $a0, current_rt	# carrega o rt
		jal print_register	# chama a fun��o para printar o rs
		jal print_comma		# adiciona a virgula
		
		jal print_numerical_imm # chama a fun�ao para printar o imediato
		
		j end_ops_switch
			
	op_28:
		lw $t1, current_funct		# carrega em $t1 o valor de funct atual
		beq $t1, 2, op_mul		# se funct = 0x2 goto op_mul
		beq $t1, 0, op_madd		# se funct = 0x0 goto op_madd
		beq $t1, 1, op_maddu		# se funct = 0x1 goto op_maddu
		beq $t1, 4, op_msub		
		beq $t1, 5, op_msub		# se funct = 0x4 ou funct = 0x5 goto op_msub
		j default
		
		
		op_mul:
			la $a1, text_op_28_mul	# printa "mul"
			li $a2, 3
			syscall
			jal print_single_space
			
			lw $a0, current_rd	# carrega o rd
			jal print_register	# chama a fun��o para printar o rd
			jal print_comma		# adiciona a virgula
			
			lw $a0, current_rs	# carrega o rs
			jal print_register	# chama a fun��o para printar o rs
			jal print_comma		# adiciona a virgula
			
			lw $a0, current_rt	# carrega o rt
			jal print_register	# chama a fun��o para printar o rt
		
			j end_ops_switch
		
		op_madd:
			la $a1, text_op_28_madd	# printa "madd"
			li $a2, 4
			syscall
			jal print_single_space
			
			lw $a0, current_rs	# carrega o rs
			jal print_register	# chama a fun��o para printar o rs
			jal print_comma		# adiciona a virgula
			
			lw $a0, current_rt	# carrega o rt
			jal print_register	# chama a fun��o para printar o rt
		
			j end_ops_switch
		
		op_maddu:
			la $a1, text_op_28_maddu	# printa "madd"
			li $a2, 4
			syscall
			jal print_single_space
			
			lw $a0, current_rs	# carrega o rs
			jal print_register	# chama a fun��o para printar o rs
			jal print_comma		# adiciona a virgula
			
			lw $a0, current_rt	# carrega o rt
			jal print_register	# chama a fun��o para printar o rt
		
			j end_ops_switch
		
		op_msub:
			la $a1, text_op_28_maddu	# printa "madd"
			li $a2, 4
			syscall
			jal print_single_space
			
			lw $a0, current_rs	# carrega o rs
			jal print_register	# chama a fun��o para printar o rs
			jal print_comma		# adiciona a virgula
			
			lw $a0, current_rt	# carrega o rt
			jal print_register	# chama a fun��o para printar o rt
		
			j end_ops_switch
		
	op_35:
		la $a1, text_op_35              # carrega endere�o do buffer de output
		li $a2, 2                       # quantidade de chars a serem escritos
		syscall
		jal print_single_space
		
		lw $a0, current_rt	# carrega o rt
		jal print_register	# chama a fun��o para printar o rs
		jal print_comma		# adiciona a virgula
		
		jal print_shift_address_from_imm
		jal print_open_parentheses
		
		lw $a0, current_rs	# carrega o rs
		jal print_register	# chama a fun��o para printar o rs
		
		jal print_close_parentheses
		
		j end_ops_switch
		
	op_43:
		la $a1, text_op_43              # carrega endere�o do buffer de output
		li $a2, 2                       # quantidade de chars a serem escritos
		syscall
		jal print_single_space
		
		lw $a0, current_rt	# carrega o rt
		jal print_register	# chama a fun��o para printar o rs
		jal print_comma		# adiciona a virgula
		
		jal print_shift_address_from_imm
		jal print_open_parentheses
		
		lw $a0, current_rs	# carrega o rs
		jal print_register	# chama a fun��o para printar o rs
		
		jal print_close_parentheses
		
		j end_ops_switch
		
	default:
		jal print_unknown
	
		
	end_ops_switch:
	
	lw $ra, 0($sp)
	addiu $sp, $sp, 4
	jr $ra
		
		
############################
close_file:
	# chamada para fechar arquivo
	li $v0, 16       
	lw $a0, file_descriptor_read
	syscall
	
	jr $ra
  
exit:
	
