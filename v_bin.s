.global v_bin

v_bin: 	push	{R0-R7}		@ Save contents of registers R0 through R7
	sub	R6,R2,#1	@ Number of bits to display (-1)
	mov	R6,#31		@ Number of bits remaining to display
	movhi	R6,#0		@ If bad range, default to displaying only 1 bit
	mov	R3,R0		@ R3 will hold a copy of input word to be displayed
	mov	R4,#1		@ Used to mask off 1 bit a time for display of the binary value

	ldr	R1,=msgtxt	@ Pointer to the "0b" string of ASCII characters
	mov	R2,#2		@ Number of bytes in the message that precedes the binary value
	mov	R0,#1		@ Code for stdout (standard output, i.e., monitor display)
	mov	R7,#4		@ Linux service command code to write string
	svc	0		@ Issue command to display string on stdout

	ldr	R5,=dig		@ Pointer to the "01" string of ASCII characters
	mov	R2,#1		@ Number of characters to be displayed at a time
	mov	R0,#1		@ Code for stdout (standard output, i.e., monitor display)
	mov	R7,#4		@ Linux service command code to write string


@	Skip over leading zeroes (on the left)

nxtzer: ands	R1,R4,R3,LSR R6	@ Select next binary digit to be displayed
	bne	nxtbit		@ Go write first binary digit
	subs	R6,#1		@ Decrement number of bits remaining to display
	bgt	nxtzer		@ Go check if there are any leading zeroes


@	Loop through single bits and output each to the standard output (stdout) display

nxtbit: and	R1,R4,R3,LSR R6	@ Select next 0 or 1 to be displayed
	add	R1,R5		@ Set R1 pointing to "0" or "1" in memory
	svc	0		@ Linux service command code to write string
	subs	R6,#1		@ Decrement number of bits remaining to display
	bge	nxtbit		@ Go display next bit until all 32 are displayed

	pop	{R0-R7}		@ Restore saved register contents
	bx	LR		@ Return to the calling program

	.data
dig:	.ascii "01"		@ ASCII string of binary digits 0 and 1

msgtxt: .ascii "0b"		@ ASCII string of "0b"
