#------------------------------------------ Data ------------------------------------------#
.data 0x10010000
	inputArray: .float -181.362, -704.334, -712.39, -699.203, 114.823, -262.384, 294.34, 901.951, -139.468, -714.727, -225.226, -84.334, 353.22, -315.223, -296.791, -471.362, 326.884, -317.067, 607.427, -556.419, 308.33, -90.64, 294.714, 900.673, 224.939, 192.653, -459.459, -319.214, -461.755, -480.98, 583.853, -110.632, -951.941, 131.183, 996.467, 414.717, 144.456, 455.796, -644.346, -360.696, 673.293, -627.565, 580.627, -986.235, 705.122, 347.513, -269.983, 245.913, -687.996, 823.05
	inputSize:  .word 50
	originalArraymsg: .asciiz "Mang ban dau : "
	space: .asciiz " "
	endl: .asciiz "\n"
	tempArray: .float 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
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
	lui $s1, 0x00001001
	ori $s1, 0x000000e0
	
	#while(start <= mid && mid + 1 <= end) = while($t0 < $a3 && $t1 < $a2)
	while:
		#start > mid ? jump ---> while1 or continue while
		slt $at, $a3, $t0 
		bne $at, $zero, while1
		#mid + 1 > end ? jump ---> while2 or continue while
		slt $at, $a2, $t1
		bne $at, $zero, while2
		
		#$f2 = array[left]
		l.s $f2, 0($t0)
		#$f3 = array[right]
		l.s $f3, 0($t1)
		#$f2 < $f3 ? jump ---> left or right
		c.lt.s $f2, $f3
		bc1t left
		j right
		left:
			#$tempArray[tempIndex] = $f2
			s.s $f2, 0($s1) 
			#left++
			addi $t0, $t0, 4
			j end_cond
		right: 
			#$tempArray[tempIndex] = $f3
			s.s $f3, 0($s1)
			#right++
			addi $t1, $t1, 4
		end_cond:
			#tempIndex++
			addi $s1, $s1, 4
			j while
	#Case 1: mid + 1 <= end && start > mid
	while1:
		#mid + 1 > end ? jump ---> end_merge or continue
		slt $at, $a2, $t1
		bne $at, $zero, end_merge
		
		#$f3 = inputArray[right]
		l.s $f3, 0($t1)
		#tempArray[tempIndex] = $f3
		s.s $f3, 0($s1)
		
		#right++
		addi $t1, $t1, 4
		#tempIndex++
		addi $s1, $s1, 4
		
		j while1
	#Case 2: start <= mid && mid + 1 > end
	while2:
		#start > mid ? jump ---> end_merge or continue
		slt $at, $a3, $t0
		bne $at, $zero, end_merge
		
		#$f2 = inputArray[left]
		l.s $f2, 0($t0)
		#tempArray[tempIndex] = $f3
		s.s $f2, 0($s1) 
		
		#left++
		addi $t0, $t0, 4
		#tempIndex++
		addi $s1, $s1, 4
		
		j while2
	end_merge:
		#$s0 = &tempArray
		lui $s0, 0x00001001
		ori $s0, 0x000000e0
		#$t0 = &begin
		addi $t0, $a1, 0
	save_originArray:
		beq $s0, $s1, end_save_originArray
		l.s $f1, 0($s0)
		s.s $f1, 0($t0)
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
	lui $a0, 0x00001001
	ori $a0, 0x00000244
	li $v0, 4
	syscall
	#print nth
	move $a0, $t9
	li $v0, 1
	syscall
	#format for printing
	bge $t9, 10, format2
	format1:
		lui $a0, 0x00001001
		ori $a0, 0x00000250
		li $v0, 4
		syscall
		j end_format
	format2:
		lui $a0, 0x00001001
		ori $a0, 0x00000254
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
	lui $s0, 0x00001001
	ori $s0, 0x00000000
	#Load $s1 = size
	lui $at, 0x00001001
	lw $s1, 0x000000c8($at)
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
		l.s $f12, 0($s0)
		li $v0, 2
		syscall
		
		#print " "
		li $v0, 4
		lui $a0, 0x00001001
		ori $a0, 0x000000dc
		syscall
		
		#Index++
		addi $s0, $s0, 4
		j loop_print
	end_print:
	li $v0, 4
	lui $a0, 0x00001001
	ori $a0, 0x000000de
	syscall
	jr $ra
#------------------------------------------------- main() ------------------------------#
main:
	#$a1 = &array
	lui $a1, 0x00001001
	ori $a1, 0x00000000
	#$a2 = &(array + size)
	lui $at, 0x00001001
	lw $a2, 0x000000c8($at)
	addi $a2, $a2, -1
	sll $a2, $a2, 2
	add $a2, $a2, $a1
	#Print originalArraymsg
	li $v0, 4
	lui $a0, 0x00001001
	ori $a0, 0x000000cc
	syscall
	#Print array
	jal print_array
	#Print seperate
	li $v0, 4
	lui $a0, 0x00001001
	ori $a0, 0x000001a8
	syscall
	#Print endl
	li $v0, 4
	lui $a0, 0x00001001
	ori $a0, 0x000000de
	syscall
	
	#Merge_sort
	li $t9, 1
	jal merge_sort
	#Print seperate
	li $v0, 4
	lui $a0, 0x00001001
	ori $a0, 0x000001a8
	syscall
	#Print endl
	li $v0, 4
	lui $a0, 0x00001001
	ori $a0, 0x000000de
	syscall
	#Print aftersortArraymsg
	li $v0, 4
	lui $a0, 0x00001001
	ori $a0, 0x00000257
	syscall
	#Print array
	jal print_array
	#End program
	li $v0, 10
	syscall