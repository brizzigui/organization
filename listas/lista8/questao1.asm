.data 

	g1: .space 4

.text

	j main

	# int p3(int i, int y)      $a0 = i; $a1 = y
	p3:
		addiu $sp, $sp, -4  # ajusta a pilha para variável int c;
		and $v0, $a0, $a1
		sw $v0, 0($sp)      # c = i & y
		
		addiu $sp, $sp, 4   # destroi a pilha
		jr $ra
		# return c; $v0 contém c
		
	
	
	# int p2(int y)         # $a0 = y

	# mapa da pilha:
	
	# $ra        = $sp + 52
	# y          = $sp + 48
	# i          = $sp + 44
	# acumulador = $sp + 40
	# b[]        = $sp + 0
	
	
	p2:
		addiu $sp, $sp, -56  # ajusta a pilha (13*sizeof(int))
		sw $ra, 52($sp)      # guarda $ra na pilha pois p2 faz outras chamadas
		
		sw $a0, 48($sp)      # guarda $a0 (aka y) na pilha
		
     		li $t0, 0	# $t0 = 0
     		sw $t0, 40($sp) # acmulador = 0
     		
     		li $t0, 0       # $t0 = 0
     		sw $t0, 44($sp) # i = 0
     		
     		j p2_for_check_condition
     		
     		p2_for_code:
     		
     			lw $t2, 44($sp)
     			sll $t2, $t2, 2
     			addu $t2, $t2, $sp  # t2 = &b[i]
     			
     			lw $a0, 44($sp)	    # a0 = i
     			lw $a1, 48($sp)	    # a1 = y
     			
     			jal p3 		    # v0 = p3(i, y)
     			
     			add $t3, $v0, $a1   # t3 = p3(i, y) + y
     			sw $t3, 0($t2)      # b[i] = p3(i, y) + y;
     			
     			lw $t4, 40($sp)     # t4 = acumulador
     			add $t3, $t3, $t4   # t3 = acumulador + b[i]
     			
     			sw $t3, 40($sp)     # acumulador = acumulador + b[i]
     			
     			addi $t0, $t0, 1    # i++
     			sw $t0, 44($sp)
     			
    		p2_for_check_condition:
    		
    			slti $t1, $t0, 10     # $t1 = $t0 < 10
    			bne $t1, $zero, p2_for_code  # se $t1 != true: goto code
    		
    		lw $v0, 40($sp)     # return acumulador
    		lw $a0, 48($sp)     # restaura a0 = y
    		lw $ra, 52($sp)     # restaura $ra
    		
    		addiu $sp, $sp, 56  # destroi a pilha
    		jr $ra              # termina procedimento
    		
    	# int p1(int x)      $a0 = x
    	
	# mapa da pilha:
	
	# $ra     = $sp + 12
	# x       = $sp + 8
	# var_a1  = $sp + 4
	# var_a2  = $sp + 0
	
	p1:
	
		addiu $sp, $sp, -16  # ajusta a pilha (4*sizeof(int))
		
		sw $ra, 12($sp)      # guarda endereço de retorno
		sw $a0, 8($sp)       # guarda argumento $a0 (aka x)
		
		# $a0 = y
		# p2(x)
		jal p2
		# $v0 contém retorno
		
		sw $v0, 4($sp)     # var_a1 = p2(x)
		add $t0, $a0, $v0  # var_a2 = x + var_a1
		sw $t0, 0($sp)
		
		lw $v0, 0($sp)     # return var_a2
		lw $a0, 8($sp)	   # restora $a0 (aka x)
		
		lw $ra, 12($sp)    # restora $ra
		addiu $sp, $sp, 16 # destroi a pilha
		jr $ra		   # finaliza procedimento
		
	# int main()
	# mapa da pilha:
	
	# $ra       = $sp + 4
	# resultado = $sp + 0
	
	main:
		addiu $sp, $sp, -8   # ajusta a pilha (2*sizeof(int))
		
		sw $ra, 4($sp)       # guarda endereço de retorno $ra
		
		li $t0, 10
		la $s0, g1
		sw $t0, 0($s0)       # g1 = 10;
		
		lw $a0, 0($s0)       # $a0 = x
		# chama o procedimento p1(g1);
		jal p1
		# $v0 contém retorno
		sw $v0, 0($sp)
		
		move $t0, $v0        # apenas para fins de depuraçao
		
		addiu $v0, $zero, 0  # return 0
		lw $ra, 4($sp)       # restora $ra
		addiu $sp, $sp, 8    # destroi a pilha
		
		# jr $ra             # (em C, haveria outros procedimentos ocultos
				     # entao voltariamos para $ra, mas aqui nao há,
				     # entao deixei essa parte comentada.
				     
				     
		###### código da traduçao termina aqui ######
		
		li $v0, 1
		move $a0, $t0
		syscall
			