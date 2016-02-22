/*****************************************************************************
 * Pulsar.asm
 *****************************************************************************/
/*
	#include <defBF537.h>
	#include "constant.h"
		
	#define CLEAR_ALL_IRQS	0x807F	// Clears ALL RTC Interrupts
 	#define	ctl_reg	= 0;
	#define A_CMD	= 65;  //{-- 'A' --}  
	#define Z_CMD    = 90;  //{-- 'Z' --}
	#define aZ_CMD   = 122; //{-- 'z' --}
	#define S_CMD	= 83;  //{-- 'S' --}
	#define aS_CMD	= 115; //{-- 's' --}
	#define T_CMD	= 84;  //{-- 'T' --}
	#define aF_CMD	= 102; //{-- 'f' --}
//{	#define aT_CMD	= 116; -- 't' --}
	#define P_CMD	= 80;  //{-- 'P' --}
	#define aP_CMD	= 112; //{-- 'p' --}   
	#define R_CMD	= 82;  //{-- 'R' --}
	#define aR_CMD	= 114; //{-- 'r' --}
//{	#define G_CMD   = 71;  -- 'G' --}
//{	#define aG_CMD  = 103; -- 'g' --}
	#define adc_reg  = 0;
	#define Fr_CMD   =71;
	
.SECTION L1_code;
.var tmp;
_main_TMP:
	call Blink_LEDs;
	call init_timers;
	//call init_spi;
	//call init_uart;
	//call init_sport;
	P3.H = hi(PORTFIO_CLEAR);
	P3.L = lo(PORTFIO_CLEAR);
	R0 = 0x0FC0(z);
	W[P3] = R0;			// toggle LED4
	r5 = 0;
wait_forever:
	jump wait_forever;
	//call sintezator;
	
	rts;

Setup_Interrupt_Vectors:
	P0.H = hi(EVT1);
	P0.L = lo(EVT1);

	R0.l = start;
	R0.h = start;
    [p0] = R0;
    
    
    RTS;
    */
/*    
pf_callback:
	[--SP] = RETI;	// Сохранение контекста
	[--SP] = P0;
	[--SP] = ASTAT;
	[--SP] = R0;
	[--SP] = R1;
	[--SP] = R2;
	//R0 = CLEAR_ALL_IRQS(z);
	p0.h = hi(SIC_ISR);
	p0.l = lo(SIC_ISR);
	//r0.h = b#01000(z);		// ПФ а
	r1 = [p0];
	r2 = r0 & r1;
	CC = r1 == 1;
	if CC jump pf_a_callback;
	r0 = b#10000(z);		// ПФ b
	CC = r1 == 1;
	if CC jump pf_b_callback;
pf_a_callback:	
	// do smth for pf_a
	CC = r5 == 0;
	if CC jump tmp1;
	r5 = 0;
	P3.H = hi(PORTFIO_CLEAR);
	P3.L = lo(PORTFIO_CLEAR);
	R0 = 0x0FC0(z);
	W[P3] = R0;			// clear LEDs
	i0.h = hi(Tp);
	i0.l = lo(Tp);
	r0 = 1;
	[i0] = r0;			// Установка флага импульса пульсара Tp
	jump timer_callback_finish;
pf_b_callback:	
	// do smth for pb_b
pf_b_callback_finish:
	R2 = [SP++];
	R1 = [SP++];
	R0 = [SP++];
	ASTAT = [SP++];
	P0 = [SP++];
	RETI = [SP++];
	RTI;
  */  
