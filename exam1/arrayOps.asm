; **********************************************************************;
; Author:          Josiah Hamm                                           ;
; Course Number:   CSC2025X01 - Computer Architecture/Assembly Language  ;
; Program Title:   String Compression Program (StringCompression.asm)    ;
; Date:            10/4/2024                                             ;
; Revisions:       None                                                  ;
; Date Last Modified: 10/4/2024                                          ;
; **********************************************************************;

INCLUDE C:\Irvine\Irvine32.inc          ; Include Irvine32 library for basic I/O operations
INCLUDELIB C:\Irvine\Irvine32.lib       ; Link Irvine32 library

.data
    promptInput dd 25  DUP(0)           ; Buffer to store user input array (25 integers)
    oddValues dd 25  DUP(0)             ; Array to store odd values
    evenValues dd 25  DUP(0)            ; Array to store even values

    numberPromptDisplay db "Enter an array of non-negative integers with a maximum lenth of 25.",13,10,
    "Any unused spaces will be assigned sequential values starting with 1.",13,10,
    "Empty numbers will be assigned a value of 0.", 13,10,
    "Press enter between each number. Enter a negative value to end your input.", 0 ; Prompt message for user input

    minValueDisplay db "The minimum value is: ", 0               ; Message to display minimum value
    maxValueDisplay db "The maximum value is: ", 0               ; Message to display maximum value
    averageValueDisplay db "The average value is: ", 0           ; Message to display average value
    remainderValueDisplay db "The remainder value is: ", 0       ; Message to display remainder after average calculation

    sortedEvensDisplay db "The sorted even values are: ", 0       ; Message to display sorted even values
    sortedOddsDisplay db "The sorted odd values are: ", 0         ; Message to display sorted odd values

    tryagainDisplay db "Would you like to enter a new string (y/n)", 0 ; Prompt to ask user to retry
    dividerDisplay db "----------------------------------------",13,10, 0 ; Divider line for output separation
    malformedInputDisplay db "Malformed input. Please try again.", 0 ; Error message for invalid input

.code

; **********************************************************************;
; Main Procedure                                                        ;
; 
; Description:
;   - Prompts the user to enter up to 25 non-negative integers.
;   - If fewer than 25 integers are entered, assigns sequential values starting from 1.
;   - Handles malformed input by prompting the user to re-enter.
;   - Calls array operations to process the input array.
;   - Provides an option to repeat the program or exit.
;
; Inputs:
;   - User input via console.
;
; Outputs:
;   - Displays prompts, results, and messages to the console.
;
; Memory Usage:
;   - Uses data segments: promptInput, oddValues, evenValues, and various display messages.
;
; Register Usage:
;   - EAX, EBX, ECX, EDX, ESI, EDI used for general purposes and procedure calls.
;
; Functional Description:
;   - Handles user input, populates the array, manages default values, and orchestrates
;     subsequent array operations.
; **********************************************************************;

