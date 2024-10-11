; **********************************************************************;
; Program Name:   String Compression Program (StringCompression.asm)    ;
; Program Description: This program prompts the user for a string       ;
;                      (maximum of 100 characters), removes all         ;
;                      non-alphabetical characters, and displays the    ;
;                      compressed string. The program also provides an  ;
;                      option to repeat the process.                    ;
; Author:          Josiah Hamm                                           ;
; Course Number:   CSC2025X01 - Computer Architecture/Assembly Language  ;
; Date:            10/4/2024                                             ;
; Revisions:       None                                                  ;
; Date Last Modified: 10/4/2024                                          ;
; **********************************************************************;

INCLUDE C:\Irvine\Irvine32.inc          ; Include Irvine32 library for basic I/O operations
INCLUDELIB C:\Irvine\Irvine32.lib       ; Link Irvine32 library

.data
    promptInput dd 25  DUP(0)
    oddValues dd 25  DUP(0)
    evenValues dd 25  DUP(0)

    numberPromptDisplay db "Enter an array of non-negative integers with a maximum lenth of 25.",13,10,
    "Any unused spaces will be assigned sequential values starting with 1 ",13,10,
    "Press enter between each number. Enter a negative value to end your input.", 0

    minValueDisplay db "The minimum value is: ", 0
    maxValueDisplay db "The maximum value is: ", 0
    averageValueDisplay db "The average value is: ", 0
    remainderValueDisplay db "The remainder value is: ", 0

    sortedEvensDisplay db "The sorted even values are: ", 0
    sortedOddsDisplay db "The sorted odd values are: ", 0

    tryagainDisplay db "Would you like to enter a new string (y/n)", 0 ; Prompt for asking if the user wants to try again
    dividerDisplay db "----------------------------------------",13,10, 0
    malformedInputDisplay db "Malformed input. Please try again.", 0

.code

; **********************************************************************;
; Main Procedure                                                        ;

; **********************************************************************;

main PROC
    progStart:


        lea edx, numberPromptDisplay
        call WriteString
        call Crlf

        mov ecx, 0
        lea edx, promptInput
    getInput:

        call ReadInt
        JO malformedInput

        cmp eax, 0
        jl fillSequential

        
        mov [edx+ecx*4], eax
        inc ecx

        .IF( ecx == 25)
            call arrayOps
            JMP ask_try_again
        .ENDIF


        jmp getInput


        fillSequential:
            ;TODO
            mov eax, 1

            fillLoop:
                mov [edx+ecx*4], eax
                inc eax
                inc ecx
                cmp ecx, 25
                jl fillLoop

            call arrayOps
            JMP ask_try_again

        malformedInput:
            lea edx, malformedInputDisplay
            call WriteString
            call Crlf
            jmp progStart


    ask_try_again:
        lea edx, tryagainDisplay            ; Load the try again prompt message
        call WriteString                    ; Display the prompt
        call ReadChar                       ; Read the user's response (single character)
        .IF al == 'y' || al == 'Y'          ; If the user enters 'y' or 'Y', repeat the process
            call Crlf                           ; Newline for formatting
            call Crlf                           ; Newline for formatting
            JMP progStart  
        .ENDIF

        INVOKE ExitProcess, 0               ; Exit the program with status 0

    main ENDP

arrayOps PROC uses eax ebx ecx edx esi edi
    call minMaxSearch
    call findAverage
    call getEvens
    call getOdds
    ret
    arrayOps ENDP

minMaxSearch PROC uses eax ebx ecx edx esi edi


    lea edx, promptInput

    mov ecx, 1
    mov esi, [edx] ; max
    mov edi, [edx] ; min

    searchLoop:
        mov ebx, [edx+ecx*4]

        .IF(ebx > edi)
            mov edi, ebx
        .ENDIF
        .IF(ebx < esi)
            mov esi, ebx
        .ENDIF

        inc ecx
        cmp ecx, 25
        jl searchLoop
    displayValues:
        call divider
        lea edx, minValueDisplay
        call WriteString
        mov eax, esi
        call WriteInt
        call Crlf

        lea edx, maxValueDisplay
        call WriteString
        mov eax, edi
        call WriteInt
        call Crlf

        ret
    minMaxSearch ENDP


findAverage PROC uses eax ebx ecx edx esi edi
    xor eax, eax
    mov ecx, 1

    addToSum:
        add eax, [edx+ecx*4]
        inc ecx
        .IF( ecx < 25) 
        JMP addToSum
        .ENDIF

    divide:

        mov ebx, 25
        xor edx, edx
        xor ecx, ecx
        div ebx

    outputResults:

        call divider

        lea edx, averageValueDisplay
        call WriteString
        mov ebx, eax
        call WriteInt
        call Crlf

        lea edx, remainderValueDisplay
        call WriteString
        mov ecx, eax
        call WriteInt
        call Crlf

    ret
    findAverage ENDP

getEvens PROC uses eax ebx ecx edx edi esi
    
    lea edx, promptInput
    mov ecx, 0 ;;prompt index

    lea ebx, evenValues
    mov edi, 0 ;;even index

    traverseLoop:
        mov eax, [edx+ecx*4]
        mov esi, eax
        and esi, 1
        .IF(esi == 0)
            mov [ebx+edi*4], eax
            inc edi
        .ENDIF

        inc ecx

        cmp ecx, 25
        jl traverseLoop

    mov eax, edi

    call sortArray

    call divider

    lea edx, sortedEvensDisplay
    call WriteString
    call Crlf

    mov ecx, 0
    displayLoop:
        mov eax, [ebx+ecx*4]
        call WriteInt
        mov al, ' '
        call WriteChar
        inc ecx
        cmp ecx, edi
        jl displayLoop

    call Crlf
        


    ret
    getEvens ENDP


getOdds PROC

    ret
    getOdds ENDP

; takes array ref in ebx
;takes number of elements in eax
; sorts array in place
sortArray PROC uses ecx edx esi edi

    mov ecx,0 ; main index
    mov edx, 0 ; temp index

    ; EBX : array ref
    ; EAX : number of elements

    .WHILE(ecx < eax)
    mov esi, (ebx+ecx*4) ; base loop min
        .WHILE(edx < eax)
            .IF([[ebx+edx*4]] < [esi])
                mov esi, (ebx+edx*4)
            .ENDIF
            inc edx
        .ENDW
    
    
    

    inc ecx
    .ENDW

    ret
    sortArray ENDP


divider PROC uses edx
    lea edx, dividerDisplay
    call WriteString
    ret
    divider ENDP 


END main
