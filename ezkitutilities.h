/*********************************************************************************

Copyright(c) 2006 Analog Devices, Inc. All Rights Reserved.

This software is proprietary and confidential.  By using this software you agree
to the terms of the associated Analog Devices License Agreement.

$RCSfile: ezkitutilities.h,v $
$Revision: 1.1 $
$Date: 2007/03/28 18:48:38 $

Description:
            EZ-Kit utility routines

*********************************************************************************/

#ifndef EZKITUTILITIES_H
#define EZKITUTILITIES_H


/*********************************************************************

Board specific info

*********************************************************************/

#if defined(__ADSP_EDINBURGH__) // ADSP-BF533 EZ-Kit specific info
#define EZ_NUM_LEDS     (6)         // number of LEDs on the board
#define EZ_NUM_BUTTONS  (4)         // number of buttons on the board
#endif
#if defined(__ADSP_BRAEMAR__)   // ADSP-BF537 EZ-Kit specific info
#define EZ_NUM_LEDS     (6)         // number of LEDs on the board
#define EZ_NUM_BUTTONS  (4)         // number of buttons on the board
#endif
#if defined(__ADSP_TETON__)     // ADSP-BF561 EZ-Kit specific info
#define EZ_NUM_LEDS     (16)        // number of LEDs on the board
#define EZ_NUM_BUTTONS  (4)         // number of buttons on the board
#endif
#if defined(__ADSP_STIRLING__)   // ADSP-BF538 EZ-Kit specific info
#define EZ_NUM_LEDS     (6)         // number of LEDs on the board
#define EZ_NUM_BUTTONS  (4)         // number of buttons on the board
#endif
#if defined(__ADSP_MOAB__)   	// ADSP-BF54x EZ-Kit specific info
#define EZ_NUM_LEDS     (6)         // number of LEDs on the board
#define EZ_NUM_BUTTONS  (4)         // number of buttons on the board
#endif
/*********************************************************************

Button / LED Defines

*********************************************************************/
#define EZ_FIRST_BUTTON     (0)                         // First Button
#define EZ_LAST_BUTTON     (EZ_NUM_BUTTONS - 1)        // Last Button

#define EZ_FIRST_LED        (0)                         // First LED
#define EZ_LAST_LED        (EZ_NUM_LEDS - 1)           // Last LED


ADI_FLAG_ID ezButtonToFlag[]; //structure containing the pf mappings for buttons
ADI_FLAG_ID ezLEDToFlag[];	  //structure containing the pf mappings for flags	

/*********************************************************************

Functions provided by the utilities

*********************************************************************/

void    ezInit              (u32 NumCores); // initializes power, ebiu, any async, flash etc.

void    ezInitLED           (u32 Led);      // enables/configures an LED for use
void    ezTurnOnLED         (u32 Led);      // lights an LED
void    ezTurnOffLED        (u32 Led);      // dims an LED
void    ezToggleLED         (u32 Led);      // toggles an LED
void    ezTurnOnAllLEDs     (void);         // light all LEDs
void    ezTurnOffAllLEDs        (void);         // dim all LEDs
void    ezToggleAllLEDs     (void);         // toggle all LEDs
u32     ezIsLEDOn           (u32 Led);      // senses if an LED is lit
void    ezCycleLEDs         (void);         // cycles LEDs
void    ezSetDisplay        (u32 Display);  // sets the LED pattern
u32     ezGetDisplay        (void);         // gets the LED pattern

void    ezInitButton        (u32 Button);   // enables/configures a button for use
u32     ezIsButtonPushed    (u32 Button);   // senses if a button is pushed
void    ezClearButton       (u32 Button);   // clears a latched button

void    ezDelay             (u32 msec);     // delays for approximately 'n' milliseconds

void    ezErrorCheck        (u32 Result);   // lights LEDs and spins to indicate an error if Result != 0

void 	ezReset1836			(void);		//resets ad1836 audio codec

void 	ezEnableVideoEncoder		(void);		// enables the 7183 video encoder
void 	ezEnableVideoDecoder		(void);		// enables the 7171 video decoder
void 	ezDisableVideoDecoder		(void);		// releases PF2 pin from Flag Manager control
void 	ezDisableVideoEncoder		(void);

#endif  // EZKITUTILITIES_H
