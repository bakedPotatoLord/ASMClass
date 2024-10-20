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

INCLUDE C:\Irvine\Irvine32.inc          ; Include Irvine32 library for basic I/O operations
INCLUDELIB C:\Irvine\Irvine32.lib       ; Link Irvine32 library

.data
    integer1Prompt DB "Please enter an integer value up to 16 bits in size: ",0
    integer2Prompt DB "Please enter another integer value up to 16 bits in size: ",0

    integer1 DD ?                         ; First user input integer
    integer2 DD ?                         ; Second user input integer

    promptOptions DB "(1) Addition",10,13,
    "(2) Subtraction",10,13,
    "(3) Multiplication",10,13,
    "(4) Division",10,13,
    "(5) Exit",10,13,
    10,13,
    "Enter your choice from the above options: ",0

    plus DB ' + ',0                       ; Display string for addition operator
    minus DB ' - ',0                      ; Display string for subtraction operator
    times DB ' * ',0                      ; Display string for multiplication operator
    divide DB ' / ',0                     ; Display string for division operator
    equals DB ' = ',0                     ; Display string for equals sign
    remainder DB ' remainder ',0          ; Display string for remainder output

    invalidInputDisplay DB "Invalid input. Please try again.",0 ; Display string for invalid input

    dividerDisplay DB "------------------------------------",0 ; Divider line for clarity

.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description: This is the main entry point of the program, which        ;
;              prompts the user for two integers and then repeatedly    ;
;              displays a menu for performing arithmetic operations.    ;
; Input:       User enters two 16-bit integers and chooses a menu option;
; Output:      The result of the arithmetic operation based on user     ;
;              choice is displayed, along with the corresponding symbol ;
; Register Usage:                                                       ;
; EAX - Used for arithmetic operations and storing results              ;
; EDX - Used for passing string addresses                               ;
; **********************************************************************;

main PROC
    prompt:                                   ; Start of the input sequence
        lea edx, integer1Prompt               ; Load address of first prompt string
        call WriteString                      ; Display prompt
        call ReadInt                          ; Read first integer input
        .IF(OVERFLOW?)                        ; Check for input overflow
            call invalidInput                 ; Handle invalid input
            jmp prompt                        ; Restart prompt sequence
        .ENDIF
        mov integer1, eax                     ; Store first integer input
        call Crlf                             ; Print new line

        lea edx, integer2Prompt               ; Load address of second prompt string
        call WriteString                      ; Display prompt
        call ReadInt                          ; Read second integer input
        .IF(OVERFLOW?)                        ; Check for input overflow
            call invalidInput                 ; Handle invalid input
            jmp prompt                        ; Restart prompt sequence
        .ENDIF
        mov integer2, eax                     ; Store second integer input
        call Crlf                             ; Print new line

        lea edx, promptOptions                ; Load address of menu options
        call WriteString                      ; Display menu options

        call ReadInt                          ; Read user menu selection
        call Crlf                             ; Print new line
        .IF(eax == 1)                         ; Check if addition is selected
            call addition                     ; Call addition procedure
        .ELSEIF(eax == 2)                     ; Check if subtraction is selected
            call subtraction                  ; Call subtraction procedure
        .ELSEIF(eax == 3)                     ; Check if multiplication is selected
            call multiplication               ; Call multiplication procedure
        .ELSEIF(eax == 4)                     ; Check if division is selected
            call division                     ; Call division procedure
        .ELSEIF(eax == 5)                     ; Check if exit is selected
            jmp exitProgram                   ; Exit the program
        .ELSE
            call invalidInput                 ; Handle invalid input
            jmp prompt                        ; Restart prompt sequence
        .ENDIF
        
        call Crlf                             ; Print new line
        call divider                          ; Print divider for clarity
        JMP prompt                            ; Repeat the menu prompt

    exitProgram:
    INVOKE ExitProcess, 0                     ; Exit the program with status 0

main ENDP

; **********************************************************************;
; Addition Procedure                                                    ;
; Description: This procedure performs addition of two integers.        ;
; Input:       integer1 and integer2 are loaded into registers.         ;
; Output:      Displays the sum of the two integers.                    ;
; Register Usage:                                                       ;
; EAX - Used for arithmetic operations                                  ;
; EDX - Used for passing string addresses                               ;
; **********************************************************************;

