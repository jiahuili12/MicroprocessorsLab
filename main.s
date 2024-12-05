#include <xc.inc>

extrn	sensor_setup, sensor_send_signal, sensor_distance
extrn	motor_setup, Forward, Backward, Left, Right, Stop, motor_test

global	safety_dist
    
psect	udata_acs
safety_dist:	ds 1			; Reserve 1 bit for safety distance

psect code, abs
 
rst:
    org 0x0
    goto setup

 
setup:
    call motor_setup			    ; Initialize motor setup
    call sensor_setup			    ; Initialize sensor setup
    call CCP_setup			    ; Initialize CCP module
    
start:    
    movlw	0x0A			    
    movwf	safety_dist, A
    
main_loop:
    call	sensor_send_signal	    ; Send ultrasonic pulse
    call	CCP_reset		    ; Reset CCP and Timer
    call	CCP_setup		    ; Re-enable CCP and Timer

    call	sensor_distance		    ; Check distance
    btfss	STATUS, 2, A		    ; Check if Z flag is set (safe distance), status register bit 2 is z = zero bit. 
					    ; if Z=0(distance<safety distance), jumps to emergency_stop
    goto	emergency_stop

    goto	continue_vehicle

    
emergency_stop:
    call	Stop			    ; Stop the vehicle

continue_vehicle:
    call	motor_test
    goto	main_loop

end rst