/*timer_callback:
	[--SP] = RETI;
	[--SP] = P0;
	[--SP] = ASTAT;
	[--SP] = R0;
	[--SP] = R1;
	[--SP] = R2;
	//R0 = CLEAR_ALL_IRQS(z);	// W1C all IRQ Bits
	R7 = 0;
	BITSET (R7,6);			//toggle LED1
	p0.h = hi(SIC_ISR);
	p0.l = lo(SIC_ISR);
	r0 = b#1(z);
	r1 = [p0];
	r2 = r0 & r1;
	CC = r1 == 1;
	if CC jump timer_0_callback;
	r0 = b#10(z);
	CC = r1 == 1;
	if CC jump timer_1_callback;
	r0 = b#100(z);
	CC = r1 == 1;
	if CC jump timer_2_callback;
timer_0_callback:	
	// Прерывание таймера Т0
	CC = r5 == 0;
	if CC jump tmp1;
	r5 = 0;
	P3.H = hi(PORTFIO_CLEAR);
	P3.L = lo(PORTFIO_CLEAR);
	R0 = 0x0FC0(z);
	W[P3] = R0;			// toggle LED4
	jump timer_callback_finish;
tmp1:
	r5 = 1;
	BITSET (R7,7);			// toggle LED2	
	P3.H = hi(PORTFIO_TOGGLE);
	P3.L = lo(PORTFIO_TOGGLE);
	W[P3] = R7;				// Write Value to LEDs 
	W[p0] = R0.L; ssync;	// clear IRQs


	jump timer_callback_finish;
timer_1_callback:
	// Прерывание таймера Т1
	jump timer_callback_finish;
timer_2_callback:	
	// Прерывание таймера Т2
timer_callback_finish:
	BITSET (R7,8);			// toggle LED3

	R2 = [SP++];
	R1 = [SP++];
	R0 = [SP++];
	ASTAT = [SP++];
	P0 = [SP++];
	RETI = [SP++];
	RTI;

Blink_LEDs:

	// set port f function enable register (need workaround)
	p0.l = lo(PORTF_FER);
    p0.h = hi(PORTF_FER);
    r0.l = 0x0000;
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

	// set PORT F direction register
    p0.l = lo(PORTFIO_DIR);
    p0.h = hi(PORTFIO_DIR);
    r0.l = 0x0FC0;
    w[p0] = r0;
    ssync; 
    
   	P3.H = hi(PORTFIO_SET);
	P3.L = lo(PORTFIO_SET);
	R0 = 0x0A80(z);
    W[P3] = R0;
    
	P3.H = hi(PORTFIO_TOGGLE);
	P3.L = lo(PORTFIO_TOGGLE);
	R0 = 0x0FC0(z);
	
	  W[P3] = R0;
	
	RTS;
	
init_timers:
*/	/*P0.H = hi(EVT11);
	P0.L = lo(EVT11);

	R0.l = timer_callback;
	R0.h = timer_callback;  // Default Real Time Clock Handler (Int8)
    [p0] = R0;*/

/*	P0.H = hi(EVT12);
	P0.L = lo(EVT12);

	R0.l = timer_callback;
	R0.h = timer_callback;  // Default Real Time Clock Handler (Int8)
    [p0] = R0;
*/    /*
    R0.l = timer_callback;
	R0.h = timer_callback;  // Default Real Time Clock Handler (Int8)
    [p0++] = R0;*/
    
  /*  P2.H = hi(IMASK);
	P2.L = lo(IMASK);
	R0 = 0x901F(z);
	[P2] = R0;	
    
    P2.H = hi(SIC_IMASK);
	P2.L = lo(SIC_IMASK);
	R0 = 0;
	[P2] = R0;				// Clear SIC_IMASK
			
	BITSET(R6, 12);			// set IVG 11 in R0 (will enable IVG11 in IMASK on "STI R0;")
	
	P1.H = hi(SIC_IAR2);
	P1.L = lo(SIC_IAR2);
	R7 = [p1];
	r7.h = 0x5555;
	r7.l = 0x5444;
	[p1] = r7; ssync;
	
	P1.H = hi(SIC_RVECT);
	P1.L = lo(SIC_RVECT);
	R7 = [p1];
	r7.h = 0x5444;
	r7.l = 0xEF00;
	[p1] = r7; ssync;
	
		// TIMERS Interrupt Unmasked 
	P1.H = hi(SIC_IMASK);
	P1.L = lo(SIC_IMASK);
	R7 = [p1];
	r7.h = 0x0038;
	r7.l = 0x0000;
	[p1] = r7; ssync;

					// Enable Interrupts
	    
*/    	/*
		00 - нет ошибок
		0000
		1 - запуск в процессе эмуляции
		0 - действительное значение PULSE_HIGH в состоянии программирование
		0 - для счетчика использовать SCLK
		0 - разрешение выхода в режиме PWM_OUT
		0 - на выходе сигналы MRx или PF1/ (1 - на выходе сигналы UART RX или PPI_CLK)
		1 - запрос прерывания разрешен
		1 - счетчик до конца PERIOD/ (0 - до конца WIDTH)
		1 - позитивный импульс
		01 - режим PWM_OUT ШИМ*/
