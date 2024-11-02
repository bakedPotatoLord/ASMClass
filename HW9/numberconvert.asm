; **********************************************************************;
; Program Name:   Base Converter Program (baseConverter.asm)            ;
; Program Description: Converts user-entered 32-bit integers between    ;
;                      Decimal, Hexadecimal, and Binary bases. Displays ;
;                      menu options, performs conversion, and provides  ;
;                      error handling for invalid entries.              ;
; Author:          Josiah Hamm   @bakedPotatoLord                       ;
; Course Number:   CSC2025X01 - Computer Architecture/Assembly Language ;
; Date:            10/20/2024                                           ;
; **********************************************************************;

.386                              ; Specify 32-bit code
.model flat,stdcall               ; Flat memory model with standard calling conventions
.stack 4096                       ; Allocate 4 KB of stack space
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

    decimalPrompt DB "Please enter a 32-bit Decimal integer with no spaces or non-decimal characters: ",0
    hexPrompt DB "Please enter a 32-bit Hexadecimal integer with no spaces or non-hex characters: ",0
    binaryString DB 34 DUP(0),0  ; Buffer for binary input string
    binaryPrompt DB "Please enter a 32-bit Binary integer with no spaces or non-binary characters: ",0
    decimalDisplay DB "Decimal Value: ",0
    hexDisplay DB "Hexadecimal Value: ",0
    binaryDisplay DB "Binary Value: ",0
    invalidInputDisplay DB "Invalid input. Please try again.",0 ; Display string for invalid input
    dividerDisplay DB "------------------------------------",0  ; Divider line for clarity

.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description: Main loop and entry point for the program, handles menu  ;
;              options and value input, performs conversions, and       ;
;              displays results.                                        ;
; Input:  User's menu selection and value to convert                    ;
; Output: Converted values displayed in decimal, hexadecimal, and binary;
; Register Usage:                                                       ;
; EAX - used for storing function return values                         ;
; EDX - used for passing string addresses to WriteString                ;
; **********************************************************************;

main PROC
    start:
        lea edx, optionsDisplay             ; Load menu options into EDX
        call WriteString                    ; Display menu options

        call readChar                       ; Read user's menu choice into AL
        call writeChar                      ; Echo choice to screen
        call Crlf                           ; New line
        call Crlf                           ; Additional line for readability

        .IF(al == '1')                      ; If user chooses (1) Decimal
            prompt1:
                lea edx, decimalPrompt      ; Prompt for decimal input
                call WriteString
                call ReadInt                ; Read 32-bit integer into EAX
                .IF(eax == 0)
                    jmp invalidnumber1      ; Jump to error if input is invalid
                .ENDIF
        .ELSEIF(al == '2')                  ; If user chooses (2) Hexadecimal
            prompt2:
                lea edx, hexPrompt          ; Prompt for hexadecimal input
                call WriteString
                call readHex                ; Read hex input and convert to integer
                .IF(eax == 0)
                    jmp invalidnumber2      ; Jump to error if input is invalid
                .ENDIF
        .ELSEIF(al == '3')                  ; If user chooses (3) Binary
            prompt3:
                lea edx, binaryPrompt       ; Prompt for binary input
                call WriteString
                call readBin                ; Read binary input, convert to integer
                .IF(eax == 0)
                    jmp invalidnumber3      ; Jump to error if input is invalid
                .ENDIF
        .ELSEIF(al == '4')                  ; If user chooses (4) Exit
            invoke ExitProcess, 0           ; Exit program with code 0
        .ELSE
            call invalidInput               ; Call error handler for invalid menu choice
            jmp start                       ; Restart menu
        .ENDIF

    call displayResults                     ; Display conversion results
    jmp start                               ; Restart menu after displaying results

    invalidnumber1:
        call invalidInput                   ; Display error and retry Decimal input
        jmp prompt1

    invalidnumber2:
        call invalidInput                   ; Display error and retry Hex input
        jmp prompt2

    invalidnumber3:
        call invalidInput                   ; Display error and retry Binary input
        jmp prompt3

main ENDP

; **********************************************************************;
; Read Binary Procedure                                                 ;
; Description: Converts a binary string input into a 32-bit integer     ;
; Input:  User's binary input in binaryString                           ;
; Output: Binary integer result in EAX                                  ;
; Register Usage:                                                       ;
; EAX - Accumulates binary value                                        ;
; EBX - Temporarily holds current character value                       ;
; ECX - Points to end of string                                         ;
; EDX - points to beginning of string                                   ;
; **********************************************************************;

readBin PROC uses ebx ecx edx
    lea edx, binaryString                    ; Load binary string buffer
    mov ecx, edx                             ; Initialize string-clearing loop
    add ecx, SIZEOF binaryString             ; ECX points to end of binaryString
    sub ecx, 1                               ; Adjust for zero-based indexing
    .WHILE(ecx > edx)                        ; Clear string values in buffer
        mov al, 0
        mov [ecx], al
        dec ecx
    .ENDW

    mov edx, offset binaryString             ; Load beginning of binaryString
    mov ecx, 33                              ; Limit for binary string length
    call readString                          ; Read input string into binaryString

    mov ecx, edx                             ; ECX holds beginning of string
    add edx, eax                             ; EDX points to end of string
    dec edx                                  ; Adjust EDX to point to last char

    xor eax, eax                             ; Clear EAX for accumulating result
    xor ebx, ebx                             ; Clear EBX for temporary character

    .WHILE(ecx <= edx)                       ; Loop through each character
        mov bl, byte ptr [ecx]               ; Load character into BL
        .IF(bl == '1' || bl == '0')          ; Check if character is 1 or 0
            shl eax, 1                       ; Shift accumulator left by 1 bit
            sub bl, '0'                      ; Convert '1'/'0' to binary 1/0
            add eax, ebx                     ; Accumulate result
        .ELSE
            xor eax, eax                     ; Clear EAX if invalid input found
            ret                              ; Return immediately
        .ENDIF
        inc ecx                              ; Move to next character
    .ENDW

    ret
readBin ENDP  

; **********************************************************************;
; Display Results Procedure                                             ;
; Description: Displays conversion results in decimal, hexadecimal,     ;
;              and binary format                                        ;
; Input:       Value to convert in EAX                                  ;
; Output:      Displayed results                                        ;
; Register Usage:                                                       ;
; EDX - Used for passing string addresses                               ;
; EAX - Holds value to display                                          ;
; **********************************************************************;

displayResults PROC uses edx
    call Crlf                               ; New lines for readability
    call Crlf

    lea edx, decimalDisplay                 ; Load decimal display prompt
    call WriteString
    call WriteInt                           ; Display decimal value
    call Crlf

    lea edx, hexDisplay                     ; Load hexadecimal display prompt
    call WriteString
    call WriteHex                           ; Display hexadecimal value
    call Crlf

    lea edx, binaryDisplay                  ; Load binary display prompt
    call WriteString
    call WriteBin                           ; Display binary value
    call Crlf

    call divider                            ; Print divider line
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
    lea edx, invalidInputDisplay             ; Load invalid input message
    call WriteString                         ; Display message
    call Crlf                                ; New line
    call divider                             ; Print divider line
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
    lea edx, dividerDisplay                  ; Load divider string
    call WriteString                         ; Print divider line
    call Crlf                                ; New line
    ret
divider ENDP

END main
