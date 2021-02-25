#include "api.h"
#include "randombytes.h"
#include "hal.h"
#include <stdint.h>
#include <string.h>

#if defined(MIXED)
#define TEST_q 4591
#define TEST_n 1620
#elif defined(MIXED1)
#define TEST_q 4591
#define TEST_n 1530
#elif defined(GOODS)
#define TEST_q 6984193
#define TEST_n 1536
#endif



#define NTESTS 10


const uint8_t canary[8] = {
  0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF
};

/* allocate a bit more for all keys and messages and
 * make sure it is not touched by the implementations.
 */
static void write_canary(uint8_t *d) {
  for (size_t i = 0; i < 8; i++) {
    d[i] = canary[i];
  }
}

static int check_canary(const uint8_t *d) {
  for (size_t i = 0; i < 8; i++) {
    if (d[i] != canary[i]) {
      return -1;
    }
  }
  return 0;
}

static int test_keys(void)
{
  unsigned char key_a[CRYPTO_BYTES+16], key_b[CRYPTO_BYTES+16];
  unsigned char pk[CRYPTO_PUBLICKEYBYTES+16];
  unsigned char sendb[CRYPTO_CIPHERTEXTBYTES+16];
  unsigned char sk_a[CRYPTO_SECRETKEYBYTES+16];
  int ret=0;

  write_canary(key_a); write_canary(key_a+sizeof(key_a)-8);
  write_canary(key_b); write_canary(key_b+sizeof(key_b)-8);
  write_canary(pk); write_canary(pk+sizeof(pk)-8);
  write_canary(sendb); write_canary(sendb+sizeof(sendb)-8);
  write_canary(sk_a); write_canary(sk_a+sizeof(sk_a)-8);


  int i;

  for(i=0; i<NTESTS; i++)
  {
    //Alice generates a public key
    crypto_kem_keypair(pk+8, sk_a+8);
    //hal_send_str("DONE key pair generation!");

    //Bob derives a secret key and creates a response
    crypto_kem_enc(sendb+8, key_b+8, pk+8);
    //hal_send_str("DONE encapsulation!");

    //Alice uses Bobs response to get her secret key
    crypto_kem_dec(key_a+8, sendb+8, sk_a+8);
    //hal_send_str("DONE decapsulation!");

    if(memcmp(key_a+8, key_b+8, CRYPTO_BYTES))
    {
      ret |= 1;
    }
    else if(check_canary(key_a) || check_canary(key_a+sizeof(key_a)-8) ||
            check_canary(key_b) || check_canary(key_b+sizeof(key_b)-8) ||
            check_canary(pk) || check_canary(pk+sizeof(pk)-8) ||
            check_canary(sendb) || check_canary(sendb+sizeof(sendb)-8) ||
            check_canary(sk_a) || check_canary(sk_a+sizeof(sk_a)-8))
    {
      ret |= 2;
    }
  }

  return ret;
}


static int test_invalid_sk_a(void)
{
  unsigned char sk_a[CRYPTO_SECRETKEYBYTES];
  unsigned char key_a[CRYPTO_BYTES], key_b[CRYPTO_BYTES];
  unsigned char pk[CRYPTO_PUBLICKEYBYTES];
  unsigned char sendb[CRYPTO_CIPHERTEXTBYTES];
  int i;
  int ret=0;

  for(i=0; i<NTESTS; i++)
  {
    //Alice generates a public key
    crypto_kem_keypair(pk, sk_a);

    //Bob derives a secret key and creates a response
    crypto_kem_enc(sendb, key_b, pk);

    //Replace secret key with random values
    randombytes(sk_a, CRYPTO_SECRETKEYBYTES);

    //Alice uses Bobs response to get her secre key
    crypto_kem_dec(key_a, sendb, sk_a);

    if(!memcmp(key_a, key_b, CRYPTO_BYTES))
    {
      ret |= 1;
    }
  }

  return ret;
}


static int test_invalid_ciphertext(void)
{
  unsigned char sk_a[CRYPTO_SECRETKEYBYTES];
  unsigned char key_a[CRYPTO_BYTES], key_b[CRYPTO_BYTES];
  unsigned char pk[CRYPTO_PUBLICKEYBYTES];
  unsigned char sendb[CRYPTO_CIPHERTEXTBYTES];
  int i;
  int ret=0;
  size_t pos;

  for(i=0; i<NTESTS; i++)
  {
    randombytes((unsigned char *)&pos, sizeof(size_t));

    //Alice generates a public key
    crypto_kem_keypair(pk, sk_a);

    //Bob derives a secret key and creates a response
    crypto_kem_enc(sendb, key_b, pk);

    // Change ciphertext to random value
    randombytes(sendb, sizeof(sendb));

    //Alice uses Bobs response to get her secret key
    crypto_kem_dec(key_a, sendb, sk_a);

    if(!memcmp(key_a, key_b, CRYPTO_BYTES))
    {
      ret |= 1;
    }
  }

  return ret;
}

int main(void)
{
  hal_setup(CLOCK_FAST);
  hal_send_str("==========================");
  int ret0,ret1,ret2;
  char out[64];
  snprintf(out,64,"Scheme: %s\n",crypto_kem_PRIMITIVE); 
  hal_send_str(out);
  snprintf(out,64,"NTT ring: Z_{%d}/(X^{%d}-1)\n",TEST_q,TEST_n); 
  hal_send_str(out);




  ret0 = test_keys();
  if (ret0&1)
    hal_send_str("ERROR KEYS\n");
  if (ret0&2)
    hal_send_str("ERROR canary overwritten\n");

  ret1 = test_invalid_sk_a();
  if (ret1)
    hal_send_str("ERROR invalid sk_a\n");
  
  ret2 = test_invalid_ciphertext();
  if (ret2)
    hal_send_str("ERROR invalid ciphertext\n");

  if (~(ret0|ret1|ret2))
    hal_send_str("SUCCESS\n");
  hal_send_str("#");

  while(1);

  return 0;
}
