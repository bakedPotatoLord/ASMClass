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

prompt DB "Enter a floating point number with at least 5 decimal places and at most 100 digits: ",0

precisionPrompt DB "Enter the number of decimal places to round to (1-4): ",0

numberInput DB 101 DUP(0)

packedBCD DB 10 DUP(0)

prepoint dd 0

postpoint dd 0

floatOutput dd 0

numberDisplay DB "The number you entered is: ",0

roundedNumberDisplay DB "The rounded number is: ",0



invalidInputDisplay DB "Invalid input. Please try again.",0

dividerDisplay DB "------------------------------------",0

.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description: 
; Input:                      ;
; Output: ;
; Register Usage:                                                       ;
; EAX - ;
; **********************************************************************;

main PROC

    floatPrompt:
        lea edx, prompt
        call WriteString

        lea edx, numberInput
        mov ecx, 100
        call readString
        
        
        call Crlf

    inputValidate:
        ;EDX holds curr address

        .WHILE(1) ;iterate through pre- point numbers

            .IF( byte ptr [edx] == 46) ; check for decimal
                jmp afterPoint
            .ELSEIF( byte ptr [edx] < 48 && byte ptr [edx] > 57) ; check for non-numeric
                call invalidInput
                jmp floatPrompt
            .ENDIF

            inc edx
        .ENDW

        afterPoint:

        xor eax, eax ; eax will be decimal counter
        .WHILE(1)
            .if( byte ptr [edx] < 48 && byte ptr [edx] > 57) ; check for non-numeric
                call invalidInput
                jmp floatPrompt

            .elseif( byte ptr [edx] == 0) ; check for end of string
                .IF(eax < 5) ; if less than 5 decimal places
                    call invalidInput
                    JMP floatPrompt
                .ENDIF
                jmp validFloat
            .ELSE ; if numeric
                inc eax
            .ENDIF

            inc edx
        .ENDW

    invalid:
        call invalidInput
        jmp floatPrompt


    validFloat:
        lea edx, numberDisplay
        call WriteString

        lea edx, numberInput
        call WriteString

        call Crlf
        call Crlf

    askprecisionPrompt:

        lea edx, precisionPrompt
        call WriteString

        call readInt

        .IF(eax < 1 || eax > 4)
            call invalidInput
            jmp askprecisionPrompt
        .ENDIF

        mov esi, eax ; store precision in esi

        
        


    convertloops:
        
    

            lea esi, offset numberInput  ; Load address of ASCII string
            xor eax, eax ; Clear EAX - will be accumlator
            xor ebx, ebx ; Clear EBX - will be digit holder

    prepointLoop:
        mov bl, byte ptr [esi]       ; Load character from string
        inc esi                       ; Move to next character
        cmp bl, '.'                    ; Check if end of first part
        je done                      ; If null terminator, exit loop


        sub bl, '0'                  
        cmp bl, 9                    ; Ensure it's a valid decimal digit
        ja prepointLoop              ; Ignore invalid characters

        mov edx, 10
        mul edx                       ; Multiply accumulator by 10
        add eax,ebx                    ;


        jmp prepointLoop             ; Repeat for the next character



    done:
        mov prepoint, eax
        finit                        ; Initialize FPU
        
        fild dword ptr prepoint              

        call writeFloat
        call Crlf
        call divider

    JMP floatPrompt

    invoke ExitProcess, 0           ; Exit program with code 0
    
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
