.include "./cs47_proj_macro.asm"
.include "./cs47_common_macro.asm"
.data
addition: .word 0x00000000
subtraction: .word 0xFFFFFFFF
.text

.globl au_logical
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_logical
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################


au_logical:
# TBD: Complete it
	
	#store frame
	addi	$sp, $sp, -28
	sw	$a0, 28($sp)
	sw	$a2, 24($sp)
	sw	$a1, 20($sp)
	sw	$a3, 16($sp)
	sw	$fp, 12($sp)
	sw 	$ra, 8($sp)
	addi	$fp, $sp, 28
	
	beq $a2, '+', add_logical
	beq $a2, '-', sub_logical
	beq $a2, '*', mul_logical
	beq $a2, '/', div_logical
	
mul_logical:
	jal mul_signed
	j exit
	
div_logical:
	jal div_signed
	j exit


add_logical:
#store frame
	addi	$sp, $sp, -28
	sw	$a0, 28($sp)
	sw	$a2, 24($sp)
	sw	$a1, 20($sp)
	sw	$a3, 16($sp)
	sw	$fp, 12($sp)
	sw 	$ra, 8($sp)
	addi	$fp, $sp, 28
	
	lw $a2, addition
	jal add_sub_logical
#	move $v1, $a3 	#move a3 to v1. move carry to v1
	j exit

#SUBTRACTION ******************************
sub_logical:

#store frame
	addi	$sp, $sp, -28
	sw	$a0, 28($sp)
	sw	$a2, 24($sp)
	sw	$a1, 20($sp)
	sw	$a3, 16($sp)
	sw	$fp, 12($sp)
	sw 	$ra, 8($sp)
	addi	$fp, $sp, 28
	
	lw $a2, subtraction
	jal add_sub_logical
	j exit
add_sub_logical:
	
	#store frame
	addi	$sp, $sp, -28
	sw	$a0, 28($sp)
	sw	$a2, 24($sp)
	sw	$a1, 20($sp)
	sw	$a3, 16($sp)
	sw	$fp, 12($sp)
	sw 	$ra, 8($sp)
	addi	$fp, $sp, 28
	
	
	addi $t0, $zero, 0 #set loop counter to 0. I = 0			
	addi $t1, $zero, 31 #set to 31 to know when to stop loop. 
	addi $t8, $zero, 0 #set sum to 0. S = 0
	extract_nth_bit($a3, $a2, $zero) #Cin to $a3. $a3 = $a2[0]
	beq $a3, 1, subtract	#branch off if Cin = 1. this means it is subtraction
	j LOOP_ADD
	
subtract:
	#two's complement --> invert $a1 and add 1
	not $a1, $a1 #invert
	j LOOP_ADD
LOOP_ADD:
	#Y = C XOR (A XOR B)
	
	extract_nth_bit($t2, $a0, $t0) #A = a[I]. A = $t2
	extract_nth_bit($t3, $a1, $t0) #B = b[I]. B = $t3
	xor $t4, $t2, $t3 # $t4 = A XOR B
	xor $t9, $a3, $t4 # $t9 = C XOR (A XOR B). Y = $t9
	
	#C = C(A XOR B) + AB
	
	and $t6, $t2, $t3 # t6 = t2 & t3 (t6 = AB)
	and $t7, $a3, $t4   # t7 = C & (A XOR B) 
	or $a3, $t7, $t6  # a3 = t7 + t6. a3 = C(A XOR B) + AB. $a3 = C
	
	# S[I] = Y
	insert_to_nth_bit($t8, $t0, $t9, $t5) #t8 is sum. t0 is i. t9 is y. it is ok to overwrite t5
	addi $t0, $t0, 1 #increment loop counter. I = I + 1	
	beq $t0, 32, exit_add_sub 	#end loop if t0 >= t1. if counter = 31 				
	j LOOP_ADD
	#bne $t0, $t1, LOOP
	#j exit_add_sub
	
	
exit_add_sub:	#end loop
	move $v0, $t8	#sum
	move $v1, $a3	#carry
	
	#restore frame\
	lw	$a0, 28($sp)
	lw	$a2, 24($sp)
	lw	$a1, 20($sp)
	lw	$a3, 16($sp)
	lw	$fp, 12($sp)
	lw 	$ra, 8($sp)
	addi	$sp, $sp, 28
	jr $ra 
	
#MULTIPLICATION ******************************************************************

twos_complement_if_neg:
    addi     $sp, $sp, -16
    sw    $fp, 16($sp)
    sw    $ra, 12($sp)
    sw    $a0,  8($sp)
    addi    $fp, $sp, 16 
    move    $v0 , $a0 
    bge     $a0, 0x0, twos_complement_if_neg_end #if a0 > 0, don't find the 2's comp
    jal    twos_complement
    j twos_complement_if_neg_end
    
    # if $a0  = 5 
    # jumps to end 
