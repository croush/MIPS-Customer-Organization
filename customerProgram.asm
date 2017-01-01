
# Assignment #6 - Customer Database
# CS 130 - Rieck - Fall 2016
# Claire Roush

                 .data

menuline1:	   .asciiz "1. Add data for a new customer\n"
menuline2:	   .asciiz "2. Search for customer from SSN\n"
menuline3:	   .asciiz "3. Delete found customer\n"
menuline4:	   .asciiz "4. Sort data by SSN\n"
menuline5:	   .asciiz "5. Sort data by priority, and then by SSN\n"
menuline6:	   .asciiz "0. Quit\n\n"
prompt:		   .asciiz "Your choice? "
insertMessageA:	   .asciiz "Please enter the SSN: "
insertMessageB:    .asciiz "Please enter the priority number: "
findMessage:	   .asciiz "Enter the SSN of the customer you wish to find: "
foundIt:	   .asciiz "Found it! Index of customer is: "
notFoundIt:	   .asciiz "Customer not found. \n"
deleteMessage:	   .asciiz "Deleting last found customer... \n"
deleteCompleteMsg: .asciiz "Deletion completed.\n"
deleteErrorMsg:	   .asciiz "Cannot delete customer, no valid search completed.\n"
sortSSNMessage:    .asciiz "Hello from 'SortSSN'\n"
sortPriorMessage:  .asciiz "Hello from 'SortPriority'\n"
badChoiceMessage:  .asciiz "Bad choice. Try again.\n" 
byeMessage:	   .asciiz "Bye now!!\n"
space:		   .asciiz " "
carriageReturn:    .asciiz "\n" 

NumberOfCustomers: .word 0  # no customers initially, but will change
IndexOfLastFound:  .word -1 # when >= 0, index of last found customer
SSNArray:	   .word 0 : 100  # room for 100 customer SSNs
PriorityArray:	   .word 0 : 100  # room for 100 customer priorities
#SSNArray:	.word 2, 4, 6, 8, 10  # for testing
#PriorityArray:	.word 1, 3, 5, 7, 9  # for testing 

                .text
main:
		jal	dump        # comment out when not debugging 
		jal	carrRet
		la	$a0, menuline1
		jal	dispStr
		la	$a0, menuline2
		jal	dispStr
		la	$a0, menuline3
		jal	dispStr
		la	$a0, menuline4
		jal	dispStr
		la	$a0, menuline5
		jal	dispStr
		la	$a0, menuline6
		jal	dispStr
smallLoop:	la	$a0, prompt
		jal	dispStr
		jal	getNum
		bne	$v0, $zero, skip1
		j	quit 
skip1:		addi	$v0, $v0, -1
		bne	$v0, $zero, skip2
		jal	insert
		j	main
skip2:		addi	$v0, $v0, -1
		bne	$v0, $zero, skip3
		jal	find
		j	main
skip3:		addi	$v0, $v0, -1
		bne	$v0, $zero, skip4
		jal	delete
		j	main
skip4:		addi	$v0, $v0, -1
		bne	$v0, $zero, skip5
		jal	sortSSN
		j	main
skip5:		addi	$v0, $v0, -1
		bne	$v0, $zero, skip6
		jal	sortPriority
		j	main
skip6:		la	$a0, badChoiceMessage
		jal	dispStr
		j	smallLoop

# insert procedure should interact with user, getting data for a new
# customer and adding this data to the arrays, using the value in 
# numberOfCustomers as an index into these arrays. It should then 
# increment numberOfCustomers

