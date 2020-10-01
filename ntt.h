#ifndef ntt_H
#define ntt_H
#include "params.h"
#include <stdint.h>
#include "consts_asm.h"
// Function definitions
//
void asm_basemul(int16_t *a, const int16_t *b, const int16_t* W); 
void asm_ntt(int16_t* o, const int16_t * a, const short* omega);
void asm_ntt1s(int16_t * antt, const int8_t* a,const short* omega);
void asm_invntt(int16_t *o, int16_t * a, const short* omega);
#endif
