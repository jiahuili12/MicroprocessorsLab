#include <xc.inc>
    
extrn	Stop, delay, Backward
extrn	Echo_Time_H, Echo_Time_L
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
    movlw	1			    ; Delay for 1 ms
    call	delay
    bsf		PORTE, 3, A		    ; Trigger is High ~ 10us
    call	delay_10us
    bcf		PORTE, 3, A		    ; Trigger is Low again
    bsf		US_measuring, 0, A	    ; Set US_measuring <0> = 1
    return

compare_distance:			    ; Compare the High Byte of distance
    movf    Echo_Time_H, W, A
    subwf   safety_dist_h, W, A             ; W = safety_dist_h - Echo_Time_H

    btfsc   STATUS, 2                       ; Zero = 1? (Echo_Time_H == safety_dist_h)
    goto    compare_distance_l              ; If equal, jump to low byte comparison

    btfss   STATUS, 0                       ; Carry = 0? (Echo_Time_H > safety_dist_h)
    goto    Distance_Unsafe                 ; If greater, jump to unsafe

    goto    Distance_Safe                   ; Otherwise (Echo_Time_H < safety_dist_h), jump to safe
    
compare_distance_l:
    ; High bytes are equal, compare low bytes
    movf	Echo_Time_L, W, A
    subwf	safety_dist_l, W, A	    ; W = safety_dist_l - Echo_Time_L
    btfsc	STATUS, 0		    ; If carry set, Echo_Time_L <= safety_dist_l
    goto	Distance_Safe
    goto	Distance_Unsafe
    
    
Distance_Unsafe:
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