;============================================================
; Author: Josiah Hamm @bakedpotatoLord
; Title: Array Pair Exchange Program
; Course: CSC2025X01 Computer Architecture/Assembly Language
; Date: 09/17/2024
; Description: This program exchanges every pair of values in
;              an array with an even number of elements. Each
;              item i is swapped with item i + 1, item i + 2 
;              with i + 3, and so on, using a loop and indexed
;              addressing.
;============================================================

.386                              ; Specify 32-bit code
.model flat,stdcall                ; Flat memory model with standard calling conventions
.stack 4096                        ; Allocate 4 KB of stack space
ExitProcess proto,dwExitCode:dword ; Prototype for ExitProcess from Windows API

.data
source dword 1, 2, 3, 4, 5, 6, 7, 8  ; Array of even length (8 elements)

.code
main proc
    ;===========================
    ; Registers:
    ; ECX - Index for accessing the array elements
    ;===========================

    mov ecx, 0                             ; Initialize ECX (array index) to 0

lp:
    PUSH [source + ecx]                    ; Push the value at source[ecx] onto the stack
    PUSH [source + ecx + TYPE source]      ; Push the value at source[ecx + 1] onto the stack
    POP  [source + ecx]                    ; Pop the value at source[ecx + 1] into source[ecx]
    POP  [source + ecx + TYPE source]      ; Pop the value at source[ecx] into source[ecx + 1]

    add ecx, TYPE source * 2               ; Move to the next pair (i + 2 and i + 3)

    cmp ecx, SIZEOF source - TYPE source   ; Check if ECX has reached the end of the array
    jl lp                                  ; If not, repeat the loop

    invoke ExitProcess, 0                  ; Exit the program
main endp
end main
