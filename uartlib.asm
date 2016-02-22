/*****************************************************************************
**																			**
**	 Name: 	UART0  Software Interface										**	
**																			**
******************************************************************************

Analog Devices, Inc.  All rights reserved.

File Name:	UART0lib.asm

Purpose:	This file contains some library functions
                commonly used on UART0 processing.				

******************************************************************************/

#include <defBF537.h>

// UART_MCR Register
#define LOOP_ENA_P	0x04
#define LOOP_ENA        0x10    /* Loopback Mode Enable */

.section L1_code;

///////// UART0_autobaud //////////////////////////////////////////////////////

/*****************************************************************************
 *
 *  Assuming 8 data bits, this functions expects a '@' (ASCII 0x40) character 
 *  on the UART0 RX pin. 
 *  Timer 2 performs the autobaud detection. Also special support for
 *  half-duplex systems is provided. 
 *
 *  Input parameters: none
 *  Return values: r0 holds timer period value (equals 8 bits)
 *  Assumptions: p0 contains UART0_GCTL register address
 *
 ****************************************************************************/

.global uart_autobaud;
uart_autobaud:

	[--sp] = r2;
	[--sp] = p1;

/*****************************************************************************
 *
 *  First of all, enable UART0 clock. It is required for autobaud detection on 
 *  silicon revision 0.0.
 *
 ****************************************************************************/ 
		
	r0 = UCEN (z);
	w[p0+UART0_GCTL-UART0_GCTL] = r0;
	

/*****************************************************************************
 *
 *  Activate Loopback mode in order the receive channel is disconnected 
 *  from RX pin during autobaud detection.
 *
 ****************************************************************************/ 

 	r0 = LOOP_ENA (z);
	w[p0+UART0_MCR-UART0_GCTL] = r0;	
		
			
/*****************************************************************************
 *
 *  Setup Timer 1 Controller to do the autobaud detection. Timer captures
 *  duration between two falling edges. It expects a '@' (ASCII 0x40) 
 *  character. 8-bit, no parity assumed.
 *
 ****************************************************************************/ 

	p1.h = hi(TIMER_STATUS);
	p1.l = lo(TIMER_STATUS);

		
/*****************************************************************************
 *
 *  Disable Timer 1 first, in case there was an unexpected history.  
 *
 ****************************************************************************/ 

	r0 = TIMDIS1 (z);
	w[p1 + TIMER_DISABLE - TIMER_STATUS] = r0;
	
	r0.l = lo(TRUN1 | TOVL_ERR1 | TIMIL1);
	r0.h = hi(TRUN1 | TOVL_ERR1 | TIMIL1);
	w[p1 + TIMER_STATUS - TIMER_STATUS] = r0;

	 
/*****************************************************************************
 *
 *  Capture from UART0 RxD pin. Select period capture from falling edge to 
 *  falling edge. Enable IRQ_ENA, but don't enable the interrupt at system 
 *  level (SIC). 
 *
 ****************************************************************************/ 
 		
 	r0 = TIN_SEL | IRQ_ENA | PERIOD_CNT | WDTH_CAP (z);				
	w[p1 + TIMER1_CONFIG - TIMER_STATUS] = r0;	

	
/*****************************************************************************
 *
 *  Start the timer and wait until the according interrupt latch bit TIMIL1
 *  in the TIMER_STATUS register is set. Then, two falling edges on the RxD
 *  pin have been detected.
 *
 ****************************************************************************/ 
	p1.h = hi(TIMER_ENABLE);
	p1.l = lo(TIMER_ENABLE);
	r0 =  TIMEN1 (z);
	
	w[p1] = r0;

	p1.h = hi(TIMER_STATUS);
	p1.l = lo(TIMER_STATUS);
	
		
wait_autobaud:
	r0 = w[p1 + TIMER_STATUS - TIMER_STATUS] (z);
	CC = bittst (r0, bitpos (TIMIL1) );
	if !CC jump wait_autobaud;
	

