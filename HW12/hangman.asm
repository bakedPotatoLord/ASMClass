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
; Description: This procedure implements a word-guessing game. It initializes the game state, 
;              processes user input, updates the game state, and determines the outcome.
; Input: None                                                           ;
; Output: None                                                          ;
; Memory Usage: Modifies game state variables such as `chosenWord` and 
;               display buffers.                                        ;
; Register Usage:                                                       ;
; EAX - General purpose; holds various values such as word positions    ;
; EBX - General purpose; holds various values such as word positions    ;
; ECX - Counter for loops (e.g., attempts, word length)                 ;
; EDX - Address for strings passed to output functions                  ;
; ESI - Pointer to the chosen word buffer                               ;
; **********************************************************************;
main PROC
    start:                           ; Start of the game loop

    mov eax, 10                      ; Load 10 into EAX for the random range
    call RandomRange                 ; Generate a random number between 0 and 9
    mov ebx, 6                       ; Load multiplier (6) into EBX
    mul ebx                          ; Multiply random number by 6
    lea ebx, allWords                ; Load address of word list into EBX
    add eax, ebx                     ; Add offset to get the start of the chosen word

    call clearVars                   ; Reset game variables

    lea esi, chosenWord              ; Load address of `chosenWord` into ESI
    xor ecx, ecx                     ; Clear ECX (loop counter for copying word)
    .WHILE(ecx < 6)
        mov dl, byte ptr [eax+ecx]   ; Load the character at [eax+ecx] into DL
        mov byte ptr [esi+ecx], dl   ; Copy character to `chosenWord` buffer
        inc ecx                      ; Increment loop counter
    .endw

    call loadValidLetters            ; Initialize valid letters for the game

    lea edx, welcomeMessage          ; Load address of welcome message into EDX
    call WriteString                 ; Display welcome message
    call Crlf                        ; Print a newline

    xor ecx, ecx                     ; Clear ECX (attempt counter)
    xor eax, eax                     ; Clear EAX
    gameLoop:                        ; Main game loop
    .WHILE(ecx < 6)

        lea edx, letterPrompt        ; Load address of letter prompt into EDX
        call WriteString             ; Display the prompt
        call ReadChar                ; Read a character from the user

        call writeChar               ; Echo the character
        call Crlf                    ; Print two newlines
        call Crlf
        
        charProcessing:              ; Process the input character
        .IF(al >= "a" && al <= "z")  ; Check if the character is lowercase
            sub al, 32               ; Convert to uppercase
        .ENDIF
        .IF(al >= "A" && al <= "Z")  ; Check if the character is uppercase
            call checkLetter         ; Check if the character is in the word
            .if(al == 1)             ; If the letter is valid
                lea edx, letterFound ; Load success message address into EDX
                call WriteString     ; Display success message
                call Crlf            ; Print a newline
            .else                    ; If the letter is invalid
                inc ecx              ; Increment attempt counter
                lea edx, letterNotFound ; Load failure message address
                call WriteString     ; Display failure message
                call Crlf            ; Print a newline
            .endif
        .ELSE                        ; If input is not a valid letter
            call invalidInput        ; Display invalid input message
            call Crlf                ; Print two newlines
            call Crlf
            jmp gameLoop             ; Restart the game loop
        .ENDIF

        call displayWordSoFar        ; Display the current state of the guessed word
        push eax                     ; Save EAX value on the stack
        call Crlf                    ; Print a newline
        call displayTriedLetters     ; Display tried letters
        call Crlf                    ; Print a newline
        mov eax, ecx                 ; Load attempt counter into EAX
        call displayHangman          ; Display hangman based on attempts
        call Crlf                    ; Print a newline
        pop eax                      ; Restore EAX from the stack
        .if(al == 0)                 ; Check if the word is complete
            jmp gameWon              ; Jump to win state
        .endif
    .ENDW

    JMP gameLost                     ; If all attempts are used, jump to loss state

    gameWon:
        call divider                 ; Display divider line
        lea edx, winnerDisplay       ; Load winning message address
        call WriteString             ; Display winning message
        call Crlf                    ; Print newline
        call divider                 ; Display divider line
        call Crlf                    ; Print newline
        jmp askRetry                 ; Ask if the user wants to retry

    gameLost:
        call divider                 ; Display divider line
        lea edx, loserDisplay        ; Load losing message address
        call WriteString             ; Display losing message

        xor ecx, ecx                 ; Clear ECX (counter for displaying word)
        lea esi, chosenWord          ; Load chosen word address into ESI
        .WHILE(ecx < 6)
            mov al, byte ptr [esi+ecx] ; Load character of the word into AL
            call WriteChar           ; Display the character
            inc ecx                  ; Increment counter
        .ENDW
        call Crlf                    ; Print newline
        call divider                 ; Display divider line
        call Crlf                    ; Print newline
        jmp askRetry                 ; Ask if the user wants to retry

    askRetry:
        lea edx, askTryAgainDisplay  ; Load retry prompt address
        call WriteString             ; Display retry prompt
        call ReadChar                ; Read user input
        call Crlf                    ; Print newline
        .IF(al == 'y' || al == 'Y')  ; If user wants to retry
            call divider             ; Display divider line
            call Crlf                ; Print newline
            jmp start                ; Restart the game
        .ELSEIF(al == 'n' || al == 'N') ; If user wants to quit
            invoke ExitProcess, 0    ; Exit the program
        .ELSE                        ; If invalid input
            jmp askRetry             ; Repeat retry prompt
        .ENDIF

