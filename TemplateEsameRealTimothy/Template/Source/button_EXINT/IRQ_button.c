#include "button.h"
#include "LPC17xx.h"

#include "../led/led.h"
#include "../timer/timer.h"


//variabili globali per la gestione del boundcing
extern int down_0;
extern int down_1;
extern int down_2;


/******************************************************************************
**
**	BOTTONE INT0 PREMUTO
**
******************************************************************************/
void EINT0_IRQHandler (void)	  
{		
	down_0 = 1;
	NVIC_DisableIRQ(EINT0_IRQn);						/* disable Button interrupts	*/
	LPC_PINCON->PINSEL4    &= ~(1 << 20);     				/* GPIO pin selection 		*/
	//-------------------- INIZIO CODICE ----------------------------------------
	
	//-------------------- FINE CODICE ------------------------------------------
	LPC_SC->EXTINT &= (1 << 0);     					/* clear pending interrupt      */
}



/******************************************************************************
**
**	BOTTONE KEY1 PREMUTO
**
******************************************************************************/
void EINT1_IRQHandler (void)	  
{
	down_1 = 1;
	NVIC_DisableIRQ(EINT1_IRQn);						/* disable Button interrupts	*/
	LPC_PINCON->PINSEL4    &= ~(1 << 22);     				/* GPIO pin selection 		*/
	//-------------------- INIZIO CODICE ----------------------------------------
	
	//-------------------- FINE CODICE ------------------------------------------
	LPC_SC->EXTINT &= (1 << 1);     					/* clear pending interrupt      */
}


/******************************************************************************
**
**	BOTTONE KEY2 PREMUTO
**
******************************************************************************/
void EINT2_IRQHandler (void)	  
{
	down_2 = 1;
	NVIC_DisableIRQ(EINT2_IRQn);						/* disable Button interrupts	*/	
	LPC_PINCON->PINSEL4    &= ~(1 << 24);    	 			/* GPIO pin selection 		*/
	//-------------------- INIZIO CODICE ----------------------------------------
	
	//-------------------- FINE CODICE ------------------------------------------
	LPC_SC->EXTINT &= (1 << 2);     					/* clear pending interrupt      */    
}