twos_complement_if_neg_end:
	
    lw    $fp, 16($sp)
    lw    $ra, 12($sp)
    lw    $a0,  8($sp)
    addi    $sp, $sp, 16

    jr    $ra

# $a0 is the number of which we are computing the complement    
twos_complement:

#store frame
    addi    $sp, $sp, -24
    sw    $fp, 24($sp)
    sw    $ra, 20($sp)
    sw    $a0, 16($sp)
    sw    $a1, 12($sp)
    sw    $a2,  8($sp)
    addi    $fp, $sp, 24

    not    $a0, $a0        # $a0 = ~$a0
    addi     $a1, $zero, 1        # $a1 = 1
    
    jal    add_logical        #add a0 + a1. ~a0 + 1

#restore frame
    lw    $fp, 24($sp)
    lw    $ra, 20($sp)
    lw    $a0, 16($sp)
    lw    $a1, 12($sp)
    lw    $a2,  8($sp)
    addi    $sp, $sp, 24
    
    jr    $ra

bit_replicator:

#store frame
	addi	$sp, $sp, -16
	sw	$a0, 16($sp)
	sw	$fp, 12($sp)
	sw 	$ra, 8($sp)
	addi	$fp, $sp, 16
	
	
    	beq $a0, $zero, zero_replicator
    	lw $v0, subtraction #0xFFFFFFFF
 	j bit_replicator_end
  
 

bit_replicator_end:
 #restore frame
	lw	$a0, 16($sp)
	lw	$fp, 12($sp)
	lw 	$ra, 8($sp)
	addi	$sp, $sp, 16
	
	jr $ra
	
zero_replicator:
	lw $v0, addition #0x00000000
	j bit_replicator_end

twos_complement_64bit:

#store frame
	addi	$sp, $sp, -28
	sw	$a2, 28($sp)
	sw	$s7, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$fp, 12($sp)
	sw 	$ra, 8($sp)
	addi	$fp, $sp, 28

	
    	not $a0, $a0   	#a0 = ~a0
    	not $a1, $a1   	#a1 = ~a1
    	move $s7, $a1  	#s0 = a1 = ~a1. to accomodate since add_logical takes a0 and a1
    	addi $a1, $zero, 1	#a1 = 1
	jal 	add_logical
#    	jal add_logical  	#add a0 + a1
    	move $a1, $s7	#move a1 from s7
    	move $s7, $v0  	#move v0 (sum) to s7. s7 = sum
    	move $a0, $v1 	#move carry to become arg
	jal 	add_logical
#    	jal add_logical 	#add a0 + a1
    	move $v1, $v0	#move v0 (sum) to v1 (hi)
    	move $v0, $s7	#move s7 (sum) to v0 (lo)
    
    #restore frame
    	lw	$a2, 28($sp)
    	lw	$s7, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$fp, 12($sp)
	lw 	$ra, 8($sp)
	addi	$sp, $sp, 28
	
	jr $ra
	
mul_unsigned:

#store frame
	addi	$sp, $sp, -40
	sw	$a2, 40($sp)
	sw	$s0, 36($sp)
	sw	$s1, 32($sp)
	sw	$s2, 28($sp)
	sw 	$s3, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$fp, 12($sp)
	sw 	$ra, 8($sp)
	addi	$fp, $sp, 40


#a0 : multiplicand
#a1 : multiplier
	addi $s0, $zero, 0 	#loop counter to 0. I = 0 
	addi $s1, $zero, 0 	#high. H = 0
	move $s2, $a1		#multiplier. $t2 = L
	move $s3, $a0		#multiplicand. $t3 = M
	j LOOP_MULT
	

LOOP_MULT:
	extract_nth_bit($t4, $s2, $zero)   #extract 0th bit of L and set it to $t4  # r = $t4
	move $a0, $t4			   #a0 = t4 = 0th bit of L # move r into $a0 arg for bit replicator
	jal bit_replicator 		   #replicate 0th bit 32 times 
	move $t4, $v0 			   #t4 = R 
	and $t7, $s3, $t4 		   # X = M & R 
	move $a0, $s1			   # a0 = H
	move $a1, $t7			   # a1 = X

	jal 	add_logical
#	jal add_logical			   # H + X
	move $s1, $v0			   # v0 holds the result of the previous add_logical H = H + X	
