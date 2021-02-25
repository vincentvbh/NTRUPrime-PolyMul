#include "api.h"
#include "hal.h"
#include "sendfn.h"

#include "polymul.h"
#include "arith.h"

#if defined(MIXED)
#define SPEED_q 4591
#define SPEED_n 1620
#elif defined(RADER)
#define SPEED_q 4591
#define SPEED_n 1530
#elif defined(GOODS)
#define SPEED_q 6984193
#define SPEED_n 1536
#endif

#include <stdio.h>
#include <stdint.h>
#include <string.h>


#define printcycles(S, U) send_unsignedll((S), (U))

int main(void)
{
  unsigned char key_a[CRYPTO_BYTES], key_b[CRYPTO_BYTES];
  unsigned char sk[CRYPTO_SECRETKEYBYTES];
  unsigned char pk[CRYPTO_PUBLICKEYBYTES];
  unsigned char ct[CRYPTO_CIPHERTEXTBYTES];
  unsigned long long t0, t1;
#if defined(RADER)
  Fq f_modq[PARAMS_M], g_modq[PARAMS_M];
  small g[761];
  for(int i=0; i<761; i++){
    f_modq[i]=i%3;
    g_modq[i]=(i*5)%3;
    g[i]=(i*5)%3;
  }

#elif defined(MIXED)

  Fq f_modq[PARAMS_M], g_modq[PARAMS_M];
  small g[761];
  for(int i=0; i<761; i++){
    f_modq[i]=i%3;
    g_modq[i]=(i*5)%3;
    g[i]=(i*5)%3;
  }

#elif defined(GOODS)
  int32_t Goodp0[3][N], Goodp1[3][N];

  Fq f[761],h[761];
  small g[761];
  for(int i=0; i<761; i++){
    f[i]=i%3;
    g[i]=(i*5)%3;
  }

#endif

  hal_setup(CLOCK_BENCHMARK);

  hal_send_str("==========================");
  char out[64];
  snprintf(out,64,"Scheme: %s\n",crypto_kem_PRIMITIVE);
  hal_send_str(out);
  snprintf(out,64,"NTT ring: Z_{%d}/(X^{%d}-1)\n",SPEED_q,SPEED_n);
  hal_send_str(out);
  // Key-pair generation
  t0 = hal_get_time();
  crypto_kem_keypair(pk, sk);
  t1 = hal_get_time();
  printcycles("keypair cycles: ", t1-t0);

  // Encapsulation
  t0 = hal_get_time();
  crypto_kem_enc(ct, key_a, pk);
  t1 = hal_get_time();
  printcycles("encaps cycles: ", t1-t0);

  // Decapsulation
  t0 = hal_get_time();
  crypto_kem_dec(key_b, ct, sk);
  t1 = hal_get_time();
  printcycles("decaps cycles: ", t1-t0);


  t0 = hal_get_time();
#if defined(RADER)
  byteToShort(g, g_modq);
  ntt17_rader(g, g_modq);
  fft9(g_modq);
  ntt17_rader(g, f_modq);
  fft9(f_modq);
  polymul_10x10_153_mr(f_modq, g_modq);
  ifft9(f_modq);
  intt17_rader_mr(f_modq, g_modq);
  mod_reduce(f_modq, g_modq);


#elif defined(MIXED)
  asm_ntt(f_modq,g_modq,omegas_asm);
  asm_ntt1s(g_modq,g,omegas_asm);
  asm_basemul(f_modq,g_modq,bromegas_asm);
  asm_invntt(g_modq,f_modq,invomegas_asm);
#elif defined(GOODS)
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
  t1 = hal_get_time();
  printcycles("Poly mul cycles: ", t1-t0);

  t0 = hal_get_time();
#if defined(RADER)
    ntt17_rader(g, f_modq);
  fft9(f_modq);
#elif defined(MIXED)
  asm_ntt(f_modq,g_modq,omegas_asm);
#elif defined(GOODS)
  NTT_forward_16(f, root_table, MOD, Mprime, &(Goodp1[0][0]));
#endif
  t1 = hal_get_time();
  printcycles("NTT cycles: ", t1-t0);
  t0 = hal_get_time();
#if defined(RADER)
    byteToShort(g, g_modq);
  ntt17_rader(g, g_modq);
  fft9(g_modq);
#elif defined(MIXED)
  asm_ntt1s(g_modq,g,omegas_asm);
#elif defined(GOODS)
  NTT_forward_8(g, root_table, MOD, Mprime, &(Goodp0[0][0]));
#endif
  t1 = hal_get_time();
  printcycles("NTT1s cycles: ", t1-t0);
  t0 = hal_get_time();
#if defined(RADER)
  polymul_10x10_153_mr(f_modq, g_modq);
#elif defined(MIXED)
  asm_basemul(f_modq, g_modq, bromegas_asm);
#elif defined(GOODS)
  __asm_my_mul(&(Goodp0[1][0]), &(Goodp1[1][0]), Mprime, MOD);
#endif
  t1 = hal_get_time();
  printcycles("Base mul cycles: ", t1-t0);
  t0 = hal_get_time();
#if defined(RADER)
   ifft9(f_modq);
  intt17_rader_mr(f_modq, g_modq);
  mod_reduce(f_modq, g_modq);
#elif defined(MIXED)
  asm_invntt(g_modq,f_modq,invomegas_asm);
#elif defined(GOODS)
  __asm_NTT_inv_1_2_3(&(Goodp0[0][0]), inv_factor_1_2_3, Mprime, MOD);
  __asm_NTT_inv_4_5_6(&(Goodp0[0][0]), inv_factor_4_5_6, Mprime, MOD);
  __asm_NTT_inv_7_8_9(&(Goodp0[0][0]), inv_factor_7_8_9, Mprime, MOD);

  __asm_final_map_and_pack(h, R2invN, Goodp0[2],
                           Goodp0[0], O_M, O_M_bar, Mhalf,
                           Mprime, MOD);
#endif
  t1 = hal_get_time();
  printcycles("invNTT cycles: ", t1-t0);

  if (memcmp(key_a, key_b, CRYPTO_BYTES)) {
    hal_send_rstr("ERROR KEYS\n");
  }
  else {
    hal_send_rstr("SUCCESS\n");
  }



  hal_send_str("#");
  while(1);
  return 0;
}
