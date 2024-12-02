; **********************************************************************;
; Author:          Josiah Hamm     @bakedPotatoLord                     ;
; Course Number:   CSC2025X01 - Computer Architecture/Assembly Language ;
; Program Title:   Blackjack (blackjack.asm)                            ;
; Program Description: 
; Date:            12/1/2024                                           ;
; Revisions:       None                                                 ;
; Date Last Modified: 12/1/2024                                        ;
; **********************************************************************;

INCLUDE C:\Irvine\Irvine32.inc          ; Include Irvine32 library for basic I/O operations
INCLUDELIB C:\Irvine\Irvine32.lib       ; Link Irvine32 library

.data
    Card STRUCT ; Define a structure to represent a card in a deck
        suit db 0 ; The suit of the card (0-3: clubs, diamonds, hearts, spades)
        value db 0 ; The value of the card (1-13: ace is low)
    Card ENDS ; End of Card structure definition

    Hand STRUCT ; Define a structure to represent a player's hand in the game
        cards Card 16 DUP(<>) ; Array of up to 16 cards in the hand
        numcards db 0 ; Number of cards currently in the hand
        numAces db 0 ; Number of aces in the hand for special blackjack rules
    Hand ENDS ; End of Hand structure definition

    Deck STRUCT ; Define a structure to represent a deck of cards
        cards Card 52 DUP(<0,0>) ; Array of 52 cards representing the deck
        top db 0 ; Index of the top card in the deck, acts as a stack pointer
    Deck ENDS ; End of Deck structure definition

    mydeck Deck <> ; Declare a deck variable named mydeck
    playerHand Hand <> ; Declare a hand variable for the player
    dealerHand Hand <> ; Declare a hand variable for the dealer

    cardDisplay DB "Card: ",0 ; Message prefix for displaying a card
    clubsDisplay DB " of Clubs",0 ; String suffix for clubs suit
    diamondsDisplay DB " of Diamonds",0 ; String suffix for diamonds suit
    heartsDisplay DB " of Hearts",0 ; String suffix for hearts suit
    spadesDisplay DB " of Spades",0 ; String suffix for spades suit

    cardCharLUT DB "*A23456789TJQK" ; Lookup table for card ranks (0 = unused, * is a placeholder)
    cardValueLUT DB 0,1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10 ; Lookup table for card values, face cards are 10

    welcomeMessage DB "Welcome to Blackjack!",0 ; Welcome message displayed to the player
    yourHandDisplay DB "Your Hand: ",0 ; Message prefix for displaying the player's hand
    dealersHandDisplay DB "Dealer's Hand: ",0 ; Message prefix for displaying the dealer's hand
    handValueDisplay DB "Hand Value: ",0 ; Message prefix for displaying the value of a hand

    hitStayPrompt DB "Would you like to hit or stay? (h/s): ",0 ; Prompt for the player to decide their next move
    playerBustDisplay DB "You busted!",0 ; Message displayed when the player exceeds 21
    dealerBustDisplay DB "Dealer busted!",0 ; Message displayed when the dealer exceeds 21
    playerWinDisplay DB "You won!",0 ; Message displayed when the player wins
    dealerWinDisplay DB "Dealer won!",0 ; Message displayed when the dealer wins
    tieDisplay DB "It's a tie!",0 ; Message displayed when the game ends in a tie
    tryagainDisplay DB "Would you like to try again? (y/n): ",0 ; Prompt to ask the player if they want to replay
    dividerDisplay DB "------------------------------------",0 ; Divider for better visual separation in output


.code

; **********************************************************************;
; main Procedure                                                        ;
; Description: The entry point for the Blackjack game, managing setup,  ;
;              game loop, player and dealer turns, and results display. ;
; Inputs: None.                                                         ;
; Outputs: Displays game messages and results to the console.           ;
; Memory Usage: Updates player and dealer hands, deck structure.        ;
; Register Usage:                                                       ;
; - EAX: General-purpose use for passing values and procedure calls.    ;
; - EDX: Used for holding addresses of strings to display.              ;
; **********************************************************************;

main PROC
    lea edx, welcomeMessage ; Load the welcome message string address
    call WriteString        ; Display the welcome message
    call Crlf               ; Print a newline

