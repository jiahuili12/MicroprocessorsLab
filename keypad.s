#include <xc.inc>
extrn	Forward, Backward, Left, Right, Stop
extrn	delay
global  Keypad_Setup, Keypad_Read

psect	udata_acs		    ; Reserve data space in access ram
Keypad_counter:		ds  1	    ; Reserve 1 byte for variable UART_counter
Keypad_Value_Row:	ds  1	    ; Reserve 1 byte for keypad value
Keypad_Value_Col:	ds  1	    ; Reserve 1 byte for keypad value
Keypad_Value:		ds  1	    ; Reserve 1 byte for keypad value

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Keypad Input Pins:								;
;	Rows:RJ7, RJ6, RJ4, RB5,						;
;	Columns: RB4, RJ2, RJ3, RJ0						;
; Read the Keypad Input:							;
;	Forward = '2', Backward = '8', Left = '4', Right = '6'			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
psect	Keypad_code,class=CODE
Keypad_Setup:
    ; Select the proper bank where INTCON2 and PORTG reside
    banksel	INTCON2
    bcf		RBPU				;clear RBPU to enable PORTB internal pull-ups

    banksel	PORTG				;PORTG on PIC87FJ50, PADCFG1 on PIC87K22
    bsf		RJPU				;RJPU to enable PORTJ internal pull-ups

    clrf	LATJ, A         
    clrf	LATB, A
    return
    
Keypad_Read:
    clrf	LATJ, A                          
    movlw	11001111B                         ; clear the 4th and 5th bits of portB to be 0 since using RB4 and RB5
    andwf	LATB, F, A                        ; and bitwish
    
    clrf	Keypad_Value_Row, A               ; clear the 8 bit keypad_value_row
    clrf	Keypad_Value_Col, A               ; clear the 8 bit keypad_value_col
    clrf	Keypad_Value, A
    
    call	Keypad_Setup_Row
    call	Keypad_Read_Row
    
    call	Keypad_Setup_Col
    call	Keypad_Read_Col
    
    movf	Keypad_Value_Row, W, A		; Move row value into W
    iorwf	Keypad_Value_Col, W, A		; Combine row and column values (logical OR)
    movwf	Keypad_Value, A			; Store combined value into Keypad_Value
    
    call     Keypad_Compare_2			; Branch to compare logic
    return
    
Keypad_Setup_Row:				;0xF0
    bsf		TRISJ, 7, A			; RJ7 as input
    bsf		TRISJ, 6, A			; RJ6 as input
    bsf		TRISJ, 4, A			; RJ4 as input
    bsf		TRISB, 5, A			; RB5 as input
    bcf		TRISB, 4, A			; RB4 as output
    bcf		TRISJ, 2, A			; RJ2 as output
    bcf		TRISJ, 3, A			; RJ3 as output
    bcf		TRISJ, 0, A			; RJ0 as output
    call	Keypad_Delay			; wait 10ms for Keypad output pins voltage to settle
    return

Keypad_Setup_Col:				; 0x0F 
    bcf		TRISJ, 7, A			; RJ7 as output
    bcf		TRISJ, 6, A			; RJ6 as output
    bcf		TRISJ, 4, A			; RJ4 as output
    bcf		TRISB, 5, A			; RB5 as output
    bsf		TRISB, 4, A			; RB4 as input
    bsf		TRISJ, 2, A			; RJ2 as input
    bsf		TRISJ, 3, A			; RJ3 as input
    bsf		TRISJ, 0, A			; RJ0 as input
    call	Keypad_Delay			; wait 10ms for Keypad output pins voltage to settle
    return

Keypad_Read_Row:
    btfsc	PORTJ, 7, A			; Check RJ7, skip if clear
    bsf		Keypad_Value_Row, 0, A		; Set bit 0 if RJ7 is high
    btfsc	PORTJ, 6, A			; Use the bit 0 to 3 store the row number
    bsf		Keypad_Value_Row, 1, A          ; the 8 bit keypad_value_row would be 0000abcd
    btfsc	PORTJ, 4, A
    bsf		Keypad_Value_Row, 2, A
    btfsc	PORTB, 5, A
    bsf		Keypad_Value_Row, 3, A
    return

Keypad_Read_Col:
    btfsc	PORTB, 4, A			; Use the bit 4 to 7 store the column number
    bsf		Keypad_Value_Col, 4, A          ; the 8 bit keypad_value_col would be abcd0000
    btfsc	PORTJ, 2, A
    bsf		Keypad_Value_Col, 5, A
    btfsc	PORTJ, 3, A
    bsf		Keypad_Value_Col, 6, A
    btfsc	PORTJ, 0, A
    bsf		Keypad_Value_Col, 7, A
    return
  

Keypad_Compare_2:
    movlw	11101101B			    ;2: 11101101B
    cpfseq	Keypad_Value, A
    bra		Keypad_Compare_4
    ;retlw	'2'
    call	Forward
    return

Keypad_Compare_4:
    movlw	11011110B			    ;4: 11011110B
    cpfseq	Keypad_Value, A
    bra		Keypad_Compare_6
    ;retlw	'4'
    call	Left
    return

Keypad_Compare_6:
    movlw	11011011B			    ;6: 11011011B
    cpfseq	Keypad_Value, A
    bra		Keypad_Compare_8
    ;retlw	'6'
    call	Right
    return

Keypad_Compare_8:
     movlw	10111101B			    ;8: 10111101B
    cpfseq	Keypad_Value, A
    bra		Keypad_Compare_null
    ;retlw	'8'
    call	Backward
    return

Keypad_Compare_null:
    movlw	11111111B
    cpfseq	Keypad_Value, A
    bra		Keypad_Compare_error
    call	Stop
    return
	
Keypad_Compare_error:
    call	Stop
    return
	
Keypad_Delay:
    movlw   10
    movwf   Keypad_counter, A
Keypad_Delay_Loop:
    decfsz  Keypad_counter, A
    bra	    Keypad_Delay_Loop
    return
