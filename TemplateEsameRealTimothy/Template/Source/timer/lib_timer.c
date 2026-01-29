/*********************************************************************************************************
**--------------File Info---------------------------------------------------------------------------------
** File name:           lib_timer.h
** Descriptions:        atomic functions to be used by higher sw levels
** Correlated files:    lib_timer.c, funct_timer.c, IRQ_timer.c
**--------------------------------------------------------------------------------------------------------
*********************************************************************************************************/
#include "timer.h"


/*----------------------------------------------------------------------------
  Funzione che abilita il TIMER <timer_num>
*----------------------------------------------------------------------------*/
void enable_timer( uint8_t timer_num )
{
  	if ( timer_num == 0 )
  	{
		LPC_TIM0->TCR = 1;
  	}
  	else if (timer_num == 1)
  	{
		LPC_TIM1->TCR = 1;
 	}
	else if (timer_num == 2)
	{
		LPC_TIM2->TCR = 1;
	}
	else if (timer_num == 3)
	{
		LPC_TIM3->TCR = 1;
	}	
  	return;
}



/*----------------------------------------------------------------------------
  Funzione che disabilita il TIMER <timer_num>
*----------------------------------------------------------------------------*/
void disable_timer( uint8_t timer_num )
{
  	if ( timer_num == 0 )
  	{
		LPC_TIM0->TCR = 0;
  	}
  	else if (timer_num == 1)
  	{
		LPC_TIM1->TCR = 0;
  	}
	else if (timer_num == 2)
	{
		LPC_TIM2->TCR = 0;
	}
	else if (timer_num == 3)
	{
		LPC_TIM3->TCR = 0;
	}
  	return;
}


/*----------------------------------------------------------------------------
  Funzione che resetta il valore del TC di TIMER <timer_num>
*----------------------------------------------------------------------------*/
void reset_timer( uint8_t timer_num )
{
  	uint32_t regVal;

  	if ( timer_num == 0 )
  	{
		regVal = LPC_TIM0->TCR;
		regVal |= 0x02;
		LPC_TIM0->TCR = regVal;
  	}
  	else if (timer_num == 1)
  	{
		regVal = LPC_TIM1->TCR;
		regVal |= 0x02;
		LPC_TIM1->TCR = regVal;
  	}
	else if (timer_num == 2)
	{
		regVal = LPC_TIM2->TCR;
		regVal |= 0x02;
		LPC_TIM2->TCR = regVal;
	}
	else if (timer_num == 3)
	{
		regVal = LPC_TIM3->TCR;
		regVal |= 0x02;
		LPC_TIM3->TCR = regVal;
	}
  	return;
}



