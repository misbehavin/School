.equ TIMER_IRQ  0x2
.equ PIE        0x1
.equ P_BASE     0x2FAF

.text
.global _start
_start:

    #Enable Interupts
    movi    r10,  PIE
    wrctl   ctl0, r10
    movia   r10,  TIMER_IRQ
    wrctl   ctl3, r10
    
    #Set Timer Period and Start it
    movi    r4, 10
    call SET_TIMER
    
    
END:
  br END

  

#--------------------------------------
UPDATE_DAC:
    addi    sp,  sp, -16
    stwio   ra,  0(sp)
    stwio   r10, 4(sp)
    stwio   r11, 8(sp)
    stwio   r12, 12(sp)
    
    movia   r10, SPI_PIO
    movia   r11, DAC_COUNT
    
    #loop until trdy is 1
TRDY:
    ldwio   r12, 8(r10)
    andi    r12, r12,0x20
    beq     r12, r0,TRDY
    
    #load count add control bits -> output
    ldhio   r12, 0(r11)
    andi    r12, r12, 0x5FFF
    sthio   r12, 4(r10)
    
    #increment count or reset back to zero if 0xFFE
    addi    r10, r0, 0x0FFE
    andi    r12, r12, 0x0FFF
    bneq    r12, 10, SKIPRESET
    sthio   r0,  0(r11)
    
    ldwio   ra,  0(sp)
    ldwio   r10, 4(sp)
    ldwio   r11, 8(sp)
    ldwio   r12, 12(sp)
    addi    sp,  sp, 16
    ret

SKIPRESET:
    addi    r12, r12, 0x1
    sthio   r12, 0(r11)
    
    ldwio   ra,  0(sp)
    ldwio   r10, 4(sp)
    ldwio   r11, 8(sp)
    ldwio   r12, 12(sp)
    addi    sp,  sp, 16
    ret
#//------------------------------------
    
    
#--------------------------------------
SET_TIMER:
    addi    sp,  sp, -16
    stwio   ra,  0(sp)
    stwio   r10, 4(sp)
    stwio   r11, 8(sp)
    stwio   r12, 12(sp)
    
    #Calculate Period Based of given Freq
    beq     r4,  r0, SKIPCALC
    movui   r12, P_BASE
    divu    r12, r12, r4
    addi    r10, r0, 0xFFFF
    sub     r12, r10, r12 
    movia   r11, TIMER_FREQ
    stwio   r12, 0(r11)

SKIPCALC:
    movia   r10, TIMER_PIO
    
    #Stop Timer
    movui   r11, 0x8
    stwio   r11,  4(r10)
    
    #Set period
    movia   r11, TIMER_FREQ
    ldwio   r11, 0(r11)
    sthio   r11, 8(r10)
    srl     r11, r11, 16
    sthio   r11, 12(r10)
    
    #Set ITO, CONT, START bits in timer
    movui   r11, 0x7
    stwio   r11,  4(r10)


    ldwio   ra,  0(sp)
    ldwio   r10, 4(sp)
    ldwio   r11, 8(sp)
    ldwio   r12, 12(sp)
    addi    sp,  sp, 16
    ret
#//------------------------------------
  
  

.global TIMER_ISR
TIMER_ISR:					
    addi    sp,  sp, -20
    stw     ra,  0(sp)
    stw     r10, 8(sp)
    stw     r16, 12(sp)
    stw     r17, 16(sp)
    
    rdctl   r10, ctl4
    andi    r10, r10, TIMER_IRQ
    beq     r10, r0,  NOIRQ
    
    movia   r12, TIMER_PIO
    stwio   r0,  0(r12)
    
    
    
    #UPDATE DAC VALUE
    call UPDATE_DAC
    
NOIRQ:
    ldw     ra,  0(sp)
    ldw     r10, 4(sp)
    ldw     r16, 8sp)
    ldw     r17, 12(sp)
    addi    sp,  sp, 16
    eret

    
    
    
.data
DAC_COUNT   .hword  0x5000
TIMER_FREQ  .word   0x0000FFFF
TIMER_PIO   .word   0x00000000
UART_PIO    .word   0x00000000
SPI_PIO     .word   0x00000000