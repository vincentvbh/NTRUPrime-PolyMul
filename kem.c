#include "params.h"
#include "randombytes.h"
#include "sha512_hash.h"
#ifdef LPR
#include "aes.h"
#endif


#include "int8.h"
#include "int16.h"
#include "int32.h"
#include "uint16.h"
#include "uint32.h"
#include "Encode.h"
#include "Decode.h"
#include <string.h>
#include "cmsis.h"

#include "polymul.h"



/* ----- masks */

#ifdef LPR 

/* return -1 if x<0; otherwise return 0 */
static int int16_negative_mask(int16 x)
{
  uint16 u = x;
  u >>= 15;
  return -(int) u;
  /* alternative with gcc -fwrapv: */
  /* x>>15 compiles to CPU's arithmetic right shift */
}
#endif
typedef int8 small;
#define q12 ((q-1)/2)
typedef int16 Fq;

#include "arith.h"


/* ----- Top and Right */

#ifdef LPR
#define tau 16

static int8 Top(Fq C)
{
  return (tau1*(int32)(C+tau0)+16384)>>15;
}

static Fq Right(int8 T)
{
  return Fq_freeze(tau3*(int32)T-tau2);
}
#endif

/* ----- small polynomials */

#ifndef LPR

/* h = f*g in the ring R3 */
static void R3_mult(small *h,const small *f,const small *g)
{
  small fg[1536];
  small f_mod3[768];
  small g_mod3[768];
  copy_p_F3_mod3(f, f_mod3, g, g_mod3);
  gf_polymul_768x768_mod3(fg, f_mod3, g_mod3);
  reduce_2p_minus1_mod3_F3(h, fg);

}

#endif



/* h = f*g in the ring Rq */
static void Rq_mult_small(Fq *h,const Fq *f,const small *g)
{
#if defined(MIXED1)
  int16_t g_modq[1530], fg[1530];
  byteToShort(h, g);
  ntt17_rader(h, g_modq);
  fft9(g_modq);
  ntt17_rader(f, fg);
  fft9(fg);
  polymul_10x10_153_mr(fg, g_modq);
  ifft9(fg);
  intt17_rader_mr(fg, g_modq);
  mod_reduce(h, g_modq);

#elif  defined(MIXED)
  Fq fg[PARAMS_M],g_modq[PARAMS_M];

  asm_ntt1s(g_modq,g,omegas_asm);
  asm_ntt(fg,f,omegas_asm);
  
  asm_basemul(fg,g_modq,bromegas_asm);
  asm_invntt(h,fg,invomegas_asm);

#elif defined(GOODS)
  int Goodp0[3][N], Goodp1[3][N];

  NTT_forward_8(g, root_table, MOD, Mprime, &(Goodp0[0][0]));
  NTT_forward_16(f, root_table, MOD, Mprime, &(Goodp1[0][0]));

  __asm_my_mul(&(Goodp0[1][0]), &(Goodp1[1][0]), Mprime, MOD);

  __asm_NTT_inv_1_2_3(&(Goodp0[0][0]), t_inv_factor_1_2_3, Mprime, MOD);
  __asm_NTT_inv_4_5_6(&(Goodp0[0][0]), t_inv_factor_4_5_6_7_group_T, Mprime, MOD);
  __asm_NTT_inv_7_8_9(&(Goodp0[0][0]), t_inv_factor_7_8_9_7_group_T, Mprime, MOD);

  __asm_final_map_and_pack(h, R2invN, Goodp0[2], 
                           Goodp0[0], O_M, O_M_bar, O_Mhalf,
                           Mprime, MOD);
#endif
}

#ifndef LPR
/* R3_fromR(R_fromRq(r)) */
static void R3_fromRq(small *out,const Fq *r)
{

  int i;
  for (i = 0;i < p;++i) out[i] = F3_freeze_short(r[i]);
}

/* h = 3f in Rq */
static void Rq_mult3(Fq *h,const Fq *f)
{
  Rq_mult3_asm(h, f);
}

#endif

/* ----- rounded polynomials mod q */

