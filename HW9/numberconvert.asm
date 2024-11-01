; **********************************************************************;
; Program Name:   Basic Calculator (basicCalc.asm)                      ;
; Program Description: This program performs basic arithmetic operations;
;                      on two 16-bit integers, including addition,      ;
;                      subtraction, multiplication, and division.       ;
; Author:          Josiah Hamm   @bakedPotatoLord                       ;
; Course Number:   CSC2025X01 - Computer Architecture/Assembly Language ;
; Date:            10/20/2024                                           ;
; Revisions:       None                                                 ;
; Date Last Modified: 10/20/2024                                        ;
; **********************************************************************;


.386                              ; Specify 32-bit code
.model flat,stdcall                ; Flat memory model with standard calling conventions
.stack 4096                        ; Allocate 4 KB of stack space
ExitProcess proto,dwExitCode:dword ; Prototype for ExitProcess from Windows API


INCLUDE C:\Irvine\Irvine32.inc          ; Include Irvine32 library for basic I/O operations
INCLUDELIB C:\Irvine\Irvine32.lib       ; Link Irvine32 library

.data

    optionsDisplay DB "(1) Decimal",10,13,
    "(2) Hexadecimal",10,13,
    "(3) Binary",10,13,
    "(4) Exit",10,13,
    10,13,
    "Enter your choice from the above options: ",0

    decimalPrompt DB "Please enter a 32-bit Decimal integer: ",0

    hexPrompt DB "Please enter a 32-bit Hexadecimal integer: ",0

    binaryString DB 32 DUP(0) ,0

    binaryPrompt DB "Please enter a 32-bit Binary integer: ",0

    decimalDisplay DB "Decimal Value: ",0
    hexDisplay DB "Hexadecimal Value: ",0
    binaryDisplay DB "Binary Value: ",0

   
    invalidInputDisplay DB "Invalid input. Please try again.",0 ; Display string for invalid input

    dividerDisplay DB "------------------------------------",0 ; Divider line for clarity

.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description: 
; Output:      
; Register Usage:                                                       ;
; EAX -             ;
; EDX -                             ;
; **********************************************************************;

main PROC
    start:
        lea edx, optionsDisplay
        call WriteString

        call readChar
        call writeChar
        call Crlf
        call Crlf

        .IF(al == '1')
            prompt1:
                lea edx, decimalPrompt
                call WriteString

                call ReadInt
                jc invalidnumber1
        .ELSEIF(al == '2')
            prompt2:
                lea edx, hexPrompt
                call WriteString
                call readHex
        .ELSEIF(al == '3')
            prompt3:
                lea edx, binaryPrompt
                call WriteString
                call readBin
        .ELSEIF(al == '4')
    invoke ExitProcess, 0 
        .ELSE
            call invalidInput
            jmp start
        .ENDIF
    call displayResults
    jmp start
    
    invalidnumber1:
        call invalidInput
        jmp prompt1

    invalidnumber2:
        call invalidInput
        jmp prompt2
                   
    invalidnumber3:
        call invalidInput
        jmp prompt3

main ENDP

;leaves value in eax
readBin PROC uses  ebx ecx edx

    lea edx, binaryString
    mov ecx, edx
    add ecx, SIZEOF binaryString
    sub ecx, 1
    .WHILE(ecx > edx) ; while not at end of string
        mov al, 0
        mov [ecx], al ; clear string value
        dec ecx
    .ENDW


    mov edx, offset binaryString
    mov ecx, 32
    call readString


    mov ecx, edx ; ecx holds beginning of string
    add edx, eax ; edx holds end of string
    dec edx ; edx points to last character

    xor eax, eax ; clear eax, it will be the accumulator
    xor ebx, ebx ; clear ebx, it will be the current value

    .WHILE(ecx <= edx) ; while not at end of string
        mov bl, byte ptr [ecx]
        .IF(bl == '1' || bl == '0') ; if character is 1 or 0
            shl eax, 1 
            sub bl, '0'
            add eax, ebx
        .ENDIF
        inc ecx
    .ENDW


    ret
readBin ENDP    


;takes number in eax
displayResults PROC

    call Crlf
    call Crlf

    lea edx, decimalDisplay
    call WriteString
    call WriteInt
    call Crlf

    lea edx, hexDisplay
    call WriteString
    call WriteHex
    call Crlf

    lea edx, binaryDisplay
    call WriteString
    call WriteBin
    call Crlf

    call divider

    ret
displayResults ENDP





; **********************************************************************;
; Invalid Input Procedure                                               ;
; Description: This procedure displays an invalid input message and     ;
;              resets the menu.                                         ;
; Input:       None                                                     ;
; Output:      Displays an error message.                               ;
; Register Usage:                                                       ;
; EDX - Used for passing string addresses                               ;
; **********************************************************************;

invalidInput PROC uses edx
    lea edx, invalidInputDisplay             ; Load address of invalid input string
    call WriteString                         ; Display error message
    call Crlf                                ; Print new line
    call divider                             ; Display divider for clarity
    ret
invalidInput ENDP

; **********************************************************************;
; Divider Procedure                                                     ;
; Description: This procedure displays a divider line for formatting.   ;
; Input:       None                                                     ;
; Output:      Displays a divider line.                                 ;
; Register Usage:                                                       ;
; EDX - Used for passing string addresses                               ;
; **********************************************************************;

divider PROC uses edx
    lea edx, dividerDisplay                  ; Load address of divider string
    call WriteString                         ; Display divider line
    call Crlf                                ; Print new line
    ret
divider ENDP


END main