progStart:
    call setupDeck          ; Initialize the deck of cards
    call shuffleDeck        ; Shuffle the deck of cards

    lea eax, playerHand     ; Load the address of the player's hand into EAX
    call dealCard           ; Deal the first card to the player
    call dealCard           ; Deal the second card to the player
    lea edx, yourHandDisplay ; Load the player's hand display message
    call WriteString        ; Display "Your Hand:"
    call Crlf               ; Print a newline
    lea eax, playerHand     ; Load the player's hand address again
    call displayHand        ; Display the player's current hand
    call Crlf               ; Print two newlines
    call Crlf

askHitStay:
    lea edx, hitStayPrompt  ; Load the hit/stay prompt string
    call WriteString        ; Display the hit/stay prompt
    call ReadChar           ; Read the user's input (h/s)
    call writeChar          ; Echo the character back to the console
    call Crlf               ; Print a newline
    .IF(al == 'h')          ; If the user chooses to "hit"
        lea edx, yourHandDisplay ; Load the "Your Hand:" message again
        call WriteString    ; Display the message
        call Crlf           ; Print a newline
        lea eax, playerHand ; Load the player's hand address
        call dealCard       ; Deal another card to the player
        call displayHand    ; Display the updated player's hand
        call Crlf           ; Print two newlines
        call Crlf
    .ELSEIF(al == 's')      ; If the user chooses to "stay"
        jmp dealerTurn      ; Jump to the dealer's turn
    .ELSE                   ; If invalid input
        call Crlf           ; Print a newline
        jmp askHitStay      ; Repeat the hit/stay prompt
    .ENDIF
    lea eax, playerHand     ; Load the player's hand address
    call handValue          ; Calculate the player's hand value
    .IF(eax > 21)           ; If the player busts (hand value > 21)
        jmp bust            ; Jump to the bust logic
    .ELSE                   ; If the player has not busted
        jmp askHitStay      ; Repeat the hit/stay prompt
    .ENDIF

