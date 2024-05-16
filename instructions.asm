.text
    main:
    	# r = a - floor(a/b)*b
        lw $t1, 0($0) # Load the first obj in memory to $t1 (a)
        lw $t2, 1($0) # Load the second obj in memory to $t2 (b)
        div $t2, $t1 # Divide the data held in the first two memory slots (a/b)
        mflo $t3 # Move the lower 32 bits of the result to $t3
        mult $t2, $t3 # Multiply the quotient by (b)
	mflo $t4
        sub $t5, $t1, $t4 # Subtract the product from (a)
        sw $t5, 2($0) # Store result (remainder, r) into the third memory slot
        
        addi $t6, $zero, 1911 # Add immediate 0x777 to zero into $t6
        sw $t6, 3($0) # Store 0x777 into fourth memory slot
        j LiamBranch # Jump past the instruction below
        addi $t7, $0, 1638 # Add 0x666 to zero into $t7 (shouldnt happen)
        sw $t7, 4($0) # Store 0x666 into fifth memory slot (shouldnt happen)
        
LiamBranch:
	beq $t6, $0, DontGoHere # Branch shouldnt happen
        # End of program
        j exit

DontGoHere:
	addi $t8, $zero, 48879 # Add immediate 0xBEEF to zero into $t8 
        sw $t8, 6($t1) # Store 0xBEEF into seventh memory slot

exit:
        # Terminate the program
        addi $t9, $zero, 57005 # Add immediate 0xDEAD to zero into $t9
        sw $t9, 7($t9) # Store 0xDEAD into eigth memory slot
        nop