/*****************************************************************************
 *
 *  Disable Timer 1 again  
 *
 ****************************************************************************/ 

 	r0 = TIMDIS1 (z);
	w[p1 + TIMER_DISABLE - TIMER_STATUS] = r0;

	r0.l = lo(TRUN1 | TOVL_ERR1 | TIMIL1);
	r0.h = hi(TRUN1 | TOVL_ERR1 | TIMIL1);
	w[p1 + TIMER_STATUS - TIMER_STATUS] = r0;
	
	 			
/*****************************************************************************
 *
 *  Save period value to R2
 *
 ****************************************************************************/ 

 	r2 = [p1 + TIMER1_PERIOD - TIMER_STATUS]; 
 
 		
/*****************************************************************************
 *
 *  In order to support also half-duplex connections, we need to delay any 
 *  transmission, in order the sent character does not overlap the autobaud
 *  pattern.
 *
 *  Use Timer 1 to perform this delay. Note that the Period Register still
 *  contains the proper value and the Width Register is not used.
 *
 ****************************************************************************/	
	
 	r0 = OUT_DIS | IRQ_ENA | PERIOD_CNT | PWM_OUT (z);				
	w[p1 + TIMER1_CONFIG - TIMER_STATUS] = r0;	
	
	r0 =  TIMEN1 (z);
	w[p1 + TIMER_ENABLE - TIMER_STATUS] = r0;	
	
wait_delay:
	r0 = w[p1 + TIMER_STATUS - TIMER_STATUS] (z);
	CC = bittst (r0, bitpos (TIMIL1) );
	if !CC jump wait_delay;

/*****************************************************************************
 *
 *  Disable Timer 1 again  
 *
 ****************************************************************************/ 

 	r0 = TIMDIS1 (z);
	w[p1 + TIMER_DISABLE - TIMER_STATUS] = r0;

	r0.l = lo(TRUN1 | TOVL_ERR1 | TIMIL1);
	r0.h = hi(TRUN1 | TOVL_ERR1 | TIMIL1);
	w[p1 + TIMER_STATUS - TIMER_STATUS] = r0;	
		
	
/*****************************************************************************
 *
 *  Deactive Loopback mode again
 *
 ****************************************************************************/ 	
		
	r0 = 0 (z);
	w[p0+UART0_MCR-UART0_GCTL] = r0;	

	
/*****************************************************************************
 *
 *  done !
 *
 ****************************************************************************/ 	
		
 	r0 = r2;
 	
	p1 = [sp++];
	r2 = [sp++];		
	
	rts;

uart_autobaud.end:
///////// UART_init //////////////////////////////////////////////////////////

/*****************************************************************************
 *
 *  Configures UART in 8 data bits, no parity, 1 stop bit mode.
 *
 *  Input parameters: r0 holds divisor latch value to be written into
 *                    DLH:DLL registers.
 *  Return values:    none
 *  Assumptions:      p0 contains UARTx_GCTL register address
 *
 ****************************************************************************/

.global uart_init;
uart_init:

	[--sp] = r1;

/*****************************************************************************
 *
 *  First of all, enable UART clock. 
 *
 ****************************************************************************/ 
		
	r1 = UCEN (z);
	w[p0+UART0_GCTL-UART0_GCTL] = r1;

	
/*****************************************************************************
 *
 *  Read period value and apply formula:  DL = PERIOD / 16 / 8
 *  Write result to the two 8-bit DL registers (DLH:DLL).
 *
 ****************************************************************************/ 

 	r1 = DLAB (z);
	w[p0+UART0_LCR-UART0_GCTL] = r1;
 	
	w[p0+UART0_DLL-UART0_GCTL] = r0;
	
	r1 = r0 >> 8;
	w[p0+UART0_DLH-UART0_GCTL] = r1;
	

/*****************************************************************************
 *
 *  Clear DLAB again and set UART frame to 8 bits, no parity, 1 stop bit. 
 *  This may differ in other scenarious.
 *
 ****************************************************************************/ 
	
	r1 = WLS(8) (z);
	w[p0+UART0_LCR-UART0_GCTL] = r1;	

	r1 = [sp++];
	
	rts;

uart_init.end:

///////// UART_wait4temt /////////////////////////////////////////////////////

/*****************************************************************************
 *
 *	This function polls the TEMT bit in the LSR register and waits until
 *  all data has been shifted out.
 *
 *  Input parameters: none
 *  Return values: none
 *  Assumptions: p0 contains UARTx_GCTL register address
 *
 ****************************************************************************/

