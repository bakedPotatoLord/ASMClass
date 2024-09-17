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

.code
main proc
    mov esi, OFFSET array         
    mov edi, OFFSET array          
    add edi, SIZEOF array - TYPE array 

    
reverse_loop:
    cmp esi, edi                    
    jge done_reversing              

    mov eax, [esi]                  
    mov ebx, [edi]                  
    mov [esi], ebx                  
    mov [edi], eax                  

    add esi, TYPE array             
    sub edi, TYPE array             

    jmp reverse_loop                

done_reversing:
    invoke ExitProcess, 0           
main endp
end main