#s0 = size of array
#$t0 = index into array
#s1 = SSN to find
#s2 = temp var for priority #
insert:		
		#protect registers, push to stack
		add	$sp, $sp, -28
		sw	$t0, 24($sp)
		sw	$ra, 20($sp) 
		sw	$a0, 16($sp)
		sw	$v0, 12($sp)
		sw	$s0, 8($sp)
		sw	$s1, 4($sp)
		sw	$s2, ($sp)
		
		#get SSN
		la	$a0, insertMessageA
		jal	dispStr
		addi	$v0, $zero, 5		#get the number
		syscall
		add	$s1, $zero, $v0 	#store the user's input in $t5
		
		#get priority number
		la	$a0, insertMessageB
		jal 	dispStr
		addi    $v0, $zero, 5		#get number
		syscall 
		add	$s2, $zero, $v0 	#store in $s2
		
		lw   	$s0, NumberOfCustomers($zero) # get array size
		sll 	$t0, $s0, 2   # $t0 is 4 times $s0 and will be used as index
		sw   	$s1, SSNArray($t0)  # put new SSN into array
		sw   	$s2, PriorityArray($t0)  # put new priority into array  
		addi 	$s0, $s0, 1   # increase array size by one 
		sw   	$s0, NumberOfCustomers($zero) #increment number of customers
		
		jal dump
		
		lw	$s2, ($sp)
		lw	$s1, 4($sp)
		lw	$s0, 8($sp)
		lw	$v0, 12($sp)
		lw	$a0, 16($sp)
		lw	$ra, 20($sp)
		lw	$t0, 24($sp)
		add	$sp, $sp, 28
		jr	$ra 



# find procedure should interact with the user to obtain a SSN to find.
# It should then look through the list of SSNs. If it finds what it's 
# looking for, then it should display that customer's priority and 
# number of purchases, in a nice message. In this case it should also 
# store the array index of the found SSN in indexOfLastFound. However, 
# if it cannot find the SSN, then it should display a message to this
# effect and set indexOfLastFound to -1. 

# s0 = size of array
# t0 = indedx into array
# s1 = SSN to find
# s2 = temp for thing to compare to in loop
# t1 = loop counter
# t2 = indexOfLastFound temp holder
find:		
		add	$sp, $sp, -28
		sw	$t0, 24($sp)
		sw	$ra, 20($sp) 
		sw	$s1, 16($sp)
		sw	$s2, 12($sp)
		sw	$t1, 8($sp)
		sw	$t2, 4($sp)
		sw	$s0, ($sp)

		la	$a0, findMessage
		jal	dispStr

		addi	$v0, $zero, 5		#get the SSN
		syscall
		add	$s1, $zero, $v0		#store the SSN in $s1
		
		#prepare for loop
		lw   	$s0, NumberOfCustomers($zero) # get array size
		addi	$t0, $zero, 0		#index into array. Start at 0 (will increment by 4 each iteration)
		add	$t1, $zero, $0		#loop counter (need in addition to $s0 b/c we need to increment $t1)
		
findLoop:	bgt	$t1, $s0, notFound	#too many iterations, SSN must not be there. Check for this first
		lw	$s2, SSNArray($t0)	#put the SSN at index $t0 into $s2
		beq	$s1, $s2, found		#they're equal! Branch to found label
		addi	$t0, $t0, 4		#increment the array index times 4
		addi	$t1, $t1, 1		#increment the loop counter once
		j	findLoop		#loop again

found:
		sw 	$t0, IndexOfLastFound($zero)
		#lw	$t2, IndexOfLastFound($zero)
		la	$a0, foundIt		#print found it message
		jal	dispStr
		add 	$a0, $zero, $t0		#print the index the SSN was found at  
		addi	$v0, $zero, 1
		syscall
		la	$a0, carriageReturn	#need a new line
		jal	dispStr
		j	findDone		#done, jump
		

notFound:	la	$a0, notFoundIt
		addi	$s6, $zero, -1
		sw	$s6, IndexOfLastFound($zero)
		jal 	dispStr		
		
findDone:	
		lw	$s0, ($sp)
		lw	$t2, 4($sp)
		lw	$t1, 8($sp)
		lw	$s2, 12($sp)
		lw	$s1, 16($sp)
		lw	$ra, 20($sp)
		lw	$t0, 24($sp)
		add	$sp, $sp, 28

		jr	$ra 

# delete procedure should only attempt to delete the data about a 
# customer if the value of indexOfLastFound in nonnegative, indicating 
# that it is the index of a valid customer (the last one found). In this 
# case, it should shift the data for all customers after this customer 
# (in the arrays), one position to the left, thus overwriting the data 
# for the customer being deleted. It should then decrement 
# numberOfCustomers to reflect that there is now one fewer customer. 
# Also, whether or not a customer is actually deleted, an appropriate 
# message should be displayed. 

