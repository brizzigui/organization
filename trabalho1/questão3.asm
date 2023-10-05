.data
	mat: .space 1000
	
	
.text
	#le int
	addiu $v0, $zero, 5
	syscall
	
	la $t0, mat
	addiu $t0, $t0, 348
	
	# mat[1][3][7] equivale a mat + 4 * ((1 * 5 * 10) + (3 * 10) + 7)
	sw $v0, ($t0)
	
	#le int
	addiu $v0, $zero, 5
	syscall
	
	la $t0, mat
	addiu $t0, $t0, 492
	
	# mat[2][2][3] equivale a mat + 4 * ((2 * 5 * 10) + (2 * 10) + 3)
	sw $v0, ($t0)
	
	lw $t0, mat+348
	lw $t1, mat+492
	addu $t0, $t0, $t1
	
	la $t2, mat
	addiu $t2, $t2, 492
	# mat[1][4][8] equivale a mat + 4 * ((1 * 5 * 10) + (4 * 10) + 8)
	
	sw $t0, ($t2)

