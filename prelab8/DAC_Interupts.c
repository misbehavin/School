.include "nios_macros.s"  # defines pseudo-instructions

.text                   # Load code into .text partition of mem
.global _start          # Make _start available outside pgm
_start:                 # Default label for 1st address in pgm




  mov r2, r0            # r2 = num of 1s, init. = 0
  movia r8, TEST_NUM    # r8 = ADDRESS of test data
  ldw r9, 0(r8)         # r9 = VALUE of test data
	
COUNTER_LOOP:
  beq r9, r0, END             # if r9=0, Break (no more 1s)
    bgt r9, r0, SKIP_COUNT    # else if r9>0, do not add
      addi r2, r2, 1          # else increment num of 1s 

SKIP_COUNT:
    slli r9, r9, 1            # shift next bit into sign
    br COUNTER_LOOP
		
END:
  br END                # Infinite Loop lets user view results



.global TIMER_ISR
TIMER_ISR:					
    subi    sp,  sp, 20		# reserve space on the stack 
    stw     ra, 0(sp)
    stw     fp, 4(sp)
    stw     r10, 8(sp)
    stw     r16, 12(sp)
    stw     r17, 16(sp)
    addi    fp,  sp, 20
    movia   r10, INTERVAL_TIMER_BASE
    sthio   r0, 0(r10)				# Clear the interrupt
    
    /* current Green LED states are passed in r3 */
    xori    r3, r3, 0xFFFF
    xorhi   r3, r3, 0xFFFF
    movia   r10, GREEN_LED_BASE
    stwio   r3, 0(r10)