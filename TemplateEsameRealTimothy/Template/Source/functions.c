// Function to extract bits between the indices `start` and `end` (inclusive)
unsigned short extract_bits(unsigned int value, int start, int end) {
    // Ensure the `start` index is greater than or equal to `end`, 
    // and both are within valid bounds (0 to 31)
    if (start < end || start >= 32 || end < 0) {
        return 0; // Return 0 for invalid input
    }

    // Calculate the number of bits to extract
    int num_bits = start - end + 1;

    // Create a mask to isolate the desired bits
    unsigned int mask = ((1U << num_bits) - 1) << end;

    // Isolate the bits using the mask and shift them to the rightmost position
    unsigned short result = (value & mask) >> end;

    return result; // Return the extracted bits as an unsigned short
}

/* 
 * Function to represent a 32-bit value `res` on the LEDs, 8 bits at a time.
 * The `position` parameter determines which 8 bits to display:
 *   - Position 0: Display the least significant byte (LSB)
 *   - Position 1: Display the next 8 bits, and so on.
 */
void represent_on_leds(unsigned int res, int position) {
    // Validate the position (must be between 0 and 3)
    if (position < 0 || position > 3) {
        // Invalid position; do nothing
        return;
    }

    // Extract 8 bits (1 byte) corresponding to the given position
    unsigned char aus = (res >> (8 * position)) & 0xFF;

    // Output the extracted byte to the LEDs
    LED_Out(aus);
}


/**************************************************************************************************************************
																FUNZIONI PER INIZIALIZZARE UN VETTORE A 0
***************************************************************************************************************************/

//funzione che inizializza tutti gli elementi di un vettore a =0 NB: VA BENE PER I 32BIT (unsigned e signed)
void initializeToZeroInt(int vett[], int numElVett){
	int c;
	for(c=0; c<numElVett; c++){
		vett[c]=0;
	}
}

//funzione che inizializza tutti gli elementi di un vettore a =0 NB: VA BENE PER I 16 BIT (unsigned e signed)
void initializeToZeroShort(unsigned short vett[], int numElVett){
	int c;
	for(c=0; c<numElVett; c++){
		vett[c]=0;
	}
}

//funzione che inizializza tutti gli elementi di un vettore a =0 NB: VA BENE PER GLI 8BIT (unsigned e signed)
void initializeToZeroChar(unsigned char vett[], int numElVett){
	int c;
	for(c=0; c<numElVett; c++){
		vett[c]=0;
	}
}