addition PROC uses eax edx
    mov eax, integer1                        ; Load first integer
    call writeInt                            ; Display first integer

    lea edx, plus                            ; Load address of plus sign string
    call writeString                         ; Display plus sign

    mov eax, integer2                        ; Load second integer
    call writeInt                            ; Display second integer

    lea edx, equals                          ; Load address of equals sign string
    call writeString                         ; Display equals sign

    add eax, integer1                        ; Add first and second integers
    call writeInt                            ; Display result

    ret
addition ENDP

; **********************************************************************;
; Subtraction Procedure                                                 ;
; Description: This procedure performs subtraction of two integers.     ;
; Input:       integer1 and integer2 are loaded into registers.         ;
; Output:      Displays the difference of the two integers.             ;
; Register Usage:                                                       ;
; EAX - Used for arithmetic operations                                  ;
; EDX - Used for passing string addresses                               ;
; **********************************************************************;

subtraction PROC uses eax edx
    mov eax, integer1                        ; Load first integer
    call writeInt                            ; Display first integer

    lea edx, minus                           ; Load address of minus sign string
    call writeString                         ; Display minus sign

    mov eax, integer2                        ; Load second integer
    call writeInt                            ; Display second integer

    lea edx, equals                          ; Load address of equals sign string
    call writeString                         ; Display equals sign

    mov eax, integer1                        ; Reload first integer
    sub eax, integer2                        ; Subtract second integer from first
    call writeInt                            ; Display result

    ret
subtraction ENDP 

; **********************************************************************;
; Multiplication Procedure                                              ;
; Description: This procedure performs multiplication of two integers.  ;
; Input:       integer1 and integer2 are loaded into registers.         ;
; Output:      Displays the product of the two integers.                ;
; Register Usage:                                                       ;
; EAX - Used for arithmetic operations                                  ;
; EBX - Used to store one of the operands                               ;
; EDX - Used for passing string addresses                               ;
; **********************************************************************;

multiplication PROC uses eax ebx edx
    mov eax, integer1                        ; Load first integer
    call writeInt                            ; Display first integer

    lea edx, times                           ; Load address of multiplication sign string
    call writeString                         ; Display multiplication sign

    mov eax, integer2                        ; Load second integer
    call writeInt                            ; Display second integer

    lea edx, equals                          ; Load address of equals sign string
    call writeString                         ; Display equals sign

    mov ebx, integer1                        ; Load first integer into EBX
    mul ebx                                  ; Multiply first and second integers
    call writeInt                            ; Display result

    ret
multiplication ENDP 

; **********************************************************************;
; Division Procedure                                                    ;
; Description: This procedure performs division of two integers.        ;
; Input:       integer1 and integer2 are loaded into registers.         ;
; Output:      Displays the quotient and remainder of the division.     ;
; Register Usage:                                                       ;
; EAX - Stores the dividend and quotient                                ;
; EDX - Stores the remainder                                             ;
; EBX - Stores the divisor                                               ;
; ECX - Temporary register for remainder                                ;
; **********************************************************************;

division PROC uses eax ebx ecx edx
    mov eax, integer1                        ; Load first integer (dividend)
    call writeInt                            ; Display first integer

    lea edx, divide                          ; Load address of division sign string
    call writeString                         ; Display division sign

    mov eax, integer2                        ; Load second integer (divisor)
    call writeInt                            ; Display second integer

    lea edx, equals                          ; Load address of equals sign string
    call writeString                         ; Display equals sign


    xor edx, edx                             ; Clear EDX for remainder
    mov eax, integer1                        ; Load dividend into EAX
    cdq                                      ; Sign extend dividend in EAX to EDX:EAX
    mov ebx, integer2                        ; Load divisor into EBX
    idiv ebx                                 ; Divide EAX by EBX, quotient in EAX, remainder in EDX
    call writeInt                            ; Display quotient
    push edx                                 ; Push remainder onto stack

    lea edx, remainder                       ; Load address of remainder string
    call writeString                         ; Display remainder label

    pop eax                                  ; Pop remainder from stack into EAX
    call writeInt                            ; Display remainder

    ret
division ENDP

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