# t0 = 4x the number of customers, index into array
# s0 = # of customers
# s1 = temp to hold swapping values
# t1 = IndexOfLastFound
# t2 = 4 more than t1
# t3 = # of customers
# t4 = -1 to compare to IndexOfLastFound

delete:		
		add	$sp, $sp, -28
		sw	$t0, 24($sp)
		sw	$ra, 20($sp) 
		sw	$t1, 16($sp)
		sw	$t2, 12($sp)
		sw	$t3, 8($sp)
		sw	$t4, 4($sp)
		sw	$s0, ($sp)
		la	$a0, deleteMessage
		jal	dispStr
		
		addi	$t4, $zero, -1 #this will be used to compare to IndexOfLastFound
		lw	$t1, IndexOfLastFound($zero)	#put IndexOfLastFound in $t1
		beq	$t1, $t4, deleteError	#branch if indexOfLastFound is -1
		lw	$s0, NumberOfCustomers
		sll 	$t0, $s0, 2   # $t0 is 4 times $s0 (# of customers) and will be used as index
		lw	$t3, NumberOfCustomers($zero)
		addi	$t2, $t1, 4			#$t2 is 4 more than $t1
		
deleteLoop: 	beq 	$t2, $t0, deleteComplete #end of the array has been reached
		lw	$s1, SSNArray($t2)
		sw	$s1, SSNArray($t1)
		lw	$s1, PriorityArray($t2)
		sw	$s1, PriorityArray($t1)
		
		addi	$t1, $t1, 4
		addi	$t2, $t2, 4
		j	deleteLoop			
	
#indexOfLastFound is -1, so error message
deleteError:	la	$a0, deleteErrorMsg 
		jal	dispStr
		j	deleteDone
		
#delete completed successfully 
deleteComplete: addi	$t3, $t3, -1 #decrement $t0 (size of array)
		sw	$t3, NumberOfCustomers #update NumberOfCustomers (-1)
		la	$a0, deleteCompleteMsg
		sw	$t4, IndexOfLastFound($zero)
		jal	dispStr
		j	deleteDone
		
		
deleteDone:	
		lw	$s0, ($sp)
		lw	$t4, 4($sp)
		lw	$t3, 8($sp)
		lw	$t2, 12($sp)
		lw	$t1, 16($sp)
		lw	$ra, 20($sp)
		lw	$t0, 24($sp)
		add	$sp, $sp, 28
		jr	$ra

# sortSSN should sort the arrays using modified Bubble Sort code, so as 
# to order by increasing SSN. 

# t0 = outer loop counter
# t1 = inner loop counter
# t2 = index*4 for first in pair
# t3 =  index*4 for second
# t4 = swap temp 1
# t5 = swap temp 2
# s1 = number of customers
# s4 = priority array swap temp 1
# s5 = priority array swap temp 2
sortSSN:		
		add	$sp, $sp, -40
		sw	$s5, 36($sp)
		sw	$ra, 32($sp)
		sw	$t0, 28($sp)
		sw	$t1, 24($sp) 
		sw	$t2, 20($sp)
		sw	$t3, 16($sp)
		sw	$t4, 12($sp)
		sw	$t5, 8($sp)
		sw	$s1, 4($sp)
		sw	$s4, ($sp)
		la	$a0, sortSSNMessage
		jal	dispStr
		
		lw	$s1, NumberOfCustomers($zero) #number of customers into $s1
		
		# Bubble Sort the array 
		add	$t0, $zero, $s1		# $t0 = outer loop counter (count down)
		addi	$t0, $t0, -1		# loop one less than array length times
outlp:		add	$t1, $zero, $s1		# $t1 = inner loop counter (count down) 
		addi	$t1, $t1, -1		# loop one less than array length times
		addi	$t2, $zero, 0		# $t2 = index (x4) to first in pair 
		addi	$t3, $zero, 4		# $t3 = index (x4) to second in pair
