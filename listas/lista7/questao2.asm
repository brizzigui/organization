.data

	a: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	i: .space 4
	j: .space 4
	k: .space 4
	acc: .word 0
	
.text

main:
	la $s0, a
	la $s1, i
	la $s2, j
	la $s3, k
	la $s4, acc
	
	# i = 1
	addiu $t0, $zero, 1
	sw $t0, ($s1)
	
	# j = 2
	addiu $t0, $zero, 2
	sw $t0, ($s2)
	
	# k = 4
	addiu $t0, $zero, 4
	sw $t0, ($s3)
	
	addiu $t0, $zero, 1
	sw $t0, ($s1)
	
	# for (i = 1; i < 10; i++)
	loop:
		# a[i] = a[i - 1] + 19;
		
		move $t2, $t0
		sll $t2, $t2, 2
		
		# $t2 = &a[i]
		addu $t2, $s0, $t2
		
		# $t3 = a[i - 1]
		add $t3, $t0, -1
		sll $t3, $t3, 2
		addu $t3, $s0, $t3
		
		lw $t3, ($t3)
		
		addiu $t3, $t3, 19
		sw $t3, ($t2)
		
		# atualiza i também na memória
		addiu $t0, $t0, 1
		sw $t0, ($s1)
		
		blt $t0, 10, loop
		
	end_for:
	
	# i = 0
	addiu $t0, $zero, 0
	sw $t0, ($s1)
	
loop_2:	# for(i = 0; i < 10; i++)
		
		# j = i
		addiu $t1, $t0, 0
		sw $t1, ($s2)
		
loop_3:		# for (j = i; j < 10; j++)
			
			# acc = acc + a[j];
			
			lw $t2, ($s4) # carrega acc
			
			addiu $t3, $t1, 0  # $t3 = j
			sll $t3, $t3, 2    # $t3 *= 4
			add $t3, $t3, $s0 # $t3 = a + 4*j
			
			lw $t3, ($t3)      # $t3 = a[j]
			
			add $t2, $t2, $t3  # acc + a[j]
			sw $t2, ($s4)      # salva acc + a[j]
			
			addiu $t1, $t1, 1
			sw $t1, ($s2)
			blt $t1, 10, loop_3
		
	
		addiu $t0, $t0, 1
		sw $t0, ($s1)
		blt $t0, 10, loop_2
	
	# a[6] = acc;
	
	lw $t0, ($s4)    # $t0 = acc
	sw $t0, 24($s0)  # a[6] = acc
	
condition:
	# while (a[k] < acc)
	
		lw $t0, ($s3)       # $t0 = k
		sll $t0, $t0, 2     # $t0 = k * 4
		addu $t0, $t0, $s0  # $t0 = a + k*4
		lw $t2, ($t0)       # $t0 = a[k]
	
		lw $t1, ($s4)       # $t1 = acc
	
		ble $t1, $t2, end_while
	
		# a[k] = a[k] + 10;
		addiu $t2, $t2, 10
		sw $t2, ($t0)
	
	j condition
	
end_while:
	
	# do{ } 
do:
		# a[7] = a[k] + 1;
		
		lw $t0, ($s3)
		sll $t0, $t0, 2
		addu $t0, $s0, $t0   # $t0 = &a[k]
		lw $t0, ($t0)        # $t0 = a[k]
		
		addiu $t0, $t0, 1
		sw $t0, 28($s0)
	
	# while(a[7] < a[8])
	lw $t1, 32($s0)
	blt $t0, $t1, do	