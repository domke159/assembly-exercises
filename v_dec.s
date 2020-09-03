	.global v_dec

@	Subroutine v_dec will display a 32-bit register in decimal digits
@	R0: contains a number to be displayed in decimal
@	    (If negative (bit 31 = 1), then the number will be displayed in brackets
@	Every 3 digits a comma will be printed
@	LR: Contains the return address
@	All register contents will be preserved

v_dec:	push	{R0-R7}		@ Save contents of registers R0 through R7

	mov	R3,R0		@ R3 will hold a copy of input word to be displayed.
	mov	R2,#1		@ Number of characters to be displayed at a time.
	mov	R0,#1		@ Code for stdout (standard output, i.e., monitor display)
	mov	R7,#4		@ Linux service command code to write string.

@	If bit-31 is set, then register contains a negative number and "-" should be output.

	cmp	R3,#0		@ Determine if brackets are needed.
	bge	absval		@ If positive number, then just display it
	ldr	R1,=symbol	@ Address of "(" in memory
	mov	R8,#1		@ Set R8 to hold a value of 1
	svc	0		@ Service call to write string to stdout device
	rsb	R3,R3,#0	@ Get absolute value (negative of negative) for display

absval:	cmp	R3,#10		@ Test whether only one's column is needed
	blt	onecol		@ Go output "final" column of display
	
@	Get highest power of ten this number will use (i.e., is it greater than 10?, 100?, ...)

	mov	R9,#2		@ Set R9 to hold a value of 2
	ldr	R6,=pow10+8	@ Point to hundred's column of power of ten table.
high10:	ldr	R5,[R6],#4	@ Load next higher power of ten
	add	R9,#1		@ Increase the digit
	cmp	R3,R5		@ Test if we've reached the highest power of ten needed
	bge	high10		@ Continue search for power of ten that is greater.
	sub	R6,#8		@ We stepped two integers too far.

@	Loop through powers of 10 and output each to the standard output (stdout) monitor display.

nxtdec:	ldr	R1,=dig-1	@ Set R1 pointing to the next higher digit '0' through '9'
	ldr	R5,[R6],#-4	@ Load next lower power of 10 (move right 1 dec column)
	sub	R9,#1		@ We stepped one digit too far

@	Loop through the next base ten digit to be displayed (i.e., thousands, hundreds, ...)

mod10:	add	R1,#1		@ Set R1 pointing to the next higher digit '0' to '9'.
	subs	R3,R5		@ Do a count down to find the correct digit
	bge	mod10		@ Keep subtracting current decimal column value
	addlt	R3,R5		@ We counted one too many (went negative)
	svc	0		@ Write the next digit to display
	cmp	R9,#4		@ Test if we've passed 3rd digit
	cmpne	R9,#7		@ Test if we've passed 6th digit (excluding previous ",")
	cmpne	R9,#10		@ Test if we've passed 9th digit (excluding previous ",")
	ldr	R1,=symbol+2	@ If we've passed 3rd, 6th or 9th digit, point to ","
	svceq	0		@ If R9 is equal to 4, 7 or 10 write ","
	
	cmp	R5,#10		@ Test if we've gone all the way to the one's column.
	bgt	nxtdec		@ If 1's column, go output rightmost digit and return.


@	Finish decimal display by calculating the one's digit 

onecol: ldr	R1,=dig		@ Pointer to "0123456789"
	add	R1,R3		@ Generate offset into "0123456789" for one's digit.
	svc	0		@ Write out the final digit.
	cmp	R0,#0		@ Determine if brackets are needed.
	cmp	R8,#1		@ If the number is negative R8 will hold a value of 1
	ldr	R1,=symbol+1	@ Set R1 pointing to ")"
	svceq	0		@ If R8 is 1 write ")"

	
	pop	{R0-R7}		@ Restore saved register contents
	bx	LR		@ Return to the calling program


	.data
pow10:	.word	1		@ 10^0
	.word	10		@ 10^1
	.word	100		@ 10^2
	.word	1000		@ 10^3 (thousand)
	.word	10000		@ 10^4
	.word	100000		@ 10^5
	.word	1000000		@ 10^6 (million)
	.word	10000000	@ 10^7
	.word	100000000	@ 10^8
	.word	1000000000	@ 10^9 (billion)

dig:	.ascii	"0123456789"	@ ASCII string of digits 0 through 9

symbol:	.ascii	"(),"		@ ASCII string of "(",")" and ","

	.end