innlp:		lw	$t4, SSNArray($t2)		# put first number of pair into $t4
		lw	$t5, SSNArray($t3)		# put second number of pair into $t5 
		
		lw	$s4, PriorityArray($t2)	#also get the corresponding priority array values
		lw	$s5, PriorityArray($t3)	#so t4,t5 are SSN, s4,s5 are priority
		
		bge	$t4, $t5, skip		# skip ahead if already in order
		sw	$t5, SSNArray($t2)		# otherwise, swap them in the array
		sw	$t4, SSNArray($t3)
		sw	$s5, PriorityArray($t2)
		sw	$s4, PriorityArray($t3)	
		
skip:		addi	$t2, $t2, 4		# update $t2 and $t3 for next pair
		addi	$t3, $t3, 4 
		addi	$t1, $t1, -1		# decrement inner loop counter 
		bne	$t1, $zero, innlp	#    and maybe loop back 
		addi	$t0, $t0, -1		# decrement outer loop counter
		bne	$t0, $zero, outlp	#    and maybe loop back 
		
		
		lw	$s4, ($sp)
		lw	$s1, 4($sp)
		lw	$t5, 8($sp)
		lw	$t4, 12($sp)
		lw	$t3, 16($sp)
		lw	$t2, 20($sp)
		lw	$t1, 24($sp)
		lw	$t0, 28($sp)
		lw	$ra, 32($sp)
		lw	$s5, 36($sp)
		add	$sp, $sp, 40
		jr	$ra

# sortPriority should sort the arrays using modified Bubble Sort code, 
# so as to order by decreasing prioity.

# s1 = # of customers
# t0 = outer loop counter
# t1 = inner loop counter
# t2 = index * 4 to first in pair
# t3 = index *4 to second pair
# t4 = priority array swap temp 1
# t5 = priority array swap temp 2
# s4 = ssn array swap temp 1
# s5 = ssn array swap temp 2
sortPriority:		
		add	$sp, $sp, -40
		sw	$s5, 36($sp)
		sw	$ra, 32($sp)
		sw	$t0, 28($sp)
		sw	$t1, 24($sp) 
		sw	$t2, 20($sp)
		sw	$t3, 16($sp)
		sw	$t4, 12($sp)
		sw	$t5, 8($sp)
		sw	$s1, 4($sp)
		sw	$s4, ($sp) 
		
		la	$a0, sortPriorMessage
		jal	dispStr
		
		lw	$s1, NumberOfCustomers($zero) #number of customers into $s1
				# Bubble Sort the array 
		add	$t0, $zero, $s1		# $t0 = outer loop counter (count down)
		addi	$t0, $t0, -1		# loop one less than array length times
outlp2:		add	$t1, $zero, $s1		# $t1 = inner loop counter (count down) 
		addi	$t1, $t1, -1		# loop one less than array length times
		addi	$t2, $zero, 0		# $t2 = index (x4) to first in pair 
		addi	$t3, $zero, 4		# $t3 = index (x4) to second in pair
innlp2:		lw	$t4, PriorityArray($t2)		# put first number of pair into $t4
		lw	$t5, PriorityArray($t3)		# put second number of pair into $t5 
		
		lw	$s4, SSNArray($t2)	#also get the corresponding SSN array values in case of swap
		lw	$s5, SSNArray($t3)	#so t4,t5 are Priority, s4,s5 are SSN
		
		bge	$t4, $t5, skipPriority		# skip ahead if already in order
		sw	$t5, PriorityArray($t2)		# otherwise, swap them in the array
		sw	$t4, PriorityArray($t3)
		sw	$s5, SSNArray($t2)
		sw	$s4, SSNArray($t3)	
		
skipPriority:   addi	$t2, $t2, 4		# update $t2 and $t3 for next pair
		addi	$t3, $t3, 4 
		addi	$t1, $t1, -1		# decrement inner loop counter 
		bne	$t1, $zero, innlp2	#    and maybe loop back 
		addi	$t0, $t0, -1		# decrement outer loop counter
		bne	$t0, $zero, outlp2	#    and maybe loop back 		
		
		
		
		lw	$s4, ($sp)
		lw	$s1, 4($sp)
		lw	$t5, 8($sp)
		lw	$t4, 12($sp)
		lw	$t3, 16($sp)
		lw	$t2, 20($sp)
		lw	$t1, 24($sp)
		lw	$t0, 28($sp)
		lw	$ra, 32($sp)
		lw	$s5, 36($sp)
		add	$sp, $sp, 40
		jr	$ra 

