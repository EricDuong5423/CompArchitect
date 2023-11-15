.data
	inputArray: .word 10,7,8,9,1,5
	inputSize:  .word 6
	originalArraymsg: .asciiz "Mang ban dau: "
	space: .asciiz " "
	endl: .asciiz "\n"
	
.text
j main
merge_sort:
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $a1, 8($sp)
	sw $a2, 4($sp)
	#$t0 = array.size()
	sub $t0, $a2, $a1
	li $t1, 4
	div $t0, $t0, $t1
	
	#if(size < 1) thi ko chia doi mang nua
	ble $t0, 1, end_merge_sort
	
	#$a1 = mid_array
	add $a2, $a1, $t0
	sw $a2, 0($sp)
	
	#Ð? quy ph?n bên trái
	jal merge_sort
	
	#Ð? quy ph?n bên ph?i
	lw $a1, 0($sp)
	lw $a2, 4($sp)
	jal merge_sort
	
	#Merge hai ph?n l?i v?i nhau
	lw $a1, 8($sp)
	lw $a2, 4($sp)
	lw $a3, 0($sp)
	j print_array
	end_merge_sort:
print_array:
	move $s0, $a1
	
	loop_print:
		beq $s0, $a2, end_print #Dieu kien dung vong lap 
		#In phan tu a[i]
		lw $a0, 0($s0)
		li $v0, 1
		syscall
		#In " "
		li $v0, 4
		la $a0, space
		syscall
		#i++
		add $s0, $s0, 4
		j loop_print
	end_print:
	li $v0, 4
	la $a0, endl
	syscall
	
	jr $ra
main:
	la $a1, inputArray #$a1 = &array.begin()
	lw $a2, inputSize #So luong phan tu
	sll $a2, $a2, 2
	add $a2, $a1, $a2
	
	#In thong bao mang ban dau
	li $v0, 4
	la $a0, originalArraymsg
	syscall
	#In mang
	jal print_array
	#Merge_sort
	