main PROC
    progStart:                            ; Label to mark the start of the program loop

        lea edx, numberPromptDisplay      ; Load address of the input prompt message into EDX
        call WriteString                  ; Call Irvine32 procedure to write the prompt string
        call Crlf                         ; Call Irvine32 procedure to move to a new line

        mov ecx, 0                        ; Initialize counter ECX to 0
        lea edx, promptInput              ; Load address of promptInput buffer into EDX

    getInput:
        call ReadInt                      ; Read integer input from the user
        JO malformedInput                 ; Jump to error handling if overflow occurs

        cmp eax, 0                        ; Compare the input value with 0
        jl fillSequential                 ; If input is negative, jump to fillSequential

        mov [edx+ecx*4], eax              ; Store the input value in the array at index ECX
        inc ecx                           ; Increment the counter ECX

        .IF( ecx == 25)                   ; Check if 25 elements have been entered
            call arrayOps                  ; Call array operations procedure
            JMP ask_try_again              ; Jump to the retry prompt
        .ENDIF

        jmp getInput                      ; Repeat the input loop

    fillSequential:
        ; Assign sequential values starting from 1 to remaining array elements
        mov eax, 1                        ; Initialize EAX with 1

    fillLoop:
        mov [edx+ecx*4], eax              ; Assign current value of EAX to the array
        inc eax                           ; Increment EAX for the next sequential value
        inc ecx                           ; Increment the counter ECX
        cmp ecx, 25                       ; Compare ECX with 25
        jl fillLoop                       ; If less than 25, continue filling

        call arrayOps                      ; Call array operations procedure
        JMP ask_try_again                  ; Jump to the retry prompt

    malformedInput:
        call Crlf                         ; Move to a new line
        call divider                      ; Call divider procedure for separation
        lea edx, malformedInputDisplay    ; Load address of malformed input message
        call WriteString                  ; Display the error message
        call Crlf                         ; Move to a new line
        call Crlf                         ; Move to another new line for spacing
        call divider                      ; Call divider procedure again
        jmp progStart                     ; Jump back to the start of the program loop

    ask_try_again:
        lea edx, tryagainDisplay          ; Load address of the retry prompt message
        call WriteString                  ; Display the retry prompt
        call ReadChar                     ; Read a single character input from the user

        .IF al == 'y' || al == 'Y'        ; Check if the user entered 'y' or 'Y'
            call Crlf                     ; Move to a new line for formatting
            call Crlf                     ; Move to another new line for spacing
            JMP progStart                 ; Jump back to the start of the program loop
        .ENDIF

        INVOKE ExitProcess, 0             ; Exit the program with status code 0

    main ENDP

; **********************************************************************;
; arrayOps Procedure                                                    ;
; 
; Description:
;   - Calls procedures to perform various array operations:
;     - Find minimum and maximum values.
;     - Calculate and display the average.
;     - Extract and sort even and odd values.
;     - Display a divider for output separation.
;
; Inputs:
;   - None directly; operates on the promptInput array.
;
; Outputs:
;   - Displays results of array operations to the console.
;
; Memory Usage:
;   - Utilizes promptInput, oddValues, evenValues arrays.
;
; Register Usage:
;   - Uses EAX, EBX, ECX, EDX, ESI, EDI for procedure calls.
;
; Functional Description:
;   - Orchestrates the sequence of array processing tasks.
; **********************************************************************;

arrayOps PROC uses eax ebx ecx edx esi edi
    call minMaxSearch                   ; Call procedure to find min and max values
    call findAverage                    ; Call procedure to calculate average value
    call getEvens                       ; Call procedure to extract and sort even values
    call getOdds                        ; Call procedure to extract and sort odd values
    call divider                        ; Call divider procedure for output separation
    ret                                 ; Return from arrayOps procedure
arrayOps ENDP

; **********************************************************************;
; minMaxSearch Procedure                                                ;
; 
; Description:
;   - Searches the input array to find the minimum and maximum values.
;   - Displays the found minimum and maximum values with appropriate messages.
;
; Inputs:
;   - promptInput array address in EDX.
;
; Outputs:
;   - Displays minimum and maximum values to the console.
;
; Memory Usage:
;   - Reads from promptInput array.
;
; Register Usage:
;   - Uses EAX, EBX, ECX, EDX, ESI, EDI for processing.
;
; Functional Description:
;   - Iterates through the array to determine min and max values.
; **********************************************************************;

