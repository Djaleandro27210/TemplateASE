	;PRESERVE8
    ;THUMB
					
	;AREA input_data, READONLY, ALIGN=4
    ;LTORG       ; Inserisce il literal pool qui
	;ALIGN 2
;DATA_IN  	DCB  0x0A,	0x01, 0x13, 0x02, 0x04, 0x06, 0x0F, 0x0A ; Dati definiti nel literal pool
	;ALIGN 2
;N 		 	DCD 8
	;ALIGN 2

	;AREA output_data, READWRITE, ALIGN=4
;BEST_3 		DCB 0x0, 0x0, 0x0
	;ALIGN 2
	
	;EXPORT DATA_IN
	;EXPORT N
	;EXPORT BEST_3	
	;NOTA BENE, LA AREA READONLY NON E' ASSOLUTAMENTE MODIFICALE E RISCRIVIBILE
	
	
	;NOTE TEORICHE MIE:
	;--estrazione v[i]-----
	; Formato: LDR RegistroDest, [Base, Indice, LSL #Shift]
	;LDRB R4, [R0, R1, LSL #0] ; OFFSET = i * 1 (Dati a 8 bit / BYTE)  (char, uint8_t)
	;LDRH R4, [R0, R1, LSL #1] ; OFFSET = i * 2 (Dati a 16 bit / HALF-WORD) (short, uint16_t)
	;LDR  R4, [R0, R1, LSL #2] ; OFFSET = i * 4 (Dati a 32 bit / WORD) (int, uint32_t, ptr,long)
	;
	;
	;i tasti sulla scheda sono: Sulla scheda sono in ordine: KEY 1 ---- KEY 2 ---- INT 0	
	;
	;
	;
	;
	;
	AREA asm_functions, CODE, READONLY	
	
;FUNZIONE ASSEMBLY GENERICA CONSIDERATA
	EXPORT  asm_funct
asm_funct FUNCTION
	
	;RO = address of VETT
	;R1 = VAL
	;R2 = N
	
	; save current SP for a faster access 
	; to parameters in the stack
	MOV   r12, sp
	; save volatile registers
	STMFD sp!,{r4-r8,r10-r11,lr}				
	
	;STMFD sp!,{R0-R3}
	;MOV R1,R0 ; ho bisogno di VETT address in R1
	;MOV R0,R2 ; bsort ha bisogno di N in R0
	;BL bsort
	;LDMFD sp!,{R0-R3}
	;; extract argument 4 and 5 into R4 and R5
	;LDR   r4, [r12]
	;LDR   r5, [r12,#4]
	;LDR   r6, [r12,#8]
				
	; setup a value for R0 to return
	; restore volatile registers
	LDMFD sp!,{r4-r8,r10-r11,pc}				
	ENDFUNC			
		


;------------------------------------------- bubblesort ----------------------------------------------------------
;--
;--
;-- parametri: R0 = indirizzo del vettore da ordinare (vettore di elementi in byte)
;--			   R1 = numero di elementi del vettore da ordinare 
;--
;-- ritorno:   X
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT bubblesort				
bubblesort PROC
	MOV   r12, sp
	STMFD sp!,{r4-r8,r10-r11,lr}				
			
	; ALGORITMO 
	MOV R5, R1
	MOV	R11, #1
				
	SUBS R1, R1, #1
	BEQ exit_bubblesort
					
while_bubblesort	
	CMP		R11, #1
	BNE		exit_bubblesort
				
	MOV 	R5, R1
	MOV 	R6, #0
	MOV		R7, #1
	MOV		R11, #0

for_bubblesort				
	LDRB	R4, [R0, R6] 
	;LDR	R4, [R0, R6, LSL#2] ;se il vettore in word
	LDRB	R8, [R0, R7]
	;LDR	R8, [R0, R7, LSL#2] ;se il vettore in word
	CMP		R8, R4
	;CMP	R4, R8 ;ordine Cresente
	MOVGT	R11, #1
	STRBGT	R8, [R0, R6]
	;STRGT	R8, [R0, R6, LSL#2]
	STRBGT	R4, [R0, R7]
	;STRGT	R4, [R0, R7, LSL#2]
				
	ADD 	R6, R6, #1
	ADD		R7, R7, #1
				
	SUBS 	R5, R5, #1
	BNE 	for_bubblesort
	BEQ		while_bubblesort

exit_bubblesort
	; restore volatile registers
	LDMFD sp!,{r4-r8,r10-r11,pc}		
	ENDP
	
	
;------------------------------------------- call_svc --------------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------		
	EXPORT  call_svc
call_svc FUNCTION
; save current SP for a faster access 
	; to parameters in the stack
	;MOV   r12, sp
	; save volatile registers
	MOV   r12, sp
	STMFD sp!,{r4-r8,r10-r11,lr}		
	MOV R0,R13 ;PASS INTO THE SVC HANDLER ADDRESS OF PSP			
	; your code
	SVC 0x15
	B .
	LDMFD sp!,{r4-r8,r10-r11,pc}					
	; restore volatile registers
	;LDMFD sp!,{pc}
	ENDFUNC
	
		
		
;------------------------------------------- isPrime --------------------------------------------------------------
;--
;--	parametri: R0 = numero da testare
;--
;-- ritorno:   ="1" se il numero è primo, "0" se il numero non è primo
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT isPrime
isPrime			FUNCTION
				stmfd sp!, {r4-r8, r10-r11, lr}
								
				cmp r0,#0
				beq not_primep
				cmp r0, #3
				ble primep
				
				mov r1, r0		;original number
				sub r2, r1, #1	;test number
				;while test number > 1: perform original_number % test_number, it it's 0 -> prime
				;if test_number reaches 1 -> not prime
				;linear complexity
				
whilep			;check test_number > 1
				cmp r2, #1
				ble primep
				
				;perform r1 % r2
				bl calc_mod
				;result in r0
				;if remainder == 0 -> not prime
				cmp r0, #0
				beq not_primep
				
				;test_number --
				sub r2, r2, #1
				;loop back
				b whilep

not_primep		mov r0, #0
				ldmfd sp!, {r4-r8, r10-r11, pc}
				
primep			mov r0, #1
				ldmfd sp!, {r4-r8, r10-r11, pc}
				ENDFUNC
					
					
					
;------------------------------------------- calc_mod ------------------------------------------------------------
;--
;--	parametri: R0 = numeratore
;-- 		   R1 = denominatore
;--
;-- ritorno:   R0%R1 = R0 mod R1 => resto della divisione intera di R0 e R1
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT calc_mod
calc_mod		FUNCTION
				STMFD sp!,{r4-r8,r10-r11,lr}
				;calcolo la divisione
				udiv r2, r1, r0 ;r2 = r1/r0
				mls r0, r2, r1, r0 ;metto in r0 il resto intero di r0/r1=r2 => r0= r0-(r2*r1)
				;result in r0
				
				LDMFD sp!,{r4-r8,r10-r11,pc}

				ENDFUNC
					
					
;------------------------------------------- check_lowerCase -----------------------------------------------------
;--
;--	parametri: R0 = parola da analizzare
;--
;-- ritorno:   =1 se parola tutta a caratteri lower, =0 altrimenti
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT check_lowerCase
check_lowerCase		FUNCTION
				STMFD sp!,{r4-r8,r10-r11,lr}
				
				cmp r0, #'a'
				blt nope
				cmp r0, #'z'
				bgt nope
				
				mov r0, #1
				bx lr
	
nope			mov r0, #0
				LDMFD sp!,{r4-r8,r10-r11,pc}
				ENDFUNC



;------------------------------------------- check_upperCase -----------------------------------------------------
;--
;--	parametri: R0 = parola da analizzare
;--
;-- ritorno:   =1 se parola tutta a caratteri upper, =0 altrimenti
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT check_upperCase
check_upperCase		FUNCTION
				STMFD sp!,{r4-r8,r10-r11,lr}
				
				cmp r0, #'A'
				blt nope2
				cmp r0, #'Z'
				bgt nope2
				
				mov r0, #1
				bx lr
	

nope2			mov r0, #0
				LDMFD sp!,{r4-r8,r10-r11,pc}
				ENDFUNC
				
				
				
;------------------------------------------- do_2_complement (32bit) ---------------------------------------------
;--
;--	parametri: R0 = numero su cui effettuare il complemento a 2 (a 32 bit) -> inverto tutti i bit e sommo "1"
;--
;-- ritorno:      = valore in complemento a 2 calcolato
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT do_2_complement
do_2_complement	FUNCTION
				STMFD sp!,{r4-r8,r10-r11,lr}	
				;number in r0
				mvn r0, r0 ;inverto tutti i bit di r0
				add r0, r0, #1
				LDMFD sp!,{r4-r8,r10-r11,pc}	
				ENDFUNC
	


;------------------------------------------- do_2_complement (64bit) ----------------------------------------------
;--
;--	parametri: R0 = parte alta (32 bit piu significativi)
;--            R1 = parte bassa (32 bit meno significativi)
;--
;-- ritorno:   R0 = parte alta modificata (vero valore di ritorno), R1 = parte bassa modificata (rimanenza => non ripristinare)
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT do_2_complement_64
do_2_complement_64	FUNCTION
				STMFD sp!,{r4-r8,r10-r11,lr}
				;r0 UPPER 32 BITS
				;r1 LOWER 32 BITS

				;two's complement of both upper and lower bits
				mvn r0, r0
				mvn r1, r1
				;add 1 to the lower 32 bits
				;if the lower 32 bits are all 1 -> overflow -> this means we're gonna add 1 to the ;upper 32 bits instead
				adds r1, r1, #1
				;check if overflow of lower 32 bits
				bvc no_overflow_2c	;no overflow
				;overflow: propagate the sum of 1 to the upper 32 bits
				add r0, r0, #1
				
				;RESULT IN R0 (UPPER BITS) AND R1 (LOWER BITS)
no_overflow_2c	LDMFD sp!,{r4-r8,r10-r11,pc}
				ENDFUNC
				
				
					
;------------------------------------------- count_leading_zero---------------------------------------------------
;--
;--	parametri: R0 = valore da analizzare => ritorna il numero di '0' nella cifra binaria prima di avere un '1'
;--
;-- ritorno:   R0 = numero di '0' contati prima di avere un '1' (da sx a dx)
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT count_leading_zero
count_leading_zero FUNCTION
	MOV   r12, sp
	; ro is value to count leading zero 	
	STMFD sp!,{r4-r8,r10-r11,lr}	
	
	CLZ R0,R0 ;count leading zero 
		
	LDMFD sp!,{r4-r8,r10-r11,pc}	
	ENDFUNC
	
	
	
;------------------------------------------- count_bit1 ----------------------------------------------------------
;--
;--	parametri: R0 = valore da analizzare => voglio contare su di esso il numero di bit a '1' presenti
;--
;-- ritorno:   R0 = numero di '1' presenti nel valore numerico passato
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT count_bit1
count_bit1 FUNCTION
	; in R0 dovrà esserci il numero in cui bisogna contare gli 1
	MOV   r12, sp
	STMFD sp!,{r4-r8,r10-r11,lr}		
			
	MOV R1, #32  ; numero di cifre del numero (BINARIO)
	MOV R2, #0   ; variabile che conterra il numero di 1
				
loopCountBit1	
	LSLS R0, R0, #1   
	ADDCS R2, R2, #1 ;incremento <=> carry bit settato = il bit che abbiamo buttato fuori sopra era =1
				
	SUBS R1, R1, #1
	BNE loopCountBit1
				
	MOV R0, R2
	
	LDMFD sp!,{r4-r8,r10-r11,pc}	
	ENDFUNC
	
	
	
;------------------------------------------- count_bit0 ----------------------------------------------------------
;--
;--	parametri: R0 = valore da analizzare => voglio contare su di esso il numero di bit a '0' presenti
;--
;-- ritorno:   R0 = numero di '0' presenti nel valore numerico passato
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT count_bit0
count_bit0 FUNCTION
	; in R0 dovrà esserci il numero in cui bisogna contare gli 0
	MOV   r12, sp
	STMFD sp!,{r4-r8,r10-r11,lr}		
			
	MOV R1, #32  ; numero di cifre del numero (BINARIO)
	MOV R2, #0   ; variabile che conterra il numero di 0
				
loopCountBit0	
	LSLS R0, R0, #1   
	ADDCC R2, R2, #1 ;incremento <=> carry bit clear = il bit che abbiamo buttato fuori sopra era =0
				
	SUBS R1, R1, #1
	BNE loopCountBit0
				
	MOV R0, R2
	
	LDMFD sp!,{r4-r8,r10-r11,pc}	
	ENDFUNC	
	


;------------------------------------------- get_max -------------------------------------------------------------
;--
;--	parametri: R0 = indirizzo del vettore contenente i dati da analizzare (vettore di celle da 32bit)
;--            R1 = dimensione del vettore da analizzare 
;--
;-- ritorno:   R0 = valore massimo trovato tra quelli presenti nel vettore
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT get_max
get_max FUNCTION
	
	MOV   r12, sp
	STMFD sp!,{r4-r8,r10-r11,lr}	
	
	LDR R6, [R0], #4         ; Carica il primo elemento dell'array in R6 (massimo iniziale)
	SUBS R1, R1, #1          ; Decrementa la dimensione (R1 = dim - 1)
	BLE exitMax              ; Se R1 <= 0, salta direttamente all'uscita

loopMax
	LDR R4, [R0], #4         ; Carica l'elemento corrente in R4 e avanza il puntatore R0
	CMP R4, R6               ; Confronta l'elemento corrente (R4) con il massimo attuale (R6)
	MOVGT R6, R4             ; Se R4 > R6, aggiorna il massimo in R6
	SUBS R1, R1, #1          ; Decrementa il contatore R1
	BGT loopMax              ; Ripeti finchè R1 > 0

exitMax
	MOV R0, R6               ; Salva il massimo trovato in R0 (registro di ritorno)
	
	LDMFD sp!,{r4-r8,r10-r11,pc}	
	ENDFUNC



;------------------------------------------- get_min -------------------------------------------------------------
;--
;--	parametri: R0 = indirizzo del vettore contenente i dati da analizzare (vettore di celle da 32bit)
;--            R1 = dimensione del vettore da analizzare 
;--
;-- ritorno:   R0 = valore minimo trovato tra quelli presenti nel vettore
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT get_min
get_min FUNCTION
	
	MOV   r12, sp
	STMFD sp!,{r4-r8,r10-r11,lr} ; Salva i registri callee-saved nello stack
	
	LDR R6, [R0], #4         ; Carica il primo elemento dell'array in R6 (minimo iniziale)
	SUBS R1, R1, #1          ; Decrementa la dimensione (R1 = dim - 1)
	BLE exitMin              ; Se R1 <= 0, salta direttamente all'uscita

loopMin
	LDR R4, [R0], #4         ; Carica l'elemento corrente in R4 e avanza il puntatore R0
	CMP R4, R6               ; Confronta l'elemento corrente (R4) con il minimo attuale (R6)
	MOVLT R6, R4             ; Se R4 < R6, aggiorna il minimo in R6
	SUBS R1, R1, #1          ; Decrementa il contatore R1
	BGT loopMin              ; Ripeti finch� R1 > 0

exitMin
	MOV R0, R6               ; Salva il minimo trovato in R0 (registro di ritorno)
	
	LDMFD sp!,{r4-r8,r10-r11,pc} ; Ripristina i registri e ritorna
	ENDFUNC



;------------------------------------- is_monotonic_increasing --------------------------------------------------
;--
;--	parametri: R0 = indirizzo del vettore contenente i valori della funzione (vettore di celle da 32bit)
;--            R1 = dimensione del vettore da analizzare 
;--
;-- ritorno:   R0 = '1' se crescente, '0' se non crescente
;--
;-----------------------------------------------------------------------------------------------------------------
    EXPORT is_monotonic_increasing
is_monotonic_increasing FUNCTION

    MOV   r12, sp
	STMFD sp!,{r4-r8,r10-r11,lr} ; Salva i registri callee-saved nello stack

    CMP R1, #1                  ; Verifica se il vettore ha al massimo un elemento
    BLE exitTrue_in             ; Un vettore con 0 o 1 elemento � monotono crescente

    LDR R4, [R0], #4            ; Carica il primo elemento dell'array in R4
    SUBS R1, R1, #1             ; Decrementa la dimensione (R1 = dim - 1)

loopCheck_in
    LDR R5, [R0], #4            ; Carica l'elemento successivo in R5
    CMP R4, R5                  ; Confronta l'elemento precedente (R4) con l'elemento corrente (R5)
    MOVGT R0, #0                ; Se R4 > R5, il vettore non � monotono crescente
    BGT exitFalse_in            ; Esce con "false" (0) se non � monotono crescente
    MOV R4, R5                  ; Aggiorna R4 con l'elemento corrente
    SUBS R1, R1, #1             ; Decrementa il contatore R1
    BGT loopCheck_in            ; Continua finch� ci sono elementi da verificare

exitTrue_in
    MOV R0, #1                  ; Imposta il risultato a "true" (1)
    B endFunction_is_monotonic_increasing               ; Salta alla fine

exitFalse_in
    MOV R0, #0                  ; Imposta il risultato a "false" (0)

endFunction_is_monotonic_increasing
	LDMFD sp!,{r4-r8,r10-r11,pc} ; Ripristina i registri e ritorna
    ENDFUNC



;------------------------------------- is_monotonic_decreasing --------------------------------------------------
;--
;--	parametri: R0 = indirizzo del vettore contenente i valori della funzione (vettore di celle da 32bit)
;--            R1 = dimensione del vettore da analizzare 
;--
;-- ritorno:   R0 = '1' se decrescente, '0' se non decrescente
;--
;-----------------------------------------------------------------------------------------------------------------
    EXPORT is_monotonic_decreasing
is_monotonic_decreasing FUNCTION

    MOV   r12, sp
	STMFD sp!,{r4-r8,r10-r11,lr} ; Salva i registri callee-saved nello stack

    CMP R1, #1                  ; Verifica se il vettore ha al massimo un elemento
    BLE exitTrue_de             ; Un vettore con 0 o 1 elemento � monotono crescente

    LDR R4, [R0], #4            ; Carica il primo elemento dell'array in R4
    SUBS R1, R1, #1             ; Decrementa la dimensione (R1 = dim - 1)

loopCheck_de
    LDR R5, [R0], #4            ; Carica l'elemento successivo in R5
    CMP R4, R5                  ; Confronta l'elemento precedente (R4) con l'elemento corrente (R5)
    MOVLT R0, #0                ; Se R4 < R5, il vettore non è monotono decrescente
    BLT exitFalse_de            ; Esce con "false" (0) se non è monotono decrescente
    MOV R4, R5                  ; Aggiorna R4 con l'elemento corrente
    SUBS R1, R1, #1             ; Decrementa il contatore R1
    BGT loopCheck_de            ; Continua finchè ci sono elementi da verificare

exitTrue_de
    MOV R0, #1                  ; Imposta il risultato a "true" (1)
    B endFunction_is_monotonic_decreasing               ; Salta alla fine

exitFalse_de
    MOV R0, #0                  ; Imposta il risultato a "false" (0)

endFunction_is_monotonic_decreasing
	LDMFD sp!,{r4-r8,r10-r11,pc} ; Ripristina i registri e ritorna
    ENDFUNC


;------------------------------------- sub_abs ------------------------------------------------------------------
;--
;--	parametri: R0 = operando 1
;--            R1 = operando 2
;--
;-- ritorno:   R0 = (R0 - R1) se questa è >0, altrimenti -(RO - R1)
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT abs_value
abs_value FUNCTION
	; save current SP for a faster access 
	; to parameters in the stack
	MOV   r12, sp
	; save volatile registers
	STMFD sp!,{r4-r8,r10-r11,lr}				
	    
	CMP R0,R1
	;r0<=r1
	RSBLT R0,R0,R1 ;r1-r0
	;r0>r1
	SUBGE R0,R0,R1 ;r0-r1
	
	; setup a value for R0 to return
	; restore volatile registers
	LDMFD sp!,{r4-r8,r10-r11,pc}
	
	ENDFUNC
	


;------------------------------------- value_is_in_range ---------------------------------------------------------
;--
;--	parametri: R0 = valore considerato da ricercare
;--            R1 = estremo inferiore (min) del range
;--  		   R2 = estremo superiore (max) del range
;--
;-- ritorno:   '1' se valore compreso tra min e max, '0' altrimenti
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT value_is_in_a_range
value_is_in_a_range FUNCTION
    ; Save current SP for faster access to parameters in the stack
    MOV     r12, sp
    ; Save volatile registers
    STMFD   sp!, {r4-r8, r10-r11, lr}

    ; Compare VALUE with MIN
    CMP     R0, R1
    BLO     outOfRange      ; If VALUE < MIN, branch to outOfRange

    ; Compare VALUE with MAX
    CMP     R0, R2
    BHI     outOfRange      ; If VALUE > MAX, branch to outOfRange

    ; If VALUE is within the range
    MOV     R0, #1          ; Set R0 to 1 (true)
    B       exitFuncV         ; Branch to exit

outOfRange
    MOV     R0, #0          ; Set R0 to 0 (false)

exitFuncV
    ; Restore volatile registers
    LDMFD   sp!, {r4-r8, r10-r11, pc}

    ENDFUNC
	
	
	
;------------------------------------------ array_sum ------------------------------------------------------------
;--
;--	parametri: R0 = indirizzo del vettore considerato (composto da elementi in 8bit)
;--            R1 = numero di elementi del vettore
;--
;-- ritorno:   somma di tutti gli elementi contenuti nel vettore
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT array_sum
array_sum FUNCTION
    ; Save current SP for faster access to parameters in the stack
    MOV     r12, sp
    ; Save volatile registers
    STMFD   sp!, {r4-r8, r10-r11, lr}
	;--------- INIZIO CODICE ------------
	MOV r4, #0 ;inizializzo il contatore del ciclo a 0
	MOV r5, #0 ;inizializzo il sommatore degli elementi del ciclo a 0
for_array_sum
	CMP R4,R1 ;confronto r5 e r1
	BEQ end_for_array_sum ;se ho ciclato su tutti gli elementi => fine
	;dentro il ciclo
	LDRB R6, [R0, R4] ;r6= vett[r4] NB: non metto ",LSL #2" perche non sto lavorando con word ma con byte => uso LDRB
	;LDR R6, [R0, R4, LSL#2]
	ADD R5, R5, R6 ;sommatore+= vett[r4]
	;incremento il contatore
	ADD R4,R4,#1 ;R4++
	B for_array_sum
end_for_array_sum
	MOV R0, R5 ;ritorno la somma risultante
	LDMFD sp!,{r4-r8,r10-r11,pc}
	ENDFUNC
	
	
	
;------------------------------------------ array_avg ------------------------------------------------------------
;--
;--	parametri: R0 = indirizzo del vettore considerato (composto da elementi in 8bit)
;--            R1 = numero di elementi del vettore
;--
;-- ritorno:   media tra tutti gli elementi contenuti nel vettore
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT array_avg
array_avg FUNCTION
	
    ; Save current SP for faster access to parameters in the stack
    MOV     r12, sp
    ; Save volatile registers
    STMFD   sp!, {r4-r8, r10-r11, lr}
	;--------- INIZIO CODICE ------------
	;chiamata alla procedura dove userò come parametri R0 e R1 
	;faccio la somma
	BL array_sum 
	;faccio la divisione (in r0 ho il numeratore ottenuto da array_sum e in r1 ho ancora la dimensione da prima
	UDIV r0, r0, r1
	;ho in r0 il risultato della divisione = media
	LDMFD sp!,{r4-r8,r10-r11,pc}
	ENDFUNC
	
;------------------------------------------ array_search ------------------------------------------------------------
;--
;--	parametri: R0 = indirizzo del vettore considerato (composto da elementi in 8bit)
;--            R1 = numero di elementi del vettore
;--            R2 = elemento da ricercare nell'array
;--
;-- ritorno:   R0= indice posizionale dell'elemento se trovato, altrimenti R0= dimensione vettore
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT array_search
array_search FUNCTION
	
    ; Save current SP for faster access to parameters in the stack
    MOV     r12, sp
    ; Save volatile registers
    STMFD   sp!, {r4-r8, r10-r11, lr}
	;--------- INIZIO CODICE ------------
	MOV R4, #0 ;inizializzo il ciclo del contatore a 0
	
for_array_search CMP R4,R1	;confronto il contatore con il numero di elementi del vettore
	BEQ endfor_array_search
	;dentro il ciclo
	LDRB R5, [R0, R4] ;R5= vett[R4]
	;LDR R5, [R0, R4, LSL#2] (se lavoro con i 32 bit)
	
	;confronto il valore dell'elemento corrente con quello da verificare
	CMP R5, R2
	BEQ endfor_array_search ;se vett[R4]= elemento cercato => fine 
	
	;altrimenti continuo
	ADD R4,R4, #1	;R4++
	B for_array_search
	
endfor_array_search ;fine ciclo 
	MOV R0, R4	;metto in r0 l'iterazione a cui sono arrivato => se uguale alla dimensione del vettore => non trovato
	
	;ho in r0 l'indice posizionale dell'elemento nell'array
	LDMFD sp!,{r4-r8,r10-r11,pc}
	ENDFUNC
	
	
	
;------------------------------------------ array_max_difference -------------------------------------------------
;--
;--	parametri: R0 = indirizzo del vettore considerato (composto da elementi in 8bit)
;--            R1 = numero di elementi del vettore
;--
;-- ritorno:   R0= valore della massima differenza tra gli elementi del vettore
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT array_max_difference
array_max_difference FUNCTION
	
    ; Save current SP for faster access to parameters in the stack
    MOV     r12, sp
    ; Save volatile registers
    STMFD   sp!, {r4-r8, r10-r11, lr}
	;--------- INIZIO CODICE ------------
	
	;calcolo il massimo
	PUSH{r0, r1, r2, r3}
	BL get_max
	;salvo il massimo in r5
	MOV r5, r0
	POP{r0, r1, r2, r3}
	
	;calcolo il minimo
	PUSH{r0, r1, r2, r3}
	BL get_min
	;salvo il minimo in r6
	MOV r6, r0
	POP{r0, r1, r2, r3}
	
	;metto in r0 la massima differenza computata come massimo - minimo
	SUB r0, r5,r6 ;valore di ritorno = massimo-minimo del vettore
	
	;ho in r0 l'indice posizionale dell'elemento nell'array
	LDMFD sp!,{r4-r8,r10-r11,pc}
	ENDFUNC
	
	
	
;----------------------------------------------- ascii_to_int ----------------------------------------------------
;--
;--	parametri: R0 = indirizzo del numero in formato stringa (ascii) da convertire (vettore di char=8bit) => termina con \0
;--
;-- ritorno:   R0= valore intero corrispondente (UNSIGNED)
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT ascii_to_int
ascii_to_int FUNCTION
	
    ; Save current SP for faster access to parameters in the stack
    MOV     r12, sp
    ; Save volatile registers
    STMFD   sp!, {r4-r8, r10-r11, lr}
	;--------- INIZIO CODICE ------------
	
	MOV 	R4, R0		;R4 = Puntatore stringa
	MOV 	R0, #0		;R0 = Risultato accumulatore
	MOV 	R5, #10		;Costante 10 per moltiplicazione

loop_atoi
	LDRB 	R6, [R4], #1	;Carica carattere e avanza
	
	;Controllo fine stringa ='0'
	CMP 	R6, #0
	BEQ 	end_atoi
	
	;Controllo se è un numero ('0'=48, '9'=57)
	CMP 	R6, #48
	BLT 	end_atoi	; Se < '0', fine (carattere non valido)
	CMP 	R6, #57
	BGT 	end_atoi	; Se > '9', fine (carattere non valido)
	
	;Non ho saltato => procedo con la conversione in intero
	SUB 	R6, R6, #48	;= digit es: voglio avere '3' => carattere ascii-48 = 3
	
	;Formula: tot = (tot * 10) + digit
	MUL 	R0, R0, R5	; R0= R0 * 10
	ADD 	R0, R0, R6	; R0= R0 + digit
	;torno su
	B 		loop_atoi

end_atoi
	
	;ho in r0 il valore intero convertito
	LDMFD sp!,{r4-r8,r10-r11,pc}
	ENDFUNC
	
	
	
;----------------------------------------------- int_to_ascii ----------------------------------------------------
;--
;--	parametri: R0 = numero intero (32bit) da convertire in stringa
;--			   R1 = indirizzo della cella di memoria in cui scrivere la stringa 
;-- ritorno:   X
;--
;-----------------------------------------------------------------------------------------------------------------
	EXPORT int_to_ascii
int_to_ascii FUNCTION
	
    ; Save current SP for faster access to parameters in the stack
    MOV     r12, sp
    ; Save volatile registers
    STMFD   sp!, {r4-r8, r10-r11, lr}
	;--------- INIZIO CODICE ------------
	
	MOV 	R4, R0		;R4= numero da convertire
	MOV 	R5, #0		;R5= contatore cifre
	MOV 	R6, #10		;R6= costante di divisione => 10
	
	;caso particolare => =0 (loop non partirebbe => me ne occupo subito)
	CMP 	R4, #0
	BNE 	loop_extract_itoa
	MOV 	R0, #48		;ASCII di '0'
	STRB 	R0, [R1], #1
	B 		terminate_string_itoa

	;ciclo di estrazione delle cifre
loop_extract_itoa
	CMP 	R4, #0
	BEQ 	loop_store_itoa	;se numero=0 => ho finito di estrarre!
	
	;calcolo r4/10 e rest0
	UDIV 	R7, R4, R6	;R7= R4/10 (Quoziente)
	MUL 	R8, R7, R6	;R8= Quoziente*10
	SUB 	R8, R4, R8	;R8= R4-R8 = resto =cifra che ci interessa
	
	;converto la cifra in ASCII (es. 3 -> '3')
	ADD 	R8, R8, #48	;sommo 48
	
	PUSH 	{R8}		;salvo nello stack => devo invertire l'ordine
	ADD 	R5, R5, #1	;incremento contatore cifre trovate
	
	MOV 	R4, R7		;aggiorno il numero => n/=10
	B 		loop_extract_itoa

loop_store_itoa
	;scrivo in memoria il risultato
	CMP 	R5, #0
	BEQ 	terminate_string_itoa
	
	POP 	{R0}	;recupero la cifra in ordine inverso
	STRB 	R0, [R1], #1	;scrivo in memeoria la cifra e avanzo il puntatore
	SUBS 	R5, R5, #1	;decremento il contatore che conta le cifre rimaste
	B 		loop_store_itoa

terminate_string_itoa
	;aggiungo il carattere di fine stringa'\0'
	MOV 	R0, #0
	STRB 	R0, [R1]

	LDMFD sp!,{r4-r8,r10-r11,pc}
	ENDFUNC	
	
	
	
;----------------------- FUNZIONE RICHIESTA ------------------------------------------------
	EXPORT nome_funzione_richiesta
nome_funzione_richiesta FUNCTION
	
    ; Save current SP for faster access to parameters in the stack
    MOV     r12, sp
    ; Save volatile registers
    STMFD   sp!, {r4-r8, r10-r11, lr}
	;--------- INIZIO CODICE --------- 
	
	;--------- FINE CODICE ---------- 
	LDMFD sp!,{r4-r8,r10-r11,pc}
	ENDFUNC
	
;----------------------- FINE FUNZIONE RICHIESTA -----------------------------------------------	

;-----------------------PROVE ESAME ---------------------------------------------------------------;

; ---------------------------------------------------------------------------------
; compute_statistics: Calcola statistiche passeggeri.
; Input: R0=Salita[], R1=Discesa[], R2=LenSalita, R3=LenDiscesa, [SP+32]=PtrMaxOut
; Output: R0 = Tempo totale trascorso con il numero massimo di passeggeri a bordo
; ---------------------------------------------------------------------------------
	EXPORT compute_statistics 
compute_statistics FUNCTION
	STMFD sp!,{r4-r8,r10-r11,lr}    ; Save context

	LDR r4, [sp, #32]               ; Load 5th param (MaxPass ptr)

	; Init
	MOV R5, R0          ; R5 = Salita ptr copy
	MOV R0, #0          ; R0 = Total Time (Result)
	MOV R6, #0          ; R6 = Current Passengers
	MOV R7, #0          ; R7 = Max Passengers Recorded
	MOV R11, #0         ; R11 = Prev Time
	MOV R12, #0         ; R12 = Delta Time

outerloop
	CMP R2, #0          ; Salita finished?
	BEQ exity           

	LDR R8, [R5]        ; R8 = Next Salita Time
	LDR R9, [R1]        ; R9 = Next Discesa Time

	; --- Time Calculation ---
	CMP R8, R9          
	MOVLT R10, R8       ; R10 = Current Event Time (Min)
	MOVGT R10, R9       
	
	SUB R12, R10, R11   ; Delta = Current - Prev
	MOV R11, R10        ; Update Prev

	; --- Accumulate Time ---
	CMP R6, R7          ; If Current == Max
	ADDEQ R0, R0, R12   ; Add Delta to Total Time in R0

	; --- Next Step Decision ---
	CMP R8, R9          
	BGT next_discesa    ; Salita > Discesa
	BLT next_salita     ; Salita < Discesa

next_salita
	ADD R6, R6, #1      ; Pass++

	CMP R7, R6          
	MOVLT R7, R6        ; Update Max if new record
	MOVLT R0, #0        ; Reset time R0 if new max found

	ADD R5, R5, #4      ; Ptr++
	ADD R2, R2, #-1     ; Count--
	B outerloop         

next_discesa
	ADD R6, R6, #-1     ; Pass--
	
	CMP R3, #0          ; Check Discesa bounds
	ADDNE R1, R1, #4    ; Ptr++
	ADDNE R3, R3, #-1   ; Count--
	B outerloop         

exity
	STRB R7, [R4]       ; Store Max Passengers to memory
	
	; Alla fine: R0 = Tempo totale trascorso alla massima occupazione
	LDMFD sp!,{r4-r8,r10-r11,pc}
	ENDFUNC



; ---------------------------------------------------------------------------------
; vincitore: Trova i primi 3 valori massimi in un array e li salva nei puntatori.
; Input: R0=Votazioni[], R1=N, R2=Ptr1°, R3=Ptr2°, [SP+32]=Ptr3°
; Nota: La funzione "distrugge" i vincitori nell'array originale mettendoli a 0.
; ---------------------------------------------------------------------------------
	EXPORT vincitore
vincitore FUNCTION
	PUSH {R4-R10, LR}

	LDR R4, [SP, #32]       ; Carico puntatore 3° posto dallo stack
	MOV R5, R0              ; R5 = Base Array
	SUB R9, R1, #1          ; R9 = Indice Ultimo Elemento (N-1)
	MOV R10, #0             ; R10 = Contatore podio (0=Start, 1=1st, 2=2nd, 3=3rd)

search_restart
	; --- Reset variabili per nuova ricerca ---
	MOV R7, R9              ; R7 = Indice corrente (parte dal fondo)
	MOV R1, R9              ; R1 = Indice del Max temporaneo
	LDR R6, [R5, R1, LSL #2]; R6 = Valore Max temporaneo (V[N-1])

inner_loop
	CMP R7, #0              ; Finito array?
	BEQ found_max           ; Se sì, abbiamo trovato il vincitore corrente

	SUB R7, R7, #1          ; i--
	LDR R8, [R5, R7, LSL #2]; R8 = V[i]
	
	CMP R8, R6              ; Confronto V[i] con Max Attuale
	MOVGT R6, R8            ; Se V[i] > Max, aggiorna valore Max
	MOVGT R1, R7            ; Se V[i] > Max, aggiorna indice Max
	
	B inner_loop            ; Continua ricerca

found_max
	; --- Gestione Vincitore Trovato ---
	MOV R12, #0
	STR R12, [R5, R1, LSL #2] ; Azzero il valore nell'array per non ritrovarlo dopo

	ADD R10, R10, #1        ; Podio step ++
	
	CMP R10, #1
	BEQ store_1st
	CMP R10, #2
	BEQ store_2nd
	CMP R10, #3
	BEQ store_3rd

store_1st
	STR R6, [R2]            ; Salva valore 1° posto
	B search_restart        ; Cerca il prossimo

store_2nd
	STR R6, [R3]            ; Salva valore 2° posto
	B search_restart        ; Cerca il prossimo

store_3rd
	STR R6, [R4]            ; Salva valore 3° posto
	; Finito, esco.

	POP {R4-R10, PC}
	ENDFUNC



; ---------------------------------------------------------------------------------
; Funzione: fibonacci
;
; 1. COSA FA:
;    - Genera una sequenza di Fibonacci di lunghezza 'n' partendo da due semi (num1, num2).
;    - Memorizza la sequenza nell'array puntato da 'vett_fib'.
;    - Confronta gli elementi di un secondo array 'vett_random' con la sequenza generata.
;    - Conta quanti numeri del 'vett_random' sono presenti nella serie di Fibonacci (Intersezione).
;
; 2. PARAMETRI IN INGRESSO:
;    R0 = num1 (Primo numero della serie)
;    R1 = num2 (Secondo numero della serie)
;    R2 = n    (Lunghezza della serie di Fibonacci da generare)
;    R3 = m    (Lunghezza del vettore di numeri casuali)
;    STACK 5° Argomento ([SP+36]) = Indirizzo base di VETT_RANDOM
;    STACK 6° Argomento ([SP+40]) = Indirizzo base di VETT_FIB
;
; 3. PARAMETRI IN USCITA:
;    R0 = Numero di corrispondenze trovate (Count delle intersezioni)
; ---------------------------------------------------------------------------------
	EXPORT fibonacci
fibonacci FUNCTION
	PUSH {R4-R11, LR}       ; Salvataggio contesto (9 registri -> 36 bytes)

	; --- RECUPERO PARAMETRI DALLO STACK ---
	LDR R4, [SP, #36]       ; R4 = Indirizzo base VETT_RANDOM
	LDR R5, [SP, #40]       ; R5 = Indirizzo base VETT_FIB
	
	; --- FASE 1: GENERAZIONE FIBONACCI ---
	MOV R11, R5             ; R11 = Puntatore scorrimento VETT_FIB
	STR R0, [R11], #4       ; Scrivo num1 in memoria (Fib[0])
	STR R1, [R11], #4       ; Scrivo num2 in memoria (Fib[1])
	ADD R9, R2, #0          ; R9 = Copia di 'n' (lunghezza Fib) per i loop successivi
	
loop_vettore_fib
	ADD R8, R0, R1          ; Calcolo prossimo: Fib[i] = Fib[i-1] + Fib[i-2]
	ADD R2, R2, #-1         ; Decremento contatore n
	STR R8, [R11], #4       ; Memorizzo il nuovo numero in VETT_FIB
	
	; Shift dei valori per il prossimo ciclo
	ADD R0, R1, #0          ; Fib[i-2] diventa Fib[i-1]
	ADD R1, R8, #0          ; Fib[i-1] diventa Fib[i] (nuovo calcolato)
	
	CMP R2, #2              ; Controllo se ho generato n numeri
	BNE loop_vettore_fib
	
	; --- FASE 2: CONTEGGIO INTERSEZIONI (MATCH) ---
	MOV R0, #0              ; R0 diventa il contatore di match (Valore di Ritorno)
	
valore_vett_rand            ; Loop Esterno: Scorre VETT_RANDOM
	ADD R3, R3, #-1         ; m-- (scorro random dall'ultimo al primo)
	CMP R3, #-1             ; Se m < 0, ho finito di controllare tutti i numeri random
	BEQ exit_outer_loop
	
	LDR R10, [R4, R3, LSL #2] ; Carico elemento corrente da VETT_RANDOM in R10
	MOV R2, #0              ; Reset indice j=0 per scorrere VETT_FIB
	
valore_vett_fib             ; Loop Interno: Scorre VETT_FIB generato prima
	LDR R11, [R5, R2, LSL #2] ; Carico elemento da VETT_FIB in R11
	
	CMP R11, R10            ; Confronto Fib[j] con Random[i]
	BEQ valore_uguale       ; Se uguali, salto a incremento contatore
	
	ADD R2, R2, #1          ; j++
	CMP R2, R9              ; Controllo se ho finito di scorrere Fibonacci (j < n)
	BEQ valore_vett_rand    ; Se finito senza match, passo al prossimo numero random
	BNE valore_vett_fib     ; Altrimenti continuo a cercare

valore_uguale
	ADD R0, R0, #1          ; Match trovato: incremento risultato (R0++)
	B valore_vett_rand      ; Passo al prossimo numero random
	
exit_outer_loop
	POP {R4-R11, PC}        ; Ripristino registri e ritorno al chiamante (R0 contiene il risultato)
	
	ENDFUNC
	

; ---------------------------------------------------------------------------------
; Funzione: updateRank
;
; 1. COSA FA:
;    - Inserisce un nuovo punteggio (score) in un array ordinato in modo decrescente.
;    - Conta gli elementi attuali e shifta l'array per fare spazio al nuovo valore.
;    - Controlla se il nuovo punteggio rientra nelle prime 3 posizioni (Podio).
;    - Calcola la differenza (Delta) tra il punteggio massimo (1°) e minimo (ultimo).
;
; 2. PARAMETRI IN INGRESSO:
;    R0 = score (uint8_t) -> Il punteggio da inserire
;    R1 = indirizzo classifica (uint8_t*) -> Array ordinato
;    R2 = indirizzo maxDiff (uint8_t*) -> Dove salvare la differenza Max-Min
;    R3 = indirizzo podio (uint8_t*) -> Dove salvare il flag (1=Podio, 0=No)
;
; 3. PARAMETRI IN USCITA:
;    R0 = Posizione in classifica ottenuta (1-based: 1=Primo, 2=Secondo, ecc.)
; ---------------------------------------------------------------------------------

	EXPORT updateRank
updateRank FUNCTION
	PUSH {R4-R11, LR}
	
	MOV R4, R0          ; R4 = Score da inserire
	MOV R5, #0          ; R5 = Indice scorrimento (i)
	MOV R8, #1          ; R8 = Contatore elementi (N). Parte da 1 se consideriamo lo 0 finale? 
	                    ; (Nota: Dal codice sembra contare gli elementi validi prima dello 0)
	
	; Reset Flag Podio
	MOV R6, #0
	STRB R6, [R3]       
	
	; --- FASE 1: CONTA GLI ELEMENTI ATTUALI ---
conta_elementi
	ADD R10, R8, #-1        ; Indice k = N-1 (Offset)
	LDRB R6, [R1, R10]      ; Leggi byte dall'array
	CMP R6, #0              ; È il terminatore (0)?
	BEQ fine_conteggio
	ADD R8, R8, #1          ; N++
	B conta_elementi
	
fine_conteggio
	ADD R8, R8, #-1         ; R8 = Numero elementi validi (Size attuale dell'array)

	; --- FASE 2: CERCA LA POSIZIONE DI INSERIMENTO ---
loop_esterno
	CMP R5, R8              ; Se siamo arrivati in fondo (i == Size)
	BEQ back                ; Inseriamo in coda
	
	LDRB R6, [R1, R5]       ; Leggi valore corrente
	CMP R4, R6              ; Confronto Score vs Corrente
	BGT inserisci           ; Se Score > Corrente, ho trovato la mia posizione
	
	ADD R5, R5, #1          ; Altrimenti avanza (i++)
	B loop_esterno
	
	; --- FASE 3: SHIFT ARRAY (FAI SPAZIO) ---
inserisci
	; Devo spostare tutto da 'i' in poi verso destra.
	; Parto dal fondo (nuova posizione R8) e copio R8-1 in R8.
	MOV R7, R8              ; J parte dalla fine (Size attuale, che diventerà Size+1)
	
loop_shift
	CMP R7, R5              ; Se J == indice inserimento, ho finito lo shift
	BEQ back
	
	SUB R9, R7, #1          ; Sorgente = J-1
	LDRB R6, [R1, R9]       ; Leggi elemento precedente
	STRB R6, [R1, R7]       ; Scrivi in posizione attuale (Shift Destra)
	
	SUB R7, R7, #1          ; J--
	B loop_shift

	; --- FASE 4: SCRITTURA E CHECK PODIO ---
back
	STRB R4, [R1, R5]       ; Scrivo il nuovo SCORE nel "buco" creato o in coda
	
	ADD R0, R5, #1          ; Calcolo Posizione (1-based) per il return
	
	CMP R0, #3              ; Controllo Podio (Posizione <= 3)
	BGT calcola_diff        ; Se > 3, niente podio
	
	MOV R6, #1
	STRB R6, [R3]           ; Setto flag Podio = 1

calcola_diff
	; --- FASE 5: CALCOLA DIFFERENZA MAX - MIN ---
	; Il MAX è sempre in testa (indice 0) perché l'array è decrescente.
	; Il MIN è in coda. Dato che ho aggiunto un elemento, la coda è all'indice R8.
	
	LDRB R11, [R1]          ; Carico il Primo (Max)
	LDRB R10, [R1, R8]      ; Carico l'Ultimo (Min) - Nota: R8 è la nuova dimensione -1
	SUB R6, R11, R10        ; Diff = Max - Min
	STRB R6, [R2]           ; Salvo il risultato nel puntatore maxDiff
	
	POP {R4-R11, PC}
	ENDFUNC
	
	

; ---------------------------------------------------------------------------------
; Funzione: compute_statistics
;
; 1. COSA FA:
;    - Simula l'andamento temporale di una partita tra HOME e GUEST.
;    - Gli array contengono i timestamp in cui è stato segnato il punto corrispondente all'indice.
;    - Scorre gli array cronologicamente, saltando i valori 0 (punti non assegnati).
;    - Ad ogni cambio di punteggio, calcola il vantaggio (Valore Assoluto |HOME - GUEST|).
;    - Memorizza il massimo vantaggio raggiunto durante il match.
;    - Determina il vincitore finale.
;
; 2. PARAMETRI IN INGRESSO:
;    R0 = Array HOME (uint32_t*)  -> Timestamp dei punti casa
;    R1 = Array GUEST (uint32_t*) -> Timestamp dei punti ospiti
;    R2 = Ptr maxAdvantage (uint8_t*) -> Indirizzo dove salvare il max distacco
;
; 3. PARAMETRI IN USCITA:
;    R0 = Vincitore (1 = HOME, 2 = GUEST, 0 = Pareggio)
; ---------------------------------------------------------------------------------

	EXPORT compute_statistics2 
compute_statistics2 PROC
	PUSH 	{R4-R11, LR} 		
	
	MOV 	R4, #0 				; R4 = Punteggio Attuale HOME
	MOV 	R5, #0 				; R5 = Punteggio Attuale GUEST
	MOV 	R6, #0 				; R6 = MaxAdvantage (Record)
	MOV 	R11, #0xFFFFFFFF 	; R11 = Valore sentinella (Infinito)

main_loop
	; --- 1. CERCA PROSSIMO EVENTO HOME ---
	MOV 	R9, R4 				; Start search from current score
find_next_h
	ADD 	R9, R9, #1 			; Next index
	CMP 	R9, #17 			; Check bounds (Max score HOME)
	BGE 	no_more_h 			
	LDR 	R7, [R0, R9, LSL #2]; Load timestamp
	CMP 	R7, #0 				; Skip invalid times (0)
	BEQ 	find_next_h 		
	B 		found_h 			
no_more_h
	MOV 	R7, R11 			; Set time to Infinity
found_h
	; R7 = Next Home Time, R9 = Potential New Score Home

	; --- 2. CERCA PROSSIMO EVENTO GUEST ---
	MOV 	R10, R5 			; Start search from current score
find_next_g
	ADD 	R10, R10, #1 		; Next index
	CMP 	R10, #16 			; Check bounds (Max score GUEST)
	BGE 	no_more_g 			
	LDR 	R8, [R1, R10, LSL #2]; Load timestamp
	CMP 	R8, #0 				; Skip invalid times (0)
	BEQ 	find_next_g 		
	B 		found_g 			
no_more_g
	MOV 	R8, R11 			; Set time to Infinity
found_g
	; R8 = Next Guest Time, R10 = Potential New Score Guest

	; --- 3. CONFRONTA TEMPI E AGGIORNA ---
	CMP 	R7, R11 			; Home finished?
	CMPEQ 	R8, R11 			; AND Guest finished?
	BEQ 	end_stats 			; Both done -> Exit

	CMP 	R7, R8 				; Compare timestamps
	
	; Aggiorno il punteggio SOLO di chi ha segnato prima (tempo minore)
	MOVLO 	R4, R9 				; If TimeH < TimeG -> Update Home Score
	MOVHS 	R5, R10 			; If TimeG <= TimeH -> Update Guest Score

	; --- 4. CALCOLA VANTAGGIO ---
	SUBS 	R12, R4, R5 		; Diff = Home - Guest
	RSBMI 	R12, R12, #0 		; ABS(Diff)
	
	CMP 	R12, R6 			; Check against Max
	MOVHI 	R6, R12 			; Update Max if record broken

	B 		main_loop 			; Next iteration

end_stats
	STRB 	R6, [R2] 			; Store Max Advantage result

	; Determina Vincitore
	CMP 	R4, R5
	MOVHI 	R0, #1 				; Winner = HOME
	MOVLS 	R0, #2 				; Winner = GUEST (assume no draw or Guest wins draws)
	MOVEQ 	R0, #0 				; (Optional: Draw)

	POP 	{R4-R11, PC}
	ENDP



; ---------------------------------------------------------------------------------
; Funzione: compute_sum_and_ranges
;
; 1. COSA FA:
;    - Scorre un vettore di numeri a 16 bit (half-word).
;    - Calcola la somma totale di tutti gli elementi del vettore.
;    - Conta quanti elementi cadono nell'intervallo [LowerBound, UpperBound] (inclusi).
;    - Restituisce la somma in R0 e scrive il conteggio range in memoria.
;
; 2. PARAMETRI IN INGRESSO:
;    R0 = Indirizzo base del vettore (uint16_t*)
;    R1 = Lunghezza del vettore (N)
;    R2 = Lower Bound (Limite inferiore range)
;    R3 = Upper Bound (Limite superiore range)
;    STACK 5° Argomento ([SP+28]) = Indirizzo puntatore Rc (Dove scrivere il conteggio)
;
; 3. PARAMETRI IN USCITA:
;    R0 = Somma totale degli elementi
; ---------------------------------------------------------------------------------
	EXPORT compute_sum_and_ranges
compute_sum_and_ranges PROC
	PUSH {R4-R9, LR}    ; Salva 7 registri -> 7 * 4 = 28 byte di offset

	; --- Recupero 5° argomento (Rc ptr) ---
	LDR R4, [SP, #28]   ; Legge l'indirizzo di Rc dallo stack

	MOV R5, R0          ; R5 = Base address vettore (copia sicura)
	MOV R0, #0          ; R0 = Accumulatore Somma
	MOV R7, #0          ; R7 = Indice i
	MOV R9, #0          ; R9 = Contatore valori nel range (Result Count)
	
loop	
	CMP R7, R1          ; Fine vettore?
	BEQ exit_somma
	
	LSL R6, R7, #1      ; Offset = i * 2 (poiché sono Half-Word 16bit)
	LDRH R8, [R5, R6]   ; R8 = Vett[i] (Load Half-word)
	
	ADD R0, R0, R8      ; Somma += Valore
	ADD R7, R7, #1      ; i++
	
	; --- Controllo Range [Lower, Upper] ---
	CMP R8, R2
	BLT loop            ; Se Valore < Lower, salta (fuori range)
	
	CMP R8, R3
	BGT loop            ; Se Valore > Upper, salta (fuori range)
	
	ADD R9, R9, #1      ; Se arrivo qui, è dentro il range: Count++
	B loop
		
exit_somma
	STR R9, [R4]        ; Scrivo il conteggio nell'indirizzo Rc
	POP {R4-R9, PC}
	ENDP



; ---------------------------------------------------------------------------------
; Funzione: analisi_accuratezza
;
; 1. COSA FA:
;    - Confronta due vettori (VETT1 e VETT2) elemento per elemento.
;    - Calcola la differenza assoluta (|VETT1[i] - VETT2[i]|) per ogni elemento.
;    - Memorizza queste differenze nel vettore RES.
;    - Calcola la media totale delle differenze (Errore Medio).
;
; 2. PARAMETRI IN INGRESSO:
;    R0 = Indirizzo VETT1 (uint8_t*)
;    R1 = Indirizzo VETT2 (uint8_t*)
;    R2 = N (Dimensione degli array)
;    R3 = Indirizzo RES  (uint8_t*) -> Dove salvare le differenze
;
; 3. PARAMETRI IN USCITA:
;    R0 = Media delle differenze (Somma differenze / N)
;
; 4. FUNZIONI ESTERNE RICHIESTE:
;    - abs_value (Input: R0, R1 -> Output: R0 = |R0-R1|)
;    - DIVISION  (Input: R0, R1 -> Output: R0 = R0/R1)
; ---------------------------------------------------------------------------------
	EXPORT analisi_accuratezza
analisi_accuratezza FUNCTION
	PUSH {R4-R11, LR}
	
	MOV R5, R0          ; R5 = Copia puntatore VETT1 (safe register)
	                    ; R1 rimane puntatore VETT2 (gestito con push/pop)
	MOV R6, #0          ; R6 = Indice i (0)
	MOV R10, #0         ; R10 = Accumulatore Somma (Numeratore media)

outerloop2
	; --- Lettura elementi ---
	LDRB R7, [R5, R6]   ; R7 = VETT1[i]
	LDRB R8, [R1, R6]   ; R8 = VETT2[i]
	
	; --- Calcolo Differenza Assoluta ---
	PUSH {R0, R1}       ; Salvo i puntatori agli array (R0, R1) perché BL sporca i registri
	MOV R0, R7          ; Parametro 1: Valore 1
	MOV R1, R8          ; Parametro 2: Valore 2
	BL abs_value        ; Chiama funzione esterna
	MOV R9, R0          ; R9 = Risultato (|a-b|)
	POP {R0, R1}        ; Ripristino i puntatori
	
	; --- Salvataggio e Accumulo ---
	STRB R9, [R3, R6]   ; Scrivo la differenza in RES[i]
	ADD R10, R10, R9    ; SommaTotale += Differenza
	
	; --- Avanzamento Loop ---
	ADD R6, R6, #1      ; i++
	CMP R6, R2          ; Controllo fine array (i < N)
	BEQ exity2
	B outerloop2

exity2
	; --- Calcolo Media Finale (Senza BL DIVISION) ---
	; Non serve più il PUSH/POP di R0 e R1 perché non chiamiamo funzioni esterne
	
	CMP R2, #0          ; Controllo divisione per zero per sicurezza
	BEQ div_zero_fix
	
	UDIV R0, R10, R2    ; R0 = SommaTotale (R10) / N (R2)
	B fine_accuracy

div_zero_fix
	MOV R0, #0          ; Se N=0, la media è 0

fine_accuracy
	POP {R4-R11, PC}
	ENDFUNC



; ---------------------------------------------------------------------------------
; Funzione: check_fibonacci
;
; 1. COSA FA:
;    - Genera i primi 'M' numeri della sequenza di Fibonacci.
;    - Controlla se il valore 'val' (R3) è troppo vicino a uno qualsiasi di questi numeri.
;      (La distanza assoluta deve essere MAGGIORE di 'boundary').
;    - Se il valore è valido (distante), lo inserisce nella prima posizione libera (0) del vettore.
;    - Se il valore è troppo vicino o uguale a un numero di Fibonacci, lo scarta.
;
; 2. PARAMETRI IN INGRESSO:
;    R0 = Indirizzo Vettore (uint8_t*) -> Dove inserire il valore
;    R1 = N (Dimensione massima del vettore)
;    R2 = M (Quanti numeri di Fibonacci controllare)
;    R3 = Val (Il valore da verificare e inserire)
;    STACK 5° Argomento ([SP+36]) = Boundary (Distanza minima richiesta)
;
; 3. PARAMETRI IN USCITA:
;    R0 = 1 se il valore è valido (ed è stato provato l'inserimento).
;         0 se il valore è invalido (troppo vicino a un numero di Fibonacci).
;
; 4. FUNZIONI ESTERNE:
;    - abs_value (Calcola valore assoluto della differenza)
; ---------------------------------------------------------------------------------
	EXPORT check_fibonacci 
check_fibonacci FUNCTION
	PUSH {R4-R11, LR}       ; Salvataggio contesto (9 registri -> 36 bytes)

	; --- Recupero 5° parametro (Boundary) ---
	LDRB R4, [SP, #36]      ; Legge Boundary dallo stack (offset 36)

	MOV R5, R0              ; R5 = Copia puntatore Vett
	MOV R6, #0              ; R6 = Fib(i)   [Inizio con 0]
	MOV R7, #1              ; R7 = Fib(i+1) [Inizio con 1]
	MOV R11, #0             ; R11 = Indice per scorrere il vettore finale
	
	MOV R0, #1              ; R0 = 1 (Default: Successo/Inseribile)
	                        ; Se fallisce i controlli, verrà messo a 0.

outerloop3
	; Calcolo prossimo Fibonacci (ma non lo uso subito, uso R6 corrente)
	ADD R8, R7, R6          ; Temp = Fib(i) + Fib(i+1)
	ADD R2, R2, #-1         ; Decremento contatore M (numeri da controllare)
	
	; Check 1: Uguaglianza esatta
	CMP R3, R6              ; Val == FibCorrente?
	BEQ nonInserire         ; Se uguale, rifiuta subito.

	; Check 2: Distanza minima (Boundary)
	PUSH {R0-R3}            ; Salvo registri volatili prima della BL
	MOV R0, R3              ; Arg1 = Valore
	MOV R1, R6              ; Arg2 = FibCorrente
	BL abs_value            ; Calcola |Val - Fib|
	MOV R9, R0              ; R9 = Distanza
	POP {R0-R3}             ; Ripristino registri
	
	CMP R9, R4              ; Distanza vs Boundary
	BLE nonInserire         ; Se Distanza <= Boundary -> Rifiuta

	; Preparazione prossimo ciclo
	MOV R6, R7              ; Fib(i) = Fib(i+1)
	MOV R7, R8              ; Fib(i+1) = Temp
	
	CMP R2, #0              ; Ho controllato tutti gli M numeri?
	BNE outerloop3           ; Se no, continua

	; Se arrivo qui, il numero è VALIDO. Cerco dove inserirlo.
	B TrovaPosVuota

nonInserire
	MOV R0, #0              ; Return 0 (Fallimento)
	B exity3

TrovaPosVuota
	LDRB R10, [R5, R11]     ; Leggo Vett[i]
	CMP R10, #0             ; È una cella vuota (0)?
	STRBEQ R3, [R5, R11]    ; Se sì, scrivo il valore (R3)
	BEQ exity3               ; E termino (R0 è ancora 1)

	ADD R11, R11, #1        ; i++
	CMP R11, R1             ; Ho superato la dimensione N?
	BEQ exity3               ; Se vettore pieno, esco (senza inserire, ma R0=1)
	B TrovaPosVuota

exity3
	POP {R4-R11, PC}
	ENDFUNC











	END	