dealerTurn:
    xor eax, eax            ; Clear EAX (used for dealer's hand value)
    .WHILE(eax < 17)        ; Dealer must hit until hand value >= 17
        lea edx, dealersHandDisplay ; Load the "Dealer's Hand:" message
        call WriteString    ; Display the message
        call Crlf           ; Print a newline
        lea eax, dealerHand ; Load the dealer's hand address
        call dealCard       ; Deal a card to the dealer
        call displayHand    ; Display the dealer's hand
        call Crlf           ; Print two newlines
        mov eax, 1000       ; Set a delay of 1000ms
        call Delay          ; Introduce a delay for better game pacing
        lea eax, dealerHand ; Load the dealer's hand address again
        call handValue      ; Calculate the dealer's hand value
    .ENDW
    .IF(eax > 21)           ; If the dealer busts (hand value > 21)
        lea edx, dealerBustDisplay ; Load the dealer bust message
        call WriteString    ; Display the dealer bust message
        call Crlf           ; Print a newline
        mov eax, 0          ; Set dealer's hand value to 0
    .ENDIF
    mov ebx, eax            ; Save the dealer's hand value to EBX
    lea eax, playerHand     ; Load the player's hand address
    call handValue          ; Calculate the player's hand value
    .IF(eax > ebx)          ; If the player wins
        lea edx, playerWinDisplay ; Load the player win message
        call WriteString    ; Display the player win message
        call Crlf           ; Print a newline
    .ELSEIF(ebx > eax)      ; If the dealer wins
        lea edx, dealerWinDisplay ; Load the dealer win message
        call WriteString    ; Display the dealer win message
        call Crlf           ; Print a newline
    .ELSE                   ; If it's a tie
        lea edx, tieDisplay ; Load the tie message
        call WriteString    ; Display the tie message
        call Crlf           ; Print a newline
    .ENDIF
    jmp ask_try_again       ; Ask if the user wants to try again

bust:
    lea edx, playerBustDisplay ; Load the player bust message
    call WriteString        ; Display the player bust message
    call Crlf               ; Print a newline

ask_try_again:
    lea edx, tryagainDisplay ; Load the retry prompt message
    call WriteString        ; Display the retry prompt
    call ReadChar           ; Read the user's input (y/n)
    call writeChar          ; Echo the character back to the console
    call Crlf               ; Print a newline
    .IF (al == 'y' || al == 'Y') ; If the user chooses to retry
        mov playerHand.numcards, 0 ; Reset player's card count
        mov playerHand.numAces, 0  ; Reset player's ace count
        mov dealerHand.numcards, 0 ; Reset dealer's card count
        mov dealerHand.numAces, 0  ; Reset dealer's ace count
        lea edx, dividerDisplay ; Load the divider line message
        call WriteString    ; Display the divider
        call Crlf           ; Print a newline
        jmp progStart       ; Restart the program loop
    .ELSEIF(al == 'n' || al == 'N') ; If the user chooses to quit
        INVOKE ExitProcess, 0 ; Exit the program with status code 0
    .ELSE                   ; If invalid input
        jmp ask_try_again   ; Repeat the retry prompt
    .ENDIF

main ENDP ; End of the main procedure


; **********************************************************************;
; setupDeck Procedure                                                   ;
; Description: Initializes the deck with all 52 cards, assigning each   ;
;              card a suit and value.                                   ;
; Inputs: None.                                                         ;
; Outputs: Populates the `mydeck` structure with a complete deck.       ;
; Memory Usage: Modifies the `mydeck.cards` array.                      ;
; Register Usage:                                                       ;
; - ESI: Points to the current card being initialized in the deck.      ;
; - ECX: CL holds the suit counter, CH holds the card value counter.    ;
; **********************************************************************;

setupDeck PROC uses esi ecx ; Procedure to set up the deck of cards

    lea esi, Card ptr mydeck.cards ; Load the base address of the deck's card array into ESI

    mov cl, 0 ; Initialize the suit counter (CL) to 0
    .WHILE (cl < 4) ; Loop through the 4 suits (0-3)
        mov ch, 1 ; Initialize the card value counter (CH) to 1 (Ace)
        .WHILE (ch < 14) ; Loop through the 13 card values (1-13: Ace to King)
            mov (Card ptr [esi]).suit, cl ; Set the suit of the current card
            mov (Card ptr [esi]).value, ch ; Set the value of the current card
            add esi, SIZE Card ; Move to the next card in the array
            inc ch ; Increment the card value counter
        .ENDW ; End of inner loop for card values
        inc cl ; Increment the suit counter
    .ENDW ; End of outer loop for suits

    ret ; Return to the caller
setupDeck ENDP ; End of the setupDeck procedure


; **********************************************************************;
; shuffleDeck Procedure                                                 ;
; Description: Randomly shuffles the cards in the deck by swapping each ;
;              card with another randomly chosen card.                  ;
; Inputs: None.                                                         ;
; Outputs: The `mydeck.cards` array is shuffled.                        ;
; Memory Usage: Modifies the `mydeck.cards` array.                      ;
; Register Usage:                                                       ;
; - ESI: Points to the base of the card array in the deck.              ;
; - ECX: Acts as the current card index being processed.                ;
; - EAX: Holds the index of the randomly selected card for swapping.    ;
; - EBX: Temporarily stores card data during the swap.                  ;
; **********************************************************************;

shuffleDeck PROC uses esi ecx ebx eax ; Procedure to shuffle the deck of cards

    lea esi, Card ptr mydeck.cards ; Load the base address of the deck's card array into ESI
    xor ecx, ecx ; Initialize the current card index (ECX) to 0

    .WHILE (ecx < 52) ; Loop through all 52 cards in the deck
        mov eax, 52 ; Load the range (52 cards) into EAX for the random function
        call RandomRange ; Call the random range function to get a random index (in EAX)

        ; Swapping suits between the current card (ECX) and the randomly chosen card (EAX)
        mov bl, (Card ptr [esi + eax * 2]).suit ; Load the suit of the random card into BL
        mov bh, (Card ptr [esi + ecx * 2]).suit ; Load the suit of the current card into BH
        mov (Card ptr [esi + ecx * 2]).suit, bl ; Assign the random card's suit to the current card
        mov (Card ptr [esi + eax * 2]).suit, bh ; Assign the current card's suit to the random card

        ; Swapping values between the current card (ECX) and the randomly chosen card (EAX)
        mov bl, (Card ptr [esi + eax * 2]).value ; Load the value of the random card into BL
        mov bh, (Card ptr [esi + ecx * 2]).value ; Load the value of the current card into BH
        mov (Card ptr [esi + ecx * 2]).value, bl ; Assign the random card's value to the current card
        mov (Card ptr [esi + eax * 2]).value, bh ; Assign the current card's value to the random card

        inc ecx ; Move to the next card in the array
    .ENDW ; End of the loop for all cards

    ret ; Return to the caller
shuffleDeck ENDP ; End of the shuffleDeck procedure



; **********************************************************************;
; displayCard Procedure                                                 ;
; Description: Displays a single card by its value and suit.            ;
; Inputs: A reference to a Card structure in EAX.                      ;
; Outputs: Writes the card's value and suit as a string to the console. ;
; Memory Usage: None.                                                   ;
; Register Usage:                                                       ;
; - EBX: Used to temporarily hold the card's value or suit.             ;
; - EDX: Holds the address of strings to be displayed.                  ;
; **********************************************************************;

displayCard PROC uses ebx edx ; Procedure to display a card, card reference passed in EAX

    lea edx, cardDisplay ; Load the address of the "Card: " label into EDX
    call WriteString ; Write the "Card: " label to the screen

    MOVZX ebx, (Card ptr [eax]).value ; Load the card's value into EBX (zero-extended)
    lea edx, cardCharLUT ; Load the address of the card character lookup table into EDX
    push eax ; Save the current value of EAX on the stack
    mov al, byte ptr [edx + ebx] ; Get the character representing the card's value
    call WriteChar ; Write the card value character to the screen
    pop eax ; Restore the original value of EAX from the stack

    MOVZX ebx, (Card ptr [eax]).suit ; Load the card's suit into EBX (zero-extended)
    .IF (bx == 0) ; If the suit is 0 (Clubs)
        lea edx, clubsDisplay ; Load the " of Clubs" string into EDX
    .ELSEIF (bx == 1) ; If the suit is 1 (Diamonds)
        lea edx, diamondsDisplay ; Load the " of Diamonds" string into EDX
    .ELSEIF (bx == 2) ; If the suit is 2 (Hearts)
        lea edx, heartsDisplay ; Load the " of Hearts" string into EDX
    .ELSEIF (bx == 3) ; If the suit is 3 (Spades)
        lea edx, spadesDisplay ; Load the " of Spades" string into EDX
    .ENDIF ; End of conditional suit checks
    call WriteString ; Write the card's suit to the screen

    ret ; Return to the caller
displayCard ENDP ; End of the displayCard procedure



; **********************************************************************;
; displayHand Procedure                                                 ;
; Description: Displays all the cards in a given hand, followed by the  ;
;              total value of the hand.                                 ;
; Inputs: A reference to a Hand structure in EAX.                       ;
; Outputs: Displays the cards and hand value on the screen.             ;
; Memory Usage: Uses the stack for local storage.                       ;
; Register Usage:                                                       ;
; - EAX: Holds the reference to the Hand structure.                     ;
; - ECX: Used as a counter for iterating through the cards.             ;
; - EDX: Holds string pointers for display operations.                  ;
; **********************************************************************;
displayHand PROC uses ecx edx ; Procedure to display the contents of a hand
    push eax ; Save the original value of EAX on the stack
    lea eax, (Hand ptr [eax]).cards ; Load the address of the cards array in the hand
    movzx ecx, (Hand ptr [eax]).numcards ; Load the number of cards in the hand into ECX
    .WHILE (ecx > 0) ; Loop while there are cards remaining to display
        call displayCard ; Call a procedure to display a single card
        add eax, SIZE Card ; Move to the next card in the array
        sub ecx, size Card ; Decrement the counter for the number of cards
        call Crlf ; Print a newline for better readability
    .ENDW ; End of the loop

    lea edx, handValueDisplay ; Load the address of the hand value display string into EDX
    call WriteString ; Write the "Hand Value:" label to the screen
    pop eax ; Restore the original value of EAX from the stack
    call handValue ; Call a procedure to calculate the hand value
    call WriteDec ; Write the calculated hand value to the screen
    call Crlf ; Print a newline for better readability

    ret ; Return to the caller
displayHand ENDP ; End of the displayHand procedure



; **********************************************************************;
; dealCard Procedure                                                    ;
; Description: Deals the top card from the deck to a specified hand.    ;
; Inputs: A reference to a Hand structure in EAX.                      ;
; Outputs: Updates the specified hand and deck.                        ;
; Memory Usage: Modifies the deck's top index and the hand's card array ;
; Register Usage:                                                      ;
; - ESI: Points to the current card in the deck.                       ;
; - EDI: Points to the destination in the hand's card array.           ;
; - EBX: Holds temporary values such as card indices and counters.     ;
; **********************************************************************;

dealCard PROC uses esi edi ebx ; Procedure to deal a card, hand reference passed in EAX

    lea esi, Card ptr mydeck.cards ; Load the base address of the deck's card array into ESI
    movzx ebx, mydeck.top ; Load the top index of the deck into EBX
    add esi, ebx ; ESI now points to the top card in the deck
    add bl, SIZE Card ; Increment the top index by the size of one card
    mov mydeck.top, bl ; Update the deck's top index

    lea edi, (Hand ptr [eax]).cards ; Load the base address of the hand's card array into EDI
    movzx ebx, (Hand ptr [eax]).numcards ; Load the number of cards currently in the hand into EBX
    add edi, ebx ; EDI now points to the next available position in the hand's card array
    add bl, SIZE Card ; Increment the number of cards in the hand
    mov (Hand ptr [eax]).numcards, bl ; Update the hand's card count

    mov bl, (Card ptr [esi]).suit ; Load the suit of the top card into BL
    mov (Card ptr [edi]).suit, bl ; Copy the suit to the destination in the hand

    mov bl, (Card ptr [esi]).value ; Load the value of the top card into BL
    mov (Card ptr [edi]).value, bl ; Copy the value to the destination in the hand

    .IF(bl == 1) ; Check if the card is an ace (value == 1)
        mov bl, (Hand ptr [eax]).numAces ; Load the current number of aces in the hand into BL
        inc bl ; Increment the ace count
        mov (Hand ptr [eax]).numAces, bl ; Update the hand's ace count
    .ENDIF ; End of ace check

    ret ; Return to the caller
dealCard ENDP ; End of the dealCard procedure



; **********************************************************************;
; handValue Procedure                                                   ;
; Description: Calculates the total value of a hand of cards.           ;
; Inputs: A reference to a Hand structure in EAX.                      ;
; Outputs: Returns the total value of the hand in EAX.                  ;
; Memory Usage: None.                                                   ;
; Register Usage:                                                       ;
; - ESI: Points to the current card being processed in the hand.        ;
; - EDI: Holds the address of the cardValueLUT table.                   ;
; - EBX: Temporarily holds the count of aces in the hand.               ;
; - ECX: Holds the number of cards in the hand.                         ;
; - EDX: Temporarily holds a card value during processing.              ;
; **********************************************************************;

handValue PROC uses esi edi ebx ecx edx ; Procedure to calculate hand value, hand reference in EAX

    lea esi, (Hand ptr [eax]).cards ; Load the base address of the hand's card array into ESI
    movzx ecx, (Hand ptr [eax]).numcards ; Load the number of cards in the hand into ECX
    movzx ebx, (Hand ptr [eax]).numAces ; Load the number of aces in the hand into EBX
    push ebx ; Save the ace count on the stack
    XOR eax, eax ; Clear EAX (accumulator for the total hand value)

    .WHILE (ecx > 0) ; Loop through all cards in the hand
        movzx edx, ((Card ptr [esi]).value) ; Load the card's value into EDX (zero-extended)
        lea edi, cardValueLUT ; Load the address of the card value lookup table into EDI

        mov bl, byte ptr [edi + edx] ; Get the corresponding card value from the LUT
        add al, bl ; Add the card value to the accumulator (EAX)

        add esi, SIZE Card ; Move to the next card in the array
        sub ecx, SIZE Card ; Decrement the card count
    .ENDW ; End of loop for card processing

    pop ebx ; Restore the ace count from the stack
    .IF (ebx > 0 && eax <= 11) ; If there is at least one ace and the total value <= 11
        add eax, 10 ; Count one ace as 11 instead of 1
    .ENDIF ; End of conditional check for ace adjustment

    ret ; Return to the caller with the total hand value in EAX
handValue ENDP ; End of the handValue procedure


END main