/*----------------------------------------------------------------------------
**	init_timer -> Funzione inizializza il timer
** 
**
**	parametri:	timer_num     = timer che si vuole inizializzare
**							Prescaler     = valore di scala su cui lavora il timer: "0" => conta alla massima velocità (normale), "alto" => timer conta molto lentamente 
**							MatchReg      = match register che si vuole utilizzare per il seguente conteggio
**							SRImatchReg   = codice che indica cosa deve fare il timer quando scatta (es: Reset, lancio evento, ...)
**							TimerInterval = valore limite che deve raggiungere il timer per scattare
**
**
************************* VALORI POSSIBILI DI SRImatchReg *******************************************
**
** LPC_TIM0->MCR = 0;   // No Interrupt, No Reset, No Stop
**                      // MR0I = 0, MR0R = 0, MR0S = 0 (interrupt disabled).
**
** LPC_TIM0->MCR = 1;   // Si Interrupt, No Reset, No Stop
**                      // MR0I = 1, MR0R = 0, MR0S = 0 (interrupt enabled, no reset).
**
** LPC_TIM0->MCR = 2;   // No Interrupt, Si Reset, No Stop
**                      // MR0I = 0, MR0R = 1, MR0S = 0 (reset enabled, interrupt disabled).
**
** LPC_TIM0->MCR = 3;   // Si Interrupt, Si Reset, No Stop
**                      // MR0I = 1, MR0R = 1, MR0S = 0 (interrupt and reset enabled).
**
** LPC_TIM0->MCR = 4;   // No Interrupt, No Reset, Si Stop
**                      // MR0I = 0, MR0R = 0, MR0S = 1 (stop enabled, interrupt/reset disabled).
**
** LPC_TIM0->MCR = 5;   // Si Interrupt, No Reset, Si Stop
**                      // MR0I = 1, MR0R = 0, MR0S = 1 (interrupt enabled, no reset, stop enabled).
**
** LPC_TIM0->MCR = 6;   // No Interrupt, Si Reset, Si Stop
**                      // MR0I = 0, MR0R = 1, MR0S = 1 (reset and stop enabled, no interrupt).
**
** LPC_TIM0->MCR = 7;   // Si Interrupt, Si Reset, Si Stop
**                      // MR0I = 1, MR0R = 1, MR0S = 1 (interrupt, reset, and stop enabled).
**
** //	Stop	Reset	Interrupt
** //	0			0			0			= 0
** //	0			0			1			= 1
** //	0			1			0			= 2
** // 0		  1	  	1		  = 3
** //	1			0			0			= 4
** //	1			0			1			= 5
** //	1			1			0			= 6
** //	1			1			1			= 7
*----------------------------------------------------------------------------*/
uint32_t init_timer ( uint8_t timer_num, uint32_t Prescaler, uint8_t MatchReg, uint8_t SRImatchReg, uint32_t TimerInterval )
{
  	if ( timer_num == 0 )
  	{
		LPC_TIM0-> PR = Prescaler;
		
		if (MatchReg == 0){
			LPC_TIM0->MR0 = TimerInterval;
			LPC_TIM0->MCR |= SRImatchReg << 3*MatchReg;			
		}
		else if (MatchReg == 1){
			LPC_TIM0->MR1 = TimerInterval;
			LPC_TIM0->MCR |= SRImatchReg << 3*MatchReg;			
		}
		else if (MatchReg == 2){
			LPC_TIM0->MR2 = TimerInterval;
			LPC_TIM0->MCR |= SRImatchReg << 3*MatchReg;	
		}
		else if (MatchReg == 3){
			LPC_TIM0->MR3 = TimerInterval;
			LPC_TIM0->MCR |= SRImatchReg << 3*MatchReg;	
		}
		NVIC_EnableIRQ(TIMER0_IRQn);			/* enable timer interrupts    */
		NVIC_SetPriority(TIMER0_IRQn, 0);		/* more priority than buttons */
		return (0);
  	}
  	else if ( timer_num == 1 )
  	{
		LPC_TIM1-> PR = Prescaler;
		
		if (MatchReg == 0){
			LPC_TIM1->MR0 = TimerInterval;
			LPC_TIM1->MCR |= SRImatchReg << 3*MatchReg;			
		}
		else if (MatchReg == 1){
			LPC_TIM1->MR1 = TimerInterval;
			LPC_TIM1->MCR |= SRImatchReg << 3*MatchReg;			
		}
		else if (MatchReg == 2){
			LPC_TIM1->MR2 = TimerInterval;
			LPC_TIM1->MCR |= SRImatchReg << 3*MatchReg;	
		}
		else if (MatchReg == 3){
			LPC_TIM1->MR3 = TimerInterval;
			LPC_TIM1->MCR |= SRImatchReg << 3*MatchReg;	
		}		
		NVIC_EnableIRQ(TIMER1_IRQn);
		NVIC_SetPriority(TIMER1_IRQn, 0);	/* less priority than buttons and timer0*/
		return (0);
  	}
	// TIMER 2
	else if ( timer_num == 2 )
  	{
		LPC_TIM2-> PR = Prescaler;
		
		if (MatchReg == 0){
			LPC_TIM2->MR0 = TimerInterval;
			LPC_TIM2->MCR |= SRImatchReg << 3*MatchReg;			
		}
		else if (MatchReg == 1){
			LPC_TIM2->MR1 = TimerInterval;
			LPC_TIM2->MCR |= SRImatchReg << 3*MatchReg;			
		}
		else if (MatchReg == 2){
			LPC_TIM2->MR2 = TimerInterval;
			LPC_TIM2->MCR |= SRImatchReg << 3*MatchReg;	
		}
		else if (MatchReg == 3){
			LPC_TIM2->MR3 = TimerInterval;
			LPC_TIM2->MCR |= SRImatchReg << 3*MatchReg;	
		}		
		NVIC_EnableIRQ(TIMER2_IRQn);
		NVIC_SetPriority(TIMER2_IRQn, 0);	/* less priority than buttons and timer0*/
		return (0);
  	}
	// TIMER 3
	else if ( timer_num == 3 )
  	{
		LPC_TIM3-> PR = Prescaler;
		
		if (MatchReg == 0){
			LPC_TIM3->MR0 = TimerInterval;
			LPC_TIM3->MCR |= SRImatchReg << 3*MatchReg;			
		}
		else if (MatchReg == 1){
			LPC_TIM3->MR1 = TimerInterval;
			LPC_TIM3->MCR |= SRImatchReg << 3*MatchReg;			
		}
		else if (MatchReg == 2){
			LPC_TIM3->MR2 = TimerInterval;
			LPC_TIM3->MCR |= SRImatchReg << 3*MatchReg;	
		}
		else if (MatchReg == 3){
			LPC_TIM3->MR3 = TimerInterval;
			LPC_TIM3->MCR |= SRImatchReg << 3*MatchReg;	
		}		
		NVIC_EnableIRQ(TIMER3_IRQn);
		NVIC_SetPriority(TIMER3_IRQn, 0);	/* less priority than buttons and timer0*/
		return (0);
  	}
	return (1);
}



