#ifndef POLYMUL
#define POLYMUL

#include "int8.h"
#include "int16.h"
#include "int32.h"
#include "uint16.h"
#include "uint32.h"


extern void gf_polymul_768x768_mod3(int8 *h, int8 *c, int8 *f);
extern int Rq_recip3_jumpdivsteps(int16 *h, int8 *c);
extern int R3_recip_jumpdivsteps(int8* H, int8* G);
extern void Rq_redp(int16 *h, const int16 *f);
extern void Rq_mult3_asm(int16 *h, const int16 *f);
extern void Rq_mov(int16 *h, const int16 *f);
extern void Rq_fromR3(int16 *h, const int8 *f);
extern int Weightw_mask_asm(int8 *ev);
extern void copy_p_F3_mod3(const int8 *f, int8 *fp, const int8 *g, int8 *gp);
extern void reduce_2p_minus1_mod3_F3(int8 *h, int8 *fg);
extern void Short_fromlist_asm(int8 *out,const uint32 *in);


#if defined(MIXED1)
#define PARAMS_M 1530
void fft17(void*f, void* fpad);
void ntt17_rader(void* f, void* fpad);
void ntt17_rader_byte(void* g, void* gpad);
void byteToShort(void* gg, void* g);
void fft9(void* fpad);
void polymul_10x10_153_mr(void* fpad, void* gpad);
void ifft9(void* fpad);
void ifft17_mr(void* fpad, void* h);
void intt17_rader_mr(void* fpad, void* h);
void mod_reduce(void* h, void* hpad);
#elif defined(MIXED)
#include "ntt.h"
#elif defined(GOODS)
#include "NTT.h"
#endif

#endif
