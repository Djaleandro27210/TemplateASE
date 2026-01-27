/*********************************************************************************************************
**--------------File Info---------------------------------------------------------------------------------
** File name:           lib_RIT.h
** Descriptions:        atomic functions to be used by higher sw levels
** Correlated files:    lib_RIT.c, funct_RIT.c, IRQ_RIT.c
**--------------------------------------------------------------------------------------------------------
*********************************************************************************************************/
#include "LPC17xx.h"
#include "RIT.h"


/*----------------------------------------------------------------------------
  Funzione che attiva il RIT
*----------------------------------------------------------------------------*/
void enable_RIT( void )
{
	LPC_RIT->RICTRL |= (1<<3);	
	return;
}


/*----------------------------------------------------------------------------
  Funzione che disattiva il RIT
*----------------------------------------------------------------------------*/
void disable_RIT( void )
{
	LPC_RIT->RICTRL &= ~(1<<3);	
	return;
}


/*----------------------------------------------------------------------------
  Funzione che resetta il RIT
*----------------------------------------------------------------------------*/
void reset_RIT( void )
{
	LPC_RIT->RICOUNTER = 0;          			// Set count value to 0
	return;
}


/*----------------------------------------------------------------------------
  Funzione che inizializza il rit con il valore di frequenza di funzionamento RITInterval
*----------------------------------------------------------------------------*/
uint32_t init_RIT ( uint32_t RITInterval )
{
	LPC_SC->PCLKSEL1  &= ~(3<<26);
	LPC_SC->PCLKSEL1  |=  (1<<26);   			// RIT Clock = CCLK
	LPC_SC->PCONP     |=  (1<<16);   			// Enable power for RIT
	
	LPC_RIT->RICOMPVAL = RITInterval;     // Set match value		
	LPC_RIT->RICTRL    = (1<<1) |    			// Enable clear on match	
											 (1<<2) ;		 			// Enable timer for debug	
	LPC_RIT->RICOUNTER = 0;          			// Set count value to 0
	
	NVIC_EnableIRQ(RIT_IRQn);
	NVIC_SetPriority(RIT_IRQn,1);
	return (0);
}


/*----------------------------------------------------------------------------
  Funzione che ritorna il valore corrente del RIT
*----------------------------------------------------------------------------*/
unsigned int get_RIT_value() {
	return LPC_RIT->RICOUNTER;
}

/******************************************************************************
**                            End Of File
******************************************************************************/
