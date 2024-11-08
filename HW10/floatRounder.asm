; **********************************************************************;
; Program Name:   Float Rounder Program (floatRounder.asm)              ;
; Program Description: Rounds a floating-point number to specified      ;
;                      decimal places, with display in scientific       ;
;                      and decimal notation.                            ;
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
    prompt DB "Enter a floating point number with (5-9) decimal places : ",0 ; Prompt message
    precisionPrompt DB "Enter the number of decimal places to round to (1-4): ",0 ; Precision prompt
    numberInput DB 64 DUP(0)            ; Buffer for user input
    precision DD 0                      ; Variable for precision level
    prepoint dd 0                       ; Holds integer part before decimal point
    postpoint dd 0                      ; Holds fractional part after decimal point
    floatOutput dd 0                    ; Placeholder for output float
    floatPass dd 0                      ; Placeholder for processing float calculations
    bcdOut TBYTE 0                      ; BCD output for decimal formatting
    decimalOutput DB 21 DUP(0)          ; Buffer for decimal output
    numberDisplay DB "The number you entered is: ",0 ; Message for displaying user input
    roundedNumberScientific DB "Rounded number in scientific notation: ",0 ; Message for scientific notation
    roundedNumberDecimal DB "Rounded number in decimal notation: ",0 ; Message for decimal notation
    repeatPrompt DB "Repeat? (y/n): ",0 ; Prompt for repeat option
    invalidInputDisplay DB "Invalid input. Please try again.",0 ; Message for invalid input
    dividerDisplay DB "------------------------------------",0 ; Divider for UI

.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description: Main procedure for handling user input, rounding float,  ;
;              and displaying output in scientific and decimal formats. ;
; Input:       User inputs a floating-point number and rounding         ;
;              precision.                                               ;
; Output:      Rounded float displayed in both scientific and decimal   ;
;              formats.                                                 ;
; Register Usage:                                                       ;
; EAX - used as accumulator and as parameter for functions              ;
; EBX - used to store digits of input float                             ;
; ECX - used as loop counter and as parameter for functions             ;
; EDX - used to pass addresses for displaying strings                   ;
; ESI - used as loop counter for iterating over strings                 ;
; EDI - used for writing to string outputbuffer                         ;
; **********************************************************************;

