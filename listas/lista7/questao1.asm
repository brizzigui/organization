.data
	a: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	i: .space 4
	j: .space 4
	k: .space 4
	
.text
	
	# i = 1 
	addiu $t0, $zero, 1
	sw $t0, i
	
	# goto abc
	j abc
	
	# a[4] = 123
	addiu $t0, $zero, 123
	sw $t0, a+16
	
	# a[5] = 900
	addiu $t0, $zero, 900
	sw $t0, a+20	
	
abc:	
	# a[0] = i
	lw $t0, i
	sw $t0, a
	
	# j = a[0]
	lw $t0, a
	sw $t0, j
	
	# k = i + 3000
	
	lw $t0, i
	addiu $t0, $t0, 3000
	sw $t0, k
	
	# if (i == j)
	
	lw $t0, i
	lw $t1, j
	
	beq $t0, $t1, start_if_1
	
	# else
	# a[2] = a[4]
	
	lw $t0, a+16
	sw $t0, a+8
	j endif_1
	
start_if_1:	
	
	# se if for verdadeiro, cai aqui
	
	# a[2] = k - a[9]
	
	lw $t0, a+36
	lw $t1, k
	
	sub $t0, $t1, $t0
	sw $t0, a+8
	
endif_1:
	# if((k < i) && (i < 600))
	
	lw $t1, k
	lw $t2, i
	
	slt $t0, $t1, $t2
	slti $t3, $t2, 600
	
	and $t0, $t0, $t3
	
	beq $t0, 1, start_if_2
	
	# else
		# a[8] = 500
	
		addiu $t4, $zero, 500
		sw $t4, a+32
	
		j end_if_2
	
start_if_2:
	# se if for verdadeiro, cai aqui
	# a[9] = 400
	
		addiu $t4, $zero, 400
		sw $t4, a+36

end_if_2:
	