; **********************************************************************;
; Program Name:   Float Rounder Program (floatRounder.asm)              ;
; Program Description: Rounds a floating-point number to specified      ;
;                      decimal places, with display in scientific       ;
;                      and decimal notation.                            ;
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


.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description: Main procedure for handling user input, rounding float,  ;
;              and displaying output in scientific and decimal formats. ;
; Input:       User inputs a floating-point number and rounding         ;
;              precision.                                               ;
; Output:      Rounded float displayed in both scientific and decimal   ;
;              formats.                                                 ;
; Memory Usage: Uses all the values in the .data section for storage,   ;
;               and passing values to and from the FPU                  ;
; Register Usage:                                                       ;
; EAX -
; **********************************************************************;

main PROC

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