main PROC

    floatPrompt:
        lea edx, prompt            ; Load the address of prompt string into EDX
        call WriteString           ; Display the prompt to the user

        lea edx, numberInput       ; Load address of numberInput buffer
        mov ecx, 63                ; Set max number of characters to read
        call readString            ; Read string input from user
        call Crlf                  ; Print a newline

    displayInput:
        lea edx, numberDisplay     ; Load address of numberDisplay string
        call WriteString           ; Display the numberDisplay label

        lea edx, numberInput       ; Load address of user's input
        call WriteString           ; Display the user's input

        call Crlf                  ; Print a newline
        call Crlf                  ; Print another newline

    askprecisionPrompt:
        lea edx, precisionPrompt   ; Load the address of precisionPrompt string
        call WriteString           ; Display precision prompt

        call readInt               ; Read integer input from user
        .IF(eax < 1 || eax > 4)    ; If input is not within [1,4]
            call invalidInput      ; Display invalid input message
            jmp askprecisionPrompt ; Loop back to prompt again
        .ENDIF
        mov precision, eax         ; Store valid precision input
        call Crlf                  ; Print a newline

    convertloops:
        lea esi, offset numberInput; Load address of numberInput string
        xor eax, eax               ; Clear EAX for accumulation
        xor ebx, ebx               ; Clear EBX for digit storage
        .WHILE(byte ptr [esi] != '.') ; Loop until decimal point is reached
            mov bl, byte ptr [esi] ; Load character from input string
            sub bl, '0'            ; Convert ASCII to digit
            inc esi                ; Move to next character
            .IF(bl > 9)            ; If character is invalid
                .CONTINUE          ; Skip invalid characters
            .ENDIF
            mov edx, 10            ; Set multiplier (base 10)
            mul edx                ; Multiply accumulator by 10
            add eax, ebx           ; Add digit to accumulator
        .ENDW
        mov prepoint, eax          ; Store integer part in prepoint

        xor eax, eax               ; Clear EAX for fraction calculation
        xor ebx, ebx               ; Clear EBX for digit storage
        xor cl, cl                 ; Clear CL for digit count
        .WHILE(byte ptr [esi] != 0); Loop until end of string
            mov bl, byte ptr [esi] ; Load character
            sub bl, '0'            ; Convert ASCII to digit
            inc esi                ; Move to next character
            .IF(bl > 9)            ; If character is invalid
                .CONTINUE          ; Skip invalid characters
            .ENDIF
            mov edx, 10            ; Set multiplier (base 10)
            mul edx                ; Multiply accumulator by 10
            add eax, ebx           ; Add digit to accumulator
            inc cl                 ; Increment digit count
        .ENDW
        mov postpoint, eax         ; Store fractional part in postpoint

    round:
        finit                      ; Initialize FPU

        fild dword ptr postpoint   ; Load fractional part to FPU stack

        .IF(cl == 1)
            mov eax, 10            ; Set multiplier for 1 digit
        .ELSEIF(cl == 2)
            mov eax, 100           ; Set multiplier for 2 digits
        .ELSEIF(cl == 3)
            mov eax, 1000          ; Set multiplier for 3 digits
        .ELSEIF(cl == 4)
            mov eax, 10000         ; Set multiplier for 4 digits
        .ELSEIF(cl == 5)
            mov eax, 100000        ; Set multiplier for 5 digits
        .ELSEIF(cl == 6)
            mov eax, 1000000       ; Set multiplier for 6 digits
        .ELSEIF(cl == 7)
            mov eax, 10000000      ; Set multiplier for 7 digits
        .ELSEIF(cl == 8)
            mov eax, 100000000     ; Set multiplier for 8 digits
        .ELSEIF(cl == 9)
            mov eax, 1000000000    ; Set multiplier for 9 digits
        .ENDIF

        mov floatPass, eax         ; Store multiplier in floatPass
        fidiv floatPass            ; Divide fractional part by multiplier
        fiadd prepoint             ; Add integer part

        .if(precision == 1)
            mov eax, 10            ; Set precision multiplier for 1 digit
        .elseif(precision == 2)
            mov eax, 100           ; Set precision multiplier for 2 digits
        .elseif(precision == 3)
            mov eax, 1000          ; Set precision multiplier for 3 digits
        .elseif(precision == 4)
            mov eax, 10000         ; Set precision multiplier for 4 digits
        .endif

        mov floatPass, eax         ; Store precision multiplier in floatPass
        fimul floatPass            ; Multiply by precision multiplier

        fistp dword ptr floatPass  ; Store rounded result
        fild dword ptr floatPass   ; Reload result for display

        mov floatPass, eax         ; Copy multiplier to floatPass
        fidiv floatPass            ; Divide by multiplier to format number

    displayvals:
        lea edx, roundedNumberScientific ; Load address of scientific notation label
        call WriteString           ; Display label

        call writeFloat            ; Display floating point result
        call Crlf                  ; Print newline

        fimul floatPass            ; Multiply by multiplier for BCD

        FBSTP tbyte ptr bcdOut     ; Convert FPU result to BCD format

        lea edx, bcdOut            ; Load BCD output address
        mov ecx, edx               ; Move address to ECX for loop limit
        add ecx, 10                ; Set ECX to end of BCD output

        xor eax, eax               ; Clear EAX for BCD digit
        xor esi, esi               ; Clear ESI for digit counter
        lea edi, decimalOutput     ; Load address of decimal output buffer

        .while edx < ecx           ; Loop through each BCD byte
            mov al, byte ptr [edx] ; Load low nibble
            and al, 0Fh            ; Isolate low nibble
            add al, '0'            ; Convert to ASCII
            mov byte ptr [edi+esi], al ; Store ASCII digit in buffer
            inc esi                ; Increment digit counter

            .if(precision == esi)  ; If precision is reached
                mov al, '.'        ; Insert decimal point
                mov byte ptr [edi+esi], al ; Store decimal point
                inc esi            ; Increment counter
            .endif

            mov al, byte ptr [edx] ; Load high nibble
            shr al, 4              ; Shift to low nibble position
            add al, '0'            ; Convert to ASCII
            mov byte ptr [edi+esi], al ; Store ASCII digit
            inc esi                ; Increment digit counter

            .if(precision == esi)  ; If precision is reached
                mov al, '.'        ; Insert decimal point
                mov byte ptr [edi+esi], al ; Store decimal point
                inc esi            ; Increment counter
            .endif

            inc edx                ; Move to next BCD byte
        .endw

        lea edx, roundedNumberDecimal ; Load decimal notation label
        call WriteString           ; Display label

        .while(esi > 0)            ; Loop to print decimal output
            dec esi                ; Decrement digit counter
            mov al, byte ptr [edi+esi] ; Load digit from buffer
            call WriteChar         ; Display digit
        .endw

        call Crlf                  ; Print newline
        call Crlf                  ; Print another newline
        call divider               ; Display divider line

    askRepeat:
        lea edx, repeatPrompt      ; Load repeat prompt address
        call WriteString           ; Display prompt

        call ReadChar              ; Read user's response
        .if(al == 'y' || al == 'Y') ; If 'y' or 'Y' entered
            call Clrscr            ; Clear screen
            JMP floatPrompt        ; Go back to start
        .ELSEIF (al == 'n' || al == 'N') ; If 'n' or 'N' entered
            invoke ExitProcess, 0  ; Exit program with status 0
        .ELSE                      ; If invalid input
            JMP askRepeat          ; Re-prompt
        .ENDIF
    
main ENDP


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

END main                                    ; End of main procedure
