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
	
	j end_if_2
	
start_if_2:
	# se if for verdadeiro, cai aqui
	# if ((k == 6) || (j >= i))
	
	lw $t1, i
	lw $t2, j
	lw $t3, k
	
	seq $t0, $t3, 6
	sle $t4, $t1, $t2
	
	or $t0, $t0, $t4
	
	beq $t0, 1, start_if_3
	
	# else
		# a[8] = 500
	
		addiu $t4, $zero, 500
		sw $t4, a+32
		
		j end_if_3
	
	start_if_3:
	# a[9] = 400
	
		addiu $t4, $zero, 400
		sw $t4, a+36
		
	end_if_3:

end_if_2:

	# switch (a[j * 2 + 1])
	lw $t0, j
	sll $t0, $t0, 1
	addiu $t0, $t0, 1
	sll $t0, $t0, 2
	
	la $t1, a
	addu $t0, $t0, $t1
	
	lw $t0, ($t0)
	
	# $t0 = a[j * 2 + 1]
	
	beq $t0, 1, case1
	
	beq $t0, 3, case3
	
	beq $t0, 5, case5
	
	j end_switch_outer
	
case1:
	# a[1] = 4000;
	addiu $t1, $zero, 4000
	
	la $t2, a
	addiu $t2, $t2, 4
	
	sw $t1, ($t2)
	
	j end_switch_outer

case3:
	# switch(a[4])
	
	la $t0, a
	addiu $t0, $t0, 16
	lw $t0, ($t0)
	
	beq $t0, 3, inner_case3
	
	beq $t0, 4, inner_case4
	
	beq $t0, 5, inner_case5
	
	j end_switch_inner
	
	inner_case3:
		# a[5] = 50000;
		addiu $t1, $zero, 50000
	
		la $t2, a
		addiu $t2, $t2, 20
	
		sw $t1, ($t2)
		
		j end_switch_inner
	
	inner_case4:
		# a[6] = 50000;
		addiu $t1, $zero, 50000
	
		la $t2, a
		addiu $t2, $t2, 24
	
		sw $t1, ($t2)
		
	inner_case5:
		# a[7] = 70000;
		addiu $t1, $zero, 70000
	
		la $t2, a
		addiu $t2, $t2, 28
	
		sw $t1, ($t2)
		
		j end_switch_inner
	
	end_switch_inner:
	
	# a[3] = 50000;
	
	addiu $t1, $zero, 50000
	
	la $t2, a
	addiu $t2, $t2, 12
	
	sw $t1, ($t2)
	
	j end_switch_outer

case5:
	# a[5] = 6000;
	
	addiu $t1, $zero, 6000
	
	la $t2, a
	addiu $t2, $t2, 20
	
	sw $t1, ($t2)
	j end_switch_outer

end_switch_outer:
	
	
	
