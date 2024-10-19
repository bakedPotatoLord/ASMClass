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

    stringPrompt DB "Please enter a one-line string with a maximum of 100 characters:", 0  ; Prompt message for user input
    originalStringDisplay DB "Original String: ", 0   ; Label for displaying the original string
    compressedStringDisplay DB "Compressed String: ", 0 ; Label for displaying the compressed string
    tryagainDisplay DB "Would you like to enter a new string (y/n)", 0 ; Prompt for asking if the user wants to try again

    alphabet DB "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0      ; Array of uppercase letters for reference
    letterFreq DW 26 dup(0)                          ; Array to store frequency counts of each letter (initialized to 0)

    stringInput DB 101 DUP(0)             ; Buffer to hold the user input string (up to 100 characters + null terminator)
    compressedString DB 101 DUP(0)        ; Buffer to store the compressed string after removing non-alphabetic characters


.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description: The main procedure prompts the user for a string,        ;
;              compresses it by removing non-letter characters, and     ;
;              asks the user if they want to repeat the process.        ;
; Input: None                                                            ;
; Output: Compressed string is displayed                                ;
; Register Usage:                                                        ;
; EAX - Used for accessing input string                                  ;
; EBX - Used for accessing output (compressed) string                    ;
; ECX - Loop counter (implicitly used by Irvine library functions)       ;
; EDX - Holds address of strings to be printed                           ;
; **********************************************************************;

main PROC

    prompt:
        lea edx, stringPrompt               ; Load the address of the prompt message
        call WriteString                    ; Display the prompt
        call Crlf                           ; Move to the next line for input
        lea edx, stringInput                ; Load the address of the input buffer
        mov ecx, 101                        ; Maximum input length (100 characters + null terminator)
        call ReadString                     ; Read the input string from the user
        lea edx, originalStringDisplay      ; Load the label for the original string
        call WriteString                    ; Display the label
        lea edx, stringInput                ; Load the input string address
        call WriteString                    ; Display the original string
        call Crlf                           ; Newline for spacing

        lea eax, stringInput                ; Load the address of the input string into EAX
        lea ebx, compressedString           ; Load the address of the compressed string buffer into EBX

    .WHILE(dl != 0)                         ; Loop through the input string until a null terminator is reached
        mov dl, [eax]                       ; Load the current character from the input string into DL
        .IF (dl >= 65 && dl <= 90) || (dl >= 97 && dl <= 122)  ; Check if the character is a letter (A-Z or a-z)
            mov [ebx], dl                   ; If it's a letter, store it in the compressed string buffer
            inc ebx                         ; Move to the next position in the compressed string buffer
        .ENDIF
        inc eax                             ; Move to the next character in the input string
    .ENDW                

    outputString:
        lea edx, compressedStringDisplay    ; Load the label for the compressed string
        call WriteString                    ; Display the label
        lea edx, compressedString           ; Load the compressed string address
        call WriteString                    ; Display the compressed string
        call Crlf                           ; Newline for spacing

        call countletters                   ; Call the countletters procedure

    ASK_TRY_AGAIN:                          ; Ask the user if they want to repeat the program
        call Crlf                           ; Newline for formatting
        lea edx, tryagainDisplay            ; Load the try again prompt message
        call WriteString                    ; Display the prompt
        call ReadChar                       ; Read the user's response (single character)
        .IF al == 'y' || al == 'Y'          ; If the user enters 'y' or 'Y', repeat the process
            call Crlf                       ; Newline for spacing
            call clearvars                  ; Clear all variables (strings and frequency counts)
            JMP prompt                      ; Jump back to the prompt to start the process again
        .ENDIF
    INVOKE ExitProcess, 0                   ; Exit the program with status 0

main ENDP


; **********************************************************************;
; countLetters Procedure                                                 ;
; Description: This procedure counts the frequency of each letter in     ;
;              the compressed string. It converts the string to         ;
;              uppercase for uniformity, calculates the letter          ;
;              frequencies, and stores them in the 'letterFreq' array.  ;
; Input: 'compressedString' - A string containing only uppercase        ;
;         alphabetical characters                                        ;
; Output: The letter frequency is displayed                              ;
; Register Usage:                                                        ;
; EAX - Points to the 'compressedString' during traversal                ;
; EBX - Points to the 'letterFreq' array where the count is stored       ;
; EDX - Temporarily stores the ASCII value of the current character      ;
; Notes: The Irvine32 library function 'str_ucase' is used to convert    ;
;        the string to uppercase. The 'displayLetterFreq' procedure      ;
;        is called to display the frequencies after counting.            ;
; **********************************************************************;
countLetters PROC uses eax ebx ecx edx

    lea eax, compressedString              ; Load the address of the compressed string into EAX
    lea ebx, letterFreq                    ; Load the address of the letter frequency array into EBX
    xor edx, edx                           ; Clear EDX (used to store the letter index)

    INVOKE str_ucase, ADDR compressedString ; Convert the compressed string to uppercase

    .WHILE(byte ptr [eax] != 0)            ; Loop through the compressed string until null terminator is reached
        mov dl, byte ptr [eax]             ; Load the current character from the compressed string into DL
        sub dl, 'A'                        ; Subtract 'A' to get the zero-based index of the letter (A=0, B=1, etc.)
        inc word ptr [ebx + 2 * edx]       ; Increment the corresponding frequency count in letterFreq
        inc eax                            ; Move to the next character in the compressed string
    .ENDW

    call displayLetterFreq                 ; Call the displayLetterFreq procedure to print the letter frequencies
    ret                                    ; Return from the procedure
