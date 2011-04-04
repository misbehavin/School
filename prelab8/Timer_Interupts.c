#include "nios2_ctrl_reg_marcos.h"

#define TIMER_PIO     0xFFFFFFFF
#define DISPLAY_PIO   0xFFFFFFFF

#define TIMER_IRQ     0x0000

#define STATUS_REG    0x0000
#define IENABLE_REG   0x0003
#define IPENDING_REG  0x0004


int main(void){

    volatile int * timer = (int *) TIMER_PIO;

    __builtin_wrctl(IENABLE_REG,TIMER_IRQ);
    __builtin_wrctl(STATUS_REG, 1);

    




}

void updateTimerFreq(int freq){
    

}


void interrupt_handler(void){
    int pending = __builtin_rdctl(IPENDING_REG);
    if((pending & TIMER_IRQ) == TIMER_IRQ){
        
    }


}



void switches_isr(void);
void interrupt_handler(void){
    int ipending;
    ipending = __builtin_rdctl(4); //Read the ipending register
    if ((ipending & 0x2) == 2){ //If irq1 is high, run pushbutton_isr, otherwise return
        pushbutton_isr();
    }
    return;
}
void pushbutton_isr(void){
    int * red_leds = (int *) LEDR_BASE_ADDRESS;
    volatile int * pushbuttons = (int *) PUSHBUTTONS_BASE_ADDRESS;
    volatile int * switches = (int *) SWITCHES_BASE_ADDRESS;
    *(red_leds) = *(switches); //Make LEDs light up to match switches
    *(pushbuttons+3) = 0; //Disable the interrupt by writing to edgecapture registers of pushbutton PIO
    return;
}

int main(void){
    volatile int * pushbuttons = (int *) PUSHBUTTONS_BASE_ADDRESS;
    *(pushbuttons + 2) = 0x8; //Enable KEY3 to enable interrupts
    __builtin_wrctl(3, 2); //Write 2 into ienable register
    __builtin_wrctl(0, 1); //Write 1 into status register
    while(1);
    return 0;
}