minMaxSearch PROC uses eax ebx ecx edx esi edi
    lea edx, promptInput                ; Load address of the input array into EDX

    mov ecx, 1                           ; Initialize counter ECX to 1
    mov esi, [edx]                       ; Initialize ESI with the first array element (max)
    mov edi, [edx]                       ; Initialize EDI with the first array element (min)

    .WHILE(ecx < 25)                     ; Loop through the array starting from the second element
        mov ebx, [edx+ecx*4]             ; Load current array element into EBX

        .IF(ebx > edi)                   ; If current element is greater than current max
            mov edi, ebx                   ; Update max value in EDI
        .ENDIF

        .IF(ebx < esi)                   ; If current element is less than current min
            mov esi, ebx                   ; Update min value in ESI
        .ENDIF

        inc ecx                           ; Increment counter ECX
    .ENDW

    call divider                          ; Call divider procedure for output separation
    lea edx, minValueDisplay              ; Load address of min value display message
    call WriteString                      ; Display min value message
    mov eax, esi                          ; Move min value into EAX
    call WriteInt                         ; Display the min value
    call Crlf                             ; Move to a new line

    lea edx, maxValueDisplay              ; Load address of max value display message
    call WriteString                      ; Display max value message
    mov eax, edi                          ; Move max value into EAX
    call WriteInt                         ; Display the max value
    call Crlf                             ; Move to a new line

    ret                                   ; Return from minMaxSearch procedure
minMaxSearch ENDP

; **********************************************************************;
; findAverage Procedure                                                 ;
; 
; Description:
;   - Calculates the average of the input array values.
;   - Displays the average and remainder values with appropriate messages.
;
; Inputs:
;   - promptInput array address in EDX.
;
; Outputs:
;   - Displays average and remainder values to the console.
;
; Memory Usage:
;   - Reads from promptInput array.
;
; Register Usage:
;   - Uses EAX, EBX, ECX, EDX, ESI for calculations and output.
;
; Functional Description:
;   - Sums all array elements and divides by 25 to find the average.
; **********************************************************************;

findAverage PROC uses eax ebx ecx edx esi edi
    xor eax, eax                         ; Clear EAX to accumulate the sum
    mov ecx, 0                           ; Initialize counter ECX to 0

    .WHILE(ecx < 25)                     ; Loop through all 25 array elements
        add eax, [edx+ecx*4]             ; Add current array element to EAX
        inc ecx                           ; Increment counter ECX
    .ENDW

divide:
    mov ebx, 25                          ; Move divisor (25) into EBX
    xor edx, edx                         ; Clear EDX before division
    xor ecx, ecx                         ; Clear ECX (not needed here but ensuring)
    div ebx                              ; Divide EAX by EBX; EAX = quotient, EDX = remainder
    mov esi, edx                         ; Move remainder into ESI

outputResults:
    call divider                          ; Call divider procedure for output separation

    lea edx, averageValueDisplay          ; Load address of average value display message
    call WriteString                      ; Display average value message

    mov eax, eax                         ; Quotient already in EAX (average)
    call WriteInt                         ; Display the average value
    call Crlf                             ; Move to a new line

    lea edx, remainderValueDisplay        ; Load address of remainder value display message
    call WriteString                      ; Display remainder value message
    mov eax, esi                          ; Move remainder value into EAX
    call WriteInt                         ; Display the remainder value
    call Crlf                             ; Move to a new line

    ret                                   ; Return from findAverage procedure
findAverage ENDP

; **********************************************************************;
; getEvens Procedure                                                    ;
; 
; Description:
;   - Traverses the input array to find all even values.
;   - Sorts the even values in ascending order.
;   - Displays the sorted even values with an appropriate message.
;
; Inputs:
;   - promptInput array address in EDX.
;
; Outputs:
;   - Displays sorted even values to the console.
;
; Memory Usage:
;   - Stores even values in evenValues array.
;
; Register Usage:
;   - Uses EAX, EBX, ECX, EDX, EDI, ESI for processing and sorting.
;
; Functional Description:
;   - Extracts even numbers, sorts them, and displays the sorted list.
; **********************************************************************;