/*----------------------------------------------------------------------------
  Funzione che commuta il timer <timer_num> => se timer attivo => si disattiva, mentre se timer non attivo => si attiva
*----------------------------------------------------------------------------*/
void toggle_timer( uint8_t timer_num ) {
	if ( timer_num == 0 )
	{
		LPC_TIM0->TCR = !LPC_TIM0->TCR;
	}
	else if (timer_num == 1)
	{
		LPC_TIM1->TCR = !LPC_TIM1->TCR;
	}
	else if (timer_num == 2)
	{
		LPC_TIM2->TCR = !LPC_TIM2->TCR;
	}
	else if (timer_num == 3)
	{
		LPC_TIM3->TCR = !LPC_TIM3->TCR;
	}
	return;
}



/*----------------------------------------------------------------------------
Funzione che ritorna il valore del TC di TIMER <timer_num> (formato: K = T*Fr = [s]*[Hz] = [s]*[1/s] )
*----------------------------------------------------------------------------*/
unsigned int get_timer_value(uint8_t timer_num) {
	if ( timer_num == 0 )
	{
		return LPC_TIM0->TC;
	}
	else if (timer_num == 1)
	{
		return LPC_TIM1->TC;
	}
	else if (timer_num == 2)
	{
		return LPC_TIM2->TC;
	}
	else if (timer_num == 3)
	{
		return LPC_TIM3->TC;
	}
	return -1;
}



/*----------------------------------------------------------------------------
Funzione che ritorna il valore del TC di TIMER <timer_num> (formato: sec)
*----------------------------------------------------------------------------*/
float get_timer_value_in_sec(uint8_t timer_num) {

	switch (timer_num) {
        	case 0:
            		return (float) (LPC_TIM0->TC) / TIMER0_FREQ;
        	case 1:
            		return (float) (LPC_TIM1->TC) / TIMER1_FREQ;
       	 	case 2:
            		return (float) (LPC_TIM2->TC) / TIMER2_FREQ;
        	case 3:
            		return (float) (LPC_TIM3->TC) / TIMER3_FREQ;
       	 	default:
            		return -1; 
    	}
}


/*----------------------------------------------------------------------------
Funzione che ritorna se il timer <timer_num> è abilitato (="1") o meno (="0")
*----------------------------------------------------------------------------*/
uint32_t is_timer_enabled ( uint8_t timer_num){
	
	uint32_t regVal = 0;
	
	switch(timer_num){
		case 0:
			regVal = LPC_TIM0->TCR;
			break;
		case 1:
			regVal = LPC_TIM1->TCR;
			break;		
		case 2:
			regVal = LPC_TIM2->TCR;
			break;
		case 3:
			regVal = LPC_TIM3->TCR;
			break;
	}

	regVal &= 0x00000001;
	return regVal; //Should be 1 if enabled, 0 if disabled
}



/*----------------------------------------------------------------------------
Funzione che alimenta elettricamente il timer 2
*----------------------------------------------------------------------------*/
void power_on_timer2(){
	LPC_SC -> PCONP |= (1 << 22);  // TURN ON TIMER 2
}

/*----------------------------------------------------------------------------
Funzione che alimenta elettricamente il timer 3
*----------------------------------------------------------------------------*/
void power_on_timer3(){
	LPC_SC -> PCONP |= (1 << 23);  // TURN ON TIMER 3	
}





/*----------------------------------------------------------------------------
** Funzione:      blink_init
**
** Descrizione:   Configura un Timer per far lampeggiare i LED a una frequenza
** specifica. Supporta sia il lampeggio infinito che a tempo limitato.
**
** Esempi d'uso:
** 1. Lampeggio INFINITO a 4Hz (Timer 2):
** blink_init(2, 0, 1, 4, 25000000, 0);
**
** 2. Lampeggio per 5 SECONDI a 2Hz (Timer 3):
** blink_init(3, 0, 1, 2, 25000000, 5);
**
** Parametri:
** timer_num   : ID del timer da usare (0, 1, 2, 3)
** mr_off      : Match Register usato per spegnere i LED (es. 0)
** mr_reset    : Match Register usato per riaccendere i LED e resettare il timer (es. 1)
** hz_led      : Frequenza di lampeggio desiderata (es. 4 Hz)
** hz_timer    : Frequenza di clock del timer (su LandTiger solitamente 25000000 = 25MHz)
** sec         : Durata del lampeggio in secondi. 
** (Se 0 o negativo => Lampeggia all'infinito)
**----------------------------------------------------------------------------*/
// --- VARIABILE GLOBALE (Necessaria per il conto alla rovescia) ---
// Va dichiarata 'extern' nel file IRQ_timer.c per poterla decrementare
volatile int blink_cnt = -1; 

