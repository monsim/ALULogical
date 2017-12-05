# Add you macro definition here - do not touch cs47_common_macro.asm"
#<------------------ MACRO DEFINITIONS ---------------------->#

.macro extract_nth_bit($regD, $regS, $regT)
#regD: will contain 0x0 or 0x1 depending on nth bit being 0 or 1
#regS: Source bit pattern
#regT:  Bit position n (0-31)
#shift $regS by $regT and mask to $regD


addi    $regD, $zero, 1 	
sllv    $regD, $regD, $regT
and 	$regD, $regD, $regS
srlv    $regD, $regD, $regT


.end_macro 

 	
.macro insert_to_nth_bit ($regD, $regS, $regT, $maskReg)
#regD: This the bit pattern in which 0 or 1 to be inserted at nth position
#regS: Value n, from which position the bit to be inserted (0- 31)
#regT: Register that contains 0x1 or 0x0 (bit value to insert)
#maskReg = Register to hold temporary mask
#li $maskReg, 1

add $maskReg, $zero, 1
sllv $maskReg, $maskReg, $regS
not $maskReg, $maskReg 
and $regD, $regD, $maskReg
sllv $regT, $regT, $regS
or $regD, $regT, $regD
.end_macro