static void Round(Fq *out,const Fq *a)
{
  int i;
  int *o1 = (int *)(void *)out;
  int *a1 = (int *)(void *)a;

  for (i = (p-1)/2; i>0; i--) {
    *(o1++) = F3_round_x2(*(a1++));
  }
  out = (Fq *)(void *) o1;
  a = (Fq *)(void *) a1;
  *out = F3_round_x2(*a);

}

/* ----- sorting to generate short polynomial */

static void Short_fromlist(small *out,const uint32 *in)
{
  Short_fromlist_asm(out, in);
}

/* ----- underlying hash function */

#define Hash_bytes 32

/* e.g., b = 0 means out = Hash0(in) */
static void Hash(unsigned char *out,int b,const unsigned char *in,int inlen)
{
  unsigned char x[inlen+1];
  unsigned char h[64];
  int i;

  x[0] = b;
  for (i = 0;i < inlen;++i) x[i+1] = in[i];
  //memcpy(x+1, in, inlen);
  sha512_hash(h,x,inlen+1);
  for (i = 0;i < 32;++i) out[i] = h[i];
  //sha512_hash(out,x,inlen+1);
}

/* ----- higher-level randomness */
static void Short_random(small *out)
{
  uint32 L[p];
  randombytes((unsigned char*)L, 4*p);
  Short_fromlist(out,L);
}

#ifndef LPR
static uint32 urandom32(void)
{
  unsigned char c[4];

  randombytes(c,4);

  return *((int *)c);
}
static void Small_random(small *out)
{
  int i;

  int *o1 = (int *)(void *)out;
  int x0, x1, x2, x3;
  int L[4];

  for (i = (p-1)/4; i>0; i--) {
    randombytes((unsigned char *)(void*)L, 16);
    x0 = L[0]; x1 = L[1]; x2 = L[2]; x3 = L[3];
    x0 = __BFC(x0, 30, 2); x0 = __SMMLA(x0, 12, -1);
    x1 = __BFC(x1, 30, 2); x1 = __SMMLA(x1, 12, -1);
    x2 = __BFC(x2, 30, 2); x2 = __SMMLA(x2, 12, -1);
    x3 = __BFC(x3, 30, 2); x3 = __SMMLA(x3, 12, -1);
    x0 = __BFI(x0, x1, 8, 8);
    x0 = __BFI(x0, x2, 16, 8);
    x0 = __BFI(x0, x3, 24, 8);
    *(o1++) = x0;
  }
  x0 = __BFC(urandom32(), 30, 2); x0 = __SMMLA(x0, 12, -1);
  out = (small *)(void *)o1;
  *out = x0;
}

#endif

/* ----- Streamlined NTRU Prime Core */

#ifndef LPR

/* h,(f,ginv) = KeyGen() */
static void KeyGen(Fq *h,small *f,small *ginv)
{
  small g[p];
  Fq finv[p];
  for (;;) {
    Small_random(g);
    if (R3_recip_jumpdivsteps(ginv,g) == 0) break;
  }
  Short_random(f);
  Rq_recip3_jumpdivsteps(finv,f);
  Rq_mult_small(h,finv,g);
}

/* c = Encrypt(r,h) */
static void Encrypt(Fq *c,const small *r,const Fq *h)
{
  Fq hr[p];
  Rq_mult_small(hr,h,r);
  Round(c,hr);
}

/* r = Decrypt(c,(f,ginv)) */
static void Decrypt(small *r,const Fq *c,const small *f,const small *ginv)
{
  Fq cf[p];
  Fq cf3[p];
  small e[p];
  small ev[p];
  int mask;
  int i;
  Rq_mult_small(cf,c,f);
  Rq_mult3(cf3,cf);
  R3_fromRq(e,cf3);
  R3_mult(ev,e,ginv);

  mask = //Weightw_mask(ev); /* 0 if weight w, else -1 */
    Weightw_mask_asm(ev);
  for (i = 0;i < w;++i) r[i] = ((ev[i]^1)&~mask)^1;
  for (i = w;i < p;++i) r[i] = ev[i]&~mask;
}

#endif

/* ----- NTRU LPRime Core */

#ifdef LPR

/* (G,A),a = KeyGen(G); leaves G unchanged */
static void KeyGen(Fq *A,small *a,const Fq *G)
{
  Fq aG[p];

  Short_random(a);

  Rq_mult_small(aG,G,a);
  Round(A,aG);
}

