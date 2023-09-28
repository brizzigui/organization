# Trabalho 1 da disciplina de Organização de Computadores
# Implementou-se aqui a funçao de ler arquivo

# Ainda falta:
# - separaçao de opcode e demais instrucoes
# - comparacao de opcodes e instrucoes
# - escrita em arquivo

.data
	file_address: .asciiz "dados/ex-000-012.bin"
	input_buffer: .word 0
	file_descriptor: .word 0
	
	op_code_mask: .word 0xFC000000
	
	instrucao_teste: .asciiz "DEU CERTO"

.text

.globl main

main:
	jal open_file
	jal read_instruction
	jal decode_instruction
	bgt $s0, 0, read_instruction	 # se nao está no end of file, loop (se chars < 0, entao end of file ou erro)
	jal close_file
	j exit

open_file:
	# chamada para abertura do arquivo
	# cujo path está no endereço de file_address
	li $v0, 13
	la $a0, file_address
	li $a1, 0
	li $a2, 0
	syscall
	
	sw $v0, file_descriptor # salva na memória o file descriptor
	

read_instruction:
	# chamada para ler do arquivo uma instruçao
	lw $a0, file_descriptor   # descritor do arquivo em a0
	la $a1, input_buffer      # endereço do buffer em a1
	li $a2, 4                 # numero de caracteres a serem lidos (4 bytes = 32 bits = 1 instruçao)
	li $v0, 14                # código da syscall de leitura de arquivo
	syscall
	
	move $s0, $v0             # s0 guarda quantos chars lemos
	
			
decode_instruction:
	# chamada para decodificar uma instruçao lida
	lw $t0, op_code_mask
	lw $t1, input_buffer
	
	and $t2, $t0, $t1    # faz and lógico entre máscara e instruçao lida
			     # isolando apenas op code (contido agora em $t2)
			  
	srl $t2, $t2, 26
	bne $t2, 9, passei_dela  # pula para "passei dela:" se nao é a instruçao esperada
	
	sou_a_primeira_instrucao:
		
		# chamada para printar string lida do arquivo
		li $v0, 4                 # código da syscall de printar string
		la $a0, instrucao_teste      # endereço do buffer da string que lemos
		syscall
	
		j passei_dela

	# chamada para printar string lida do arquivo
	li $v0, 4                 # código da syscall de printar string
	la $a0, input_buffer      # endereço do buffer da string que lemos
	syscall
	
	passei_dela:
	
close_file:
	# chamada para fechar arquivo
	li $v0, 16       
	lw $a0, file_descriptor
	syscall
  
exit:
	
