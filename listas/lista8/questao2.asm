.data
	g1: .space 4
	g2: .space 4
	
.text
	j main
	
	# int incrementa2(int *y)    $a0 = int *y
	# procedimento folha, nao precisa salvar $ra
	# podemos manter $a0 em si mesmo
	# assim, nao é preciso ajustar a pilha
	
	incrementa2:
		lw $t0, 0($a0)      # $t0 = *y
		addiu $t0, $t0, 1   # $t0 = *y + 1
		sw $t0, ($a0)       # *y = *y + 1
		
		move $v0, $t0       # return x;
		jr $ra              # finaliza procedimento
		
		
	# int incrementa1(int x)     $a0 = int x
	# procedimento folha, nao precisa salvar $ra
	# podemos manter $a0 em si mesmo
	# assim, nao é preciso ajustar a pilha
	
	incrementa1:
		move $t0, $a0       # $t0 = x
		addiu $t0, $t0, 1   # $t0 = x + 1
		
		move $v0, $t0       # return x;
		jr $ra              # finaliza procedimento
	
		
	# int main()
	
	# mapa da pilha:
	
	# $ra  = $sp + 8
	# inc1 = $sp + 4
	# inc2 = $sp + 0
		
	main:
		la $s0, g1           # carrega endereço das variáveis globais       
		la $s1, g2
		
		addiu $sp, $sp, -12  # ajusta a pilha
		sw $ra, 8($sp)       # guarda $ra
		
		li $t0, 10
		sw $t0, 0($s0)       # g1 = 10
		sw $t0, 0($s1)	     # g2 = 10
		
		lw $a0, 0($s0)       # $a0 = g1
		jal incrementa1      # incrementa1(g1);
		# $v0 contém o retorno
		sw $v0, 4($sp)
		move $t1, $v0        # apenas para depuraçao

		move $a0, $s1         # $a0 = &g2
		jal incrementa2       # incrementa2(&g2);	
		# $v0 contém o retorno
		sw $v0, 0($sp)
		move $t2, $v0        # apenas para depuraçao
		
		lw $ra, 8($sp)       # restaura $ra
		li $v0, 0            # return 0;
		addiu $sp, $sp, 12   # destroi a pilha
		

	