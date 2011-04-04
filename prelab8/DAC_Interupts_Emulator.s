
.text
loop:
    addi r4,r0,10
    call SET_TIMER
    
    movia r10,TIMER_PIO
    ldwio r10, 0(r10)
    addi r12,r0,1
    
    timeout:
    ldwio r11, 0(r10)
    andi   r11, r11, 0x1
    bne  r12,r11, timeout
    
    call UPDATE_DAC
br loop
    
    
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
   #ldwio   r10, 0(r10)
    
    movia   r11, DAC_COUNT
    
    #loop until trdy is 1
#TRDY:
#    ldwio   r12, 8(r10)
#   andi    r12, r12,0x20
#    beq     r12, r0,TRDY
    
    #load count add control bits -> output
    ldwio   r12, 0(r11)
    ori    r12, r12, 0x5000
    stwio   r12, 4(r10)
    
    #increment count or reset back to zero if 0xFFE
    addi    r10, r0, 0x0FFE
    andi    r12, r12, 0x0FFF
    bne     r12, r10, SKIPRESET
    stwio   r0,  0(r11)
    
    ldwio   ra,  0(sp)
    ldwio   r10, 4(sp)
    ldwio   r11, 8(sp)
    ldwio   r12, 12(sp)
    addi    sp,  sp, 16
    ret

SKIPRESET:
    addi    r12, r12, 0x1
    stwio   r12, 0(r11)
    
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
    
    #Calculate Period Based off given Freq
    beq     r4,  r0, SKIPCALC
    movui   r12, 0x2FAF
    div     r12, r12, r4
    addi    r10, r0, 0xFFFF
    sub     r12, r10, r12
    movia   r11, TIMER_FREQ
    stwio   r12, 0(r11)

SKIPCALC:
    movia   r10, TIMER_PIO
    ldwio   r10, 0(r10)
    
    #Stop Timer
    movui   r11, 0x8
    stwio   r11,  4(r10)
    
    #Set period
    movia   r11, TIMER_FREQ
    ldwio   r11, 0(r11)
    sthio   r11, 8(r10)
    srli    r11, r11, 16
    sthio   r11, 12(r10)
    
    #Set ITO, CONT, START bits in timer
    movui   r11, 0x4
    stwio   r11,  4(r10)


    ldwio   ra,  0(sp)
    ldwio   r10, 4(sp)
    ldwio   r11, 8(sp)
    ldwio   r12, 12(sp)
    addi    sp,  sp, 16
    ret
#//------------------------------------
  
.data
DAC_COUNT:   .word   0x00005000
TIMER_FREQ:  .word   0x00000000
TIMER_PIO:   .word   0x00000820
UART_PIO:    .word   0x00000000
SPI_PIO:     .word   0x00000000
SPI_PIO2:    .word   0x00000000
SPI_PIO3:    .word   0x00000000
SPI_PIO4:    .word   0x00000000
