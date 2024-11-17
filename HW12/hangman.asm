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

    allwords DB "diadem","indigo","sphere","schism","avatar","guitar","sulfur","dengue","walrus","lizard"

    chosenWord DB 6 DUP(0)

    allLetters DB "ABCDEFGHIJKLMNOPQRSTUVWXYZ",0

    triedLetters DB 26 DUP(0)

    validLetters DB 26 DUP(0)


    hangman0 DB "+----+---",13,10,
                "|        ",13,10,
                "|        ",13,10,
                "|        ",13,10,
                "|        ",13,10,0

    hangman1 DB "+----+---",13,10,
                "|    o   ",13,10,
                "|        ",13,10,
                "|        ",13,10,
                "|        ",13,10,0

    hangman2 DB "+----+---",13,10,
                "|    o   ",13,10,
                "|    I   ",13,10,
                "|        ",13,10,
                "|        ",13,10,0

    hangman3 DB "+----+---",13,10,
                "|    o   ",13,10,
                "|   /I   ",13,10,
                "|        ",13,10,
                "|        ",13,10,0

    hangman4 DB "+----+---",13,10,
                "|    o   ",13,10,
                "|   /I\  ",13,10,
                "|        ",13,10,
                "|        ",13,10,0

    hangman5 DB "+----+---",13,10,
                "|    o   ",13,10,
                "|   /I\  ",13,10,
                "|   /    ",13,10,
                "|        ",13,10,0

    hangman6 DB "+----+---",13,10,
                "|    o   ",13,10,
                "|   /I\  ",13,10,
                "|   / \  ",13,10,
                "|        ",13,10,0


    welcomeMessage DB "Welcome to Hangman!",0

    letterPrompt DB "Guess a letter: ",0

    letterFound DB "Congratulations! That letter is in the word.",0
    letterNotFound DB "Sorry, that letter is not in the word.",0

    triedLettersDisplay DB "Tried letters: ",0
    wordSoFarDisplay DB "the word so far: ",0

    invalidInputDisplay DB "Invalid input. Please try again.",0

    winnerDisplay DB "Congratulations! You won!",0
    loserDisplay DB "Sorry, you lost. The correct word was: ",0

    askTryAgainDisplay DB "Would you like to try again? (y/n) :",0

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

    mov eax, 10
    call RandomRange ; get random 0-9
    mov ebx, 6
    mul ebx
    lea ebx, allWords
    add eax, ebx ;eax holds start of word

    call clearVars

    lea esi, chosenWord

    xor ecx, ecx ; ecx will be counter

    .WHILE(ecx < 6)
        mov dl, byte ptr [eax+ecx]

        mov byte ptr [esi+ecx] , dl
        inc ecx
    .endw

    call loadValidLetters

    lea edx, welcomeMessage
    call WriteString
    call Crlf

    xor ecx, ecx ; ecx will be attempt counter

    xor eax, eax

    gameLoop:

    .WHILE(ecx < 6)

        lea edx, letterPrompt
        call WriteString
        call ReadChar

        call writeChar
        call Crlf
        call Crlf
        
        charProcessing:
        .IF( al >= "a" && al <= "z")

            sub al, 32 ; convert to uppercase
        .ENDIF
        .IF(al >= "A" && al <= "Z")
            call checkLetter

            .if(al == 1) ; if valid
                lea edx, letterFound
                call WriteString
                call Crlf
            .else ; if invalid
                inc ecx
                lea edx, letterNotFound
                call WriteString
                call Crlf
            .endif

            

        .ELSE
            call invalidInput
            call Crlf
            call Crlf
            jmp gameLoop
        .ENDIF

        call displayWordSoFar

        push eax
        call Crlf

        call displayTriedLetters
        call Crlf
        mov eax, ecx
        call displayHangman
        call Crlf

        pop eax

        .if(al == 0) ; if word complete
            jmp gameWon
        .endif

    .ENDW

    JMP gameLost

        gameWon:
        call divider
        lea edx, winnerDisplay
        call WriteString
        call Crlf
        call divider
        call Crlf

        jmp askRetry

        gameLost:

        call divider
        lea edx, loserDisplay
        call WriteString

        xor ecx, ecx
        lea esi, chosenWord
        .WHILE(ecx < 6)
            mov al, byte ptr [esi+ecx]
            call WriteChar
            inc ecx
        .ENDW

        call Crlf
        call divider
        call Crlf

        jmp askRetry

        askRetry:

        lea edx, askTryAgainDisplay
        call WriteString
        call ReadChar
        call Crlf

        .IF(al == 'y' || al == 'Y')
            call divider
            call Crlf
            jmp start
        .ELSEIF(al == 'n' || al == 'N')
            invoke ExitProcess, 0
        .ELSE
            jmp askRetry
        .ENDIF

