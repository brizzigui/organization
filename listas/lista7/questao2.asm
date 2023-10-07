.data

	a: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	i: .space 4
	j: .space 4
	k: .space 4
	acc: .word 0
	
.text

	# i = 1
	addiu $t0, $zero, 1
	sw $t0, i
	
	# j = 2
	addiu $t0, $zero, 2
	sw $t0, j
	
	# k = 4
	addiu $t0, $zero, 4
	sw $t0, k
	
	addiu $t0, $zero, 1
	sw $t0, i
	
	# for (i = 1; i < 10; i++)
	loop:
		# a[i] = a[i - 1] + 19;
		
		la $t1, a
		move $t2, $t0
		sll $t2, 2
		
		# $t2 = &a[i]
		addu $t2, $t1, $t2
		
		# $t3 = a[i - 1]
		add $t3, $t0, -1
		sll $t3, $t3, 2
		addiu $t3, $t1, $t3
		
		lw $t3, ($t3)
		
		addiu $t3, $t3, 19
		sw $t3, ($t2)
		
		# atualiza i também na memória
		addiu $t0, $t0, 1
		sw $t0, i
		
		blt $t0, 10, loop
		
	end_for:

	
	
	