#	print_reg_int($v0)
#	print_reg_int($s1)
	addi $t6, $zero, 1		   # $t6 = 1
	addi $t4, $zero, 31		   # $t4 = 31
	#srlv $s2, $s2, $t6		   # L = L >> 1
	srl $s2, $s2 , 1
	extract_nth_bit($t8, $s1, $zero)   # $t8 = H[0]
	insert_to_nth_bit($s2, $t4, $t8, $t9)  # L[31] = H[0]
	
	
	# srlv $s1, $s1, $t6		   # H = H >> 1
	srl $s1, $s1 , 1
#	print_reg_int($s1)
	addi $s0, $s0, 1		   # increment loop counter. I = I + 1
#	print_reg_int($s2)
#	print_reg_int($s1)
	beq $s0, 32, mul_unsigned_end	   #if I == 32 end of loop and exit
	j LOOP_MULT			   #loop again otherwise
	
mul_unsigned_end:
	#lo to $v0 and hi to $v1
	
#	print_reg_int($s2)
#s	print_reg_int($s1)
	move $v0, $s2		#s2 is lo
	move $v1, $s1		#s1 is hi
	
	#restore frame
	lw	$a2, 40($sp)
	lw	$s0, 36($sp)
	lw	$s1, 32($sp)
	lw	$s2, 28($sp)
	lw	$s3, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$fp, 12($sp)
	lw 	$ra, 8($sp)
	addi	$sp, $sp, 40
	
	
	jr $ra

mul_signed: 

#store frame
	addi	$sp, $sp, -44
	sw	$s1, 44($sp)
	sw	$s2, 40($sp)
	sw	$s3, 36($sp)
	sw	$s6, 32($sp)
	sw	$s5, 28($sp)
	sw 	$s4, 24($sp)
	sw	$a0, 20($sp)
	sw	$a1, 16($sp)
	sw	$fp, 12($sp)
	sw 	$ra, 8($sp)
	addi	$fp, $sp, 44


#a0 : multiplicand
#a1 : multiplier
	move $s4, $a0	#a0 is N1. s4 is original a0, not to be changed
	move $s5, $a1	#a1 is N2. s5 is original a1, not to be changed
	jal twos_complement_if_neg	#N1 two's comp
	move $s3, $v0 		#two's comp N1 into temporary register 
	move $a0, $a1		#move N2 to arg (a0) of twos_comp
	jal twos_complement_if_neg
	move $a1, $v0		#two's comp N2 into N2
	move $a0, $s3		#move N1 back to a0
	jal mul_unsigned
	
	addi $t7, $zero, 31
	
	move $a0, $v0 	#a0 = Rlo
	move $a1, $v1	#a1 = Rhi
	
	extract_nth_bit($s2, $s4, $t7)	#$t9 = $s4[31]. s4 is original a0
	extract_nth_bit($s1, $s5, $t7)	#$t8 = $s5[31]. s5 is original a1
	
	xor $s6, $s2, $s1		#t9 XOR t8. s6 = S
	bne $s6, 1, mul_signed_end
	
	jal twos_complement_64bit	#if S = 1 find two's comp of Rhi and Rlo
	
	j mul_signed_end
						
mul_signed_end:
	
	#restore frame
	lw	$s1, 44($sp)
	lw	$s2, 40($sp)
	lw	$s3, 36($sp)
	lw	$s6, 32($sp)
	lw	$s5, 28($sp)
	lw	$s4, 24($sp)
	lw	$a0, 20($sp)
	lw	$a1, 16($sp)
	lw	$fp, 12($sp)
	lw 	$ra, 8($sp)
	addi	$sp, $sp, 44
	
	jr $ra


	

# DIVISION ****************************************************************************

	
div_unsigned:

#store frame
	addi	$sp, $sp, -52
	sw	$t6, 52($sp)
	sw	$t4, 48($sp)
	sw	$s5, 44($sp)
	sw	$t3, 40($sp)
	sw	$s2, 36($sp)
	sw	$s7, 32($sp)
	sw	$a2, 28($sp)
	sw	$a0, 24($sp)
	sw	$s1, 20($sp)
	sw	$s0, 16($sp)
	sw	$fp, 12($sp)
	sw 	$ra, 8($sp)
	addi	$fp, $sp, 52
	
	
	
	addi $s7, $zero, 0 	# s7  = I = 0
	addi $s2, $zero, 0	# $s2 = R = 0
	move $s0, $a0		#dividend (Q)
	move $s1, $a1		#divisor (D)
#	print_reg_int($t0)
	j LOOP_DIV
	
LOOP_DIV:
#	addi $t3, $zero, 1	# $t3 = 1
	sll $s2, $s2, 1 	# R = R << 1
	addi $t3, $zero, 31	# $t3 = 31
	extract_nth_bit($t4, $s0, $t3) # $t4 = Q[31]
	insert_to_nth_bit($s2, $zero, $t4, $t5)
	addi $t3, $zero, 1
	sll $s0, $s0, 1 	# Q = Q << 1
	move $t6, $a0
	move $a0, $s2		#move R to a0. D is already a1
