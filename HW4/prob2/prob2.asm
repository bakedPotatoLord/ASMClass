;============================================================
; Author: Josiah Hamm @bakedpotatoLord
; Title: Array Reversal Program
; Course: CSC2025X01 Computer Architecture/Assembly Language
; Date: 09/17/2024
; Description: This program reverses the elements of an integer 
;              array in place using a loop with indexed addressing.
;              The array size and type are flexible using SIZEOF, 
;              TYPE, and LENGTHOF operators.
;============================================================

.386                               ; Specify 32-bit code
.model flat,stdcall                ; Flat memory model with standard calling conventions
.stack 4096                        ; Allocate 4 KB of stack space
ExitProcess proto,dwExitCode:dword ; Prototype for ExitProcess from Windows API

.data
array dword 0, 2, 5, 9, 10, 15, 17, 23, 25, 25  ; 10-element array of doublewords

.code
main proc
    ;===========================
    ; Registers:
    ; EAX - Points to the current element from the start of the array
    ; EBX - Points to the current element from the end of the array
    ;===========================

    mov eax, OFFSET array                   ; EAX points to the start of the array (first element)
    mov ebx, OFFSET array                   ; EBX points to the start of the array
    add ebx, SIZEOF array - TYPE array      ; EBX points to the last element of the array

lp:
    ; Swap the elements at EAX and EBX
    PUSH [ebx]                              ; Save the value at EBX onto the stack
    PUSH [eax]                              ; Save the value at EAX onto the stack
    POP [ebx]                               ; Pop the value at EAX into EBX (swap)
    POP [eax]                               ; Pop the value at EBX into EAX (swap)

    add eax, TYPE array                     ; Move EAX to the next element from the start
    sub ebx, TYPE array                     ; Move EBX to the previous element from the end

    cmp eax, ebx                            ; Compare the two pointers (EAX and EBX)
    jle lp                                  ; If EAX <= EBX, continue the loop (otherwise, stop)

    invoke ExitProcess, 0                   ; Exit the program
main endp
end main
