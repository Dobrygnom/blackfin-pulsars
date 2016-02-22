
/*****************************************************************************
**																			**
**	 Name: 	UART  Software Interface										**	
**																			**
******************************************************************************

(C) Copyright 2003 - Analog Devices, Inc.  All rights reserved.

File Name:		uartlib.h

Date Modified:	04/03/03		bk		Rev 1.0

Software:       VisualDSP++ 3.1 beta

Purpose:		This file contains .extern directives for all library
                functions implemented in uartlib.h				

******************************************************************************/


#ifndef __UARTLIB_HEADER__
#define __UARTLIB_HEADER__

.extern uart_autobaud;
.extern uart_init;
.extern uart_putreg;
.extern uart_putc;
.extern uart_puts;
.extern uart_wait4temt;
.extern uart_disable;

.extern start_observation;

#endif //  __UARTLIB_HEADER__ 