void blink_init(int timer_num, int mr_off, int mr_reset, int hz_led, int hz_timer, float sec) {
    
    // 1. Calcolo il periodo totale del timer (Tempo tra due accensioni)
    // Formula: Frequenza Timer / Frequenza Lampeggio
    int total = hz_timer / hz_led;

    // 2. Calcolo il tempo di "ON" (Duty Cycle 50%)
    // I LED staranno accesi per metà periodo e spenti per l'altra metà
    int on = total / 2;

    // 3. Gestione della durata limitata
    if (sec > 0.0f) {
        // Calcolo quanti cicli totali servono.
        // Esempio: 4Hz * 5 secondi = 20 lampeggi totali.
        blink_cnt = (int) (sec * hz_led);
			if (blink_cnt == 0 && sec > 0.0f) {
             blink_cnt = 1; 
        }
    } else {
        // Se sec <= 0, imposto -1 che convenzionalmente significa "Infinito"
        blink_cnt = -1; 
    }

    // 4. Configuro il Match Register per lo SPEGNIMENTO (MR_OFF)
    // Genera interrupt ma NON resetta il timer -> Spegne i LED a metà ciclo
    init_timer(timer_num, 0, mr_off, 1, on);
    
    // 5. Configuro il Match Register per il RESET (MR_RESET)
    // Genera interrupt E resetta il timer -> Riaccende i LED e ricomincia il ciclo
    init_timer(timer_num, 0, mr_reset, 3, total);
    
    // 6. Avvio il timer
    enable_timer(timer_num);
}

/*-------------------------------------------------------------------------------------------------------------------/
**	Funzione per la gestione dell'interrupt di lampeggio (Handler)
**
**	Descrizione: Gestisce l'accensione e lo spegnimento dei LED in base ai flag del Timer.
** Gestisce anche il decremento del contatore per il lampeggio a tempo limitato.
**
**	Parametri:	*TIMx      = puntatore al registro del timer (es. LPC_TIM0, LPC_TIM1...)
** mr_off     = numero del Match Register usato per spegnere i LED (metà ciclo)
** mr_reset   = numero del Match Register usato per riaccendere/resettare (fine ciclo)
** led_num    = numero del LED da pilotare (se 150 => tutti i LED)
** timer_id   = ID numerico del timer (0-3), serve per disabilitarlo a fine conteggio
**
**	NB -> Questa funzione va chiamata ESCLUSIVAMENTE all'interno del TIMERx_IRQHandler.
** Non aggiungere altro codice di gestione flag nell'IRQ se usi questa funzione.
**
**	Esempio chiamata: blink_handler(LPC_TIM2, 0, 1, 150, 2);
**--------------------------------------------------------------------------------------------------------------------*/
void blink_handler(LPC_TIM_TypeDef *TIMx, uint8_t mr_off, uint8_t mr_reset, uint8_t led_num, uint8_t timer_id) {

    // -----------------------------------------------------------------
    // CASO 1: Interrupt generato da MR_OFF (Metà periodo -> Spegnimento)
    // -----------------------------------------------------------------
    if (TIMx->IR & (1 << mr_off)) {
        
        if (led_num == 150) {
            LED_OffAll();       // Spegni tutti
        } else {
            LED_OffAll();   // Spegni led specifico
        }
        
        TIMx->IR = (1 << mr_off); // Pulisci il flag di interrupt
    }
    
    // -----------------------------------------------------------------
    // CASO 2: Interrupt generato da MR_RESET (Fine periodo -> Riaccensione)
    // -----------------------------------------------------------------
    else if (TIMx->IR & (1 << mr_reset)) {
        
        // Gestione del lampeggio a tempo limitato (blink_cnt)
        if (blink_cnt > 0) {
            blink_cnt--; // Decremento il contatore dei cicli rimanenti
            
            // Se il contatore arriva a 0, il tempo è scaduto
            if (blink_cnt == 0) {
                disable_timer(timer_id); // Fermo il timer
                LED_OffAll();            // Pulisco i LED
                blink_cnt = -1;          // Resetto la variabile a stato "inattivo"
                TIMx->IR = (1 << mr_reset); 
                return;                  // Esco senza riaccendere i LED
            }
        }

        // Se sono qui, devo riaccendere i LED (Nuovo ciclo)
        if (led_num == 150) {
            LED_OnAll();
        } else {
            LED_Out(led_num);
        }
            
        TIMx->IR = (1 << mr_reset); // Pulisci il flag di interrupt
    }
}

/******************************************************************************
**                            End Of File
******************************************************************************/
