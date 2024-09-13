;============================================================
; Author: Josiah Hamm @bakedpotatoLord
; Title: Fibonacci Sequence Generator (First 26 values)
; Course: CSC2025X01 Computer Architecture/Assembly Language
; Date: 09/13/2024
; Description: This program generates the first 26 Fibonacci 
;              numbers and stores them in an array using MASM 
;              x86 Assembly Language.
;============================================================

.386                            ; Specify 32-bit code
.model flat,stdcall              ; Flat memory model with standard calling conventions
.stack 4096                      ; Allocate 4 KB of stack space
ExitProcess proto,dwExitCode:dword ; Prototype for ExitProcess from Windows API

.data
fibArray DWORD 26 DUP(0)         ; Array to store the first 26 Fibonacci numbers, initialized to 0

.code
main proc
    ;===========================
    ; Registers:
    ; EAX - Holds current Fibonacci number (F(n))
    ; EBX - Holds next Fibonacci number (F(n+1))
    ; ECX - Loop counter (used to store index)
    ; EDX - Temporary register to store previous Fibonacci number (F(n-1))
    ;===========================

    mov eax, 0                    ; Initialize EAX to the first Fibonacci number (F(0) = 0)
    mov ebx, 1                    ; Initialize EBX to the second Fibonacci number (F(1) = 1)
    mov ecx, 0                    ; Set ECX to 0 (index for fibArray)

loop_label:
    mov  [fibArray + ecx * 4], eax ; Store the current Fibonacci number in fibArray[ecx]

    mov edx, eax                   ; Copy current Fibonacci number (F(n)) to EDX
    add edx, ebx                   ; Calculate the next Fibonacci number (F(n+1) = F(n) + F(n-1))
    mov eax, ebx                   ; Update EAX to hold F(n+1)
    mov ebx, edx                   ; Update EBX to hold F(n+2)

    inc ecx                        ; Increment ECX to point to the next index in the array
    cmp ecx, 26                    ; Check if we have generated 26 numbers
    jne loop_label                 ; If not, repeat the loop

    invoke ExitProcess, 0          ; Exit the program
main endp
end main