#	li $a2, '-'
#	jal au_logical 
	jal sub_logical
	move $a0, $t6
	move $s5, $v0		# s5 = S = R - D
	bge $s5, $zero, LABEL_1	#branch if S is greater than 0 
	j increment_i	#if less than, then increment i

				
LABEL_1:
	move $s2, $s5 		# R = S
	addi $t3, $zero, 1	# $t3 = 1
	insert_to_nth_bit($s0, $zero, $t3, $t6)	#insert 1 into LSB of Q 
	j increment_i

		
increment_i:
 	addi $s7, $s7, 1	# increment i
#	addi $t3, $zero, 32	# $t3 = 32
#	print_reg_int($t0)
	beq $s7, 32, div_unsigned_end 	#end loop if i is 32
	j LOOP_DIV			#else loop again


div_signed:
#store frame
	addi	$sp, $sp, -60
	sw	$s7, 60($sp)
	sw	$s2, 56($sp)
	sw	$s6, 52($sp)
	sw	$t4, 48($sp)
	sw	$s5, 44($sp)
	sw	$s3, 40($sp)
	sw	$s1, 36($sp)
	sw	$s0, 32($sp)
	sw	$a1, 28($sp)
	sw	$a0, 24($sp)
	sw	$fp, 12($sp)
	sw 	$ra, 8($sp)
	addi	$fp, $sp, 60
	move $s0, $a0	#s0 is a0, don't change it
	move $s1, $a1	#s1 is a1, don't change it
	jal twos_complement_if_neg	#turn a0 is 2's comp a0 if neg
	move $t2, $v0	#N1
	move $a0, $s1	#put s1 in arg position
	jal twos_complement_if_neg	#find two's comp of a1
	move $a1, $v0	#a1 is 2's complement N2
	move $a0, $t2	#a0 is 2's complement N1
	jal div_unsigned 	#neither a0 or a1 are signed now, safe to do
	move $s2, $v0		#s2 = Q
	move $s3, $v1		#s3 = R
	addi $t4, $zero, 31	# $t4 = 31
	extract_nth_bit($s5, $s0, $t4) 	# $t5 = a0[31]
	extract_nth_bit($s6, $s1, $t4)	# $t6 = a1[31]
	xor $s7, $s5, $s6		# S = a0[31] XOR a1[31]
	move $a0, $s2			# a0 = Q
	bne $s7, 1, find_r
	jal twos_complement		#find two's comp of Q if S is 1
	move $s2, $v0			#set Q as 2's comp of Q
	j find_r
	
find_r:
	move $s7, $s5  #S = a0[31]
	bne $s7, 1, div_signed_end
	move $a0, $s3
	jal twos_complement
	move $s3, $v0	#set R as 2's comp of R
	j div_signed_end
	

div_signed_end:

	move $v0, $s2	#quotient
	move $v1, $s3	#remainder
	
	#restore frame
	lw	$s7, 60($sp)
	lw	$s2, 56($sp)
	lw	$s6, 52($sp)
	lw	$t4, 48($sp)
	lw	$s5, 44($sp)
	lw	$s3, 40($sp)
	lw	$s1, 36($sp)
	lw	$s0, 32($sp)
	lw	$a1, 28($sp)
	lw	$a0, 24($sp)
	lw	$fp, 12($sp)
	lw 	$ra, 8($sp)
	addi	$sp, $sp, 60
	
	jr $ra


div_unsigned_end:
		
	move $v1, $s2	#remainder
	move $v0, $s0	#quotient
			
	#restore frame
	lw	$t6, 52($sp)
	lw	$t4, 48($sp)
	lw	$s5, 44($sp)
	lw	$t3, 40($sp)
	lw	$s2, 36($sp)
	lw	$s7, 32($sp)
	lw	$a2, 28($sp)
	lw	$a0, 24($sp)
	lw	$s1, 20($sp)
	lw	$s0, 16($sp)
	lw	$fp, 12($sp)
	lw 	$ra, 8($sp)
	addi	$sp, $sp, 52
	
	jr $ra
		
												
				
					
							

# EXIT ALU_LOGICAL ************************************************
exit:	#end loop
	
	#restore frame
	lw	$a0, 28($sp)
	lw	$a2, 24($sp)
	lw	$a1, 20($sp)
	lw	$a3, 16($sp)
	lw	$fp, 12($sp)
	lw 	$ra, 8($sp)
	addi	$sp, $sp, 28
	jr $ra 
	