/* B,T = Encrypt(r,(G,A),b) */
static void Encrypt(Fq *B,int8 *T,const int8 *r,const Fq *G,const Fq *A,const small *b)
{
  Fq bG[p];
  Fq bA[p];
  int i;
#if defined(MIXED1)
  int16_t b_modq[1530], G_modq[1530], A_modq[1530];
  byteToShort(bG, b);
  ntt17_rader(bG, b_modq);
  fft9(b_modq);
  ntt17_rader(G, G_modq);
  fft9(G_modq);
  ntt17_rader(A, A_modq);
  fft9(A_modq);
  polymul_10x10_153_mr(G_modq, b_modq);
  polymul_10x10_153_mr(A_modq, b_modq);
  ifft9(G_modq);
  intt17_rader_mr(G_modq, b_modq);
  mod_reduce(bG, b_modq);
  ifft9(A_modq);
  intt17_rader_mr(A_modq, b_modq);
  mod_reduce(bA, b_modq);

#elif defined(MIXED)
  Fq b_modq[PARAMS_M],G_modq[PARAMS_M],A_modq[PARAMS_M];
  
  asm_ntt1s(b_modq,b,omegas_asm);
  asm_ntt(G_modq,G,omegas_asm);
  asm_ntt(A_modq,A,omegas_asm);
  asm_basemul(G_modq,b_modq,bromegas_asm);
  asm_basemul(A_modq,b_modq,bromegas_asm);
  asm_invntt(bG,G_modq,invomegas_asm);
  asm_invntt(bA,A_modq,invomegas_asm);

#elif defined(GOODS)
  // reuse NTT'd small part

  int Goodp0[3][N], Goodp1[3][N], Goodp2[3][N];

  NTT_forward_8(b, root_table, MOD, Mprime, &(Goodp0[0][0]));
  NTT_forward_16(G, root_table, MOD, Mprime, &(Goodp1[0][0]));
  NTT_forward_16(A, root_table, MOD, Mprime, &(Goodp2[0][0]));

  __asm_my_mul(&(Goodp1[1][0]), &(Goodp0[1][0]), Mprime, MOD);
  __asm_my_mul(&(Goodp2[1][0]), &(Goodp0[1][0]), Mprime, MOD);

  __asm_NTT_inv_1_2_3(&(Goodp1[0][0]), t_inv_factor_1_2_3, Mprime, MOD);
  __asm_NTT_inv_4_5_6(&(Goodp1[0][0]), t_inv_factor_4_5_6_7_group_T, Mprime, MOD);
  __asm_NTT_inv_7_8_9(&(Goodp1[0][0]), t_inv_factor_7_8_9_7_group_T, Mprime, MOD);

  __asm_NTT_inv_1_2_3(&(Goodp2[0][0]), t_inv_factor_1_2_3, Mprime, MOD);
  __asm_NTT_inv_4_5_6(&(Goodp2[0][0]), t_inv_factor_4_5_6_7_group_T, Mprime, MOD);
  __asm_NTT_inv_7_8_9(&(Goodp2[0][0]), t_inv_factor_7_8_9_7_group_T, Mprime, MOD);

  __asm_final_map_and_pack(bG, R2invN, Goodp1[2], 
                           Goodp1[0], O_M, O_M_bar, O_Mhalf,
                           Mprime, MOD);
  __asm_final_map_and_pack(bA, R2invN, Goodp2[2], 
                           Goodp2[0], O_M, O_M_bar, O_Mhalf,
                           Mprime, MOD);
#endif

  Round(B,bG); 
  for (i = 0;i < I;++i) T[i] = Top(Fq_freeze(bA[i]+r[i]*q12));
}

/* r = Decrypt((B,T),a) */
static void Decrypt(int8 *r,const Fq *B,const int8 *T,const small *a)
{
  Fq aB[p];
  int i;
  Rq_mult_small(aB,B,a);
  for (i = 0;i < I;++i)
    r[i] = -int16_negative_mask(Fq_freeze(Right(T[i])-aB[i]+4*w+1));
}

#endif

/* ----- encoding I-bit inputs */

#ifdef LPR

#define Inputs_bytes (I/8)
typedef int8 Inputs[I]; /* passed by reference */

