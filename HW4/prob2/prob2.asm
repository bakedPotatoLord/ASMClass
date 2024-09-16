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
array dword 0,1,2,3,4,5,6,7,8,9

result dword ?

.code
main proc

mov eax, SIZEOF array 
mov ebx, TYPE array[0]

mov ecx,0

lp:


cmp ecx, (eax /ebx)
jne lp


    invoke ExitProcess, 0          ; Exit the program
main endp
end main
