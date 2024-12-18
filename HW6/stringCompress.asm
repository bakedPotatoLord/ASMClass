; **********************************************************************;
; Program Name:   String Compression Program (StringCompression.asm)    ;
; Program Description: This program prompts the user for a string       ;
;                      (maximum of 100 characters), removes all         ;
;                      non-alphabetical characters, and displays the    ;
;                      compressed string. The program also provides an  ;
;                      option to repeat the process.                    ;
; Author:          Josiah Hamm                                           ;
; Course Number:   CSC2025X01 - Computer Architecture/Assembly Language  ;
; Date:            10/4/2024                                             ;
; Revisions:       None                                                  ;
; Date Last Modified: 10/4/2024                                          ;
; **********************************************************************;

INCLUDE C:\Irvine\Irvine32.inc          ; Include Irvine32 library for basic I/O operations
INCLUDELIB C:\Irvine\Irvine32.lib       ; Link Irvine32 library

.data

    stringPrompt DB "Please enter a one-line string with a maximum of 100 characters:", 0  ; Prompt message for user input
    originalStringDisplay DB "Original String: ", 0   ; Label for displaying the original string
    compressedStringDisplay DB "Compressed String: ", 0 ; Label for displaying the compressed string
    tryagainDisplay DB "Would you like to enter a new string (y/n)", 0 ; Prompt for asking if the user wants to try again

    alphabet DB "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
    letterFreq DW 26 dup(0)

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

    .WHILE(dl != 0)
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

    ASK_TRY_AGAIN:                          ; Ask the user if they want to repeat the program
        call Crlf                           ; Newline for formatting
        lea edx, tryagainDisplay            ; Load the try again prompt message
        call WriteString                    ; Display the prompt
        call ReadChar                       ; Read the user's response (single character)
        .IF al == 'y' || al == 'Y'          ; If the user enters 'y' or 'Y', repeat the process
            call Crlf                       ; Newline for spacing

            call clearvars

            JMP prompt  
        .ENDIF
    INVOKE ExitProcess, 0               ; Exit the program with status 0

main ENDP

//takes from compressedString
//writes to letterFreq
countletters PROC

    lea eax, compressedString
    lea ebx, letterFreq
    lea ecx, alphabet

    INVOKE str_ucase ADDR compressedString

    WHILE(byte ptr [eax] != 0)

        mov dl, byte ptr [eax]
        sub dl, 'A'

        inc word ptr [ebx + 2 * edx]


        inc eax //move through string
    .ENDW

countletters ENDP

clearvars PROC
    lea eax, stringInput    ; Load the address of the input string into EAX
    WHILE(byte ptr [eax] != 0)
        mov byte ptr [eax], 0 
        inc eax
    .ENDW
    lea ebx, compressedString 
    WHILE(byte ptr [ebx] != 0)
        mov byte ptr [ebx], 0 
        inc ebx
    .ENDW
    ret
clearvars ENDP


END main
