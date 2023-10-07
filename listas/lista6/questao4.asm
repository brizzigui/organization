.data
	string: .space 800
	i: .word 1
	
.text
	la $t0, string
	lw $t1, i
	
	addu $t0, $t0, $t1
	
	# carrega string[i]
	addiu $t3, $zero, 65
	sb $t3, ($t0)
	lb $t2, ($t0)
	
	# print char
	move $a0, $t2
	addiu $v0, $zero, 11
	syscall
	