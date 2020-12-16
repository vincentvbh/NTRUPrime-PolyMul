#ifndef NTT1536_H
#define NTT1536_H

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>

void NTT_forward_8(const signed char* g, int*, int, int, int *);
void NTT_forward_16(const short* g, int*, int, int, int *);
void  __asm_my_mul(int*, int*, int, int);
void __asm_NTT_inv_1_2_3(int*, int*, int, int);
void __asm_NTT_inv_4_5_6(int*, int*, int, int);
void __asm_NTT_inv_7_8_9(int*, int*, int, int);
void  __asm_final_map_and_pack(short*, int, int*, int*, int, int, int, int, int);
#endif