main ENDP                              ; End of main procedure


displayHangman PROC uses edx
    ;takes number of fails in EAX

    .IF(eax == 0)
        lea edx, hangman0
        call WriteString
    .ELSEIF(eax == 1)
        lea edx, hangman1
        call WriteString
    .ELSEIF(eax == 2)
        lea edx, hangman2
        call WriteString
    .ELSEIF(eax == 3)
        lea edx, hangman3
        call WriteString
    .ELSEIF(eax == 4)
        lea edx, hangman4
        call WriteString
    .ELSEIF(eax == 5)
        lea edx, hangman5
        call WriteString
    .ELSE
        lea edx, hangman6
        call WriteString
    .ENDIF



    ret
displayHangman ENDP

clearVars PROC uses ecx esi edi
    lea edi, triedLetters
    lea esi, validLetters

    xor ecx, ecx
    .WHILE(ecx < 26)
        mov byte ptr [edi+ecx], 0
        mov byte ptr [esi+ecx], 0
        inc ecx
    .endw
    
    ret
clearVars ENDP

checkLetter PROC uses esi edi
    ; takes uppercase ASCII char in AL
    ; sets al 1 if char is valid, and sets al to 0 if invalid
    ; sets letter as tried in triedLetters regardless
    sub al, "A"
    mov ah, 0
    lea edi, triedLetters
    mov byte ptr [edi+eax], 1
    lea esi, validLetters

    .IF(byte ptr [esi+eax] == 1)
        mov eax, 1
    .ELSE
        mov eax, 0
    .ENDIF
    ret
checkLetter ENDP

loadValidLetters PROC uses esi edi eax ebx ecx edx

    lea esi, chosenWord

    xor ecx, ecx
    xor eax, eax

    .WHILE(ecx < 6)

        lea ebx, validLetters   
        mov al, byte ptr [esi+ecx]
        sub al, "a"

        mov byte ptr [eax+ebx], 1

        inc ecx
    .ENDW

    ret
loadValidLetters ENDP


displayTriedLetters PROC uses eax ebx edx ecx edi esi
    lea edi, allLetters

    lea edx, triedLettersDisplay
    lea esi, triedLetters

    call WriteString

    xor ecx, ecx
    .while(ecx < 26)

        .IF( byte ptr [esi+ecx] == 1)
            mov al, byte ptr [edi+ecx]
            call WriteChar
            mov al, ' '
            call WriteChar
        .ENDIF

        inc ecx
    .endw
    call Crlf
    ret
displayTriedLetters ENDP


displayWordSoFar PROC uses  ebx edx ecx edi esi
    ;displays word so far
    ;return number incorrect in AL
    ;if al = 0, word is complete

    lea edi, chosenWord
    lea esi, triedLetters

    lea edx, wordSoFarDisplay
    call WriteString

    xor ecx, ecx
    xor edx, edx
    xor ebx, ebx
    .WHILE(ecx < 6)
        mov bl, byte ptr [edi+ecx]
        sub bl, 'a'
        .IF(byte ptr [esi+ebx] == 1)
            mov al, byte ptr [edi+ecx]
            call WriteChar
        .ELSE
            mov al, '_'
            call WriteChar
            inc dl
        .ENDIF
        inc ecx
    .ENDW

    mov al, dl

    ret
displayWordSoFar ENDP


invalidInput PROC uses edx
    lea edx, invalidInputDisplay             ; Load invalid input message
    call WriteString                         ; Display message
    call Crlf                                ; New line
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
    lea edx, dividerDisplay          ; Load address of divider line string
    call WriteString                 ; Display the divider line
    call Crlf                        ; New line
    ret                              ; Return from procedure
divider ENDP

END main                             ; End of main procedure, program entry point
