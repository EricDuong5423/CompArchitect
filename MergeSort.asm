#------------------------------------------ Data ------------------------------------------#
.data
	inputArray: .word 21,35,19,25,39,44,7,33,5,34,50,2,48,12,3,13,22,28,26,42,32,27,40,23,47,31,38,46,24,14,41,8,1,18,17,10,37,36,0,16,43,29,30,11,9,15,45,20,49,4
	inputSize:  .word 50
	originalArraymsg: .asciiz "Mang ban dau: "
	space: .asciiz " "
	endl: .asciiz "\n"
	tempArray: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	seperate: .asciiz "---------------------------------------------------------------------------------------------------------------------------------------------------------"
.text
#------------------------------------------ Source code ------------------------------------------#
j main

#------------------------------------------ Merge Function ------------------------------------------#
#input: $a1 = &begin, $a3 = &mid, $a2 = &end, $s1 = &tempArray#
#output: Sorted array from &begin ----> &end#
merge:
	#$t0 = $a1 = &begin
	addi $t0, $a1, 0
	#$t1 = $a3 = &mid + 1
	addi $t1, $a3, 0
	addi $t1, $t1, 4
	#$s1 = &tempArray
	lui $at, 4097
	ori $s1, $at, 224
	
	#while(start <= mid && mid + 1 <= end) = while($t0 < $a3 && $t1 < $a2)
	while:
		#start > mid ? jump ---> while1 or continue while
		slt $at, $a3, $t0 
		bne $at, $zero, while1
		#mid > end ? jump ---> while2 or continue while
		slt $at, $a2, $t1
		bne $at, $zero, while2
		
		#$t2 = array[left]
		lw $t2, 0($t0)
		#$t3 = array[right]
		lw $t3, 0($t1)
		#$t2 >= $t3 ? jump ---> left or right
		slt $at, $t3, $t2
		beq $at, $zero, left
		j right
		left:
			#$tempArray[tempIndex] = $t2
			sw $t2, 0($s1) 
			#left++
			addi $t0, $t0, 4
			j end_cond
		right: 
			#$tempArray[tempIndex] = $t3
			sw $t3, 0($s1)
			#right++
			addi $t1, $t1, 4
		end_cond:
			#tempIndex++
			addi $s1, $s1, 4
			j while
	#Case 1: mid <= end && start > mid
	while1:
		#mid > end ? jump ---> end_merge or continue
		slt $at, $a2, $t1
		bne $at, $zero, end_merge
		
		#$t3 = inputArray[right]
		lw $t3, 0($t1)
		#tempArray[tempIndex] = $t3
		sw $t3, 0($s1)
		
		#right++
		addi $t1, $t1, 4
		#tempIndex++
		addi $s1, $s1, 4
		
		j while1
	#Case 2: start <= mid && mid > end
	while2:
		#start > mid ? jump ---> end_merge or continue
		slt $at, $a3, $t0
		bne $at, $zero, end_merge
		
		#$t2 = inputArray[left]
		lw $t2, 0($t0)
		#tempArray[tempIndex] = $t3
		sw $t2, 0($s1) 
		
		#left++
		addi $t0, $t0, 4
		#tempIndex++
		addi $s1, $s1, 4
		
		j while2
	end_merge:
		#$s0 = &tempArray
		lui $at, 4097
		ori $s0, $at, 224
		#$t0 = &begin
		addi $t0, $a1, 0
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
	sw $ra, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	
	sub $t0, $a2, $a1
	
	#bge $a1, $a2, end_merge_sort
	slt $at, $a1, $a2
	beq $at, $zero, end_merge_sort
	
	srl $t0, $t0, 3
	sll $t0, $t0, 2
	
	add $a2, $a1, $t0
	
	sw $a2, 12($sp)
	
	jal merge_sort
	
	lw $a1, 12($sp)
	addi $a1, $a1, 4
	lw $a2, 8($sp)
	
	
	jal merge_sort
	
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $a3, 12($sp)
	
	jal merge
	
	#In mang
	
	jal print_array
	
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	#Ket thuc merge_sort
	end_merge_sort:
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	jr $ra
	
print_array:
	#la $s0, inputArray
	lui $at, 4097
	ori $s0, $at, 0
	
	#lw $s1, inputSize
	lui $at, 4097
	lw $s1, 200($at)
	addi $s1, $s1, -1
	sll $s1, $s1, 2
	add $s1, $s1, $s0
	loop_print:
		#bgt $s0, $s1, end_print #Dieu kien dung vong lap
		slt $at, $s1, $s0
		bne $at, $zero, end_print
		#In phan tu a[i]
		lw $a0, 0($s0)
		li $v0, 1
		syscall
		#In " "
		li $v0, 4
		#la $a0, space
		lui $at, 4097
		ori $a0, $at, 219
		syscall
		#i++
		add $s0, $s0, 4
		j loop_print
	end_print:
	li $v0, 4
	#la $a0, endl
	lui $at, 4097
	ori $a0, $at, 221
	syscall
	jr $ra
main:
	#la $a1, inputArray #$a1 = &array.begin()
	lui $at, 4097
	ori $a1, $at, 0
	#lw $a2, inputSize #So luong phan tu
	lui $at, 4097
	lw $a2, 200($at)
	addi $a2, $a2, -1
	sll $a2, $a2, 2
	add $a2, $a2, $a1
	#In thong bao mang ban dau
	li $v0, 4
	#la $a0, originalArraymsg
	lui $at, 4097
	ori $a0, $at, 204
	syscall
	#In mang
	jal print_array
	#In cach dong
	li $v0, 4
	#la $a0, seperate
	lui $at, 4097
	ori $a0, $at, 424
	syscall
	li $v0, 4
	#la $a0, endl
	lui $at, 4097
	ori $a0, $at, 221
	syscall
	#Merge_sort
	jal merge_sort