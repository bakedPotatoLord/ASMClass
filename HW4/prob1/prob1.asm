;============================================================
; Author: Josiah Hamm @bakedpotatoLord
; Title: Basic Arithmetic Test
; Course: CSC2025X01 Computer Architecture/Assembly Language
; Date: 09/13/2024
; Description: This program calculates the result of the 
;              expression (VarA + VarB) - (VarC + VarD) 
;              using MASM x86 Assembly Language.
;============================================================

.386                              ; Specify 32-bit code
.model flat,stdcall                ; Flat memory model with standard calling conventions
.stack 4096                        ; Allocate 4 KB of stack space
ExitProcess proto,dwExitCode:dword ; Prototype for ExitProcess from Windows API

.data
array dword 0, 2, 5, 9, 10, 15, 17, 23, 25, 25
arrLength dword 10

result dword ?

.code
main proc

    mov eax, 0 ;reset accumulator

    mov ecx, 0

    ADDGAP:
    mov ebx, [array+ecx*4]
    inc ecx;
    mov edx, [array+ecx*4]

    sub edx, ebx
    add eax, edx
    
    

    cmp ecx, 9
    jne ADDGAP

mov result, eax

    invoke ExitProcess, 0          ; Exit the program
main endp
end main
