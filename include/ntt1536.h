#ifndef NTT1536_H
#define NTT1536_H

#include <stdint.h>

void NTT_forward_8(const signed char* g, const int32_t*, int, int, int32_t *);
void NTT_forward_16(const short* g, const int32_t*, int, int, int32_t *);
void  __asm_my_mul(int32_t*, int32_t*, int, int);
void __asm_NTT_inv_1_2_3(int32_t*, const int32_t*, int, int);
void __asm_NTT_inv_4_5_6(int32_t*, const int32_t*, int, int);
void __asm_NTT_inv_7_8_9(int32_t*, const int32_t*, int, int);
void  __asm_final_map_and_pack(short*, int, int32_t*, int32_t*, int, int, int, int, int);
#endif