/*	p0.l = lo(TIMER0_CONFIG);
    p0.h = hi(TIMER0_CONFIG);
    r0 = b#0000001000011101;
    W[p0] = r0;	
		
	p0.l = lo(TIMER0_PERIOD);
    p0.h = hi(TIMER0_PERIOD);
    r0.h = 0x0000;
    r0.l = 0x000C;
    [p0] = r0;
    
    p0.l = lo(TIMER0_WIDTH);
    p0.h = hi(TIMER0_WIDTH);
    r0.h = 0x0004;
    r0.l = 0;
    [p0] = r0;
	
    p0.l = lo(TIMER_ENABLE);
    p0.h = hi(TIMER_ENABLE);
    r0 = 0x0001(z);
    [p0] = r0;
    
	STI R0;
	P2.H = hi(IMASK);
	P2.L = lo(IMASK);
	R0 = 0x901F(z);
	[P2] = R0;	
    
	rts;
	
init_spi:
    p0.l = lo(SPI_CTL);
    p0.h = hi(SPI_CTL);
*/    /* Передачи начинаются при записи в SPI_TDBR, если SPI_TDBR пуст - передается последнее слово, Blackfin - ведущий, активный уровень 1, SPI - порт разрешен, длина слова - 8 битов*/
   /* r0.l = b#0000000000000001;
    W[p0] = r0;
    p0.l = lo(SPI_BAUD);
    p0.h = hi(SPI_BAUD);
 */   /* Передачи начинаются при записи в SPI_TDBR, если SPI_TDBR пуст - передается последнее слово, Blackfin - ведущий, активный уровень 1, SPI - порт разрешен, длина слова - 8 битов*/
  /*  r0.l = 2;
    W[p0] = r0;
    rts;

init_sport:
	p0.l = lo(SPORT0_TCR1);
    p0.h = hi(SPORT0_TCR1);
   */ /*
    По фронту TSCLK, внутренняя синхронизация, передача разрешена,
    младшими вперед, активный уровень - 1, генерация TFS не зависит
    от данных
     */
   /* r0.l = b#0000000000000011;
    [p0] = r1;
    nop;
    nop;
    nop;
    nop;
    p0.l = lo(SPORT0_TCR2);
    p0.h = hi(SPORT0_TCR2);
*/    /*
    Длина передаваемых слов = 16
     */
   /* r0.l = 15;
    [p0] = r1;
	rts;
	
sintezator:
	p0.l = lo(SPI_TDBR);
	p0.h = hi(SPI_TDBR);
    r0 = 0xF800 (z);
    W[p0] = r0;
    p5 = 1000;
    call delay;
    
    r0 = 0xA000 (z);
    [p0] = r0;
    p5 = 1000;
    call delay;
  */  /* tFt1 - тактвая частота млад.*/
 /*   i0.l = lo(tFt1);
    i0.h = hi(tFt1);
    r0 = [i0];
    r1 = b#0000000011111111;
    r2 = r1 & r0;
    r1 = 0x3000 (z);
    r0 = r1 | r2;
    [p0] = r0;
    r0 = 1000 (z);
    call delay;
    
    r0 = [i0];
    r0.l= r0.l << 8; 	// ??????
    r2 = 0x2100 (z);
    r0 = r1 | r2;
    [p0] = r0;
    p5 = 1000 (z);
    call delay;
    
    i1.l = lo(tFt2);
    i1.h = hi(tFt2);
    r0 = [i1];
    r1 = b#0000000011111111;
    r2 = r1 & r0;
    r1 = 0x3200 (z);
    r0 = r1 | r2;
    [p0] = r0;
    p5 = 1000 (z);
    call delay;
    
    r0 = [i1];
    r0.l= r0.l << 8;		//???????
    r2 = 0x2300 (z);
    r0 = r1 | r2;
    [p0] = r0;
    p5 = 1000 (z);
    call delay;
    
    nop;
    
    r0 = 0xC000 (z); //init sintezator
    [p0] = r0;
    
    nop;
    
    rts;
    
delay:
	LSETUP(delay_start, delay_start) LC0 = p5;
	delay_start: nop;	
	rts;
	
Cycle:
	//r0 = char_ready;			//UART stuff
	CC = r0 == 0;
	if !CC jump Stop;
	i0.l = lo(WaitStart);
    i0.h = hi(WaitStart);
	r0 = [i0];
	CC = r0 == 0;
	if !CC jump Per;	// not 0 -   Старт кадра
	i0.l = lo(Flag);
    i0.h = hi(Flag);
	r0 = [i0];
	CC = r0 == 0;
	if CC jump Cycle;
	r0 = 0;
	[i0] = r0;			// Flag = 1 - from ADC
	
	i0.l = lo(tMr0);
    i0.h = hi(tMr0);
	r0 = [i0];			// counter - 1
	CC = r0 < 0;
	if CC jump Transmit_S;
	
	//call Buf_Save_Item;			// not done
	jump Cycle;
	
Per:
    i0.l = lo(Period);
    i0.h = hi(Period);
	r0 = 0;
	[i0] = r0;
	
	i0.l = lo(tMr1);
    i0.h = hi(tMr1);
	r0 = [i0];
	r1 = 1;
	r0 = r0 - r1;
	
    
	[i0] = r0;
	CC = r0 <= 0;
	if !CC jump New_Get_Frame;
	i0.l = lo(tMr11);
    i0.h = hi(tMr11);
	r0 = [i0];
	CC = r0 <= 0;
	if CC jump Per_next2;
	jump New_Get_frame_1;
Per_next2:
	//imask = b#0000000001; 	//Надо сопоставить
	//call Change_Buffers;  	//Надо доделать
	jump New_Send_Frame;
New_Send_Frame:
	//call Set_Up_Send_Frame;	// Надо доделать
	
New_Get_Frame:	
	//call Set_Up_Get_Frame;	//Надо доделать
	//call Buf_Set_Index;		//Надо доделать
	i0.l = lo(Period);
    i0.h = hi(Period);
	r0 = 0;
	[i0] = r0;
	//imask = b#1010000011;		//Надо сопоставить
	// irq 1 shuts down
	jump Cycle;
	
New_Get_frame_1:
	r1 = 1;
	r0 = r0 - r1;
	i0.l = lo(tMr11);
    i0.h = hi(tMr11);
	[i0] = r0;
	r0 = 0x7FFF (z);		// 
	i0.l = lo(tMr1);
    i0.h = hi(tMr1);
	[i0] = r0;
	jump New_Get_Frame;
	
Transmit_S:
Stop:
	rts;	
	
.SECTION data1; 
.align 4;
	.var 	FlagSt;	//{Flag = 0 - start dialog }
	.var	Flag;	//{Flag = 1 - from ADC}
	.var	Period; //{Flag = 1 - start period}
	.var	WaitStart;
	.var	CCD_LEN;
	.var	CCD_LEN_2;
	.var	Nread;
	.var	Nread2;
	.var	tCCD_LEN;
	.var	tCCD_LEN_2;
	.var	tNread;
	.var	tNread2;
	.var	New_Params;
	.var	CRC;
	.var	Ostatok;
	.var	tx_c;
	.var	tx_2c;
	.var	tMr0;	//{Counter element}
	.var	tMr1;	//{Counter periodov}
	.var	tMr11;	//{Counter periodov}
	.var	stek1;	
	.var	stek2;	
	.var	stek3;	
	.var	stek4;	
	.var	min_;
	.var	s5;	
	.var	s6;	
	.var 	test;	
	.var	Bsempl;
	.var 	tMr5;
	.var	tFt1;
	.var	tFt2;
	.var	odd_shift;
		
	.global	tx_c;
	.global	tx_2c;
	.global tMr1;
	.global Nread;
	.global tMr11;
	.global Nread2;
	.global CCD_LEN;
	.global min_;
	.global tMr0;
	.global Bsempl;
	.global odd_shift;
   	.GLOBAL	_main;*/
