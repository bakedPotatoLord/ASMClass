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
source BYTE "This is the source string",0
target BYTE SIZEOF source DUP('#')


.code
main proc

mov eax, OFFSET source ; front of source
mov ebx, OFFSET source ; back of source
add ebx, SIZEOF source - TYPE source

mov edi, OFFSET target ; front of target
mov esi, OFFSET target ; back of target
add esi, SIZEOF target - TYPE target


lp:

    cmp eax, ebx
    jge endprgm

    mov cl, [eax]
    mov [esi], cl

    mov cl, [ebx]
    mov [edi], cl

    add eax, TYPE source
    sub ebx, TYPE source

    add edi, TYPE source
    sub esi, TYPE source
    jmp lp



endprgm:
    invoke ExitProcess, 0  
        
main endp
end main