countLetters ENDP


; **********************************************************************;
; displayLetterFreq Procedure                                            ;
; Description: This procedure displays the alphabet followed by the      ;
;              corresponding letter frequency values stored in the       ;
;              'letterFreq' array. Each letter is printed with its       ;
;              frequency next to it, separated by spaces.                ;
; Input: None (implicitly uses global 'alphabet' and 'letterFreq')       ;
; Output: The letters and their frequency counts are printed to the      ;
;         console                                                        ;
; Register Usage:                                                        ;
; EAX - Used to hold the current character from 'alphabet' and           ;
;       frequencies from 'letterFreq'                                    ;
; EDX - Points to the 'alphabet' and 'letterFreq' arrays during traversal;
; ECX - Holds the upper bound of the 'letterFreq' array during iteration ;
; Notes: The Irvine32 library procedures 'WriteChar', 'WriteDec', and    ;
;        'Crlf' are used for output. Each letter's frequency is displayed;
;        as a decimal number.                                            ;
; **********************************************************************;
displayLetterFreq PROC uses eax edx ecx

    lea edx, alphabet                      ; Load the address of the alphabet array into EDX
    xor eax, eax                           ; Clear EAX (used to store current character)

    .WHILE(byte ptr [edx] != 0)            ; Loop through the alphabet until the null terminator is reached
        mov al, byte ptr [edx]             ; Load the current letter into AL
        call WriteChar                     ; Print the letter

        mov al, ' '                        ; Load a space character into AL
        call WriteChar                     ; Print the space after the letter
        inc edx                            ; Move to the next letter in the alphabet
    .ENDW

    call Crlf                              ; Print a newline after displaying all the letters

    lea edx, letterFreq                    ; Load the address of the letter frequency array into EDX
    mov ecx, edx                           ; Copy EDX to ECX for use as the upper bound
    add ecx, (SIZEOF letterFreq)           ; Add the size of the letterFreq array to ECX to calculate the end address

    .WHILE(edx < ecx)                      ; Loop through the letterFreq array
        mov ax, word ptr [edx]             ; Load the current frequency count (word size) into AX
        call WriteDec                      ; Print the frequency count as a decimal number
        mov al, ' '                        ; Load a space character into AL
        call WriteChar                     ; Print a space after the frequency count
        add edx, 2                         ; Move to the next frequency count (word size = 2 bytes)
    .ENDW

    ret                                    ; Return from the procedure
displayLetterFreq ENDP


; **********************************************************************;
; clearVars Procedure                                                    ;
; Description: This procedure clears the input string, compressed string,;
;              and the letter frequency array by setting all their       ;
;              values to zero. This ensures no residual data remains     ;
;              from previous operations.                                 ;
; Input: None (implicitly operates on global variables)                  ;
; Output: The 'stringInput', 'compressedString', and 'letterFreq'        ;
;         variables are cleared (set to zero)                            ;
; Register Usage:                                                        ;
; EAX - Used to point to the 'stringInput', 'compressedString', and      ;
;       'letterFreq' during clearing                                     ;
; EBX - Holds the end address of the 'letterFreq' array for the loop     ;
; Notes: The procedure uses two-byte (word) increments to clear          ;
;        'letterFreq' since it holds word-sized counts.                  ;
; **********************************************************************;
clearVars PROC uses eax ebx
    lea eax, stringInput                   ; Load the address of the input string into EAX
    .WHILE(byte ptr [eax] != 0)            ; Loop through the input string until null terminator is reached
        mov byte ptr [eax], 0              ; Set each byte of the input string to 0 (clear the string)
        inc eax                            ; Move to the next character
    .ENDW

    lea eax, compressedString              ; Load the address of the compressed string into EAX
    .WHILE(byte ptr [eax] != 0)            ; Loop through the compressed string until null terminator is reached
        mov byte ptr [eax], 0              ; Set each byte of the compressed string to 0 (clear the string)
        inc eax                            ; Move to the next character
    .ENDW

    lea eax, letterFreq                    ; Load the address of the letter frequency array into EAX
    mov ebx, eax                           ; Copy the base address of letterFreq into EBX
    add ebx, SIZEOF letterFreq             ; Calculate the end address of the letterFreq array
    .WHILE(eax < ebx)                      ; Loop through the letterFreq array
        mov word ptr [eax], 0              ; Set each word (2 bytes) of the letterFreq array to 0 (clear frequencies)
        add eax, 2                         ; Move to the next word (2 bytes)
    .ENDW
    ret                                    ; Return from the procedure
clearVars ENDP


END main