.global uart_wait4temt;
uart_wait4temt:
	[--sp] = r1;
	
temt_wait:	
	r1 = w[p0+UART0_LSR-UART0_GCTL] (z);
	CC = bittst(r1,bitpos(TEMT));
	if !CC jump temt_wait;			
	
	r1 = [sp++];
	
	nop;
	nop;
		
	ssync;		
					rts;

uart_wait4temt.end:	
		
	
///////// UART_disble ////////////////////////////////////////////////////////

/*****************************************************************************
 *
 *	This function disables the UART clock, but polls the TEMT bit before
 *
 *  Input parameters: none
 *  Return values: none
 *  Assumptions: p0 contains UARTx_GCTL register address
 *
 ****************************************************************************/

.global uart_disable;
uart_disable:
	[--sp] = r0;
	[--sp] = rets;
	
	call uart_wait4temt;
 	
 	r0 = 0 (z);
	w[p0+UART0_GCTL-UART0_GCTL] = r0;

	rets = [sp++];		
	r0 = [sp++];		
	
	rts;

uart_disable.end:	

///////// UART_putc //////////////////////////////////////////////////////////

/*****************************************************************************
 *
 *	This function transmits a character by polling THRE bit in the LSR
 *  register.
 *
 *  Input parameters: r0 holds the character to transmit
 *  Return values: none
 *  Assumptions: p0 contains UARTx_GCTL register address
 *
 ****************************************************************************/

.global uart_putc;
uart_putc:
	[--sp] = r1;	
		
putc_wait:		
	r1 = w[p0+UART0_LSR-UART0_GCTL] (z);
	CC = bittst(r1,bitpos(THRE));
	if !CC jump putc_wait;		
		
	w[p0+UART0_THR-UART0_GCTL] = r0;		
	
	r1 = [sp++];

	rts;

uart_putc.end:	


///////// UART_puts //////////////////////////////////////////////////////////

/*****************************************************************************
 *
 *	This function transmits a byte string by polling THRE bit in the LSR
 *  register. The string must be NULL-terminated (C-style).
 *
 *  Input parameters: p1 holds the start address of the string to transmit
 *  Return values: none
 *  Assumptions: p0 contains UARTx_GCTL register address
 *
 ****************************************************************************/
		
.global uart_puts;	
uart_puts:
	[--sp] = rets;
	[--sp] = r0;
	
puts_loop:
	r0 = b[p1++] (z);
	CC = r0 == 0;
	if CC jump puts_end;		
	call uart_putc;
	jump puts_loop;				

puts_end:
	r0 = [sp++];
	rets = [sp++];
	rts;
uart_puts.end:


///////// UART_putreg ////////////////////////////////////////////////////////

/*****************************************************************************
 *
 *	This function transmits the content of the r0 register in hexdecimal
 *  representation. This is based on polling operation.
 *
 *  Input parameters: r0 holds hex value
 *  Return values: none
 *  Assumptions: p0 contains UARTx_GCTL register address
 *
 ****************************************************************************/

.global uart_putreg;
uart_putreg:
	[--sp] = rets;
	[--sp] = (r7:1, p5:5);
	r1 = r0;

	r0 = 0x20; // ' '
	call uart_putc;
	r0 = 0x30; // '0'
	call uart_putc;
	r0 = 0x78; // 'x'
	call uart_putc;
	
	r2 = 0x0400;
	r3 = 0x0030;
	[--sp] = r3;	
	r4 = 0x0037;
	r5 = 9;
	r6 = 0x1C04;
		
	p5 = 8;		
	lsetup (putreg_lbegin, putreg_lend) lc0=p5;
	
putreg_lbegin:	
		r0 = extract(r1,r6.l)(z) || r3 = [sp];	// Read next nibble	
		CC = r0 <= r5;
		if !CC r3 = r4;		// 0..9 or A..F
		r0 = r0 + r3; 		// Make ASCII
		call uart_putc;		
putreg_lend:
		r6 = r6 - r2; 		// next nibble position
		
	sp+= 4;
	(r7:1, p5:5) = [sp++];
	rets = [sp++];			
	rts; 
uart_putreg.end:







