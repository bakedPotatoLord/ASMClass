; **********************************************************************;
; Program Name:   Time Conversion Program (TimeConversion.asm)          ;
; Program Description: This program prompts the user for hours, minutes ;
;                      and seconds, computes the total time in minutes  ;
;                      and seconds, and provides an option to repeat.   ;
; Author:          Josiah Hamm                                          ;
; Course Number:   CSC2025X01 - Computer Architecture/Assembly Language ;
; Date:            9/24/2024                                            ;
; Revisions:       None                                                 ;
; Date Last Modified: 9/24/2024                                         ;
;***********************************************************************;

INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

.data
hrsPrompt BYTE "Enter the number of hours: ", 0
minsPrompt BYTE "Enter the number of minutes: ", 0
secsPrompt BYTE "Enter the number of seconds: ", 0

hrsConfirm BYTE "The number of hours entered was ", 0
minConfirm BYTE "The number of minutes entered was ", 0
secConfirm BYTE "The number of seconds entered was ", 0

totalMins1 BYTE "The total number of minutes is ", 0
totalMins2 BYTE " minutes.", 0

totalSecs1 BYTE "The total number of seconds is ", 0
totalSecs2 BYTE " seconds.", 0

tryagain BYTE "Try again (y/n)? ", 0

.code

; **********************************************************************;
; Main Procedure                                                        ;
; Description: This procedure prompts the user to input hours, minutes, ;
;              and seconds, computes total time in minutes and seconds, ;
;              and outputs the result. The user is given an option to   ;
;              repeat the program.                                      ;
; Input:       Hours, minutes, and seconds entered by the user          ;
; Output:      Total minutes and seconds, original input values         ;
; Registers:   ESI (stores hours), EDI (stores minutes), EBX (stores    ;
;              seconds), EAX (stores temporary values), ECX (for division);
;              EDX (stores strings for WriteString)                     ;
; Memory:      No additional memory usage                               ;
; **********************************************************************;

main PROC

START:
    mov edx, OFFSET hrsPrompt         ; Load hours prompt message
    call WriteString                  ; Display the hours prompt
    call ReadInt                      ; Read user input into EAX
    mov esi, eax                      ; Store hours in ESI

    mov edx, OFFSET minsPrompt        ; Load minutes prompt message
    call WriteString                  ; Display the minutes prompt
    call ReadInt                      ; Read user input into EAX
    mov edi, eax                      ; Store minutes in EDI

    mov edx, OFFSET secsPrompt        ; Load seconds prompt message
    call WriteString                  ; Display the seconds prompt
    call ReadInt                      ; Read user input into EAX
    mov ebx, eax                      ; Store seconds in EBX

    call Crlf                         ; Print a newline for better formatting

    mov edx, OFFSET hrsConfirm        ; Load hours confirmation message
    call WriteString                  ; Display confirmation message
    mov eax, esi                      ; Move hours from ESI to EAX for printing
    call WriteInt                     ; Display the entered hours
    call Crlf                         ; Newline for formatting

    mov edx, OFFSET minConfirm        ; Load minutes confirmation message
    call WriteString                  ; Display confirmation message
    mov eax, edi                      ; Move minutes from EDI to EAX for printing
    call WriteInt                     ; Display the entered minutes
    call Crlf                         ; Newline for formatting

    mov edx, OFFSET secConfirm        ; Load seconds confirmation message
    call WriteString                  ; Display confirmation message
    mov eax, ebx                      ; Move seconds from EBX to EAX for printing
    call WriteInt                     ; Display the entered seconds
    call Crlf                         ; Newline for formatting

    call Crlf                         ; Additional newline for spacing

    xor edx, edx                      ; Clear EDX before division
    mov eax, ebx                      ; Move seconds to EAX for division
    mov ecx, 60                       ; Set divisor to 60 (seconds per minute)
    div ecx                           ; Divide seconds by 60, result in EAX (minutes), remainder in EDX
    mov ebx, edx                      ; Store remaining seconds in EBX

    imul esi, 60                      ; Convert hours to minutes by multiplying by 60
    add edi, esi                      ; Add the converted hours (in minutes) to minutes
    add edi, eax                      ; Add the divided seconds (now in minutes) to total minutes

    mov eax, edi                      ; Move total minutes to EAX for output

    mov edx, OFFSET totalMins1        ; Load total minutes message
    call WriteString                  ; Display the message
    call WriteInt                     ; Display total minutes
    mov edx, OFFSET totalMins2        ; Load "minutes" string
    call WriteString                  ; Display "minutes"
    call Crlf                         ; Newline for formatting

    imul eax, 60                      ; Convert total minutes to seconds
    add eax, ebx                      ; Add the remaining seconds

    mov edx, OFFSET totalSecs1        ; Load total seconds message
    call WriteString                  ; Display the message
    call WriteInt                     ; Display total seconds
    mov edx, OFFSET totalSecs2        ; Load "seconds" string
    call WriteString                  ; Display "seconds"
    call Crlf                         ; Newline for formatting

ASK_TRY_AGAIN:                        ; Ask user if they want to repeat the program
    call Crlf                         ; Newline for formatting
    mov edx, OFFSET tryagain          ; Load try again message
    call WriteString                  ; Display try again prompt
    call ReadChar                     ; Read user response

    .IF al == 'y' || al == 'Y'        ; If user enters 'y' or 'Y', repeat
        call Crlf                     ; Newline for spacing
        JMP START                     ; Jump back to START label
    .ENDIF

    INVOKE ExitProcess, 0             ; Exit the program with status 0

main ENDP

END main
