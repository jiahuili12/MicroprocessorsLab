#include <xc.inc>
    
extrn	Stop, delay, Backward
extrn	Echo_Time_H, Echo_Time_L
extrn	pulse_h, pulse_l
extrn	safety_dist_h, safety_dist_l

global	sensor_setup, sensor_trigger, compare_distance, US_measuring

psect udata_acs
US_measuring:	ds 1			    ; flag to indicate if measurement in progress

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup Sensors and Trigger rountine	                                     ;
;   Trigger: RE3, Echo: RC2						     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
psect	sensor_code,class=CODE
    
sensor_setup:
    bcf		TRISE, 3,  A		    ; set RE3 as trigger
    ;bcf		TRISE, 1, A
    ;bsf		TRISE, 3, A		     
    ;bsf		TRISC, 2, A		
    ;bcf		LATE, 3, A
    ;bcf	    	LATE, 1, A
    clrf	US_measuring, A
    return          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Send a short pulse via RE3 to trigger the ultrasonic sensor			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
sensor_trigger:
    btfsc	PORTC, 2, A		    ; Check if Echo is Low
    return

    bcf		PORTE, 3, A		    ; Ensure Trigger is Low
    ;movlw	1			    ; Delay for 1 ms
    ;call	delay
    bsf		PORTE, 3, A		    ; Trigger is High ~ 10us
    call	delay_10us
    bcf		PORTE, 3, A		    ; Trigger is Low again
    bsf		US_measuring, 0, A	    ; Set US_measuring <0> = 1
    return

compare_distance:			    ; Compare the High Byte of distance
    movf	pulse_h, W, A
    ;movf	Echo_Time_H, W, A
    subwf	safety_dist_h, W, A	    ; W = safety_dist_h - pulse_h
    
    btfsc   	STATUS, 2		    ; Zero bit: If zero skip next. (Z=1 safety_dist_h = Echo_Time_H) 
    goto	compare_distance_l
    
    btfsc	STATUS, 0		    ; Carry bit: C = 1 and and Z = 0, safety_dist_h > Echo_Time_h.
    
    goto	Distance_Unsafe		    ; C = 0, Z= 0
    goto	Distance_Safe
    

    
compare_distance_l:			    ; High bytes are equal, compare low bytes
    movf	pulse_l, W, A
    ;movf	Echo_Time_L, W, A
    subwf	safety_dist_l, W, A	    ; W = safety_dist_l - pulse_l
    
    btfsc	STATUS, 0		    ; If carry set, Echo_Time_L <= safety_dist_l
    
    goto	Distance_Unsafe		    ; C=1, No borrow,  safety_dist > pulse, unsafe
    goto	Distance_Safe		    ; C=0, Borrow occured, safety_dist < pulse, safe
    
Distance_Unsafe:
    call	Stop
    call	Backward
    call	Stop
    call	Backward
    return

Distance_Safe:
    return


delay_10us:
    nop					    ; Adjust based on clock speed, usually ~4 cycles per NOP
    nop					    ; Checked on Osilloscope, the delay is ~ 10us.
    nop
    nop
    nop
    nop
    nop	
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    return
end