static void Inputs_encode(unsigned char *s,const Inputs r)
{
  int i;
  for (i = 0;i < Inputs_bytes;++i) s[i] = 0;
  for (i = 0;i < I;++i) s[i>>3] |= r[i]<<(i&7);
}

#endif

/* ----- Expand */

#ifdef LPR

static const unsigned char aes_nonce[16] = {0};

static void Expand(uint32 *L,const unsigned char *k)
{
  aes256ctx ctx;
  aes256_ctr_keyexp(&ctx, k);
  aes256_ctr((unsigned char *) L, 4*p, aes_nonce, &ctx);
}

#endif

/* ----- Seeds */

#ifdef LPR

#define Seeds_bytes 32

static void Seeds_random(unsigned char *s)
{
  randombytes(s,Seeds_bytes);
}

#endif

/* ----- Generator, HashShort */

#ifdef LPR

/* G = Generator(k) */
static void Generator(Fq *G,const unsigned char *k)
{
  uint32 L[p];
  int i;

  Expand(L,k);
  union llreg_u{
  uint32_t w32[2];
  uint64_t w64;
  } llr;
  for (i = 0;i < p;++i) {
    llr.w64 = __UMULL(q32inv, L[i]);
#ifndef __ARMEB__
    int qq = llr.w32[1];
#else
    int qq = llr.w32[0];
#endif
    G[i] = Fq_freeze_short(__MLS(qq, q, L[i])-q12);
  }
}

/* out = HashShort(r) */
static void HashShort(small *out,const Inputs r)
{
  unsigned char s[Inputs_bytes];
  unsigned char h[Hash_bytes];
  uint32 L[p];

  Inputs_encode(s,r);
  Hash(h,5,s,sizeof s);
  Expand(L,h);
  Short_fromlist(out,L);
}

#endif

/* ----- NTRU LPRime Expand */

#ifdef LPR

/* (S,A),a = XKeyGen() */
static void XKeyGen(unsigned char *S,Fq *A,small *a)
{
  Fq G[p];

  Seeds_random(S);
  Generator(G,S);
  KeyGen(A,a,G);
}

/* B,T = XEncrypt(r,(S,A)) */
static void XEncrypt(Fq *B,int8 *T,const int8 *r,const unsigned char *S,const Fq *A)
{
  Fq G[p];
  small b[p];

  Generator(G,S);
  HashShort(b,r);
  Encrypt(B,T,r,G,A,b);
}

#define XDecrypt Decrypt

#endif

/* ----- encoding small polynomials (including short polynomials) */

#define Small_bytes ((p+3)/4)

/* these are the only functions that rely on p mod 4 = 1 */

static void Small_encode(unsigned char *s,const small *f)
{
  small x;
  int i;


#if 0
  for (i = 0;i < p/4;++i) {
    x = *f++ + 1;
    x += (*f++ + 1)<<2;
    x += (*f++ + 1)<<4;
    x += (*f++ + 1)<<6;
    *s++ = x;
  }
  x = *f++ + 1;
  *s++ = x;
#else
  int xx = 0x01010101;
  int x0, x1, x2, x3, y;
  int *ff = (int *)(void *)f;
  int *ss = (int *)(void *)s;
  for (i = (p/16); i>0; i--) {
    x1 = *(ff+1);
    x2 = *(ff+2);
    x3 = *(ff+3);
    x0 = *ff; ff+=4;
    x0 = __UADD8(x0, xx);
    x1 = __UADD8(x1, xx);
    x2 = __UADD8(x2, xx);
    x3 = __UADD8(x3, xx);
    y  = x0 + (x0 >> 6);
    y += (x0 >> 12);
    x0 = y+ (x0 >> 18);
    y  = x1 + (x1 >> 6);
    y += (x1 >> 12);
    x1 = y+ (x1 >> 18);
    y  = x2 + (x2 >> 6);
    y += (x2 >> 12);
    x2 = y+ (x2 >> 18);
    y  = x3 + (x3 >> 6);
    y += (x3 >> 12);
    x3 = y+ (x3 >> 18);
    x0 = __BFI(x0, x1, 8, 8);
    x0 = __BFI(x0, x2, 16, 8);
    x0 = __BFI(x0, x3, 24, 8);
    *ss++ = x0;
  }
  s = (unsigned char *)(void *)ss;
  for (i = ((p%16)/4); i>0; i--) {
    x0 = *(ff++);
    x0 = __UADD8(x0, xx);
    y  = x0 + (x0 >> 6);
    y += (x0 >> 12);
    x0 = y+ (x0 >> 18);
    *s++ = x0;
  }
  f = (small *)(void *)ff;
  x = *f++ + 1;
  *s++ = x;
#endif
}

