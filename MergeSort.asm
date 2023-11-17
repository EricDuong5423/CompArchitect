#------------------------------------------ Data ------------------------------------------#
.data
	inputArray: .word 21,35,19,25,39,44,7,33,5,34,50,2,48,12,3,13,22,28,26,42,32,27,40,23,47,31,38,46,24,14,41,8,1,18,17,10,37,36,0,16,43,29,30,11,9,15,45,20,49,4
	inputSize:  .word 50
	originalArraymsg: .asciiz "Mang ban dau : "
	space: .asciiz " "
	endl: .asciiz "\n"
	tempArray: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	seperate: .asciiz "-----------------------------------------------------------------------------------------------------------------------------------------------------------"
	mergeMsg: .asciiz "Merge Sort "
	colons: .asciiz " : "
	colon: .asciiz ": "
	aftersortArraymsg: .asciiz "Mang sau cung: "
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
	la $s1, tempArray
	
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
		la $s0, tempArray
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
#------------------------------------------------- mergesort(start, end) ------------------------------#
#Input: $a1 = &array, $a2 = &(array + size)
#Output: $a3 = &(array + mid)
merge_sort:
	#Take out 16 byte in stack
	addi $sp, $sp, -16
	#0->3 byte use for $ra for recursing
	sw $ra, 0($sp)
	#4->7 byte use for storing address of begin array
	sw $a1, 4($sp)
	#8->11 byte for storing address of end array
	sw $a2, 8($sp)
	
	#$t0 = current_size * 4byte = *end - *start
	sub $t0, $a2, $a1
	
	#start > end ? jump ---> end_merge_sort
	slt $at, $a1, $a2
	beq $at, $zero, end_merge_sort
	
	#$t0 / 8 = size/(4 byte * 2) = mid
	srl $t0, $t0, 3
	#$t0 * 4 = mid * 4byte
	sll $t0, $t0, 2
	
	#--------------------- first_recursion:merge_sort(start,mid) ---------------------#
	#$a2 = &mid
	add $a2, $a1, $t0
	#12->15 byte for storing address of mid array
	sw $a2, 12($sp)
	#Recursion
	jal merge_sort
	
	#--------------------- second_recursion:merge_sort(mid + 1,end) ---------------------#
	#$a1 = &mid
	lw $a1, 12($sp)
	#$a1 = &mid + 1
	addi $a1, $a1, 4
	#$a2 = &end
	lw $a2, 8($sp)
	#Recursion
	jal merge_sort
	
	#--------------------- merge(start,mid,end) ---------------------#
	#$a1 = &start
	lw $a1, 4($sp)
	#$a2 = &end
	lw $a2, 8($sp)
	#$a3 = &mid
	lw $a3, 12($sp)
	#merge
	jal merge
	
	#--------------------- print_array ---------------------#
	#print msg for array after nth MergeSort
	la $a0, mergeMsg
	li $v0, 4
	syscall
	#print nth
	move $a0, $t9
	li $v0, 1
	syscall
	#format for printing
	bge $t9, 10, format2
	format1:
		la $a0, colons
		li $v0, 4
		syscall
		j end_format
	format2:
		la $a0, colon
		li $v0, 4
		syscall
	end_format:
	#n++
	addi $t9, $t9, 1
	#print_array
	jal print_array
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	
	#Ket thuc merge_sort
	end_merge_sort:
	#Load back the return address to $ra
	lw $ra, 0($sp)
	#Return 16 byte take from stack
	addi $sp, $sp, 16
	#Jump back to orginal address
	jr $ra
#------------------------------------------------- print_array(&array) ------------------------------#
#Input: $a1 = &array
#Output: none	
print_array:
	#Load $s0 = &array
	la $s0, inputArray
	#Load $s1 = size
	lw $s1, inputSize
	addi $s1, $s1, -1
	#$s1 * 4byte
	sll $s1, $s1, 2
	#$s1 = &(array + size - 1)
	add $s1, $s1, $s0
	loop_print:
		#$s0 > $s1 ? jump ---> end_print
		slt $at, $s1, $s0
		bne $at, $zero, end_print
		
		#$a0 = array[index]
		lw $a0, 0($s0)
		li $v0, 1
		syscall
		
		#print " "
		li $v0, 4
		la $a0, space
		syscall
		
		#Index++
		addi $s0, $s0, 4
		j loop_print
	end_print:
	li $v0, 4
	la $a0, endl
	syscall
	jr $ra
#------------------------------------------------- main() ------------------------------#
main:
	#$a1 = &array
	la $a1, inputArray
	#$a2 = &(array + size)
	lw $a2, inputSize
	addi $a2, $a2, -1
	sll $a2, $a2, 2
	add $a2, $a2, $a1
	#Print originalArraymsg
	li $v0, 4
	la $a0, originalArraymsg
	syscall
	#Print array
	jal print_array
	#Print seperate
	li $v0, 4
	la $a0, seperate
	syscall
	#Print endl
	li $v0, 4
	la $a0, endl
	syscall
	
	#Merge_sort
	li $t9, 1
	jal merge_sort
	#Print seperate
	li $v0, 4
	la $a0, seperate
	syscall
	#Print endl
	li $v0, 4
	la $a0, endl
	syscall
	#Print aftersortArraymsg
	li $v0, 4
	la $a0, aftersortArraymsg
	syscall
	#Print array
	jal print_array
	#End program
	li $v0, 10
	syscall