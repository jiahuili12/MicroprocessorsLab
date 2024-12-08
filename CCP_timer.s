#include <xc.inc>
    
global  CCP_setup, CCP_interrupt, CCP_reset, CCP_capture, T1_setup,ECCP1CON
global  count_high, count_low

psect udata_acs
count_high:	    ds 1
count_low:	    ds 1    
    

psect CCP_code, class=CODE
    
CCP_setup:
    bcf         TRISF, 7, A       ;set portF7 as input (ccp1)
    movlw	00000100B		    ;Interrupt every falling edge edge
    movwf	ECCP1CON, A
    bsf		PIE1, 2, A		    ;Enable CCP1 interrupt
    banksel OSCCON    ; select OSCCON Bank
    movlw 0b01110010  ; SCS=10 (internal oscillator)?IRCF=111 (8 MHz)
    movwf OSCCON,A    ; set osccon registor
    
WAIT_OSC:
    btfss OSCCON, 2  ,A ; wait for stable
    goto WAIT_OSC     
    return 
    
T1_setup:
    bsf		INTCON, 6, A		    ;Enable peripheral interrupts (PEIE)
    bsf		INTCON, 7, A		    ;Enable Global interrupts (GIE)
    clrf	RCON, A			    ;Disable Interrupt Priority (IPEN)
    clrf	PIR1, A			    ;Clear all interrupt flags
    clrf	CCPR1L, A		    ;Clear CCP1 low byte
    clrf	CCPR1H, A		    ;Clear CCP1 high byte
    clrf	TMR1L, A		    ;Clear Timer 1 low byte
    clrf	TMR1H, A		    ;Clear Timer 1 high byte
    movlw	01101001B		    ;Enable Timer 1 with prescaler 1:4 (5 and 4 bits is 1 and 0)(1:8 need 5,4 bit to be 11)
    movwf	T1CON, A		    
    return

CCP_interrupt:				    ;Interrupt routine
    bcf	        PIR1, 0, A		    ;Clear Timer 1 interrupt flag, everytime it interrupt, 0th bit of PIR1 become)
    btfsc	PIR1, 2, A		    ;Check if CCP1 interrupt
    goto	CCP_capture
    retfie				    ;Return from interrupt routine
    
CCP_capture:
    movff	CCPR1H, count_high, A	    ;Store high byte of Timer 1 
    movff	CCPR1L, count_low, A	    ;Store low byte of Timer 1
    clrf	PIR1, A			    ;Clear all flags
    clrf	CCPR1L, A		    ;Clear CCP1 count
    clrf	CCPR1H, A
    clrf	TMR1L, A		    ;Clear Timer 1 count
    clrf	TMR1H, A
    retfie
    
CCP_reset:
    clrf	ECCP1CON, A		    ;Disable CCP1
    clrf	PIR1, A			    ;Clear all interrupt flags
    bcf		PIE1, 2, A		    ;CCP1IE disabled
    clrf	CCPR1L, A		    ;Clear CCP1 count
    clrf	CCPR1H, A
    movlw	01001000B		    ;Disable Timer 1
    movwf	T1CON, A
    return
end

    