static void Small_decode(small *f,const unsigned char *s)
{
  unsigned char x;
  int i;

#if 0
  for (i = 0;i < p/4;++i) {
    x = *s++;
    *f++ = ((small)(x&3))-1; x >>= 2;
    *f++ = ((small)(x&3))-1; x >>= 2;
    *f++ = ((small)(x&3))-1; x >>= 2;
    *f++ = ((small)(x&3))-1;
  }
  x = *s++;
  *f++ = ((small)(x&3))-1;

#else
  int xx = 0x01010101;
  int xxx = 0x03030303;
  int xoxo = 0xff00ff00;
  int *ff = (int *)(void *)f;
  int *ss = (int *)(void *)s;
  for (i = (p/16); i>0; i--) {
    int y = *(ss++);
    int x00 = xxx & y;			// (f0, f4, f8, f12)
    int x01 = xxx & (y >> 2);		// (f1, f5, f9, f13)
    int x02 = xxx & (y >> 4);		// (f2, f6, f10, f14)
    int x03 = xxx & (y >> 6);		// (f3, f7, f11, f15)
    int x10 = __PKHBT(x00, x02, 16);	// (f0, f4, f2, f6)
    int x12 = __PKHTB(x02, x00, 16);	// (f8, f12, f10, f14)
    int x11 = __PKHBT(x01, x03, 16);	// (f1, f5, f3, f7)
    int x13 = __PKHTB(x03, x01, 16);	// (f9, f13, f11, f15)
    y = xoxo & (x11 << 8); int x0 = __USUB8(__UXTAB16(y, x10, 0), xx);
    y = xoxo & x11;        int x1 = __USUB8(__UXTAB16(y, x10, 8), xx);
    y = xoxo & (x13 << 8); int x2 = __USUB8(__UXTAB16(y, x12, 0), xx);
    y = xoxo & x13;        int x3 = __USUB8(__UXTAB16(y, x12, 8), xx);
    *(ff+1) = x1;
    *(ff+2) = x2;
    *(ff+3) = x3;
    *(ff)   = x0; ff += 4;
  }
  f = (small *)(void *)ff;
  s = (unsigned char *)(void *)ss;
  for (i = (p%16)/4; i>0 ; i--) {
    x = *s++;
    *f++ = ((small)(x&3))-1; x >>= 2;
    *f++ = ((small)(x&3))-1; x >>= 2;
    *f++ = ((small)(x&3))-1; x >>= 2;
    *f++ = ((small)(x&3))-1;
  }
  x = *s++;
  *f++ = ((small)(x&3))-1;
#endif
}

/* ----- encoding general polynomials */

#ifndef LPR

static void Rq_encode(unsigned char *s,const Fq *r)
{
  Encode_Rq(s, (int16 *)r);
}

static void Rq_decode(Fq *r,const unsigned char *s)
{
  Decode_Rq((int16 *)r, s);
}

#endif

/* ----- encoding rounded polynomials */

static void Rounded_encode(unsigned char *s,const Fq *r)
{
  Encode_Rounded(s, (int16 *)r);
}

static void Rounded_decode(Fq *r,const unsigned char *s)
{
  Decode_Rounded((int16 *)r, s);
}

/* ----- encoding top polynomials */

#ifdef LPR

#define Top_bytes (I/2)

static void Top_encode(unsigned char *s,const int8 *T)
{
  int i;
  for (i = 0;i < Top_bytes;++i)
    s[i] = T[2*i]+(T[2*i+1]<<4);
}

static void Top_decode(int8 *T,const unsigned char *s)
{
  int i;
  for (i = 0;i < Top_bytes;++i) {
    T[2*i] = s[i]&15;
    T[2*i+1] = s[i]>>4;
  }
}

#endif

/* ----- Streamlined NTRU Prime Core plus encoding */

