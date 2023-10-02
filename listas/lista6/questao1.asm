.data 

	a: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
	i: .space 4
	j: .space 4
	k: .space 4
	
.text
	
main:
	# i = 1
	addiu $t0, $zero, 1
	sw $t0, i
	
	# j = 3
	addiu $t0, $zero, 3
	sw $t0, j
	
	# k = 4
	addiu $t0, $zero, 4
	sw $t0, k
	
	# a[0] = 5
	addiu $t0, $zero, 5
	sw $t0, a
	
	# a[3] = a[0] + 20
	lw $t1, a
	addiu $t0, $t1, 20
	sw $t0, a+8
	
	# a[3] = a[4] + 200000
	lw $t0, a+16
	addiu $t0, $t0, 200000
	sw $t0, a+12
	
	# a[4] = 10000
	addiu $t0, $zero, 10000
	sw $t0, a+16
	
	# a[5] = a[6] + a[7] - a[8]
	lw $t0, a+24
	lw $t1, a+28
	lw $t2, a+32
	
	sub $t1, $t1, $t2
	add $t0, $t0, $t1
	
	sw $t0, a+20
	
	# a[6] = a[7] - i
	
	lw $t0, a+28
	lw $t1, i
	
	sub $t0, $t0, $t1
	
	sw $t0, a+24
	
	# a[7] = a[8] - a[j]
	lw $t0, j # carrega o conteúdo de j
	sll $t0, $t0, 2 # multiplica j por 4
	la $t1, a # carrega o endereço de a
	
	add $t0, $t0, $t1 # equivale a ptr = a + j*4 (aritmetica de ponteiros)
	
	lw $t3, ($t0)
	lw $t2, a+32
	
	sub $t2, $t2, $t3
	sw $t2, a+28
	
	
	# a[j] = a[i+k] - i + j
	
	lw $t0, j
	sll $t0, $t0, 2
	la $t1, a
	
	add $t0, $t0, $t1
	
	lw $t1, i
	lw $t2, k
	
	addu $t4, $t1, $t2
	sll $t4, $t4, 2
	la $t3, a
	addu $t4, $t4, $t3
	
	lw $t5, j
	sub $t5, $t5, $t1
	
	lw $t3, ($t4)
	add $t5, $t5, $t3
	
	sw $t5, ($t0)
	
	
	# a[k] = a[a[i]]
	
	lw $t0, i
	sll $t0, $t0, 2
	la $t1, a
	
	addu $t0, $t0, $t1
	
	lw $t0, ($t0)
	sll $t0, $t0, 2
	addu $t0, $t0, $t1
	
	lw $t0, ($t0)
	
	
	lw $t2, k
	sll $t2, $t2, 2
	
	addu $t2, $t2, $t1
	
	sw $t0, ($t2)
	
	

	
