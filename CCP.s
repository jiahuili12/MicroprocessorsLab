#include <xc.inc>

global  T1_setup, CCP_setup, CCP_Interrupt, CCP_reset
global	Echo_Time_H, Echo_Time_L, pulse_h, pulse_l
global end_time_L, end_time_H, start_time_L,  start_time_H
extrn	US_measuring, sensor_trigger

psect udata_acs
capture_state:	ds 1			    ; 0 = capture rising edge, 1 = capture falling edge
start_time_H:	ds 1			    ;reserve 1 byte for start time high
start_time_L:	ds 1			    ;reserve 1 byte for start time low
end_time_H:	ds 1			    ;reserve 1 byte for end time high
end_time_L:	ds 1			    ;reserve 1 byte for end time low
Echo_Time_H:	ds 1			    ;reserve 1 byte for Echo time high
Echo_Time_L:	ds 1			    ;reserve 1 byte for Echo time low
pulse_h:	ds 1
pulse_l:	ds 1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup and Initialization for Timer 1 and CCP module.				    ;
; RE1: Echo									    ;
; Echo_Time_H = end_time_H - start_time_H	    				    ;
; Echo_Time_L = end_time_L - start_time_L	    				    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
psect	ccp_code,class=CODE

CCP_setup:				    ;Enhanced Capture/ Compare/ PWM Module
    bsf		TRISC, 2, A		    ;RE1 = CCP1 as input
    movlw	00000101B		    ;Capture on every rising edge: 0101
    movwf	ECCP1CON, A		    ;ECCP1 Control Register
    bsf		PIE1, 2, A		    ;Enable CCP1 interrupt
    
    clrf	capture_state, A	    ; Start with capturing rising edge
    return

T1_setup:
    bsf		INTCON, 6, A		    ;Enable peripheral interrupts (PEIE)
    bsf		INTCON, 7, A		    ;Enable Global interrupts (GIE)
    clrf	RCON, A			    ;Disable Interrupt Priority (IPEN)
    clrf	PIR1, A			    ;Clear all interrupt flags
    
    bsf		PIE1, 0			    ; Enable Timer 1 overflow interrupt (PIE1<0>)
    
    bcf		T3CCP1			    ; use timer1 for ccp
    bcf		T3CCP2
    clrf	CCPR1L, A		    ;Clear CCP1 low byte
    clrf	CCPR1H, A		    ;Clear CCP1 high byte
    clrf	TMR1L, A		    ;Clear Timer 1 low byte
    clrf	TMR1H, A		    ;Clear Timer 1 high byte
    movlw	01101001B		    ;TMR1 ON,  prescaler 1:4, Internal Clock, R/W into 2 8-bit operations
    movwf	T1CON, A		    
    return
    
CCP_reset:
    clrf	PIR1, A			    ;Clear all flags
    clrf	CCPR1L, A		    ;Clear CCP1 count
    clrf	CCPR1H, A
    ;clrf	TMR1L, A
    ;clrf	TMR1H, A
    return
    
CCP_Interrupt:				    ;Interrupt routine
    btfsc	PIR1, 2, A		    ;Check if CCP1 interrupt
    goto	CCP_Echo_Capture
    
    btfsc	PIR1, 0			    ; PIR1<0>
    goto	No_Echo_detected
    
    retfie	f			    ;Return from interrupt routine
    
CCP_Echo_Capture:			    ;Store current capture value
    movff	CCPR1L, Echo_Time_L, A	    ;Store low byte of Timer 1
    movff	CCPR1H, Echo_Time_H, A	    ;Store high byte of Timer 1 
    
    btfsc	capture_state, 0, A	    ;If capture_state <0> = 0 , skip next
    goto	falling_edge
    
rising_edge:
    movff	Echo_Time_H, start_time_H, A
    movff	Echo_Time_L, start_time_L, A
    
    movlw	00000100B		    ;Capture on every falling edge: 0100
    movwf	ECCP1CON,A
    
    bsf		capture_state, 0, A	    ; Set capture_state <0> = 1
    call	CCP_reset
    retfie  f
    
falling_edge:
    movff	Echo_Time_H, end_time_H, A
    movff	Echo_Time_L, end_time_L, A
    
    
pulse_width:				    ; Compute Echo_Time = end_time - start_time (16-bit)
    movf	start_time_L, W, A	    ; W = start_time_L
    subwf	end_time_L, W, A	    ; W = end_time_L - start_time_L
    movwf	pulse_l, A		    ; Echo_Time_L = end_time_L - start_time_L
	
    movf	start_time_H, W, A	    ; W = start_time_H
    subwfb	end_time_H, W, A	    ; W = end_time_H - start_time_H - borrow
    movwf	pulse_h, A		    ; Echo_Time_H = end_time_H - start_time_H - borrow
    
    movlw	00000101B		    ; Capture on every rising edge
    movwf	ECCP1CON, A
    bcf		capture_state, 0, A	    ; Clear capture_state <0> = 0
    
    call	CCP_reset
    bcf		US_measuring, 0, A	    ; Clear US_measuring <0> = 0

    retfie  f

No_Echo_detected:
    bcf     PIR1, 0			    ; Clear Timer1 Interrupt Flag

    btfss   US_measuring, 0, A
    retfie				    ; If not measuring, just return

    bcf     US_measuring, 0, A		    ; Clear measuring flag
    call    CCP_reset			    ; Reset Timer1 & CCP
    call    sensor_trigger		    ; Send a new trigger pulse
    retfie  f

end