; AddTwo.asm - adds two 32-bit integers.
; Chapter 3 example

.386
.model flat,stdcall
.stack 4096
ExitProcess proto,dwExitCode:dword

.data
sum	DWORD	?	;Uninitialized output for our computation result

.code
main proc
	mov	eax,5	; Get the first operand in our sum (5)		
	add	eax,6	; Add the second operand in our sum (5+6)
	mov	sum, eax	; It is our first program, so we should keep the result!

	invoke ExitProcess,0
main endp
end main
