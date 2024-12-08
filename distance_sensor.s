#include <xc.inc>
    
    
extrn	CCP_capture ,count_high, count_low, T1_setup, CCP_setup
extrn	safety_dist   

global	sensor_setup, sensor_trigger, sensor_distance

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup Sensors and Trigger rountine	                                     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
psect	sensor_code,class=CODE
    
sensor_setup:
    bcf		TRISE, 3,  A
    bcf		TRISF, 7, A
    bsf		TRISE, 3, A		    ; set RE6 as trigger 
    bsf		TRISF, 7, A		    ; Set RE7 as echo
    clrf	LATE, A
    clrf	LATF, A
    return          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Send a short pulse via RE6 to trigger the ultrasonic sensor			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sensor_trigger:
    bcf		PORTE, 3, A		    ;Trigger is Low
    call	delay_10us
    bsf		PORTE, 3, A		    ;Trigger is High
    call	delay_10us
    bcf		PORTE, 3, A		    ;Trigger is Low
    ;bsf	PORTE, PORTE_RE3_POSN, A    ;RE3 high: send trigger pulse
    ;nop
    ;nop
    ;bcf	PORTE, PORTE_RE3_POSN, A    ;RE3 low: end trigger pulse
    ;bsf	TRISE, PORTE_RE3_POSN, A    ;RE3 input
    retfie

sensor_distance:
    ; Check high byte of Echo_Time
    movf    count_high, W, A          ; Load high byte of Timer1 value
    iorwf   count_high, W, A          ; Check if high byte is non-zero
    btfsc   STATUS, 2, A               ; Skip if Z is set (Echo_Time_H == 0)
    goto    Distance_Unsafe            ; Unsafe if Echo_Time_H > 0

    ; Compare low byte of Echo_Time with safety_dist
    movf    count_low, W, A          ; Load low byte of Timer1 value
    subwf   safety_dist, W, A          ; Subtract safety_dist from Echo_Time_L
    btfsc   STATUS, 0, A                 ; Check carry bit (safety_dist >= Echo_Time_L)
    goto    Distance_Safe              ; Safe if safety distance >= Echo_Time_L

Distance_Unsafe:
    bcf    STATUS, 2, A			; Clear Z flag (unsafe)
    return

Distance_Safe:
    bsf     STATUS, 2, A		; Set Z flag (safe)
    return

delay_10us:
    nop	          ; Adjust based on clock speed, usually ~4 cycles per NOP
    nop
    nop
    nop
    RETURN
end
  