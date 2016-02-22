#include <defBF537.h>
#include "uartlib.h"

.extern start_observation;
.section L1_data;

.byte sHead[] = 13,10,'Welcome to Supervisor. Type 0 to start observation', 13, 10, 0;
.byte sInputNumOfObservations[] = 13, 10, 'Input number of observations: ', 13, 10, 0;
.byte sStartingObservation[] = 13,10,'Starting observation...', 13, 10, 0;
.byte sFinishObservation[] = 13,10,'Observation finished!', 13, 10, 0;

.align 4;                                

.var aEchoFifo[16];

.section L1_code;

/***********************************************
* Register used:
* p0 - don't modify during code. Pointer to PORTF_FER.
* etc tbd
************************************************/

.global _main;
//_START:
_main:

	[--sp] = rets;
	
	// set FERF registers
	p0.l = lo(PORTF_FER);
    p0.h = hi(PORTF_FER);
    r0.l = 0x0003;
    r1 = w[p0] (z);

#if (__SILICON_REVISION__ < 0x0001)
    ssync;
    w[p0] = r0;
    ssync;
    w[p0] = r0;
    ssync;

#else

    w[p0] = r0;

#endif    
	// Configure UART0 RX and UART0 TX pins
	p0.l = lo(PORT_MUX);
    p0.h = hi(PORT_MUX);
    r0.l = 0x0000;
    r1 = w[p0] (z);
    ssync;
    w[p0] = r0;
    ssync;
    w[p0] = r0;
    ssync;

 	p0.l = lo(UART0_GCTL);
	p0.h = hi(UART0_GCTL);
		
	call uart_autobaud;

 	r0 >>= 7;	
 	
 	call uart_init;
  
	p1.l = lo(IMASK);
	p1.h = hi(IMASK);
	
	r0.l = isr_uart_tx;
	r0.h = isr_uart_tx;
	[p1 + EVT10 - IMASK] = r0;

	r0 = [p1 + IMASK - IMASK];
	bitset(r0, bitpos(EVT_IVG10));
	[p1 + IMASK - IMASK] = r0;
	
	p1.l = lo(SIC_IMASK);
	p1.h = hi(SIC_IMASK);	

	r0.l = 0x1000;
	r0.h = 0x0000;
	[p1] = r0;

	[--sp] = reti;	

	r0 = w[p0+UART0_RBR-UART0_GCTL] (z);
	r0 = w[p0+UART0_LSR-UART0_GCTL] (z);
	r0 = w[p0+UART0_IIR-UART0_GCTL] (z);
				
	r0 = ETBEI;
	w[p0+UART0_IER-UART0_GCTL] = r0;	

	//call uart_wait4temt;
	
	reti = [sp++];	
	
	p1.l = lo(IMASK);
	p1.h = hi(IMASK);	
	
	i0.l = aEchoFifo;
	i0.h = aEchoFifo;
	
	i1 = i0;	
	b0 = i0;
	b1 = i0;
	l0 = length(aEchoFifo);
	l1 = l0;
		
	r0.l = isr_uart_error;
	r0.h = isr_uart_error;
	[p1 + EVT7 - IMASK] = r0;
	
	r0.l = isr_uart_rx;
	r0.h = isr_uart_rx;
	[p1 + EVT8 - IMASK] = r0;	

/*****************************************************************************
 *
 *  Mask EVT10 interrupt and unmask EVT7 and EVT8.
 *
 ****************************************************************************/ 	
	
	r0 = [p1 + IMASK - IMASK];
	bitclr(r0, bitpos(EVT_IVG10));
	bitset(r0, bitpos(EVT_IVG7));
	bitset(r0, bitpos(EVT_IVG8));
	[p1 + IMASK - IMASK] = r0;
	