getEvens PROC uses eax ebx ecx edx edi esi
    lea edx, promptInput                ; Load address of the input array into EDX
    mov ecx, 0                           ; Initialize array index counter ECX to 0

    lea ebx, evenValues                  ; Load address of evenValues array into EBX
    mov edi, 0                           ; Initialize even index counter EDI to 0

    traverseLoop:
        mov eax, [edx+ecx*4]             ; Load current array element into EAX
        mov esi, eax                     ; Move EAX to ESI for bitwise operation
        and esi, 1                       ; Perform bitwise AND with 1 to check odd/even
        .IF(esi == 0)                    ; If the least significant bit is 0, it's even
            mov [ebx+edi*4], eax         ; Store even value in evenValues array
            inc edi                       ; Increment even index counter EDI
        .ENDIF

        inc ecx                           ; Increment array index counter ECX
        cmp ecx, 25                       ; Compare ECX with 25
        jl traverseLoop                   ; If less than 25, continue traversing

    mov eax, edi                          ; Move the number of even elements into EAX

    call sortArray                        ; Call sortArray procedure to sort evenValues

    call divider                          ; Call divider procedure for output separation

    lea edx, sortedEvensDisplay           ; Load address of sorted evens display message
    call WriteString                      ; Display sorted evens message
    call Crlf                             ; Move to a new line

    mov ecx, 0                            ; Initialize display counter ECX to 0
    .WHILE(ecx < edi)                     ; Loop through sorted evenValues array
        mov eax, [ebx+ecx*4]             ; Load even value into EAX
        call WriteInt                     ; Display the even value
        mov al, ' '                       ; Load space character into AL
        call WriteChar                    ; Display space for separation
        inc ecx                           ; Increment display counter ECX
        cmp ecx, edi                      ; Compare ECX with the number of even elements
    .ENDW

    call Crlf                             ; Move to a new line
    ret                                   ; Return from getEvens procedure
getEvens ENDP

; **********************************************************************;
; getOdds Procedure                                                     ;
; 
; Description:
;   - Traverses the input array to find all odd values.
;   - Sorts the odd values in ascending order.
;   - Displays the sorted odd values with an appropriate message.
;
; Inputs:
;   - promptInput array address in EDX.
;
; Outputs:
;   - Displays sorted odd values to the console.
;
; Memory Usage:
;   - Stores odd values in oddValues array.
;
; Register Usage:
;   - Uses EAX, EBX, ECX, EDX, EDI, ESI for processing and sorting.
;
; Functional Description:
;   - Extracts odd numbers, sorts them, and displays the sorted list.
; **********************************************************************;

getOdds PROC
    lea edx, promptInput                ; Load address of the input array into EDX
    mov ecx, 0                           ; Initialize array index counter ECX to 0

    lea ebx, oddValues                   ; Load address of oddValues array into EBX
    mov edi, 0                           ; Initialize odd index counter EDI to 0

    traverseLoop:
        mov eax, [edx+ecx*4]             ; Load current array element into EAX
        mov esi, eax                     ; Move EAX to ESI for bitwise operation
        and esi, 1                       ; Perform bitwise AND with 1 to check odd/even
        .IF(esi == 1)                    ; If the least significant bit is 1, it's odd
            mov [ebx+edi*4], eax         ; Store odd value in oddValues array
            inc edi                       ; Increment odd index counter EDI
        .ENDIF

        inc ecx                           ; Increment array index counter ECX
        cmp ecx, 25                       ; Compare ECX with 25
        jl traverseLoop                   ; If less than 25, continue traversing

    mov eax, edi                          ; Move the number of odd elements into EAX

    call sortArray                        ; Call sortArray procedure to sort oddValues

    call divider                          ; Call divider procedure for output separation

    lea edx, sortedOddsDisplay            ; Load address of sorted odds display message
    call WriteString                      ; Display sorted odds message
    call Crlf                             ; Move to a new line

    mov ecx, 0                            ; Initialize display counter ECX to 0
    .WHILE(ecx < edi)                     ; Loop through sorted oddValues array
        mov eax, [ebx+ecx*4]             ; Load odd value into EAX
        call WriteInt                     ; Display the odd value
        mov al, ' '                       ; Load space character into AL
        call WriteChar                    ; Display space for separation
        inc ecx                           ; Increment display counter ECX
        cmp ecx, edi                      ; Compare ECX with the number of odd elements
    .ENDW

    call Crlf                             ; Move to a new line
    ret                                   ; Return from getOdds procedure
