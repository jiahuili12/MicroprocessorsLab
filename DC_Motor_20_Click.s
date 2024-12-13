#include <xc.inc>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;mikrobus1:
;RA0=input_1, RD2=Input_2, RG3=input_3, RB3=Input_4			;
;Motor driver = TC78H651AFNG						;
;mikrobus2:
;RA1=input_1, RD0=Input_2, RG0=input_3, RB2=Input_4			;
;Motor driver = TC78H651AFNG						;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

extrn  delay

global Forward, Backward, Right, Left, Stop, motor_setup, motor_test

    
psect	udata_acs		; reserve data space in access ram

psect	motors_code, class=CODE

motor_setup:
    bcf	LATA, 1, A		; Clear LAT registers
    bcf	LATD, 0, A
    bcf	LATG, 0, A
    bcf	LATB, 2, A
    bcf TRISA, 1, A		; Set RA1 as output 1
    bcf TRISD, 0, A		; Set RD2 as output 2
    bcf TRISG, 0, A		; Set RG0 as output 3
    bcf TRISB, 2, A		; Set RB2 as output 4
    return
    
Forward:
    bsf LATA, 1, A		; Set RA1 as High
    bcf LATD, 0, A		; Set RD0 as Low
    bsf LATG, 0, A		; Set RG0 as High
    bcf LATB, 2, A		; Set RB2 as Low
    ;call delay			; Delay for specified time
    return

Backward:
    bcf LATA, 1, A		; Set RA0 as Low
    bsf LATD, 0, A		; Set RD2 as High
    bcf LATG, 0, A		; Set RG3 as Low
    bsf LATB, 2, A		; Set RB3 as High
    ;call delay			; Delay for specified time
    return

Right:
    bsf LATA, 1, A		; Set RA0 as High
    bcf LATD, 0, A		; Set RD2 as Low
    bcf LATG, 0, A		; Set RG3 as Low
    bsf LATB, 2, A		; Set RB3 as High
    ;call delay			; Delay for specified time
    return

Left:
    bcf LATA, 1, A		; Set RA0 as Low
    bsf LATD, 0, A		; Set RD2 as High
    bsf LATG, 0, A		; Set RG3 as High
    bcf LATB, 2, A		; Set RB3 as Low
    ;call delay			; Delay for specified time
    return

Stop:
    bcf LATA, 1, A		; Set all as Low
    bcf LATD, 0, A
    bcf LATG, 0, A
    bcf LATB, 2, A 
    ;call delay			; Delay for specified time
    return

motor_test:
    ;Execute motion sequences
    call Forward
    call delay
    call Stop
    call delay
    
    call Backward
    call delay
    call Stop
    call delay
    
    call Left
    call delay
    call Stop
    call delay
    
    call Right
    call delay
    call Stop
    call delay
    
    ;goto motor_test		; Repeat forever
end 