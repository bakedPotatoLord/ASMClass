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
source dword 1,2,3,4,5



.code
main proc

mov ecx, 0

lp:

    PUSH [source+ecx]
    PUSH [source+ecx+ TYPE source]
    POP [source+ecx]
    POP [source+ecx+ TYPE source]

    add ecx, TYPE source *2
    

    cmp ecx, (SIZEOF source - TYPE source)
    jl lp


invoke ExitProcess, 0  
        
main endp
end main
