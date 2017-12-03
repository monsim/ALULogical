.include "./cs47_proj_macro.asm"
.text
.globl au_normal
# TBD: Complete your project procedures
# Needed skeleton is given
#####################################################################
# Implement au_normal
# Argument:
# 	$a0: First number
#	$a1: Second number
#	$a2: operation code ('+':add, '-':sub, '*':mul, '/':div)
# Return:
#	$v0: ($a0+$a1) | ($a0-$a1) | ($a0*$a1):LO | ($a0 / $a1)
# 	$v1: ($a0 * $a1):HI | ($a0 % $a1)
# Notes:
#####################################################################
au_normal:
# TBD: Complete it
	
	
	beq $a2, '+', ADD
	beq $a2, '-', SUB
	beq $a2, '*', MUL
	beq $a2, '/', DIV

ADD:
	add $v0, $a0, $a1
	jr	$ra

SUB:
	sub $v0, $a0, $a1
	jr	$ra

MUL:
	mult $a0, $a1
	mflo $v0
	mfhi $v1
	jr	$ra

DIV:
#	div $v0, $a0
#	mflo $v0
#	mfhi $v1
	jr	$ra
