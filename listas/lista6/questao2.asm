.data
	mat_A: .space 100
	
.text
	# matriz 5x5 de ints
	# l� int
	addiu $v0, $zero, 5
	syscall
	
	sw $v0, mat_A+32
	
	# l� int
	addiu $v0, $zero, 5
	syscall
	
	sw $v0, mat_A+48
	
	lw $t0, mat_A+32
	lw $t1, mat_A+48
	
	add $t0, $t0, $t1
	
	sw $t0, mat_A+56
	
	
	