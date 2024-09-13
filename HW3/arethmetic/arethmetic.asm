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
varA dword 8                       ; Variable A initialized to 8
varB dword 2                       ; Variable B initialized to 2
varC dword 1                       ; Variable C initialized to 1
varD dword 4                       ; Variable D initialized to 4

result dword ?                     ; Placeholder for the result of the expression

.code
main proc
    ;===========================
    ; Registers:
    ; EAX - Holds the sum of VarA and VarB
    ; EBX - Temporarily holds VarB
    ; ECX - Holds the sum of VarC and VarD
    ; EDX - Temporarily holds VarD
    ;===========================

    mov eax, varA                  ; Move VarA into EAX
    mov ebx, varB                  ; Move VarB into EBX
    add eax, ebx                   ; EAX = VarA + VarB

    mov ecx, varC                  ; Move VarC into ECX
    mov edx, varD                  ; Move VarD into EDX
    add ecx, edx                   ; ECX = VarC + VarD

    sub eax, ecx                   ; EAX = (VarA + VarB) - (VarC + VarD)

    mov result, eax                ; Store the result in the 'result' variable

    invoke ExitProcess, 0          ; Exit the program
main endp
end main
