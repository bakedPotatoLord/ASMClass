;============================================================
; Author: Josiah Hamm @bakedpotatoLord
; Title: String Reversal Program
; Course: CSC2025X01 Computer Architecture/Assembly Language
; Date: 09/17/2024
; Description: This program copies a string from source to 
;              target and reverses the character order using 
;              a loop and indirect addressing.
;============================================================

.386                              ; Specify 32-bit code
.model flat,stdcall                ; Flat memory model with standard calling conventions
.stack 4096                        ; Allocate 4 KB of stack space
ExitProcess proto,dwExitCode:dword ; Prototype for ExitProcess from Windows API

.data
source BYTE "This is the source string", 0  ; Null-terminated source string
target BYTE SIZEOF source DUP('#')          ; Target string initialized with '#', same size as source

.code
main proc
    ;===========================
    ; Registers:
    ; EAX - Points to the current character at the start of the source string
    ; EBX - Points to the current character at the end of the source string
    ; EDI - Points to the current position in the target string (start)
    ; ESI - Points to the current position in the target string (end)
    ; CL  - Used to store the current character being copied
    ;===========================

    mov eax, OFFSET source                  ; EAX points to the start of the source string
    mov ebx, OFFSET source                  ; EBX points to the start of the source string
    add ebx, SIZEOF source - TYPE source    ; EBX points to the last character in the source string

    mov edi, OFFSET target                  ; EDI points to the start of the target string
    mov esi, OFFSET target                  ; ESI points to the start of the target string
    add esi, SIZEOF target - TYPE target    ; ESI points to the last character in the target string

lp:
    cmp eax, ebx                            ; Compare the pointers (EAX and EBX)
    jge endprgm                             ; If EAX >= EBX, end the loop

    mov cl, [eax]                           ; Move the character at EAX (source start) to CL
    mov [esi], cl                           ; Move the character in CL to the target end (ESI)

    mov cl, [ebx]                           ; Move the character at EBX (source end) to CL
    mov [edi], cl                           ; Move the character in CL to the target start (EDI)

    add eax, TYPE source                    ; Move EAX to the next character from the start
    sub ebx, TYPE source                    ; Move EBX to the previous character from the end

    add edi, TYPE source                    ; Move EDI to the next position in the target (start)
    sub esi, TYPE source                    ; Move ESI to the previous position in the target (end)

    jmp lp                                  ; Repeat the loop

endprgm:
    invoke ExitProcess, 0                   ; Exit the program
main endp
end main
