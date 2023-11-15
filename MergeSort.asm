.data
	inputArray: .word 10,7,8,9,1,5
	inputSize:  .word 6
	originalArraymsg: .asciiz "Mang ban dau: "
	space: .asciiz " "
	endl: .asciiz "\n"
	tempArray: .word 0,0,0,0,0,0
.text
j main
	#In thong bao mang ban dau
	li $v0, 4
	la $a0, originalArraymsg
	syscall
	#In mang
	jal print_array
merge:
	move $t0, $a1
	move $t1, $a3
	la $s1, tempArray
	
	#while(start < mid && mid < end) = while($t0 < $a3 && $t1 < $a2)
	while:
		bge $t0, $a3, while1 #$t0 < $a3 ? 
		bge $t1, $a2, while2 #$t1 < $a2 ?
		lw $t2, 0($t0) #$t2 = array[left] (left < mid)
		lw $t3, 0($t1) #$t3 = array[right] (right < end)
		ble $t2, $t3, left #$t2 >= $t3 ? left : right
		j right
		left:
			sw $t2, 0($s1) #$t4[cur_index] = $t2
			addi $t0, $t0, 4 #left++
			j end_cond
		right: 
			sw $t3, 0($s1) #$t4[cur_index] = $t3
			addi $t1, $t1, 4 #right++
		end_cond:
			addi $s1, $s1, 4
			j while
	#TH: right con phan tu
	while1:
		bge $t1, $a2, end_merge
		
		lw $t3, 0($t1)
		sw $t3, 0($s1)
		
		addi $t1, $t1, 4
		addi $s1, $s1, 4
		
		j while1
	#TH: left con phan tu
	while2:
		bge $t0, $a3, end_merge
		
		lw $t2, 0($t0)
		sw $t2, 0($s1) 
		
		addi $t0, $t0, 4
		addi $s1, $s1, 4
		
		j while2
	end_merge:
		la $s0, tempArray
		move $t0, $a1
		sub $s2, $s1, $s0
	save_originArray:
		beq $s0, $s1, end_save_originArray
		lw $t1, 0($s0)
		sw $t1, 0($t0)
		addi $t0, $t0, 4
		addi $s0, $s0, 4
		j save_originArray
	end_save_originArray:
	jr $ra
merge_sort:
	addi $sp, $sp, -16
	sw $ra, 12($sp)#Dia chi quay ve $ra
	sw $a1, 8($sp)#$a1 la dau mang
	sw $a2, 4($sp)#$a2 la cuoi mang
	
	#$t0 = array.size()
	sub $t0, $a2, $a1
	srl $t0, $t0, 3
	sll $t0, $t0, 2
	
	#if(size < 1) thi ko chia doi mang nua
	ble $t0, 1, end_merge_sort
	
	#$a1 = mid_array
	add $a2, $t0, $a1
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
	jal merge
	
	#In mang
	lw $a1, 8($sp)
	lw $a2, 4($sp)
	jal print_array
	
	#Ket thuc merge_sort
	end_merge_sort:
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
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
	addi $a2, $a1, 24
	#Merge_sort
	jal merge_sort
