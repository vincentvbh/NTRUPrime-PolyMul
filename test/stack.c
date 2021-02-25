#include "api.h"
#include "randombytes.h"
#include "hal.h"
#include "sendfn.h"

#if defined(MIXED)
#define STACK_q 4591
#define STACK_n 1620
#elif defined(MIXED1)
#define STACK_q 4591
#define STACK_n 1530
#elif defined(GOODS)
#define STACK_q 6984193
#define STACK_n 1536
#endif


#include <string.h>

#define MAX_SIZE 0x1A000


#define send_stack_usage(S, U) send_unsigned((S), (U))

unsigned int canary_size = MAX_SIZE;
volatile unsigned char *p;
unsigned int c;
uint8_t canary = 0x42;
  unsigned char key_a[CRYPTO_BYTES], key_b[CRYPTO_BYTES];
  unsigned char sk[CRYPTO_SECRETKEYBYTES];
  unsigned char pk[CRYPTO_PUBLICKEYBYTES];
  unsigned char ct[CRYPTO_CIPHERTEXTBYTES];

unsigned int stack_key_gen, stack_encaps, stack_decaps;

#define FILL_STACK()                                                           \
  p = &a;                                                                      \
  while (p > &a - canary_size)                                                 \
    *(p--) = canary;
#define CHECK_STACK()                                                          \
  c = canary_size;                                                             \
  p = &a - canary_size + 1;                                                    \
  while (*p == canary && p < &a) {                                             \
    p++;                                                                       \
    c--;                                                                       \
  }

static int test_keys(void) {
  volatile unsigned char a;
  // Alice generates a public key
  FILL_STACK()
   crypto_kem_keypair(pk, sk);
  CHECK_STACK()
  if(c >= canary_size) return -1;
  stack_key_gen = c;

  // Bob derives a secret key and creates a response
  FILL_STACK()
   crypto_kem_enc(ct, key_a, pk);
  CHECK_STACK()
  if(c >= canary_size) return -1;
  stack_encaps = c;

  // Alice uses Bobs response to get her secret key
  FILL_STACK()
   crypto_kem_dec(key_b, ct, sk);;
  CHECK_STACK()
  if(c >= canary_size) return -1;
  stack_decaps = c;
  
  if (memcmp(key_a, key_b, CRYPTO_BYTES)){
    return -1;
  } else {
    send_stack_usage("canary size: ", canary_size);
    send_stack_usage("key gen stack usage: ", stack_key_gen);
    send_stack_usage("encaps stack usage: ", stack_encaps);
    send_stack_usage("decaps stack usage: ", stack_decaps);
    hal_send_str("SUCCESS\n");
    return 0;
  }
}

int main(void) {
  hal_setup(CLOCK_FAST);

  // marker for automated benchmarks
  hal_send_str("==========================");
  char out[64];
  snprintf(out,64,"Scheme: %s\n",crypto_kem_PRIMITIVE); 
  hal_send_str(out);
  snprintf(out,64,"NTT ring: Z_{%d}/(X^{%d}-1)\n",STACK_q,STACK_n); 
  hal_send_str(out);
  
  canary_size = 0x1000;
  while(test_keys()){
    canary_size += 0x100;
    if(canary_size >= MAX_SIZE) {
      hal_send_str("failed to measure stack usage.\n");
      break;
    }
  }
  // marker for automated benchmarks
  hal_send_str("#");

  while (1);

  return 0;
}