#ifndef LPR

typedef small Inputs[p]; /* passed by reference */
#define Inputs_random Short_random
#define Inputs_encode Small_encode
#define Inputs_bytes Small_bytes

#define Ciphertexts_bytes Rounded_bytes
#define SecretKeys_bytes (2*Small_bytes)
#define PublicKeys_bytes Rq_bytes

/* pk,sk = ZKeyGen() */
static void ZKeyGen(unsigned char *pk,unsigned char *sk)
{
  Fq h[p];
  small f[p],v[p];

  KeyGen(h,f,v);
  Rq_encode(pk,h);
  Small_encode(sk,f); sk += Small_bytes;
  Small_encode(sk,v);
}

/* C = ZEncrypt(r,pk) */
static void ZEncrypt(unsigned char *C,const Inputs r,const unsigned char *pk)
{
  Fq h[p];
  Fq c[p];
  Rq_decode(h,pk);
  Encrypt(c,r,h);
  Rounded_encode(C,c);
}

/* r = ZDecrypt(C,sk) */
static void ZDecrypt(Inputs r,const unsigned char *C,const unsigned char *sk)
{
  small f[p],v[p];
  Fq c[p];

  Small_decode(f,sk); sk += Small_bytes;
  Small_decode(v,sk);
  Rounded_decode(c,C);
  Decrypt(r,c,f,v);
}

#endif

/* ----- NTRU LPRime Expand plus encoding */

#ifdef LPR

#define Ciphertexts_bytes (Rounded_bytes+Top_bytes)
#define SecretKeys_bytes Small_bytes
#define PublicKeys_bytes (Seeds_bytes+Rounded_bytes)

static void Inputs_random(Inputs r)
{
  unsigned char s[Inputs_bytes];
  int i;

  randombytes(s,sizeof s);
  for (i = 0;i < I;++i) r[i] = 1&(s[i>>3]>>(i&7));
}

/* pk,sk = ZKeyGen() */
static void ZKeyGen(unsigned char *pk,unsigned char *sk)
{
  Fq A[p];
  small a[p];

  XKeyGen(pk,A,a); pk += Seeds_bytes;
  Rounded_encode(pk,A);
  Small_encode(sk,a);
}

/* c = ZEncrypt(r,pk) */
static void ZEncrypt(unsigned char *c,const Inputs r,const unsigned char *pk)
{
  Fq A[p];
  Fq B[p];
  int8 T[I];

  Rounded_decode(A,pk+Seeds_bytes);
  XEncrypt(B,T,r,pk,A);
  Rounded_encode(c,B); c += Rounded_bytes;
  Top_encode(c,T);
}

/* r = ZDecrypt(C,sk) */
static void ZDecrypt(Inputs r,const unsigned char *c,const unsigned char *sk)
{
  small a[p];
  Fq B[p];
  int8 T[I];

  Small_decode(a,sk);
  Rounded_decode(B,c);
  Top_decode(T,c+Rounded_bytes);
  XDecrypt(r,B,T,a);
}

#endif

/* ----- confirmation hash */

#define Confirm_bytes 32

/* h = HashConfirm(r,pk,cache); cache is Hash4(pk) */
static void HashConfirm(unsigned char *h,const unsigned char *r,/*const unsigned char *pk,*/const unsigned char *cache)
{
#ifndef LPR
  unsigned char x[Hash_bytes*2];
  int i;

  Hash(x,3,r,Inputs_bytes);
  for (i = 0;i < Hash_bytes;++i) x[Hash_bytes+i] = cache[i];
#else
  unsigned char x[Inputs_bytes+Hash_bytes];
  int i;

  for (i = 0;i < Inputs_bytes;++i) x[i] = r[i];
  for (i = 0;i < Hash_bytes;++i) x[Inputs_bytes+i] = cache[i];
#endif
  Hash(h,2,x,sizeof x);
}

/* ----- session-key hash */

