#include <xc.inc>

global delay
    
psect udata_acs
delay_ms:   ds 1	    ; reserve one byte for milliseconds variables
counter_h:  ds 1	    ; reserve one byte for variables counter_h
counter_l:  ds 1	    ; reserve one byte for variables counter_l

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Code for a delay routine for approximately 1 second.			;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

psect delay_code, class=CODE

delay:
    movlw	1000		    ; move 1000 into W
    movwf	delay_ms, A	    ; delay for 1000*1ms = 1s
delay_loop:
    movlw	250		    ; move 250 into w
    call	delay_x4us	    ; delay for 250*4us = 1 ms
    decfsz	delay_ms, A
    bra		delay_loop
    return
    
delay_x4us:
    movwf	counter_l, A	    ; now need to multiply by 16
    swapf	counter_l, F, A	    ; swap nibbles
    movlw	0x0f	    
    andwf	counter_l, W, A	    ; move low nibble to W
    movwf	counter_h, A	    ; then to LCD_cnt_h
    movlw	0xf0	    
    andwf	counter_l, F, A    ; keep high nibble in LCD_cnt_l
    call	big_delay
    return

big_delay:			    ; delay routine	4 instruction loop == 250ns	    
    movlw 	0x00		    ; W=0
delay_loop_2:	
    decf 	counter_l, F, A	    ; no carry when 0x00 -> 0xff
    subwfb 	counter_h, F, A	    ; no carry when 0x00 -> 0xff
    bc		delay_loop_2	    ; carry, then loop again
    return			    ; carry reset so return