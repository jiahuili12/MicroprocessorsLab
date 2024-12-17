#include <xc.inc>
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RC1=input_1, RC2=Input_2, RC3=input_3, RC4=Input_4			;
; Motor driver = L293D							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
global Forward, Backward, Right, Left, Stop, motor_setup, motor_test

psect	udata_acs

psect	data
R_Input1  EQU 1    ; RC1 -> Right Motor Input 1
R_Input2  EQU 2    ; RC2 -> Right Motor Input 2
L_Input1  EQU 3    ; RC3 -> Left Motor Input 1
L_Input2  EQU 4    ; RC4 -> Left Motor Input 2


psect	motors_code, class=CODE


Forward:
    BSF PORTC, R_Input1, A     ; Set L1 HIGH
    BCF PORTC,R_Input2, A  ; Set L2 LOW
    BSF PORTC,L_Input1, A     ; Set L3 HIGH
    BCF PORTC,L_Input2, A     ; Set L4 LOW
    call Delay			; Delay for specified time
    return

Backward:
    BCF PORTC, R_Input1, A     ; Set L1 LOW
    BSF PORTC, R_Input2, A     ; Set L2 HIGH
    BCF PORTC, L_Input1, A     ; Set L3 LOW
    BSF PORTC, L_Input2, A     ; Set L4 HIGH
    call Delay			; Delay for specified time
    return

Right:
    BSF PORTC, R_Input1, A     ; Set L1 HIGH
    BCF PORTC, R_Input2, A     ; Set L2 LOW
    BCF PORTC, L_Input1, A     ; Set L3 LOW
    BSF PORTC, L_Input2, A     ; Set L4 HIGH
    call Delay			; Delay for specified time
    return

Left:
    BCF PORTC, R_Input1, A     ; Set L1 LOW
    BSF PORTC, R_Input2, A     ; Set L2 HIGH
    BSF PORTC, L_Input1, A     ; Set L3 HIGH
    BCF PORTC, L_Input2, A     ; Set L4 LOW
    call Delay			; Delay for specified time
    return

Stop:
    BCF PORTC, R_Input1, A     ; Set all pins LOW
    BCF PORTC, R_Input2, A
    BCF PORTC, L_Input1, A
    BCF PORTC, L_Input2, A
    call Delay			; Delay for specified time
    return

; Delay Subroutine (approximately 1 ms delay per call)
Delay:  
    MOVLW   0xFF                ; Load WREG with delay count (adjust as needed)
    MOVWF   0x20, A                ; Store in memory (temp register 0x20)
Delay_Loop:
    decfsz  0x20, F, A             ; Decrement delay counter
    goto    Delay_Loop          ; Repeat until counter reaches zero
    return                      ; Return from delay

; Main Program
motor_setup:
    CLRF PORTC, A        ; Clear PORTC
    BCF TRISC, 1, A      ; Set RC0 as output
    BCF TRISC, 2, A      ; Set RC1 as output
    BCF TRISC, 3, A    ; Set RC2 as output
    BCF TRISC, 4, A      ; Set RC3 as output

motor_test:
    ; Execute motion sequences
    call Forward
    call Delay
    call Stop
    call Delay
    call Backward
    call Delay
    call Stop
    call Delay
    call Left
    call Delay
    call Stop
    call Delay
    call Right
    call Delay
    call Stop
    call Delay
    GOTO motor_test    ; Repeat forever

END 