/*#include "constant.h"

.SECTION BufData; 

.var	buf0[4000];
.var	buf1[4000];
.var 	odd_pass;
.var	odd_shift;
.var	h_byte;
.var	l_byte;
.var	send_hi;
.var	Temp_First_DKV;
.var	Temp_Item;
.var	TR_Counter;
.var	Nsempl;
.global	Temp_Item;

.SECTION BufCode;

Init_Buffers:
	/*m0 = 0;
	m1 = 1;
	m2 = 2;
	m3 = 1;
	//m6 = 0;			//!!!
	//m7 = 1;			//!!!
	l0 = 0;
	l1 = 0;
	l2 = 0;
	l3 = 0;
	i0.h = buf1>>16;
	i0.l = buf1;
	i1.h = buf0>>16;
	i1.l = buf0;
	
	r0 = Bsempl;//ar = dm(Bsempl);
	i2.h = Nsempl>>16;
	i2.l = Nsempl;
	[i2] = r0; //Nsempl = r0;
	r0 = 0;
	p5 = 18;*/
	/*LSETUP(Fill0_start, Fill0_end) LC0 = p5;
Fill0_start	[i1+m1] = r0;
Fill0_end:	[i0++m1] = r0;*/
	//rts;
/*	r0 = 1;
	[i1++m1] = r0;
	dm(i0,m1) = ar;
	
	ar = 0;
	LSETUP(Fill1_start, Fill1_end) LC0 = 3981;
Fill1_start:
	ar = ar + 1;
	dm(i1,m1) = ar;
Fill1_end:	dm(i0,m1) = ar;*/
	
	/*ar = 0;
	dm(odd_pass) = ar;
	dm(send_hi) = ar;
	dm(odd_shift) = ar;*/
		
	/*ar = 1;
	dm(odd_pass) = ar;*/
	/*i0 = ^buf1+20;
	i1 = ^buf0+20;
	rts;*/