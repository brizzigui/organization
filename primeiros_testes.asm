.data

answer: .space 16

num0: .word 0
num1: .word 0
num2: .word 10

.text
lw $t0, num1
lw $t1, num2
lw $t2, num0

addiu $t0, $zero, 9 

li $v0, 1
move $a0, $t0
syscall

sw $t0, answer
lw $t0, num0

li $v0, 1
move $a0, $t0
syscall

lw $t0, answer

li $v0, 1
move $a0, $t0
syscall