/*****************************************************************************
 *
 *  Enable and assign interrupts.
 *
 ****************************************************************************/ 	
		
	p1.l = lo(SIC_IMASK);
	p1.h = hi(SIC_IMASK);	
		
	r0.l = 0xF0FF;
	r0.h = 0xFFFF;
	[p1 + SIC_IAR0 - SIC_IMASK] = r0;	
	
	r0.l = 0x1FFF;
	r0.h = 0xFFFF;	
	[p1 + SIC_IAR1 - SIC_IMASK] = r0;			

	r0.l = 0xFFFF;
	r0.h = 0xFFFF;
	[p1 + SIC_IAR2 - SIC_IMASK] = r0;
	
	r0.l = 0xFFFF;
	r0.h = 0xFFFF;
	[p1 + SIC_IAR3 - SIC_IMASK] = r0;

	r0.l = 0x0804;
	r0.h = 0x0000;
	[p1 + SIC_IMASK - SIC_IMASK] = r0;	
 	
	[--sp] = reti;	

	r0 = w[p0+UART0_RBR-UART0_GCTL] (z);
	r0 = w[p0+UART0_LSR-UART0_GCTL] (z);
	r0 = w[p0+UART0_IIR-UART0_GCTL] (z);
				
	r0 = ELSI | ERBFI;
	w[p0+UART0_IER-UART0_GCTL] = r0;
	r2 = -1;
supervisor_loop:	
	r1 = -1;
	CC = r1 == r2;
	if !CC jump supervisor_loop_0;
		p1.l = sHead;
		p1.h = sHead;
		call uart_puts;
		call uart_wait4temt;
		r2 = 0;
		jump supervisor_loop;
supervisor_loop_0:
	r1 = 1;
	CC = r1 == r2;
	if !CC jump supervisor_loop_1;
		p1.l = sInputNumOfObservations;
		p1.h = sInputNumOfObservations;
		call uart_puts;
		call uart_wait4temt;
		r2 = 2;
		jump supervisor_loop;
supervisor_loop_1:
	r1 = 3;
	CC = r1 == r2;
	if !CC jump supervisor_loop_2;
		p1.l = sStartingObservation;
		p1.h = sStartingObservation;
		call uart_puts;
		call uart_wait4temt;
		call start_observation;
		p1.l = sFinishObservation;
		p1.h = sFinishObservation;
		call uart_puts;
		call uart_wait4temt;
		r2 = -1;
supervisor_loop_2:
	jump supervisor_loop;
	
_main.end: nop;	
	

isr_uart_tx:
	
	[--sp] = r0;

	r0 = b[p3++] (z);
	CC = r0 == 0;
	
	if CC jump isr_tx_done;
	
	w[p0+UART0_THR-UART0_GCTL] = r0;
	
	nop;
	nop;	

	ssync;
	r0 = [sp++];
	rti;		
	
isr_tx_done:

	r0 = w[p0+UART0_IIR-UART0_GCTL] (z); 

	ssync;
	r0 = [sp++];
	rti;		

isr_uart_tx.end:	


isr_uart_rx:
	
	[--sp] = r0;
	[--sp] = r1;

	r0 = w[p0+UART0_RBR-UART0_GCTL] (z);
		
	[i0++] = r0;
	
	r1 = 0;		// Initial state
	CC = r2 == r1;
	if !CC jump isr_uart_continue_1;
		r1 = 0x30;		// start observation
		CC = r0 == r1;
	
		if !CC jump isr_uart_end;
			r2 = 1 (z); // Set start observation bit
			jump isr_uart_end;
isr_uart_continue_1:
	r1 = 2;		// Read number of Observations
	CC = r2 == r1;
	if !CC jump isr_uart_end;
		r2 = 3 (z);
		r3 = r0;
		jump isr_uart_end;
isr_uart_end:
	nop;
	ssync;	
	r1 = [sp++];
	r0 = [sp++];
	rti;
	
isr_uart_rx.end:	
	
isr_uart_error:

	[--sp] = r0;	
	
	r0 = w[p0+UART0_LSR-UART0_GCTL] (z);
		
	r0 = 0xFF (z);
	[i0++] = r0;
	
	ssync;
	r0 = [sp++];
	rti;	

isr_uart_error.end:		
	
		

		