main ENDP                            ; End of main procedure


; **********************************************************************;
; displayHangman Procedure                                              ;
; Description: Displays the hangman graphic corresponding to the number ;
;              of failed attempts provided in EAX.                      ;
; Input:                                                                ;
;     EAX - Number of failed attempts (0 to 6).                         ;
; Output: Displays the appropriate hangman graphic string.              ;
; Memory Usage: None                                                    ;
; Register Usage:                                                       ;
;     EAX - Input (number of failed attempts).                          ;
;     EDX - Holds the address of the hangman graphic string to display. ;
; **********************************************************************;
displayHangman PROC uses edx

    .IF(eax == 0)                   ; Check if no failed attempts
        lea edx, hangman0           ; Load address of hangman graphic for 0 fails
        call WriteString            ; Display the hangman graphic
    .ELSEIF(eax == 1)               ; Check if 1 failed attempt
        lea edx, hangman1           ; Load address of hangman graphic for 1 fail
        call WriteString            ; Display the hangman graphic
    .ELSEIF(eax == 2)               ; Check if 2 failed attempts
        lea edx, hangman2           ; Load address of hangman graphic for 2 fails
        call WriteString            ; Display the hangman graphic
    .ELSEIF(eax == 3)               ; Check if 3 failed attempts
        lea edx, hangman3           ; Load address of hangman graphic for 3 fails
        call WriteString            ; Display the hangman graphic
    .ELSEIF(eax == 4)               ; Check if 4 failed attempts
        lea edx, hangman4           ; Load address of hangman graphic for 4 fails
        call WriteString            ; Display the hangman graphic
    .ELSEIF(eax == 5)               ; Check if 5 failed attempts
        lea edx, hangman5           ; Load address of hangman graphic for 5 fails
        call WriteString            ; Display the hangman graphic
    .ELSE                          ; Any other value (assume 6 failed attempts)
        lea edx, hangman6           ; Load address of hangman graphic for 6 fails
        call WriteString            ; Display the hangman graphic
    .ENDIF

    ret                             ; Return to the caller
displayHangman ENDP

; **********************************************************************;
; clearVars Procedure                                                   ;
; Description: Clears the `triedLetters` and `validLetters` arrays by   ;
;              setting all their elements to 0. This prepares the game  ;
;              state for a new round.                                   ;
; Input: None                                                           ;
; Output: Both `triedLetters` and `validLetters` arrays are cleared.    ;
; Memory Usage: Directly modifies `triedLetters` and `validLetters` arrays. ;
; Register Usage:                                                       ;
;     ECX - Loop counter for clearing the arrays.                       ;
;     ESI - Pointer to the `validLetters` array.                        ;
;     EDI - Pointer to the `triedLetters` array.                        ;
; **********************************************************************;
clearVars PROC uses ecx esi edi
    lea edi, triedLetters           ; Load address of `triedLetters` into EDI
    lea esi, validLetters           ; Load address of `validLetters` into ESI
    xor ecx, ecx                    ; Clear ECX (loop counter)
    .WHILE(ecx < 26)                ; Loop through 26 elements (A-Z)
        mov byte ptr [edi+ecx], 0   ; Set element in `triedLetters` to 0
        mov byte ptr [esi+ecx], 0   ; Set element in `validLetters` to 0
        inc ecx                     ; Increment loop counter
    .endw

    ret                             ; Return to the caller