# Do a carriage return 
carrRet: 
		addi	$sp, $sp, -8
		sw	$ra, ($sp)
		sw	$a0, 4($sp)
		la	$a0, carriageReturn
		jal	dispStr
		lw	$ra, ($sp)
		lw	$a0, 4($sp)
		addi	$sp, $sp, 8
		jr	$ra

# Display a space  
dispSpace: 
		addi	$sp, $sp, -8
		sw	$ra, ($sp)
		sw	$a0, 4($sp)
		la	$a0, space
		jal	dispStr
		lw	$ra, ($sp)
		lw	$a0, 4($sp)
		addi	$sp, $sp, 8
		jr	$ra

# Display a string
# receive: 
#   $a0 = starting address of string 
# (leave registers unaffected) 
dispStr: 
		addi	$sp, $sp, -4
		sw	$v0, ($sp)
		addi	$v0, $zero, 4
		syscall
		lw	$v0, ($sp)
		addi	$sp, $sp, 4
		jr	$ra

# Display a number
# receive: 
#   $a0 = number to display
# (leave registers unaffected) 
dispNum: 
		addi	$sp, $sp, -4
		sw	$v0, ($sp)
		addi	$v0, $zero, 1
		syscall
		lw	$v0, ($sp)
		addi	$sp, $sp, 4
		jr	$ra

# Get a number from user
# return: 
#   $v0 = number from user  
# (leave other registers unaffected) 
getNum: 
		addi	$v0, $zero, 5
		syscall
		jr	$ra

# terminate program cleanly 
quit: 
		la	$a0, byeMessage
		jal	dispStr
		addi	$v0, $zero, 10
		syscall
		
# display both arrays (for diagnostic purposes) 
dump: 
	addi	$sp, $sp, -20		# push registers that will be changed 
	sw	$s0 16($sp) 
	sw	$t1 12($sp) 
	sw	$t0  8($sp) 
	sw	$v0, 4($sp)
	sw	$a0, 0($sp)
	la	$a0, carriageReturn	# start a new line 
	addi	$v0, $zero, 4
	syscall
	lw	$s0, NumberOfCustomers($zero) # $s0 = array size 
	beq	$s0, $zero, dump3 
	add	$t0, $zero, $s0		# $t0 = loop counter (count down)
	addi	$t1, $zero, 0		# $t1 is array index times four
dump1:	lw	$a0, SSNArray($t1)	# loop: get SSNArray entry and display it 
	addi	$v0, $zero, 1
	syscall
	la	$a0, space		# separate numbers with spaces
	addi	$v0, $zero, 4
	syscall
	addi	$t1, $t1, 4		# update array index (times four) 
	addi	$t0, $t0, -1		# decrement loop counter 
	bne	$t0, $zero, dump1	# maybe loop back 
	la	$a0, carriageReturn	# start a new line 
	addi	$v0, $zero, 4
	syscall
	add	$t0, $zero, $s0		# $t0 = loop counter (count down)
	addi	$t1, $zero, 0		# $t1 is array index times four
dump2:	lw	$a0, PriorityArray($t1)	# loop: get PriorityArray entry and display it 
	addi	$v0, $zero, 1
	syscall
	la	$a0, space		# separate numbers with spaces
	addi	$v0, $zero, 4
	syscall
	addi	$t1, $t1, 4		# update array index (times four) 
	addi	$t0, $t0, -1		# decrement loop counter 
	bne	$t0, $zero, dump2	# maybe loop back 
dump3:	la	$a0, carriageReturn	# start a new line 
	addi	$v0, $zero, 4
	syscall
	lw	$s0 16($sp) 		# pop registers that will be changed 
	lw	$t1 12($sp) 
	lw	$t0  8($sp) 
	lw	$v0, 4($sp)
	lw	$a0, 0($sp)
	addi	$sp, $sp, 20
	jr	$ra
