#include <xc.inc>
 
;define port and constant
Trigger_pin EQU 0
ECHO_pin    EQU 1
Time_out    EQU 36

;start program
    ORG 0x0000
    GOTO MAIN
    
;initialize ports
INIT:
    CLRF PORTB          ;clear portb
    MOVLW 0xFE          ;set RB0 as output, RB1 as input
    MOVWF TRISB         
    RETURN
    
 ; Send a 10 탎 pulse on the trigger pin
SEND_TRIGGER:
    BCF PORTB, TRIGGER_PIN ; Set Trigger low
    NOP
    BSF PORTB, TRIGGER_PIN ; Set Trigger high
    CALL DELAY_10US        ; Wait 10 탎
    BCF PORTB, TRIGGER_PIN ; Set Trigger low
    RETURN

; Wait for Echo pin to go high and measure pulse duration
WAIT_FOR_ECHO:
    CLRF TMR0L             ; Clear Timer0
    CLRF TMR0H
    BSF T0CON, TMR0ON      ; Start Timer0
WAIT_HIGH:
    BTFSS PORTB, ECHO_PIN  ; Check if Echo pin is high
    GOTO WAIT_HIGH
    RETURN

MEASURE_PULSE:
    CLRF TMR0L             ; Reset Timer0 for pulse duration measurement
    CLRF TMR0H
WAIT_LOW:
    BTFSC PORTB, ECHO_PIN  ; Wait for Echo pin to go low
    GOTO WAIT_LOW
    MOVF TMR0L, W          ; Store low byte of timer
    MOVWF PULSE_WIDTH
    RETURN

; Main program
MAIN:
    CALL INIT
LOOP:
    CALL SEND_TRIGGER      ; Send trigger signal
    CALL WAIT_FOR_ECHO     ; Wait for Echo pin to go high
    CALL MEASURE_PULSE     ; Measure the pulse duration
    MOVF PULSE_WIDTH, W    ; Get the measured time
    SUBLW TIMEOUT          ; Check if time exceeds the timeout
    BTFSS STATUS, C        ; If no carry, object detected
    GOTO OBJECT_DETECTED
    ; Otherwise, no object detected
    GOTO NO_OBJECT

OBJECT_DETECTED:
    ; Code to handle object detected
    ; You can implement distance calculation here
    GOTO LOOP

NO_OBJECT:
    ; Code to handle no object detected
    GOTO LOOP

; Delay subroutine for 10 탎
DELAY_10US:
    MOVLW D'10'            ; Load the cycle count for 10 탎 (adjust based on clock)
    MOVWF COUNTER
DELAY_LOOP:
    DECFSZ COUNTER, F
    GOTO DELAY_LOOP
    RETURN

; End program
    END
    

