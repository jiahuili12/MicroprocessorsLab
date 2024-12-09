#include <xc.inc>

extrn	CCP_capture, count_high, count_low, T1_setup, CCP_setup
extrn	safety_dist, Motors_setup, Forward, Backward, Turn_left, Turn_right, Stop, Start_motors

psect udata_acs
dist_cond:	ds 1

global	sensor_setup, sensor_trigger, Ping_distance

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup Sensors and Trigger routine	                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
psect sensor_code, class=CODE

sensor_setup:
    bcf		TRISE, 3,  A
    bcf		TRISF, 7, A
    bsf		TRISE, 3, A		    ; Set RE3 as trigger
    bsf		TRISF, 7, A		    ; Set RF7 as echo
    clrf	LATE, A
    clrf	LATF, A
    return          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Send a short pulse via RE6 to trigger the ultrasonic sensor			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sensor_trigger:
    bcf		PORTE, 3, A		    ; Trigger is Low
    call	delay_10us
    bsf		PORTE, 3, A		    ; Trigger is High
    call	delay_10us
    bcf		PORTE, 3, A		    ; Trigger is Low
    retfie

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Compare high byte and low byte with threshold to determine safety	       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Ping_distance:
    ; Compare count_high with 0x04 (threshold)
    movlw   0x04                    ; Load threshold value
    subwf   count_high, W, A        ; Subtract count_high from 0x04
    btfss   STATUS, 0, A            ; Check carry bit (count_high >= 0x04)
    goto    Distance_Safe           ; Safe if count_high >= 0x04

    ; If high count is less than threshold
    goto    Distance_Unsafe

Distance_Unsafe:
    call    Stop                    ; Call Stop routine (unsafe distance)
    return

Distance_Safe:
    call    Start_motors            ; Call Start_motors routine (safe distance)
    return

delay_10us:
    nop	          ; Adjust based on clock speed, usually ~4 cycles per NOP
    nop
    nop
    nop
    RETURN

end