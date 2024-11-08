; **********************************************************************;
; Program Name:   Float Rounder Program (baseConverter.asm)            ;
; Program Description:             ;
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
    prompt DB "Enter a floating point number with (5-9) decimal places : ",0
    precisionPrompt DB "Enter the number of decimal places to round to (1-4): ",0
    numberInput DB 64 DUP(0)
    precision DD 0
    prepoint dd 0
    postpoint dd 0
    floatOutput dd 0
    floatPass dd 0
    bcdOut TBYTE 0
    decimalOutput DB 21 DUP(0)
    numberDisplay DB "The number you entered is: ",0
    roundedNumberScientific DB "Rounded number iin scientific notation: ",0
    roundedNumberDecimal DB "Rounded number in decimal notation: ",0
    repeatPrompt DB "Repeat? (y/n): ",0
    invalidInputDisplay DB "Invalid input. Please try again.",0
    dividerDisplay DB "------------------------------------",0
.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description: 
; Input:                                                                ;
; Output: ;
; Register Usage:                                                       ;
; EAX - used as accumulator and as parameter for functions              ;
; **********************************************************************;

main PROC

    floatPrompt:
        lea edx, prompt
        call WriteString

        lea edx, numberInput
        mov ecx, 63
        call readString
        call Crlf

    displayInput:
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
        mov precision, eax ; store precision
        call Crlf

    convertloops:

        lea esi, offset numberInput  ; Load address of ASCII string
        xor eax, eax ; Clear EAX - will be accumlator
        xor ebx, ebx ; Clear EBX - will be digit holder
        .WHILE( byte ptr [esi] != '.')
            mov bl, byte ptr [esi]       ; Load character from string
            sub bl, '0'   
            inc esi                       ; Move to next character
            .IF(bl > 9)               
                .CONTINUE               ; Ignore invalid characters
            .ENDIF
            mov edx, 10
            mul edx                       ; Multiply accumulator by 10
            add eax,ebx                   
        .ENDW
        mov prepoint, eax

        xor eax, eax ; Clear EAX - will be accumlator
        xor ebx, ebx ; Clear EBX - will be digit holder
        xor cl, cl ; Clear CL - will be digit counter
        .WHILE( byte ptr [esi] != 0)
            mov bl, byte ptr [esi]       ; Load character from string
            sub bl, '0'   
            inc esi                       ; Move to next character
            .IF(bl > 9)               
                .CONTINUE               ; Ignore invalid characters
            .ENDIF
            mov edx, 10
            mul edx                       ; Multiply accumulator by 10
            add eax,ebx                    ;
            inc cl     ; inc digit counter
        .ENDW

        mov postpoint, eax

    round:
        finit                        ; Initialize FPU

        fild dword ptr postpoint 

        .IF(cl == 1)
            mov eax, 10
        .ELSEIF(cl == 2)
            mov eax, 100
        .ELSEIF(cl == 3)
            mov eax, 1000
        .ELSEIF(cl == 4)
            mov eax, 10000
        .ELSEIF(cl == 5)
            mov eax, 100000
        .ELSEIF(cl == 6)
            mov eax, 1000000
        .ELSEIF(cl == 7)
            mov eax, 10000000
        .ELSEIF(cl == 8)
            mov eax, 100000000
        .ELSEIF(cl == 9)
            mov eax, 1000000000
        .ENDIF

        mov floatPass, eax
        fidiv floatPass  ; divide by appropriate power of 10
        fiadd prepoint

        .if( precision == 1)
            mov eax, 10
        .elseif(precision == 2)
            mov eax, 100
        .elseif(precision == 3)
            mov eax, 1000
        .elseif(precision == 4)
            mov eax, 10000
        .endif

        mov floatPass, eax
        fimul floatPass  ; multiply by apropriate power of 10

        fistp dword ptr floatPass ; pop to floatPass
        fild dword ptr floatPass ; push to floatPass

        mov floatPass, eax ; move multiplier to floatPass
        fidiv floatPass  ; divide by appropriate power of 10

    displayvals:
        lea edx, roundedNumberScientific
        call WriteString

        call writeFloat
        call Crlf

        fimul floatPass  ; multiply by apropriate power of 10

        FBSTP tbyte ptr bcdOut ; pop to floatPass

        ; mov eax, precision
        ; inc eax
        ; mov precision, eax


        lea edx, bcdOut
        mov ecx, edx
        add ecx, 10

        xor eax, eax ; eax will hold the BDC value
        xor esi, esi  ; esi will be the digit counter
        lea edi, decimalOutput ; edi will hold the decimal output

        .while edx < ecx
            mov al, byte ptr [edx]
            and al, 0Fh ; isolate low nibble
            add al, '0' ; convert to ASCII
            mov byte ptr [edi+esi], al
            inc esi

            .if(precision == esi)
                mov al, '.'
                mov byte ptr [edi+esi], al
                inc esi
            .endif

            mov al, byte ptr [edx]
            shr al, 4 ; isolate high nibble
            add al, '0' ; convert to ASCII
            mov byte ptr [edi+esi], al
            inc esi

            .if(precision == esi)
                mov al, '.'
                mov byte ptr [edi+esi], al
                inc esi
            .endif
            
            inc edx
        .endw

        lea edx, roundedNumberDecimal
        call WriteString

        .while(esi > 0 )
            dec esi
            mov al, byte ptr [edi+esi]
            call WriteChar        
        .endw

        call Crlf
        call Crlf
        call divider

    askRepeat:
        lea edx, repeatPrompt
        call WriteString

        call ReadChar
        .if(al == 'y' || al == 'Y')
            call Clrscr
            JMP floatPrompt
        .ELSEIF (al == 'n' || al == 'N')
            invoke ExitProcess, 0           ; Exit program with code 0
        .ELSE
            JMP askRepeat
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
