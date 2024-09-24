; **********************************************************************;
; Program Name:   Template (Template.asm)				;
; Program Description:							;
; Author:								;
; Creation Date:							;
; Revisions: 								;
; Date Last Modified:							;
;***********************************************************************;

INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
hrsPrompt BYTE "Enter the number of hours: ",0
minsPrompt BYTE "Enter the number of minutes: ",0
secsPrompt BYTE "Enter the number of seconds: ",0

hrsConfirm BYTE "The number of hours entered was ",0
minConfirm BYTE "The number of minutes entered was ",0
secConfirm BYTE "The number of seconds entered was ",0

totalMins1 BYTE "The total number of minutes is ",0
totalMins2 BYTE " minutes.",0

totalSecs1 BYTE "The total number of seconds is ",0
totalSecs2 BYTE " seconds.",0

tryagain BYTE "Try again (y/n)? ",0

invalidInput BYTE "Invalid input. Try again.",0



; **********************************************************************;
; Functional description of the main program				;
;	Inputs								;
;	Outputs								;
;	Registers used and associated purpose of each			;
;	Memory locations use and associated purpose of each		;					
;	Functional details						;
; There should be a similar block prior to procedures, functions, or   ;
;	otherwise major sections of code				;
; **********************************************************************;

.code
main PROC

  
START:
	mov edx, OFFSET hrsPrompt
	call WriteString 
	call ReadInt
	mov esi, eax ; store hours in esi

	mov edx, OFFSET minsPrompt
	call WriteString
	call ReadInt
	mov edi, eax ; store minutes in edi

	mov edx, OFFSET secsPrompt
	call WriteString
	call ReadInt
	mov ebx, eax ; store seconds in ebx

	call Crlf
	
	mov edx, OFFSET hrsConfirm
	call WriteString
	mov eax, esi
	call WriteInt
	call Crlf

	mov edx, OFFSET minConfirm
	call WriteString
	mov eax, edi
	call WriteInt
	call Crlf

	mov edx, OFFSET secConfirm
	call WriteString
	mov eax, ebx
	call WriteInt
	call Crlf

	call Crlf

	
	xor edx, edx ; clear edx
	mov eax, ebx ;move seconds to eax
	mov ecx, 60 
	div ecx ; divide seconds by 60 (minutes from seconds is now in EAX)

	mov ebx, edx ; store remainder seconds in ebx

	imul esi, 60 ; convert hrs to mins

	add edi, esi ; add minutes

	add edi, eax ; add minutes 

	mov eax, edi

	mov edx, OFFSET totalMins1
	call WriteString
	call WriteInt
	mov edx, OFFSET totalMins2
	call WriteString
	call Crlf

	imul eax, 60

	add eax, ebx ; add remainder seconds back

	mov edx, OFFSET totalSecs1
	call WriteString
	call WriteInt
	mov edx, OFFSET totalSecs2
	call WriteString
	call Crlf


ASK_TRY_AGAIN:
	call Crlf
	mov edx, OFFSET tryagain
	call WriteString	
	call ReadChar

.IF al == 'y' || al == 'Y'
	call Crlf
 	JMP START
.ENDIF

	INVOKE ExitProcess,0

main ENDP

END main