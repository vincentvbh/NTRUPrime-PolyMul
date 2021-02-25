#include "Rq_mult.h"


/*************************************************
* Name:        Rq_mult_small
*
* Description: Computes polynomial multiplication in Z_q/(X^p-X-1) 
*              with selected implementation. 
*
* Arguments:   
* Fq *h          : pointer to the output polynomial in R_q
* const Fq *f    : pointer to the input polynomial in R_q
* const small *g : pointer to the input polynomial in R_q
**************************************************/
void Rq_mult_small(Fq *h,const Fq *f,const small *g)
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

  __asm_NTT_inv_1_2_3(&(Goodp0[0][0]), inv_factor_1_2_3, Mprime, MOD);
  __asm_NTT_inv_4_5_6(&(Goodp0[0][0]), inv_factor_4_5_6, Mprime, MOD);
  __asm_NTT_inv_7_8_9(&(Goodp0[0][0]), inv_factor_7_8_9, Mprime, MOD);

  __asm_final_map_and_pack(h, R2invN, Goodp0[2], 
                           Goodp0[0], O_M, O_M_bar, Mhalf,
                           Mprime, MOD);
#endif
}

/*************************************************
* Name:        Rq_mult_twice
*
* Description: Computes two polynomial multiplications in Z_q/(X^p-X-1) 
*              with selected implementation. 
*
* Arguments:   
* Fq *bG          : pointer to the output polynomial in R_q
* Fq *bA          : pointer to the output polynomial in R_q 
* const Fq *G    : pointer to the input polynomial in R_q
* const Fq *A    : pointer to the input polynomial in R_q
* const small *b : pointer to the input polynomial in R_q
**************************************************/
void Rq_mult_twice(Fq *bG, Fq *bA, const Fq *G, const Fq *A, const small *b){
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

  __asm_NTT_inv_1_2_3(&(Goodp1[0][0]), inv_factor_1_2_3, Mprime, MOD);
  __asm_NTT_inv_4_5_6(&(Goodp1[0][0]), inv_factor_4_5_6, Mprime, MOD);
  __asm_NTT_inv_7_8_9(&(Goodp1[0][0]), inv_factor_7_8_9, Mprime, MOD);

  __asm_NTT_inv_1_2_3(&(Goodp2[0][0]), inv_factor_1_2_3, Mprime, MOD);
  __asm_NTT_inv_4_5_6(&(Goodp2[0][0]), inv_factor_4_5_6, Mprime, MOD);
  __asm_NTT_inv_7_8_9(&(Goodp2[0][0]), inv_factor_7_8_9, Mprime, MOD);

  __asm_final_map_and_pack(bG, R2invN, Goodp1[2], 
                           Goodp1[0], O_M, O_M_bar, Mhalf,
                           Mprime, MOD);
  __asm_final_map_and_pack(bA, R2invN, Goodp2[2], 
                           Goodp2[0], O_M, O_M_bar, Mhalf,
                           Mprime, MOD);
#endif
}