/* k = HashSession(b,y,z) */
static void HashSession(unsigned char *k,int b,const unsigned char *y,const unsigned char *z)
{
#ifndef LPR
  unsigned char x[Hash_bytes+Ciphertexts_bytes+Confirm_bytes];
  int i;

  Hash(x,3,y,Inputs_bytes);
  for (i = 0;i < Ciphertexts_bytes+Confirm_bytes;++i) x[Hash_bytes+i] = z[i];
#else
  unsigned char x[Inputs_bytes+Ciphertexts_bytes+Confirm_bytes];
  int i;

  for (i = 0;i < Inputs_bytes;++i) x[i] = y[i];
  for (i = 0;i < Ciphertexts_bytes+Confirm_bytes;++i) x[Inputs_bytes+i] = z[i];
#endif
  Hash(k,b,x,sizeof x);
}

/* ----- Streamlined NTRU Prime and NTRU LPRime */

/* pk,sk = KEM_KeyGen() */
static void KEM_KeyGen(unsigned char *pk,unsigned char *sk)
{
  int i;

  ZKeyGen(pk,sk); sk += SecretKeys_bytes;
  for (i = 0;i < PublicKeys_bytes;++i) *sk++ = pk[i];
  randombytes(sk,Inputs_bytes); sk += Inputs_bytes;
  Hash(sk,4,pk,PublicKeys_bytes);
}

/* c,r_enc = Hide(r,pk,cache); cache is Hash4(pk) */
static void Hide(unsigned char *c,unsigned char *r_enc,const Inputs r,const unsigned char *pk,const unsigned char *cache)
{
  Inputs_encode(r_enc,r);
  ZEncrypt(c,r,pk); c += Ciphertexts_bytes;
  HashConfirm(c,r_enc,/*pk,*/cache);
}

/* c,k = Encap(pk) */
static void Encap(unsigned char *c,unsigned char *k,const unsigned char *pk)
{
  Inputs r;
  unsigned char r_enc[Inputs_bytes];
  unsigned char cache[Hash_bytes];

  Hash(cache,4,pk,PublicKeys_bytes);
  Inputs_random(r);
  Hide(c,r_enc,r,pk,cache);
  HashSession(k,1,r_enc,c);
}

/* 0 if matching ciphertext+confirm, else -1 */
static int Ciphertexts_diff_mask(const unsigned char *c,const unsigned char *c2)
{
  uint16 differentbits = 0;
  int len = Ciphertexts_bytes+Confirm_bytes;

#if 0
  while (len-- > 0) differentbits |= (*c++)^(*c2++);
  return (1&((differentbits-1)>>8))-1;
#else
  int *cc = (int *)(void *)c;
  int *cc2 = (int *)(void *)c2;
  int differentbits2 = 0;
  for (len-=4 ;len>=0; len-=4) {
    differentbits2 = __USADA8((*cc++),(*cc2++),differentbits2);
  }
  c = (unsigned char *)(void *) cc;
  c2 = (unsigned char *)(void *) cc2;
  for (len &= 3; len > 0; len--)
    differentbits2 =__USADA8((*c++),(*c2++),differentbits2);
  return ((-1)-((differentbits-1)>>31));
#endif


}

/* k = Decap(c,sk) */
static void Decap(unsigned char *k,const unsigned char *c,const unsigned char *sk)
{
  const unsigned char *pk = sk + SecretKeys_bytes;
  const unsigned char *rho = pk + PublicKeys_bytes;
  const unsigned char *cache = rho + Inputs_bytes;
  Inputs r;
  unsigned char r_enc[Inputs_bytes];
  unsigned char cnew[Ciphertexts_bytes+Confirm_bytes];
  int mask;
  int i;

  ZDecrypt(r,c,sk);
  Hide(cnew,r_enc,r,pk,cache);
  mask = Ciphertexts_diff_mask(c,cnew);
  for (i = 0;i < Inputs_bytes;++i) r_enc[i] ^= mask&(r_enc[i]^rho[i]);
  HashSession(k,1+mask,r_enc,c);
}

/* ----- crypto_kem API */

#include "api.h"

int crypto_kem_keypair(unsigned char *pk,unsigned char *sk)
{
  KEM_KeyGen(pk,sk);
  return 0;
}

int crypto_kem_enc(unsigned char *c,unsigned char *k,const unsigned char *pk)
{
  Encap(c,k,pk);
  return 0;
}

int crypto_kem_dec(unsigned char *k,const unsigned char *c,const unsigned char *sk)
{
  Decap(k,c,sk);
  return 0;
}
