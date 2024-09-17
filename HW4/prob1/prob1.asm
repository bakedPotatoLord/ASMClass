;============================================================
; Author: Josiah Hamm @bakedpotatoLord
; Title: Gap Sum Calculator
; Course: CSC2025X01 Computer Architecture/Assembly Language
; Date: 09/17/2024
; Description: This program calculates the sum of gaps between
;              successive elements in a 10-element array of 
;              integers arranged in non-decreasing order. 
;              The result is stored in a memory location.
;============================================================

.386                               ; Specify 32-bit code
.model flat,stdcall                ; Flat memory model with standard calling conventions
.stack 4096                        ; Allocate 4 KB of stack space
ExitProcess proto,dwExitCode:dword ; Prototype for ExitProcess from Windows API

.data
array dword 0, 2, 5, 9, 10, 15, 17, 23, 25, 25  ; 10-element array in non-decreasing order
arrLength dword 10                              ; Array length set to 10
result dword ?                                  ; Variable to store the sum of the gaps

.code
main proc
    ;===========================
    ; Registers:
    ; EAX - Accumulator for the sum of gaps
    ; EBX - Holds the current array element
    ; ECX - Loop counter (index for the array)
    ; EDX - Holds the next array element
    ;===========================

    mov eax, 0                  ; Reset EAX (accumulator for sum of gaps)
    mov ecx, 0                  ; Initialize loop counter (ECX) to 0

ADDGAP:
    mov ebx, [array + ecx*4]    ; Load current array element into EBX
    inc ecx                     ; Increment ECX to point to the next element
    mov edx, [array + ecx*4]    ; Load next array element into EDX

    sub edx, ebx                ; Calculate the gap between current and next element
    add eax, edx                ; Add the gap to EAX (accumulator)

    cmp ecx, 9                  ; Check if we have processed the 9th index (last valid gap)
    jne ADDGAP                  ; If not, continue the loop

    mov result, eax             ; Store the result (sum of gaps) in the 'result' variable

    invoke ExitProcess, 0       ; Exit the program
main endp
end main