clearVars ENDP

; **********************************************************************;
; checkLetter Procedure                                                 ;
; Description: Checks whether the given uppercase ASCII character in AL 
;              is a valid letter (i.e., exists in `validLetters`). Marks
;              the letter as "tried" in the `triedLetters` array.        ;
; Input:                                                                ;
;     AL - Uppercase ASCII character ('A'-'Z') to check.                ;
; Output:                                                               ;
;     AL - Set to 1 if the letter is valid, 0 otherwise.                ;
; Memory Usage:                                                         ;
;     Modifies the `triedLetters` array to mark the letter as tried.    ;
; Register Usage:                                                       ;
;     AL - Input character (and result of validity check).              ;
;     AH - Cleared to 0 for indexing purposes.                          ;
;     ESI - Pointer to the `validLetters` array.                        ;
;     EDI - Pointer to the `triedLetters` array.                        ;
; **********************************************************************;
checkLetter PROC uses esi edi

    sub al, "A"                     ; Convert ASCII letter ('A'-'Z') to 0-based index (0-25)
    mov ah, 0                       ; Clear AH to prepare for 16-bit addressing if needed
    lea edi, triedLetters           ; Load address of `triedLetters` into EDI
    mov byte ptr [edi+eax], 1       ; Mark the letter as "tried" in `triedLetters`

    lea esi, validLetters           ; Load address of `validLetters` into ESI
    .IF(byte ptr [esi+eax] == 1)    ; Check if the letter is valid (present in `validLetters`)
        mov eax, 1                  ; Set AL to 1 (letter is valid)
    .ELSE                           ; If the letter is not valid
        mov eax, 0                  ; Set AL to 0 (letter is invalid)
    .ENDIF

    ret                             ; Return to the caller
checkLetter ENDP

; **********************************************************************;
; loadValidLetters Procedure                                            ;
; Description: Populates the `validLetters` array based on the letters 
;              in the `chosenWord`. Each letter in `chosenWord` is 
;              marked as valid in `validLetters`.                       ;
; Input: None                                                           ;
; Output: Updates the `validLetters` array to mark valid letters.       ;
; Memory Usage: Modifies the `validLetters` array.                      ;
; Register Usage:                                                       ;
;     EAX - Holds the converted 0-based index of the current letter.    ;
;     EBX - Pointer to the `validLetters` array.                        ;
;     ECX - Loop counter (tracks position in `chosenWord`).             ;
;     ESI - Pointer to the `chosenWord` array.                         ;
; **********************************************************************;
loadValidLetters PROC uses esi eax ebx ecx

    lea esi, chosenWord             ; Load address of `chosenWord` into ESI
    xor ecx, ecx                    ; Clear ECX (loop counter)
    xor eax, eax                    ; Clear EAX (used for letter index)

    .WHILE(ecx < 6)                 ; Loop through all 6 letters in `chosenWord`
        lea ebx, validLetters       ; Load address of `validLetters` into EBX
        mov al, byte ptr [esi+ecx]  ; Load the current letter from `chosenWord`
        sub al, "a"                 ; Convert ASCII letter ('a'-'z') to 0-based index (0-25)
        mov byte ptr [eax+ebx], 1   ; Mark the letter as valid in `validLetters`
        inc ecx                     ; Increment loop counter
    .ENDW

    ret                             ; Return to the caller
loadValidLetters ENDP



