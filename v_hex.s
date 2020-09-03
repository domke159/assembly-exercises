	.global v_hex

@	Subroutine v_hex will display a 32-bit register in binary digits
@	R0: contains a number to be displayed in hexadecimal
@	R2: Number of nibbles to be displayed (from right side of R0)
@	Note: If R2=0 or R2>8 leading zeroes (on left) will not be displayed
@	LR: Contains the return address
@	All register contents will be preserved

v_hex:	push	{R0-R7}		@ Save contents of registers R0 through R7
	mov	R3,R0		@ R3 will hold a copy of input word to be displayed
	mov	R4,#0b1111	@ Used to mask off 4 bits ata a time for display
	mov	R6,R2,lsl#2	@ Load number of bits to display (4 bits for each nibble)

@	Display "0x" before the hex value

	ldr	R1,=msgtxt	@ Pointer to the message that prints "0x" before the hex value
	mov	R2,#2		@ Number of bytes in the message that precedes the hex value
	mov	R0,#1		@ Code for stdout (standard output, i.e., monitor display)
	mov	R7,#4		@ Linux service command code to write string
	svc	0		@ Issue command to display string on stdout

@	Set up registers for calling Linux to display 1 character on the display monitor

	ldr	R5,=dig		@ Pointer to the "012...EF" string of ASCII characters
	mov	R2,#1		@ Number of characters to be displayed at a time
	mov	R0,#1		@ Code for stdout (standard output, i.e., monitor display)
	mov	R7,#4		@ Linux service command code to write string

@	Determine number of bits to be output (R6 has that value if it is between 4 and 32)

	cmp	R6,#32		@ Test error value entered (there's only 32 bits in register)
	movhi	R6,#0		@ Default to omitting leading zeroes if value > 32
	subs	R6,#4		@ Set R6 point to "right" side of first nibble to output

	mov	R6,#28		@ Number of bits in register - number of bits per hex digit

@	Loop through groups of 4-bit nibbles and output each to stdout (monitor)

nxthex: sub	R6,#4		@ Decrement number of nibbles remaining to display
	ands	R1,R4,R3,LSR R6	@ Select next hex digit (0 .. F) to be displayed
	add	R1,R5		@ Set R1 pointing to "0", "1", ... or "F" in memory	
	svcne	0		@ Output if not zero
	movne	R8,#1		@ If R8 is one, there are preceding zeroes on the left
	cmpeq	R8,#1		@ Determine if R1 is a zero on the left
	svceq	0		@ If zero is not on the left, output it
	cmp	R6,#0		@ Determine if all nibbles are checked
	cmpeq	R8,#0		@ Determine if all zeroes are checked
	svceq	0		@ If zero is not on the left, output it
	cmp	R6,#0		@ Determine if all nibbles are checked
	bgt	nxthex		@ Go display next nibble until max bit-count reached

	pop	{R0-R7}		@ Restore saved register contents
	bx	LR		@ Return to the calling program


	.data
dig:	.ascii	"0123456789"	@ ASCII string of digits 0 through 9
	.ascii	"ABCDEF"	@ ASCII string of digits A through F

msgtxt: .ascii	"0x"		@ ASCII string of "0x"
	.end