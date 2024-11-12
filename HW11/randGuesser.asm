; **********************************************************************;
; Program Name:   Float Rounder Program (floatRounder.asm)              ;
; Program Description: Rounds a floating-point number to specified      ;
;                      decimal places, with display in scientific       ;
;                      and decimal notation.                            ;
; Author:          Josiah Hamm   @bakedPotatoLord                       ;
; Course Number:   CSC2025X01 - Computer Architecture/Assembly Language ;
; Date:            11/08/2024                                           ;
; **********************************************************************;

.386                              ; Specify 32-bit code
.model flat,stdcall               ; Flat memory model with standard calling conventions
.stack 4096                       ; Allocate 4 KB of stack space
ExitProcess proto,dwExitCode:dword ; Prototype for ExitProcess from Windows API

INCLUDE C:\Irvine\Irvine32.inc          ; Include Irvine32 library for basic I/O operations
INCLUDELIB C:\Irvine\Irvine32.lib       ; Link Irvine32 library

.data

    prompt DB "Guess a number 1 to 50 : ",0
    tooHigh DB "That number is too high. Please try again.",0
    tooLow DB "That number is too low. Please try again.",0
    correct DB "Correct! You guessed the number.",0
    triesRemaining DB " tries remaining. ",0
    noTriesRemaining DB "No tries remaining. The correct number was: ",0
    playAgainPrompt DB "Would you like to play again? (y/n) ",0
    invalidInputDisplay DB "Invalid input.",0
    dividerDisplay DB "------------------------------------",0

.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description:  ;
; Input:                                                     ;
; Output:                                                       ;
; Memory Usage:                 ;
; Register Usage:                                                       ;
; EAX - used for passing to and from functions
; ECX - holds the random number
; EDX - used to pass string to WriteString function
; ESI - holds the number of tries remaining
; **********************************************************************;

main PROC

    start:
    mov eax , 50
    call randomRange
    inc eax 
    mov ecx, eax ; ECX holds rand number

    mov esi, 10 ; ESI will be attempt counter

    .WHILE(esi > 0)

        mov edx, offset prompt
        call WriteString
        call ReadDec

        .IF(eax == 0)
            lea edx, invalidInputDisplay             ; Load invalid input message
            call WriteString                         ; Display message
            call Crlf                                ; New line
            jmp afterFeedback
        .ENDIF

        .IF(eax > ecx)
            mov edx, offset tooHigh
            call WriteString
            call Crlf
        .ELSEIF(eax < ecx)
            mov edx, offset tooLow 
            call WriteString
            call Crlf
        .ELSE
            mov edx, offset correct
            call WriteString
            call Crlf
            jmp askPlayAgain
        .ENDIF

        afterFeedback:

        dec esi
        mov eax, esi
        call WriteDec
        mov edx, offset triesRemaining
        call WriteString
        call Crlf
        call Crlf
    .ENDW

    lea edx, noTriesRemaining
    call WriteString

    mov eax, ecx
    call WriteDec
    call Crlf

    askPlayAgain:
        mov edx, offset playAgainPrompt
        call WriteString
        call ReadChar
        call Crlf

        .IF( al == 'y' || al == 'Y')
            call divider
            jmp start
        .ELSEIF(al == 'n' || al == 'N')
            invoke ExitProcess, 0           ; Exit program with code 0
        .ELSE
            call invalidInput
            jmp askPlayAgain
        .ENDIF

main ENDP


; **********************************************************************;
; Divider Procedure                                                     ;
; Description: This procedure displays a divider line for formatting.   ;
; Input:       None                                                     ;
; Output:      Displays a divider line.                                 ;
; Register Usage:                                                       ;
; EDX - Used for passing string addresses                               ;
; **********************************************************************;

divider PROC uses edx
    lea edx, dividerDisplay                  ; Load divider string
    call WriteString                         ; Print divider line
    call Crlf                                ; New line
    ret
divider ENDP

END main                                    ; End of main procedure
