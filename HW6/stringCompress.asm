; **********************************************************************;
; Program Name:   Time Conversion Program (TimeConversion.asm)          ;
; Program Description: This program prompts the user for hours, minutes ;
;                      and seconds, computes the total time in minutes  ;
;                      and seconds, and provides an option to repeat.   ;
; Author:          Josiah Hamm                                          ;
; Course Number:   CSC2025X01 - Computer Architecture/Assembly Language ;
; Date:            9/24/2024                                            ;
; Revisions:       None                                                 ;
; Date Last Modified: 9/24/2024                                         ;
;***********************************************************************;

INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data

stringPrompt BYTE "Please enter a one-line string with a maximum of 100 characters:", 0
originalStringDisplay BYTE "Original String: ", 0
compressedStringDisplay BYTE "Compressed String: ", 0

stringInput BYTE 101 DUP(0)
compressedString BYTE 101 DUP(0)

tryagainDisplay BYTE "Would you like to enter a new string (y/n)", 0

.code

; **********************************************************************;
; Main Procedure                                                        ;

; **********************************************************************;

main PROC

prompt:
    mov edx, OFFSET stringPrompt
    call WriteString
    call Crlf
    mov edx, OFFSET stringInput
    mov ecx, 101
    call ReadString

    

    mov edx, OFFSET originalStringDisplay
    call WriteString

    mov edx, OFFSET stringInput
    call WriteString

    call Crlf
    
    mov eax, OFFSET stringInput
    mov ebx, OFFSET compressedString

compressloop:

    mov dl, [eax]

    .IF (dl >= 65 && dl <= 90) || (dl >= 97 && dl <= 122)
    
        mov [ebx], dl
        inc ebx
    .ENDIF
    inc eax

    cmp dl,0
    jne compressloop

outputString:

    mov edx, OFFSET compressedStringDisplay
    call WriteString

    mov edx, OFFSET compressedString
    call WriteString

    call Crlf

ASK_TRY_AGAIN:                        ; Ask user if they want to repeat the program
    call Crlf                         ; Newline for formatting
    mov edx, OFFSET tryagainDisplay   ; Load try again message
    call WriteString                  ; Display try again prompt
    call ReadChar                     ; Read user response

    .IF al == 'y' || al == 'Y'        ; If user enters 'y' or 'Y', repeat
        call Crlf                     ; Newline for spacing
        JMP prompt                     ; Jump back 
    .ENDIF

    INVOKE ExitProcess, 0             ; Exit the program with status 0

main ENDP



END main
