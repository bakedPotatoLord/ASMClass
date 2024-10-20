; **********************************************************************;
; Program Name:   String Compression Program (StringCompression.asm)    ;
; Program Description: This program prompts the user for a string       ;
;                      (maximum of 100 characters), removes all         ;
;                      non-alphabetical characters, and displays the    ;
;                      compressed string. The program alse provides a   ;
;                      letter frequency table and an option to repeat   ;
;                      the process.                                     ;
; Author:          Josiah Hamm                                          ;
; Course Number:   CSC2025X01 - Computer Architecture/Assembly Language ;
; Date:            10/19/2024                                           ;
; Revisions:       None                                                 ;
; Date Last Modified: 10/19/2024                                        ;
; **********************************************************************;

INCLUDE C:\Irvine\Irvine32.inc          ; Include Irvine32 library for basic I/O operations
INCLUDELIB C:\Irvine\Irvine32.lib       ; Link Irvine32 library

.data

    integer1Prompt DB "Please enter an integer value up to 16 bits in size: ",0
    integer2Prompt DB "Please enter another integer value up to 16 bits in size: ",0

    integer1 DD ?
    integer2 DD ?

    promptOptions DB "(1) Addition",10,13,
    "(2) Subtraction",10,13,
    "(3) Multiplication",10,13,
    "(4) Division",10,13,
    "(5) Exit",10,13,
    10,13,
    "Enter your choice from the above options: ",0


    plus DB ' + ',0
    minus DB ' - ',0
    times DB ' * ',0
    divide DB ' / ',0
    equals DB ' = ',0
    remainder DB ' remainder ',0

    invalidInputDisplay DB "Invalid input. Please try again.",0

    dividerDisplay DB "------------------------------------",0


.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description:    ;
; Input:                                                             ;
; Output:                                 ;
; Register Usage:                                                        ;
; EAX - 
; **********************************************************************;

main PROC

    prompt:
        lea edx, integer1Prompt
        call WriteString
        call ReadInt
        .IF(OVERFLOW?)
            call invalidInput
            jmp prompt
        .ENDIF
        mov integer1, eax
        call Crlf

        lea edx, integer2Prompt
        call WriteString
        call ReadInt
        .IF(OVERFLOW?)
            call invalidInput
            jmp prompt
        .ENDIF
        mov integer2, eax
        call Crlf

        lea edx, promptOptions
        call WriteString

        call ReadInt
        call Crlf
        .IF(eax == 1)
            call addition
        .ELSEIF(eax == 2)
            call subtraction
        .ELSEIF(eax == 3)
            call multiplication
        .ELSEIF(eax == 4)
            call division
        .ELSEIF(eax == 5)
            jmp exitProgram
        .ELSE
            call invalidInput
            jmp prompt
        .ENDIF
        
        call Crlf
        call divider
        JMP prompt

    exitProgram:
    INVOKE ExitProcess, 0   ; Exit the program with status 0

main ENDP


addition PROC uses eax edx
    mov eax, integer1
    call writeInt

    lea edx, plus
    call writeString

    mov eax, integer2
    call writeInt

    lea edx, equals
    call writeString

    add eax, integer1
    call writeInt

    ret
addition ENDP

subtraction PROC uses eax edx
    mov eax, integer1
    call writeInt

    lea edx, minus
    call writeString

    mov eax, integer2
    call writeInt

    lea edx, equals
    call writeString

    mov eax, integer1
    sub eax, integer2
    call writeInt

    ret
subtraction ENDP 


multiplication PROC uses eax ebx edx
    mov eax, integer1
    call writeInt

    lea edx, times
    call writeString

    mov eax, integer2
    call writeInt

    lea edx, equals
    call writeString

    mov ebx, integer1
    mul ebx
    call writeInt

    ret
multiplication ENDP 


division PROC uses eax ebx ecx edx

    mov eax, integer1
    call writeInt

    lea edx, divide
    call writeString

    mov eax, integer2
    call writeInt

    lea edx, equals
    call writeString

    xor edx, edx
    mov eax, integer1
    mov ebx, integer2
    div ebx
    call writeInt
    push edx

    lea edx, remainder
    call writeString

    pop eax
    call writeInt

    ret
division ENDP

invalidInput PROC uses edx
    lea edx, invalidInputDisplay
    call WriteString
    call Crlf
    call divider
    ret
invalidInput ENDP

divider PROC uses edx
    lea edx, dividerDisplay
    call WriteString
    call Crlf
    ret
divider ENDP

END main