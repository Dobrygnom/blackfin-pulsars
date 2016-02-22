	#include <defBF537.h>
	/*#include "constant.h"*/
	#include "uartlib.h"
	#define	Flag_ObservationFinished 	0
	#define Flag_ReadyToSend		 	1
	#define Flag_ADCDataRecieved	 	2
	#define Flag_PulsarPeriod		 	3
	#define Flag_BuffersSwitched	 	4
	
	//.SECTION observation_data;
	.SECTION L1_data;
//	.extern NumOfPeriods;
//	.extern NumOfCycles;
.byte NumOfPeriods = 0;
.byte NumOfCycles = 0;
//	.extern NumOfBufCells;		[TBD] Ask, possibly it is not needed
// Input - output buffers
	//.var	BufferFirst[4000];
	//.var	BufferSecond[4000];
	.byte BufferFirst[4000];
	.byte BufferSecond[4000];
	//.SECTION observation_code;
	.SECTION L1_code;
/***********************************
* Registers used:
* r0 - Number of pulsars period
* r1 - Number of measure cycles
* r2 - Number of output buffer cells. Increments in input cycle.
* r5 = b...43210 - Flags indicator
*		   |||||
*		   |||| \ - Indicates that all pulsar's periods are measured
*		   ||| \ - Indicates that output buffer's data is ready to be sent
*		   ||\ - Indicates that we are ready to read PPI with pulsar's data in it's registers
*		   | \ - Indicates that pulsar's period impulse was recieved from telescope time service
*		    \ - Flag for i/o buffers exchange
[TBD] possibly offsets should be stored in m1 and m0 registers
* r6 - internal usage
* r7 - internal usage
*
* p0 - Input buffer's iterator
* p1 - Output buffer's iterator
* i0 - Input buffer address
* i1 - Output buffer address
************************************
* Input parameters:
* NumOfPeriods - Number of pulsars period
* NumOfCycles - Number of measure cycles
* NumOfBufCells - Number of output buffer cells
*************************************/
.global start_observation;
start_observation:
	RTS;
// Init variables with input parameters	
	i0.l = lo(NumOfPeriods);
    i0.h = hi(NumOfPeriods);
	r0 = [i0];
	i0.l = lo(NumOfCycles);
    i0.h = hi(NumOfCycles);
	r1 = [i0];
// Set initiate value to all registers
	r2 = 0;
	p0 = r1;
	r4 = 0;
	r5 = 0;
	r6 = 0;
	r7 = 0;
// Set i/o buffer addresses	
	i0.l = lo(BufferFirst);
	i0.h = hi(BufferFirst);
	i1.l = lo(BufferSecond);
	i1.h = hi(BufferSecond);
	call cycle_observation;
// 	Cycle is over - send "end" symbol to Comuter
// [TBD]: Add Send command
// Going back to dispatcher
	rts;
/***********************************
* Registers used:
* r0 - r5 same as start_observation
************************************
* Function:
* Does NumOfPeriods pulsar's measurements
************************************/	
cycle_observation:
	CC = bittst(r5, Flag_ObservationFinished);
	if !CC jump try_send_data;		// If Observation is finished - check if data is sent
l_check_ADC:
	CC = bittst(r5, Flag_ADCDataRecieved);
	if CC jump process_ADC_data;
l_check_pulsar_period:	
	CC = bittst(r5, Flag_PulsarPeriod);
	if CC jump process_pulsar_period;
try_send_data:
	CC = bittst(r5, Flag_ReadyToSend);
	if CC jump send_data;
// Exit if voth flags Flag_ReadyToSend and Flag_ObservationFinished are set
	CC = bittst(r5, Flag_ObservationFinished);
	if CC jump l_check_ADC;	// if observation is finished - exit, else - continue
// [TBD] Prepare to exit
	rts;
/****************************
* r6, r7 - internal usage
****************************/	
//[TBD] Try to change to [i0++]
process_ADC_data:
// [TMP] Get data from PPI register to r7
	r6 = [i0];			// Get current buffer data
	r7 = r7 + r6;		// Current data + PPI data
	[i0] = r7;			// Buffer = prev op result
	r6 = 1;
	r3 = r3 - r6;
	CC = r3 == 0;
	if !CC jump process_ADC_data_continue;	// If r3 != NumOfCycles
// Increment number of cells
	r2 = r2 + r6;		// r2++
//	[i0++] = r7;		possibly it solves problem.
	r7 = i0;
	r7 = r7 + r6;		// r7++ ( = i0++)
	i0 = r7;			// Set address to the next cell
process_ADC_data_continue:
	jump l_check_pulsar_period;

/****************************
* r6 - internal usage
****************************/
process_pulsar_period:
	r4 = r2;		// Update ouput buffer's iterator with MaxBufferSize value
	r6 = 1;
	r1 = r1 - r6;
	r2 = 0;
	CC = r1 == 0;
	if !CC jump process_pulsar_period_continue;
	// Swutch buffers
	CC = bittst(r5, Flag_BuffersSwitched);
	if CC jump l_buffers_1;
l_buffers_0:
	//buf second = in
	//buf first = out
	i1.l = lo(BufferFirst);
	i1.h = hi(BufferFirst);
	i0.l = lo(BufferSecond);
	i0.h = hi(BufferSecond);
	jump l_switch_finish;
l_buffers_1:
	//buf first = in
	//buf second = out
	i0.l = lo(BufferFirst);
	i0.h = hi(BufferFirst);
	i1.l = lo(BufferSecond);
	i1.h = hi(BufferSecond);
l_switch_finish:
	bitset(r5, Flag_ReadyToSend);	// Now we are ready to send
	r6 = 1;
	r0 = r0 - r6;
	CC = r0 == 0;
	if !CC jump process_pulsar_period_continue;	// If r0 != 0 continue, else observation finished
	bitset(r5, Flag_ObservationFinished);
process_pulsar_period_continue:	
	jump try_send_data;

send_data:
	CC = r4 == 0;
	if !CC jump send_data_start;
send_data_start:
// If data is sent => set buffer[i] = 0.
	[sp--] = r0;
	r0=[i1++];		// [TBD] mb i1, but not i1++
	call uart_putc;
	r0 = [sp++];
	r6 = 1;
	r4 = r4 - r6;
	jump cycle_observation;	