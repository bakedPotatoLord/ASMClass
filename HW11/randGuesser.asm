; **********************************************************************;
; Program Name:   Random Number Guesser (randGuesser.asm)               ;
; Program Description: This program allows the user to guess a randomly 
;                      generated number between 1 and 50. Feedback is 
;                      given on each guess, and the user can choose to 
;                      play again after each round. 
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

    prompt DB "Guess a number 1 to 50 : ",0             ; Prompt for user input
    tooHigh DB "That number is too high. Please try again.",0 ; Message if guess is too high
    tooLow DB "That number is too low. Please try again.",0   ; Message if guess is too low
    correct DB "Correct! You guessed the number.",0           ; Message if guess is correct
    triesRemaining DB " tries remaining. ",0                  ; Message for tries remaining
    noTriesRemaining DB "No tries remaining. The correct number was: ",0 ; Message if out of tries
    playAgainPrompt DB "Would you like to play again? (y/n) ",0 ; Prompt to ask if user wants to replay
    invalidInputDisplay DB "Invalid input.",0                 ; Message for invalid input
    dividerDisplay DB "------------------------------------",0 ; Divider line for formatting

.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description: Handles game flow, including guessing logic, feedback, 
;              and play-again prompt.
; Input: None                                                            ;
; Output: Displays messages and takes input for guesses and play-again   ;
; Memory Usage: Stack is used for local variables                        ;
; Register Usage:                                                       ;
; EAX - used for passing to and from functions                          ;
; ECX - holds the random number                                         ;
; EDX - used to pass string to WriteString function                     ;
; ESI - holds the number of tries remaining                             ;
; **********************************************************************;

main PROC

    start:                           ; Start of the game loop

    mov eax , 50                     ; Set upper limit of random range
    call randomRange                 ; Generate random number between 0 and 49
    inc eax                          ; Increment to get range from 1 to 50
    mov ecx, eax                     ; Store random number in ECX for comparison

    mov esi, 10                      ; Initialize attempts counter in ESI

    .WHILE(esi > 0)                  ; While loop to keep asking for guesses until attempts run out

        mov edx, offset prompt       ; Load address of prompt message
        call WriteString             ; Display the prompt message
        call ReadDec                 ; Read user input (guess) into EAX

        .IF(eax == 0)                ; If the guess is 0 (invalid input)
            lea edx, invalidInputDisplay  ; Load address of invalid input message
            call WriteString              ; Display invalid input message
            call Crlf                     ; Move to a new line
            jmp afterFeedback             ; Skip the feedback section
        .ENDIF

        .IF(eax > ecx)               ; If the guess is greater than the random number
            mov edx, offset tooHigh  ; Load address of "too high" message
            call WriteString         ; Display "too high" message
            call Crlf                ; New line
        .ELSEIF(eax < ecx)           ; If the guess is less than the random number
            mov edx, offset tooLow   ; Load address of "too low" message
            call WriteString         ; Display "too low" message
            call Crlf                ; New line
        .ELSE                        ; If the guess is correct
            mov edx, offset correct  ; Load address of "correct" message
            call WriteString         ; Display "correct" message
            call Crlf                ; New line
            jmp askPlayAgain         ; Skip to play-again prompt
        .ENDIF

        afterFeedback:               ; Label after feedback to handle decrementing tries

        dec esi                      ; Decrement attempt counter
        mov eax, esi                 ; Move remaining tries to EAX for printing
        call WriteDec                ; Display remaining tries count
        mov edx, offset triesRemaining ; Load address of "tries remaining" message
        call WriteString             ; Display "tries remaining" message
        call Crlf                    ; New line
        call Crlf                    ; Another new line for readability
    .ENDW                            ; End of WHILE loop (if attempts run out)

    lea edx, noTriesRemaining        ; Load address of "no tries remaining" message
    call WriteString                 ; Display out of tries message

    mov eax, ecx                     ; Move correct answer to EAX for printing
    call WriteDec                    ; Display the correct answer
    call Crlf                        ; New line

    askPlayAgain:                    ; Label for play-again prompt

        mov edx, offset playAgainPrompt ; Load address of play-again prompt
        call WriteString                 ; Display play-again prompt
        call ReadChar                    ; Read single character input into AL
        call Crlf                        ; New line

        .IF( al == 'y' || al == 'Y')    ; If user input is 'y' or 'Y'
            call divider                ; Call divider procedure for formatting
            jmp start                   ; Restart the game loop
        .ELSEIF(al == 'n' || al == 'N') ; If user input is 'n' or 'N'
            invoke ExitProcess, 0       ; Exit program with exit code 0
        .ELSE                           ; If input is invalid
            call invalidInput           ; Display invalid input message
            jmp askPlayAgain            ; Repeat play-again prompt
        .ENDIF

main ENDP                              ; End of main procedure

; **********************************************************************;
; Divider Procedure                                                     ;
; Description: This procedure displays a divider line for formatting.   ;
; Input:       None                                                     ;
; Output:      Displays a divider line.                                 ;
; Register Usage:                                                       ;
; EDX - Used for passing string addresses                               ;
; **********************************************************************;

divider PROC uses edx
    lea edx, dividerDisplay          ; Load address of divider line string
    call WriteString                 ; Display the divider line
    call Crlf                        ; New line
    ret                              ; Return from procedure
divider ENDP

END main                             ; End of main procedure, program entry point