; **********************************************************************;
; displayTriedLetters Procedure                                         ;
; Description: Displays all the letters that have been marked as "tried"
;              in the `triedLetters` array. Each "tried" letter is shown
;              followed by a space for readability.                    ;
; Input: None                                                           ;
; Output: Displays the "tried" letters on the screen.                   ;
; Memory Usage: Reads data from the `triedLetters` and `allLetters` arrays. ;
; Register Usage:                                                       ;
;     EAX - Holds the ASCII value of the current letter to display.     ;
;     EDX - Holds the address of the `triedLettersDisplay` message.     ;
;     ECX - Loop counter (tracks position in the arrays).               ;
;     EDI - Pointer to the `allLetters` array.                         ;
;     ESI - Pointer to the `triedLetters` array.                       ;
; **********************************************************************;
displayTriedLetters PROC uses eax edx ecx edi esi

    lea edi, allLetters             ; Load address of `allLetters` into EDI
    lea edx, triedLettersDisplay    ; Load address of `triedLettersDisplay` message into EDX
    lea esi, triedLetters           ; Load address of `triedLetters` into ESI
    call WriteString                ; Display the message "Tried Letters:"

    xor ecx, ecx                    ; Clear ECX (loop counter)
    .WHILE(ecx < 26)                ; Loop through all 26 letters (A-Z)
        .IF(byte ptr [esi+ecx] == 1) ; Check if the letter has been marked as "tried"
            mov al, byte ptr [edi+ecx] ; Load the ASCII letter from `allLetters`
            call WriteChar           ; Display the letter
            mov al, ' '              ; Load a space character
            call WriteChar           ; Display the space
        .ENDIF
        inc ecx                     ; Increment loop counter
    .ENDW

    call Crlf                       ; Move to the next line
    ret                             ; Return to the caller
displayTriedLetters ENDP



; **********************************************************************;
; displayWordSoFar Procedure                                            ;
; Description: Displays the current progress of the guessed word.       ;
;              Shows correctly guessed letters and underscores for      ;
;              letters yet to be guessed.                               ;
; Input: None                                                           ;
; Output: Displays the "word so far" on the screen.                     ;
;         AL - Number of incorrect guesses (letters yet to be guessed). ;
;         If AL = 0, the word is complete.                              ;
; Memory Usage: Reads data from `chosenWord` and `triedLetters` arrays. ;
; Register Usage:                                                       ;
;     AL - Holds the current letter to display or underscore. Also used ;
;          to return the count of missing letters (incorrect guesses).  ;
;     BL - Holds the 0-based index of the current letter.               ;
;     CL - Loop counter (tracks position in the word).                  ;
;     DL - Counter for the number of missing letters (incorrect guesses).;
;     EDI - Pointer to the `chosenWord` array.                          ;
;     ESI - Pointer to the `triedLetters` array.                        ;
;     EDX - Used for address calculations and as a return value.        ;
; **********************************************************************;
displayWordSoFar PROC uses ebx edx ecx edi esi

    lea edi, chosenWord             ; Load address of `chosenWord` into EDI
    lea esi, triedLetters           ; Load address of `triedLetters` into ESI
    lea edx, wordSoFarDisplay       ; Load address of `wordSoFarDisplay` message into EDX
    call WriteString                ; Display the message "Word so far:"

    xor ecx, ecx                    ; Clear ECX (loop counter)
    xor edx, edx                    ; Clear EDX (used for counting incorrect guesses)
    xor ebx, ebx                    ; Clear EBX (used for letter index calculation)

    .WHILE(ecx < 6)                 ; Loop through the 6 letters of the chosen word
        mov bl, byte ptr [edi+ecx]  ; Load the current letter from `chosenWord` into BL
        sub bl, 'a'                 ; Convert the letter to a 0-based index (0-25)
        .IF(byte ptr [esi+ebx] == 1) ; Check if the letter has been guessed
            mov al, byte ptr [edi+ecx] ; Load the correctly guessed letter
            call WriteChar           ; Display the letter
        .ELSE                       ; If the letter has not been guessed
            mov al, '_'             ; Use an underscore as a placeholder
            call WriteChar           ; Display the underscore
            inc dl                  ; Increment the count of missing letters
        .ENDIF
        inc ecx                     ; Move to the next letter in the word
    .ENDW

    mov al, dl                      ; Move the count of missing letters to AL
    ret                             ; Return to the caller
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