getOdds ENDP

; **********************************************************************;
; sortArray Procedure                                                   ;
; 
; Description:
;   - Sorts an array of integers in ascending order using selection sort.
;   - Operates in-place on the provided array.
;
; Inputs:
;   - EBX: Address of the array to sort.
;   - EAX: Number of elements in the array.
;
; Outputs:
;   - Sorted array in ascending order.
;
; Memory Usage:
;   - Uses the provided array in EBX.
;
; Register Usage:
;   - Uses ECX, EDX, ESI, EDI for sorting logic.
;
; Functional Description:
;   - Implements selection sort by finding the minimum element in the unsorted portion
;     and swapping it with the first unsorted element.
; **********************************************************************;

sortArray PROC uses ecx edx esi edi
    mov esi, 4                          ; Initialize ESI with the size of each element (4 bytes)
    mul esi                             ; Multiply EAX (number of elements) by ESI to get byte offset
    add eax, ebx                        ; Add base address of the array to get the end address
    mov ecx, ebx                        ; Initialize ECX with the base address of the array

    ; EAX : end of array address
    ; EBX : base address of the array
    ; ECX : current index pointer

    .WHILE(ecx < eax)                    ; Loop through each element in the array
        mov esi, ecx                     ; Initialize ESI with the current index (min pointer)

        mov edx, ecx                     ; Initialize EDX with the current index for inner loop
        .WHILE(edx < eax)                ; Inner loop to find the minimum element
            push eax                      ; Save EAX on the stack
            mov eax, [edx]                 ; Load current element into EAX
            .IF([esi] > eax)               ; If current element is less than the current minimum
                mov esi, edx                 ; Update the min pointer to current index
            .ENDIF
            add edx, 4                      ; Move to the next element (4 bytes per integer)
            pop eax                        ; Restore EAX from the stack
        .ENDW

        ; Swap the found minimum element with the current element
        call swap                        ; Call swap procedure to exchange values

        add ecx, 4                        ; Move to the next element in the array
    .ENDW

    ret                                 ; Return from sortArray procedure
sortArray ENDP

; **********************************************************************;
; swap Procedure                                                        ;
; 
; Description:
;   - Swaps the values of two array elements.
;
; Inputs:
;   - ECX: Address of the first element.
;   - ESI: Address of the second element.
;
; Outputs:
;   - The values at ECX and ESI are exchanged.
;
; Memory Usage:
;   - Temporary storage in EBX and EAX.
;
; Register Usage:
;   - Uses EAX and EBX for temporary storage during the swap.
;
; Functional Description:
;   - Exchanges the values pointed to by ECX and ESI.
; **********************************************************************;

swap PROC uses eax ebx 
    mov ebx, [ecx]                       ; Move value at ECX into EBX (temporary storage)
    mov eax, [esi]                       ; Move value at ESI into EAX

    mov [esi], ebx                       ; Move value from EBX into ESI
    mov [ecx], eax                       ; Move value from EAX into ECX

    ret                                   ; Return from swap procedure
swap ENDP

; **********************************************************************;
; divider Procedure                                                     ;
; 
; Description:
;   - Displays a divider line to separate output sections.
;
; Inputs:
;   - None directly; uses the dividerDisplay message.
;
; Outputs:
;   - Displays a divider line to the console.
;
; Memory Usage:
;   - Uses dividerDisplay string.
;
; Register Usage:
;   - Uses EDX for message display.
;
; Functional Description:
;   - Calls WriteString to display the divider line.
; **********************************************************************;

divider PROC uses edx
    lea edx, dividerDisplay             ; Load address of the divider display message into EDX
    call WriteString                     ; Display the divider line
    ret                                  ; Return from divider procedure
divider ENDP 

END main
