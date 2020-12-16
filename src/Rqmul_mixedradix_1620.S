
.syntax unified
.cpu cortex-m4
.thumb

.macro load3 a, a0, a1, a2, mem0, mem1, mem2
  ldr.w \a0, [\a, \mem0]
  ldr.w \a1, [\a, \mem1]
  ldr.w \a2, [\a, \mem2]
.endm

.macro store3 a, a0, a1, a2, mem0, mem1, mem2
  str.w \a0, [\a, \mem0]
  str.w \a1, [\a, \mem1]
  str.w \a2, [\a, \mem2]
.endm

.macro load5 a, a0, a1, a2, a3, a4, mem0, mem1, mem2, mem3, mem4
  ldrsh \a0, [\a, \mem0]
  ldrsh \a1, [\a, \mem1]
  ldrsh \a2, [\a, \mem2]
  ldrsh \a3, [\a, \mem3]
  ldrsh \a4, [\a, \mem4]
.endm

.macro store5 a, a0, a1, a2, a3, a4, mem0, mem1, mem2, mem3, mem4
  strh \a0, [\a, \mem0]
  strh \a1, [\a, \mem1]
  strh \a2, [\a, \mem2]
  strh \a3, [\a, \mem3]
  strh \a4, [\a, \mem4]
.endm


.macro reduce a, t, q, qinv
  smmulr \t, \a, \qinv
  mls   \a, \t, \q, \a
.endm
.macro reducet t, a, q, qinv
  smmulr \t, \a, \qinv
  mls   \t, \t, \q, \a
.endm

.macro dblmred tb1, tb2, a, w, t0, t1, q, qinv
  smulb\tb1 \t0, \a, \w
  smult\tb2 \t1, \a, \w
  reduce \t0, \a, \q, \qinv
  reduce \t1, \a, \q, \qinv
.endm

.macro dblmredpack tb1, tb2, a, w, t0, t1, q, qinv
  smulb\tb1 \t0, \a, \w
  smult\tb2 \t1, \a, \w
  reduce \t0, \a, \q, \qinv
  reduce \t1, \a, \q, \qinv
  pkhbt \a, \t0, \t1, LSL #16
.endm

.macro bfthree a0, a12, w12, t0, t1, q, qinv
  mov \t0, #65537
  smlad \t0, \t0, \a12, \a0
  smladx \t1, \a12, \w12, \a0      // a[i+1] = a[i+0] + w^1*a[i+1] + w^2*a[i+2]
  smlad \a12, \a12, \w12, \a0     // a[i+2] = a[i+0] + w^2*a[i+1] + w^1*a[i+1]
  mov \a0, \t0
  reduce \t1, \t0, \q, \qinv
  reduce \a12, \t0, \q, \qinv
  pkhbt \a12, \t1, \a12, LSL #16
.endm
.macro bfthreer a0, a12, w12, t0, t1, q, qinv
  mov \t0, #65537
  smlad \t0, \t0, \a12, \a0
  smladx \t1, \a12, \w12, \a0      // a[i+1] = a[i+0] + w^1*a[i+1] + w^2*a[i+2]
  smlad \a12, \a12, \w12, \a0     // a[i+2] = a[i+0] + w^2*a[i+1] + w^1*a[i+1]
  reducet \a0, \t0, \q, \qinv
  reduce \t1, \t0, \q, \qinv
  reduce \a12, \t0, \q, \qinv
  pkhbt \a12, \t1, \a12, LSL #16
.endm
.macro bfthreenr a0, a12, w12, t0, t1, q, qinv
  mov \t0, #65537
  smlad \t0, \t0, \a12, \a0
  smladx \t1, \a12, \w12, \a0      // a[i+1] = a[i+0] + w^1*a[i+1] + w^2*a[i+2]
  smlad \a12, \a12, \w12, \a0     // a[i+2] = a[i+0] + w^2*a[i+1] + w^1*a[i+1]
  mov \a0, \t0
  pkhbt \a12, \t1, \a12, LSL #16
.endm

.macro bffive a0, a12, a34, w12, w34, t0, t1, t2, t3, q, qinv
  pkhbt  \t0, \w12, \w34, LSL #16
  pkhtb  \t3, \w34, \w12, ASR #16
  smlad \t1, \a12, \t3, \a0       // a[i+2] = a[i+0] + w^2*a[i+1] + w^4*a[i+2] 
  smlad \t1, \a34, \t0, \t1       // a[i+2] = a[i+2] + w^1*a[i+3] + w^3*a[i+4] 
  smladx \t2, \a12, \t0, \a0      // a[i+3] = a[i+0] + w^3*a[i+1] + w^1*a[i+2] 
  smladx \t2, \a34, \t3, \t2      // a[i+3] = a[i+3] + w^4*a[i+1] + w^2*a[i+2] 
  smlad \t0, \a12, \w12, \a0      // a[i+1] = a[i+0] + w^1*a[i+1] + w^2*a[i+2] 
  smlad \t0, \a34, \w34, \t0      // a[i+1] = a[i+1] + w^3*a[i+3] + w^4*a[i+4] 
  smladx \t3, \a12, \w34, \a0     // a[i+4] = a[i+0] + w^4*a[i+1] + w^3*a[i+2] 
  smladx \t3, \a34, \w12, \t3     // a[i+4] = a[i+4] + w^2*a[i+3] + w^1*a[i+4] 
  reduce \t0, \a12, \q, \qinv
  reduce \t1, \a12, \q, \qinv
  reduce \t3, \a34, \q, \qinv
  reduce \t2, \a34, \q, \qinv
.endm

.global asm_ntt1s
.type asm_ntt1s,%function
.align 4
asm_ntt1s:
  push    {r4-r11, r14}

  poly        .req r0
  twiddle_ptr .req r1
  a0          .req r2
  a12         .req r3
  b0          .req r4
  b12         .req r5
  w12         .req r6
  w           .req r4
  t0          .req r7
  t1          .req r8
  t2          .req r9
  qinv        .req r10
  q           .req r11
  tmp         .req r12
  tmp1        .req r14
 
   mov tmp, twiddle_ptr   
   mov twiddle_ptr, a0
   mov q, #4591
   mov qinv, #18015
   movt qinv, #14
 
   vmov.w s7, tmp
//  b nttsecondpart
// bftwo and the first bfthree
  .equ distance, 540
//
  mov w12, #65225
  movt w12, #310
  mov tmp, #36
  nop
  nop
  nop
  nop
  nop
  nop
  nop
firstloop1s:
  vmov.w s0, tmp
  ldrh b12, [twiddle_ptr], #2
  ldr.w a0, [twiddle_ptr], #4
  ldr.w a12, [twiddle_ptr], #4
  vmov.w s1, b12
  vmov.w s2, a0
  vmov.w s3, a12
  
  vmov.w tmp, s7
  
  ldr t1, [tmp, #distance/2]
  ldr t2, [tmp, #distance] 
  ldr t0, [tmp], #4 
  
  sxtb16 a0, t1
  sxtb16 a12, t1, ror#8
  pkhbt t1, a0, a12, lsl#16
  pkhtb a0, a12, a0, asr#16
  vmov.w s11, a0
  
  sxtb16 a0, t2
  sxtb16 a12, t2, ror#8
  pkhbt t2, a0, a12, lsl#16
  pkhtb a0, a12, a0, asr#16
  vmov.w s12, a0
  
  sxtb16 a0, t0
  sxtb16 a12, t0, ror#8
  pkhbt t0, a0, a12, lsl#16
  pkhtb a0, a12, a0, asr#16
  vmov.w s10, a0
  
  vmov.w s7, tmp

// First two coefficients
// N/2+i part  
  vmov.w w, s2
  // input is in (-1, 0, 1) no need for reduction
  smulbb a12, t1, w
  smultb b12, t1, w
  smulbt tmp, t2, w
  smultt tmp1, t2, w
  pkhbt a12, a12, tmp, LSL #16
  pkhbt b12, b12, tmp1, LSL #16
  mov tmp, t0
  vmov.w w, s1
  smulbb a0, t0, w
  smultb b0, t0, w
  bfthree a0, a12, w12, tmp, tmp1, q, qinv
  bfthree b0, b12, w12, tmp, tmp1, q, qinv
  pkhbt tmp, a0, b0, LSL #16
  str.w tmp, [poly, #3*distance] 
  vmov.w tmp, s3
  dblmred b, t, a12, tmp, a0, b0, q, qinv
  dblmred b, t, b12, tmp, tmp1, a12, q, qinv 
  pkhbt b12, a0, tmp1, LSL #16
  pkhbt b0, b0, a12, LSL #16
  str.w b12, [poly, #4*distance]
  str.w b0, [poly, #5*distance]
// i part 
  pkhbt a12, t1, t2, LSL #16
  pkhtb b12, t2, t1, ASR #16
  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  bfthreenr a0, a12, w12, t0, t1, q, qinv
  bfthreenr b0, b12, w12, t0, t1, q, qinv
  pkhbt t0, a0, b0, LSL #16
  dblmred b, t, a12, tmp, t1, t2, q, qinv 
  dblmred b, t, b12, tmp, a0, a12, q, qinv 
  
  pkhbt b12, t1, a0, LSL #16
  pkhbt a0, t2, a12, LSL #16

  str.w a0, [poly, #2*distance]
  str.w b12, [poly, #distance]
  str.w t0, [poly], #4

// Second two coefficients
  vmov.w t0, s10
  vmov.w t1, s11
  vmov.w t2, s12
  
  vmov.w w, s2
  // input is in (-1, 0, 1) no need for reduction
  smulbb a12, t1, w
  smultb b12, t1, w
  smulbt tmp, t2, w
  smultt tmp1, t2, w
  pkhbt a12, a12, tmp, LSL #16
  pkhbt b12, b12, tmp1, LSL #16
  mov tmp, t0
  vmov.w w, s1
  smulbb a0, t0, w
  smultb b0, t0, w
  bfthree a0, a12, w12, tmp, tmp1, q, qinv
  bfthree b0, b12, w12, tmp, tmp1, q, qinv
  pkhbt tmp, a0, b0, LSL #16
  str.w tmp, [poly, #3*distance] 
  vmov.w tmp, s3
  dblmred b, t, a12, tmp, a0, b0, q, qinv
  dblmred b, t, b12, tmp, tmp1, a12, q, qinv 
  pkhbt b12, a0, tmp1, LSL #16
  pkhbt b0, b0, a12, LSL #16
  str.w b12, [poly, #4*distance]
  str.w b0, [poly, #5*distance]
// i part 
  pkhbt a12, t1, t2, LSL #16
  pkhtb b12, t2, t1, ASR #16
  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  bfthreenr a0, a12, w12, t0, t1, q, qinv
  bfthreenr b0, b12, w12, t0, t1, q, qinv
  pkhbt t0, a0, b0, LSL #16
  dblmred b, t, a12, tmp, t1, t2, q, qinv 
  dblmred b, t, b12, tmp, a0, a12, q, qinv 
  
  pkhbt b12, t1, a0, LSL #16
  pkhbt a0, t2, a12, LSL #16

  str.w a0, [poly, #2*distance]
  str.w b12, [poly, #distance]
  str.w t0, [poly], #4

// Last two coefficients
  vmov.w tmp, s7
  
  ldrh t1, [tmp, #distance/2]
  ldrh t2, [tmp, #distance] 
  ldrh t0, [tmp], #2 

  sxtb16 a0, t1
  sxtb16 a12, t1, ror#8
  pkhbt t1, a0, a12, lsl#16
  
  sxtb16 a0, t2
  sxtb16 a12, t2, ror#8
  pkhbt t2, a0, a12, lsl#16
  
  sxtb16 a0, t0
  sxtb16 a12, t0, ror#8
  pkhbt t0, a0, a12, lsl#16

  vmov.w s7, tmp
// N/2+i part  
  vmov.w w, s2
  // input is in (-1, 0, 1) no need for reduction
  smulbb a12, t1, w
  smultb b12, t1, w
  smulbt tmp, t2, w
  smultt tmp1, t2, w
  pkhbt a12, a12, tmp, LSL #16
  pkhbt b12, b12, tmp1, LSL #16
  mov tmp, t0
  vmov.w w, s1
  smulbb a0, t0, w
  smultb b0, t0, w
  bfthree a0, a12, w12, tmp, tmp1, q, qinv
  bfthree b0, b12, w12, tmp, tmp1, q, qinv
  pkhbt tmp, a0, b0, LSL #16
  str.w tmp, [poly, #3*distance] 
  vmov.w tmp, s3
  dblmred b, t, a12, tmp, a0, b0, q, qinv
  dblmred b, t, b12, tmp, tmp1, a12, q, qinv 
  pkhbt b12, a0, tmp1, LSL #16
  pkhbt b0, b0, a12, LSL #16
  str.w b12, [poly, #4*distance]
  str.w b0, [poly, #5*distance]
// i part 
  pkhbt a12, t1, t2, LSL #16
  pkhtb b12, t2, t1, ASR #16
  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  bfthreenr a0, a12, w12, t0, t1, q, qinv
  bfthreenr b0, b12, w12, t0, t1, q, qinv
  pkhbt t0, a0, b0, LSL #16
  dblmred b, t, a12, tmp, t1, t2, q, qinv 
  dblmred b, t, b12, tmp, a0, a12, q, qinv 
  
  pkhbt b12, t1, a0, LSL #16
  pkhbt a0, t2, a12, LSL #16

  str.w a0, [poly, #2*distance]
  str.w b12, [poly, #distance]
  str.w t0, [poly], #4

  vmov.w tmp, s0
  subs.w tmp, #1
  bne.w firstloop1s

// last small polynomial only has 5 non-zero coefficients
  ldrsh b12, [twiddle_ptr], #2
  ldr.w a0, [twiddle_ptr], #4
  ldr.w a12, [twiddle_ptr], #4
  vmov.w s1, b12
  vmov.w s2, a0
  vmov.w s3, a12
  
  vmov.w tmp, s7
  
  ldr t1, [tmp, #distance/2]
  ldr t2, [tmp, #distance] 
  ldr t0, [tmp], #4

  sxtb16 a0, t1
  sxtb16 a12, t1, ror#8
  pkhbt t1, a0, a12, lsl#16
  pkhtb a0, a12, a0, asr#16
  vmov.w s11, a0
 
  sxtb16 a0, t2
  sxtb16 a12, t2, ror#8
  pkhbt t2, a0, a12, lsl#16
  pkhtb a0, a12, a0, asr#16
  vmov.w s12, a0

  sxtb16 a0, t0
  sxtb16 a12, t0, ror#8
  pkhbt t0, a0, a12, lsl#16
  pkhtb a0, a12, a0, asr#16
  vmov.w s10, a0
  
  vmov.w s7, tmp

// First two coefficients
// N/2+i part  
  vmov.w w, s2
  // input is in (-1, 0, 1) no need for reduction
  smulbb a12, t1, w
  smultb b12, t1, w
  smulbt tmp, t2, w
  smultt tmp1, t2, w
  pkhbt a12, a12, tmp, LSL #16
  pkhbt b12, b12, tmp1, LSL #16
  mov tmp, t0
  vmov.w w, s1
  smulbb a0, t0, w
  smultb b0, t0, w
  bfthree a0, a12, w12, tmp, tmp1, q, qinv
  bfthree b0, b12, w12, tmp, tmp1, q, qinv
  pkhbt tmp, a0, b0, LSL #16
  str.w tmp, [poly, #3*distance] 
  vmov.w tmp, s3
  dblmred b, t, a12, tmp, a0, b0, q, qinv
  dblmred b, t, b12, tmp, tmp1, a12, q, qinv 
  pkhbt b12, a0, tmp1, LSL #16
  pkhbt b0, b0, a12, LSL #16
  str.w b12, [poly, #4*distance]
  str.w b0, [poly, #5*distance]
// i part 
  pkhbt a12, t1, t2, LSL #16
  pkhtb b12, t2, t1, ASR #16
  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  bfthreenr a0, a12, w12, t0, t1, q, qinv
  bfthreenr b0, b12, w12, t0, t1, q, qinv
  pkhbt t0, a0, b0, LSL #16
  dblmred b, t, a12, tmp, t1, t2, q, qinv 
  dblmred b, t, b12, tmp, a0, a12, q, qinv 
  
  pkhbt b12, t1, a0, LSL #16
  pkhbt a0, t2, a12, LSL #16

  str.w a0, [poly, #2*distance]
  str.w b12, [poly, #distance]
  str.w t0, [poly], #4

// Second two coefficients
  vmov.w t0, s10
  vmov.w t1, s11
  vmov.w t2, s12
  
  vmov.w w, s2
  // input is in (-1, 0, 1) no need for reduction
  smulbb a12, t1, w
  smultb b12, t1, w
  smulbt tmp, t2, w
  smultt tmp1, t2, w
  pkhbt a12, a12, tmp, LSL #16
  pkhbt b12, b12, tmp1, LSL #16
  mov tmp, t0
  vmov.w w, s1
  smulbb a0, t0, w
  smultb b0, t0, w
  bfthree a0, a12, w12, tmp, tmp1, q, qinv
  bfthree b0, b12, w12, tmp, tmp1, q, qinv
  pkhbt tmp, a0, b0, LSL #16
  str.w tmp, [poly, #3*distance] 
  vmov.w tmp, s3
  dblmred b, t, a12, tmp, a0, b0, q, qinv
  dblmred b, t, b12, tmp, tmp1, a12, q, qinv 
  pkhbt b12, a0, tmp1, LSL #16
  pkhbt b0, b0, a12, LSL #16
  str.w b12, [poly, #4*distance]
  str.w b0, [poly, #5*distance]
// i part 
  pkhbt a12, t1, t2, LSL #16
  pkhtb b12, t2, t1, ASR #16
  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  bfthreenr a0, a12, w12, t0, t1, q, qinv
  bfthreenr b0, b12, w12, t0, t1, q, qinv
  pkhbt t0, a0, b0, LSL #16
  dblmred b, t, a12, tmp, t1, t2, q, qinv 
  dblmred b, t, b12, tmp, a0, a12, q, qinv 
  
  pkhbt b12, t1, a0, LSL #16
  pkhbt a0, t2, a12, LSL #16

  str.w a0, [poly, #2*distance]
  str.w b12, [poly, #distance]
  str.w t0, [poly], #4

// Last two coefficients
  vmov.w tmp, s7

  ldrh t1, [tmp, #distance/2]
  ldrb t2, [tmp, #distance]
  ldrh t0, [tmp], #2

  sxtb16 a0, t1
  sxtb16 a12, t1, ror#8
  pkhbt t1, a0, a12, lsl#16
  
  sxtb16 t2, t2
  
  sxtb16 a0, t0
  sxtb16 a12, t0, ror#8
  pkhbt t0, a0, a12, lsl#16

  vmov.w s7, tmp
// N/2+i part  
  vmov.w w, s2
  // input is in (-1, 0, 1) no need for reduction
  smulbb a12, t1, w
  smultb b12, t1, w
  smulbt tmp, t2, w
  smultt tmp1, t2, w
  pkhbt a12, a12, tmp, LSL #16
  pkhbt b12, b12, tmp1, LSL #16
  mov tmp, t0
  vmov.w w, s1
  smulbb a0, t0, w
  smultb b0, t0, w
  bfthree a0, a12, w12, tmp, tmp1, q, qinv
  bfthree b0, b12, w12, tmp, tmp1, q, qinv
  pkhbt tmp, a0, b0, LSL #16
  str.w tmp, [poly, #3*distance] 
  vmov.w tmp, s3
  dblmred b, t, a12, tmp, a0, b0, q, qinv
  dblmred b, t, b12, tmp, tmp1, a12, q, qinv 
  pkhbt b12, a0, tmp1, LSL #16
  pkhbt b0, b0, a12, LSL #16
  str.w b12, [poly, #4*distance]
  str.w b0, [poly, #5*distance]
// i part 
  pkhbt a12, t1, t2, LSL #16
  pkhtb b12, t2, t1, ASR #16
  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  bfthreenr a0, a12, w12, t0, t1, q, qinv
  bfthreenr b0, b12, w12, t0, t1, q, qinv
  pkhbt t0, a0, b0, LSL #16
  dblmred b, t, a12, tmp, t1, t2, q, qinv 
  dblmred b, t, b12, tmp, a0, a12, q, qinv 
  
  pkhbt b12, t1, a0, LSL #16
  pkhbt a0, t2, a12, LSL #16

  str.w a0, [poly, #2*distance]
  str.w b12, [poly, #distance]
  str.w t0, [poly], #4

// Remaining part always has zero in the third element from 762nd to 810th
  mov tmp, #8
  nop
  nop
  nop
  nop
rmdrloop1s:
  vmov.w s0, tmp
  ldr.w w, [twiddle_ptr], #6 
  ldr.w a0, [twiddle_ptr], #4
  vmov.w s1, w
  vmov.w s2, a0

  vmov.w tmp, s7
 
  ldr t1, [tmp, #distance/2]
  ldr t0, [tmp], #4 

  sxtb16 a0, t1
  sxtb16 a12, t1, ror#8
  pkhbt t1, a0, a12, lsl#16
  pkhtb a0, a12, a0, asr#16
  vmov.w s11, a0
  
  sxtb16 a0, t0
  sxtb16 a12, t0, ror#8
  pkhbt t0, a0, a12, lsl#16
  pkhtb a0, a12, a0, asr#16
  vmov.w s10, a0

  vmov.w s7, tmp
// First two coefficients
// N/2+i part  

  vmov.w w, s1
  smulbb a0, t0, w
  smulbt a12, t1, w
  add tmp1, a0, a12
  smultb t2, t0, w 
  smultt b12, t1, w
  add tmp, t2, b12
  pkhbt tmp, tmp1, tmp, LSL #16
  str.w tmp, [poly, #3*distance]

  smlabt tmp1, a12, w12, a0
  reduce tmp1, tmp, q, qinv
  smlabt tmp, b12, w12, t2
  reduce tmp, w, q, qinv
  pkhbt tmp1, tmp1, tmp, LSL #16

  smlabb a12, a12, w12, a0
  reduce a12, a0, q, qinv
  smlabb b12, b12, w12, t2
  reduce b12, a0, q, qinv
  pkhbt a12, a12, b12, LSL #16
  vmov.w tmp, s2 
  smulbb a0, tmp1, tmp
  reduce a0, t2, q, qinv
  smultb t2, tmp1, tmp
  reduce t2, b12, q, qinv
  pkhbt a0, a0, t2, LSL #16
  smulbt b12, a12, tmp
  reduce b12, t2, q, qinv
  smultt t2, a12, tmp
  reduce t2, w, q, qinv
  pkhbt b12, b12, t2, LSL #16

  str.w a0, [poly, #4*distance] 
  str.w b12, [poly, #5*distance]
  
// i part 
  sadd16 t2, t0, t1

  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  sbfx  a12, t1,  #0, #16
  sbfx  b12, t1, #16, #16 
  
  smlabt t0, a12, w12, a0
  smulbb t0, t0, tmp
  reduce t0, tmp1, q, qinv
  smlabt t1, b12, w12, b0
  smulbb t1, t1, tmp
  reduce t1, tmp1, q, qinv
  pkhbt t0, t0, t1, LSL #16
  
  smlabb a0, a12, w12, a0
  smulbt a0, a0, tmp
  reduce a0, tmp1, q, qinv
  smlabb b0, b12, w12, b0
  smulbt b0, b0, tmp
  reduce b0, tmp1, q, qinv
  pkhbt a0, a0, b0, LSL #16

  str.w a0, [poly, #2*distance]
  str.w t0, [poly, #distance]
  str.w t2, [poly], #4

// Second two coefficients
// N/2+i part  
  vmov.w t0, s10
  vmov.w t1, s11

  vmov.w w, s1
  smulbb a0, t0, w
  smulbt a12, t1, w
  add tmp1, a0, a12
  smultb t2, t0, w 
  smultt b12, t1, w
  add tmp, t2, b12
  pkhbt tmp, tmp1, tmp, LSL #16
  str.w tmp, [poly, #3*distance]

  smlabt tmp1, a12, w12, a0
  reduce tmp1, tmp, q, qinv
  smlabt tmp, b12, w12, t2
  reduce tmp, w, q, qinv
  pkhbt tmp1, tmp1, tmp, LSL #16

  smlabb a12, a12, w12, a0
  reduce a12, a0, q, qinv
  smlabb b12, b12, w12, t2
  reduce b12, a0, q, qinv
  pkhbt a12, a12, b12, LSL #16
  vmov.w tmp, s2 
  smulbb a0, tmp1, tmp
  reduce a0, t2, q, qinv
  smultb t2, tmp1, tmp
  reduce t2, b12, q, qinv
  pkhbt a0, a0, t2, LSL #16
  smulbt b12, a12, tmp
  reduce b12, t2, q, qinv
  smultt t2, a12, tmp
  reduce t2, w, q, qinv
  pkhbt b12, b12, t2, LSL #16


  str.w a0, [poly, #4*distance] 
  str.w b12, [poly, #5*distance]
  
// i part 
  sadd16 t2, t0, t1

  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  sbfx  a12, t1,  #0, #16
  sbfx  b12, t1, #16, #16 
  
  smlabt t0, a12, w12, a0
  smulbb t0, t0, tmp
  reduce t0, tmp1, q, qinv
  smlabt t1, b12, w12, b0
  smulbb t1, t1, tmp
  reduce t1, tmp1, q, qinv
  pkhbt t0, t0, t1, LSL #16
  
  smlabb a0, a12, w12, a0
  smulbt a0, a0, tmp
  reduce a0, tmp1, q, qinv
  smlabb b0, b12, w12, b0
  smulbt b0, b0, tmp
  reduce b0, tmp1, q, qinv
  pkhbt a0, a0, b0, LSL #16

  str.w a0, [poly, #2*distance]
  str.w t0, [poly, #distance]
  str.w t2, [poly], #4

  // Last two coefficients
  vmov.w tmp, s7

  ldrh t1, [tmp, #distance/2]
  ldrh t0, [tmp], #2 
  
  sxtb16 a0, t1
  sxtb16 a12, t1, ror#8
  pkhbt t1, a0, a12, lsl#16
  

  sxtb16 a0, t0
  sxtb16 a12, t0, ror#8
  pkhbt t0, a0, a12, lsl#16
  
  vmov.w s7, tmp
// N/2+i part  
  vmov.w w, s1
  smulbb a0, t0, w
  smulbt a12, t1, w
  add tmp1, a0, a12
  smultb t2, t0, w 
  smultt b12, t1, w
  add tmp, t2, b12
  pkhbt tmp, tmp1, tmp, LSL #16
  str.w tmp, [poly, #3*distance]

  smlabt tmp1, a12, w12, a0
  reduce tmp1, tmp, q, qinv
  smlabt tmp, b12, w12, t2
  reduce tmp, w, q, qinv
  pkhbt tmp1, tmp1, tmp, LSL #16

  smlabb a12, a12, w12, a0
  reduce a12, a0, q, qinv
  smlabb b12, b12, w12, t2
  reduce b12, a0, q, qinv
  pkhbt a12, a12, b12, LSL #16
  vmov.w tmp, s2 
  smulbb a0, tmp1, tmp
  reduce a0, t2, q, qinv
  smultb t2, tmp1, tmp
  reduce t2, b12, q, qinv
  pkhbt a0, a0, t2, LSL #16
  smulbt b12, a12, tmp
  reduce b12, t2, q, qinv
  smultt t2, a12, tmp
  reduce t2, w, q, qinv
  pkhbt b12, b12, t2, LSL #16


  str.w a0, [poly, #4*distance] 
  str.w b12, [poly, #5*distance]
  
// i part 
  sadd16 t2, t0, t1

  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  sbfx  a12, t1,  #0, #16
  sbfx  b12, t1, #16, #16 
  
  smlabt t0, a12, w12, a0
  smulbb t0, t0, tmp
  reduce t0, tmp1, q, qinv
  smlabt t1, b12, w12, b0
  smulbb t1, t1, tmp
  reduce t1, tmp1, q, qinv
  pkhbt t0, t0, t1, LSL #16
  
  smlabb a0, a12, w12, a0
  smulbt a0, a0, tmp
  reduce a0, tmp1, q, qinv
  smlabb b0, b12, w12, b0
  smulbt b0, b0, tmp
  reduce b0, tmp1, q, qinv
  pkhbt a0, a0, b0, LSL #16

  str.w a0, [poly, #2*distance]
  str.w t0, [poly, #distance]
  str.w t2, [poly], #4

  vmov.w tmp, s0
  subs.w tmp, #1
  bne.w rmdrloop1s


  sub poly, #distance
  b nttsecondpart


.global asm_ntt
.type asm_ntt,%function
.align 4
asm_ntt:
  push    {r4-r11, r14}
  poly        .req r0
  twiddle_ptr .req r1
  a0          .req r2
  a12         .req r3
  b0          .req r4
  b12         .req r5
  w12         .req r6
  w           .req r4
  t0          .req r7
  t1          .req r8
  t2          .req r9
  qinv        .req r10
  q           .req r11
  tmp         .req r12
  tmp1        .req r14

   vmov s7, twiddle_ptr
   mov twiddle_ptr, a0
   mov q, #4591
   mov qinv, #18015
   movt qinv, #14
// bftwo and the first bfthree
  .equ distance, 540
//
  mov w12, #65225
  movt w12, #310
  mov tmp, #36
  nop
  nop
  nop
  nop
  nop
  nop
  nop
firstloop:
  vmov.w s0, tmp
  ldrh b12, [twiddle_ptr], #2
  ldr.w a0, [twiddle_ptr], #4
  ldr.w a12, [twiddle_ptr], #4
  vmov.w s1, b12
  vmov.w s2, a0
  vmov.w s3, a12
.rept 3
  //load3 poly, t0, t1, t2, #0, #distance, #2*distance
  vmov tmp, s7
  ldr.w t2, [tmp, #2*distance]
  ldr.w t1, [tmp, #distance]
  ldr.w t0, [tmp], #4
  vmov s7, tmp
// N/2+i part  

  vmov.w w, s2
  smulbb a12, t1, w
  reduce a12, b12, q, qinv
  smultb b12, t1, w
  reduce b12, tmp, q, qinv
  smulbt tmp, t2, w
  reduce tmp, tmp1, q, qinv
  smultt tmp1, t2, w
  reduce tmp1, w, q, qinv
  pkhbt a12, a12, tmp, LSL #16
  pkhbt b12, b12, tmp1, LSL #16
  mov tmp, t0
  vmov.w w, s1
  dblmred b, b, tmp, w, a0, b0, q, qinv
  bfthree a0, a12, w12, tmp, tmp1, q, qinv
  bfthree b0, b12, w12, tmp, tmp1, q, qinv
  pkhbt tmp, a0, b0, LSL #16
  str.w tmp, [poly, #3*distance] 
  vmov.w tmp, s3
  dblmred b, t, a12, tmp, a0, b0, q, qinv
  dblmred b, t, b12, tmp, tmp1, a12, q, qinv 
  pkhbt b12, a0, tmp1, LSL #16
  pkhbt b0, b0, a12, LSL #16
  str.w b12, [poly, #4*distance]
  str.w b0, [poly, #5*distance]
// i part 
  pkhbt a12, t1, t2, LSL #16
  pkhtb b12, t2, t1, ASR #16
  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  bfthree a0, a12, w12, t0, t1, q, qinv
  bfthree b0, b12, w12, t0, t1, q, qinv
  pkhbt t0, a0, b0, LSL #16
  dblmred b, t, a12, tmp, t1, t2, q, qinv 
  dblmred b, t, b12, tmp, a0, a12, q, qinv 
  
  pkhbt b12, t1, a0, LSL #16
  pkhbt a0, t2, a12, LSL #16

  str.w a0, [poly, #2*distance]
  str.w b12, [poly, #distance]
  str.w t0, [poly], #4
.endr
  vmov.w tmp, s0
  subs.w tmp, #1
  bne.w firstloop

  ldrh b12, [twiddle_ptr], #2
  ldr.w a0, [twiddle_ptr], #4
  ldr.w a12, [twiddle_ptr], #4
  vmov.w s1, b12
  vmov.w s2, a0
  vmov.w s3, a12

.rept 2
  vmov tmp, s7
  ldr.w t2, [tmp, #2*distance]
  ldr.w t1, [tmp, #distance]
  ldr.w t0, [tmp], #4
  vmov s7, tmp
// N/2+i part  

  vmov.w w, s2
  smulbb a12, t1, w
  reduce a12, b12, q, qinv
  smultb b12, t1, w
  reduce b12, tmp, q, qinv
  smulbt tmp, t2, w
  reduce tmp, tmp1, q, qinv
  smultt tmp1, t2, w
  reduce tmp1, w, q, qinv
  pkhbt a12, a12, tmp, LSL #16
  pkhbt b12, b12, tmp1, LSL #16
  mov tmp, t0
  vmov.w w, s1
  dblmred b, b, tmp, w, a0, b0, q, qinv
  bfthree a0, a12, w12, tmp, tmp1, q, qinv
  bfthree b0, b12, w12, tmp, tmp1, q, qinv
  pkhbt tmp, a0, b0, LSL #16
  str.w tmp, [poly, #3*distance] 
  vmov.w tmp, s3
  dblmred b, t, a12, tmp, a0, b0, q, qinv
  dblmred b, t, b12, tmp, tmp1, a12, q, qinv 
  pkhbt b12, a0, tmp1, LSL #16
  pkhbt b0, b0, a12, LSL #16
  str.w b12, [poly, #4*distance]
  str.w b0, [poly, #5*distance]
// i part 
  pkhbt a12, t1, t2, LSL #16
  pkhtb b12, t2, t1, ASR #16
  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  bfthree a0, a12, w12, t0, t1, q, qinv
  bfthree b0, b12, w12, t0, t1, q, qinv
  pkhbt t0, a0, b0, LSL #16
  dblmred b, t, a12, tmp, t1, t2, q, qinv 
  dblmred b, t, b12, tmp, a0, a12, q, qinv 
  
  pkhbt b12, t1, a0, LSL #16
  pkhbt a0, t2, a12, LSL #16

  str.w a0, [poly, #2*distance]
  str.w b12, [poly, #distance]
  str.w t0, [poly], #4
.endr

  vmov tmp, s7
  ldrh t2, [tmp, #2*distance]
  ldr.w t1, [tmp, #distance]
  ldr.w t0, [tmp], #4
  vmov s7, tmp
// N/2+i part  

  vmov.w w, s2
  smulbb a12, t1, w
  reduce a12, b12, q, qinv
  smultb b12, t1, w
  reduce b12, tmp, q, qinv
  smulbt tmp, t2, w
  reduce tmp, tmp1, q, qinv
  pkhbt a12, a12, tmp, LSL #16
  mov tmp, t0
  vmov.w w, s1
  dblmred b, b, tmp, w, a0, b0, q, qinv
  bfthree a0, a12, w12, tmp, tmp1, q, qinv
  //bfthree b0, b12, w12, tmp, tmp1, q, qinv
  smlabb tmp, b12, w12, b0
  smlabt tmp1, b12, w12, b0
  add b0, b12
  reduce tmp, b12, q, qinv
  reduce tmp1, b12, q, qinv
  pkhbt b12, tmp1, tmp, LSL #16

  pkhbt tmp, a0, b0, LSL #16
  str.w tmp, [poly, #3*distance] 
  vmov.w tmp, s3
  dblmred b, t, a12, tmp, a0, b0, q, qinv
  dblmred b, t, b12, tmp, tmp1, a12, q, qinv 
  pkhbt b12, a0, tmp1, LSL #16
  pkhbt b0, b0, a12, LSL #16
  str.w b12, [poly, #4*distance]
  str.w b0, [poly, #5*distance]
// i part 
  pkhbt a12, t1, t2, LSL #16
  asr b12, t1, #16
  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  bfthree a0, a12, w12, t0, t1, q, qinv
  //bfthree b0, b12, w12, t0, t1, q, qinv
  smlabb t0, b12, w12, b0
  smlabt t1, b12, w12, b0
  add b0, b12
  reduce t0, b12, q, qinv
  reduce t1, b12, q, qinv
  pkhbt b12, t1, t0, LSL #16

  pkhbt t0, a0, b0, LSL #16
  dblmred b, t, a12, tmp, t1, t2, q, qinv 
  dblmred b, t, b12, tmp, a0, a12, q, qinv 
  
  pkhbt b12, t1, a0, LSL #16
  pkhbt a0, t2, a12, LSL #16

  str.w a0, [poly, #2*distance]
  str.w b12, [poly, #distance]
  str.w t0, [poly], #4


// Remaining part always has zero in the third element from 762nd to 810th
  mov tmp, #8
rmdrloop:
  vmov.w s0, tmp
  ldr.w w, [twiddle_ptr], #6 
  ldr.w a0, [twiddle_ptr], #4
  vmov.w s1, w
  vmov.w s2, a0

.rept 3
  vmov tmp, s7
  ldr.w t1, [tmp, #distance]
  ldr.w t0, [tmp], #4
  vmov s7, tmp
// N/2+i part  

  vmov.w w, s1
  smulbb a0, t0, w
  smulbt a12, t1, w
  reduce a12, tmp, q, qinv
  add tmp1, a0, a12
  reduce tmp1, tmp, q, qinv
  smultb t2, t0, w 
  smultt b12, t1, w
  add tmp, t2, b12
  reduce b12, w, q, qinv
  reduce tmp, w, q, qinv
  pkhbt tmp, tmp1, tmp, LSL #16
  str.w tmp, [poly, #3*distance]

  smlabt tmp1, a12, w12, a0
  reduce tmp1, tmp, q, qinv
  smlabt tmp, b12, w12, t2
  reduce tmp, w, q, qinv
  pkhbt tmp1, tmp1, tmp, LSL #16

  smlabb a12, a12, w12, a0
  reduce a12, a0, q, qinv
  smlabb b12, b12, w12, t2
  reduce b12, a0, q, qinv
  pkhbt a12, a12, b12, LSL #16
  vmov.w tmp, s2
  smulbb a0, tmp1, tmp
  reduce a0, t2, q, qinv
  smultb t2, tmp1, tmp
  reduce t2, b12, q, qinv
  pkhbt a0, a0, t2, LSL #16
  smulbt b12, a12, tmp
  reduce b12, t2, q, qinv
  smultt t2, a12, tmp
  reduce t2, w, q, qinv
  pkhbt b12, b12, t2, LSL #16


  str.w a0, [poly, #4*distance] 
  str.w b12, [poly, #5*distance]
  
// i part 
  sadd16 t2, t0, t1

  sbfx  a0, t0,  #0, #16
  sbfx  b0, t0, #16, #16 
  sbfx  a12, t1,  #0, #16
  sbfx  b12, t1, #16, #16 
  
  smlabt t0, a12, w12, a0
  reduce t0, tmp1, q, qinv
  smulbb t0, t0, tmp
  reduce t0, tmp1, q, qinv
  smlabt t1, b12, w12, b0
  reduce t1, tmp1, q, qinv
  smulbb t1, t1, tmp
  reduce t1, tmp1, q, qinv
  pkhbt t0, t0, t1, LSL #16
  
  smlabb a0, a12, w12, a0
  reduce a0, tmp1, q, qinv
  smulbt a0, a0, tmp
  reduce a0, tmp1, q, qinv
  smlabb b0, b12, w12, b0
  reduce b0, tmp1, q, qinv
  smulbt b0, b0, tmp
  reduce b0, tmp1, q, qinv
  pkhbt a0, a0, b0, LSL #16

  str.w a0, [poly, #2*distance]
  str.w t0, [poly, #distance]
  str.w t2, [poly], #4
.endr
  vmov.w tmp, s0
  subs.w tmp, #1
  bne.w rmdrloop


  sub poly, #distance
// The second bfthree
// all inputs in mod q now
nttsecondpart:
  mov tmp, #5


b3out:
  vmov.w s0, tmp 
  mov tmp1, #6
  ldr.w a0, [twiddle_ptr], #4
  ldr.w a12, [twiddle_ptr], #4
  ldr.w b0, [twiddle_ptr], #4
  ldr.w b12, [twiddle_ptr], #4
  vmov.w s2, a0
  vmov.w s3, a12
  vmov.w s4, b0
  vmov.w s5, b12
  nop
  nop
  nop
  nop
b3in:
  vmov.w s1, tmp1
.rept 6
  ldrsh a0, [poly, #0]
  ldrsh b0, [poly, #60]
  ldrsh t0, [poly, #120]
  ldrh a12, [poly, #180]
  ldrh b12, [poly, #240]
  ldrh  t1, [poly, #300]
  ldrh  t2, [poly, #360]
  pkhbt a12, a12, t2, LSL #16
  ldrh  t2, [poly, #420]
  pkhbt b12, b12, t2, LSL #16
  ldrh  t2, [poly, #480]
  pkhbt t1, t1, t2, LSL #16

  bfthreer a0, a12, w12, t2, tmp1, q, qinv
  bfthreer b0, b12, w12, t2, tmp1, q, qinv
  bfthreer t0,  t1, w12, t2, tmp1, q, qinv
  pkhbt b0, b0, t0, LSL #16
  vmov.w tmp, s2
  dblmred b, t, a12, tmp, t0, t2, q, qinv
  vmov.w tmp, s3
  dblmred b, t, b12, tmp, tmp1, tmp, q, qinv
  vmov.w b12, s4
  dblmred b, t,  t1, b12,  a12, b12, q, qinv
  pkhbt tmp1, tmp1, a12, LSL #16
  pkhbt tmp, tmp, b12, LSL #16
  bfthree a0, b0, w12, b12, a12, q, qinv
  bfthree t0, tmp1, w12, b12, a12, q, qinv
  bfthree t2, tmp, w12, b12, a12, q, qinv
  strh t0, [poly, #180]
  strh t2, [poly, #360]
  vmov.w b12, s5
  dblmred b, t, b0, b12, t0, a12, q, qinv
  dblmred b, t, tmp1, b12, t1, t2, q, qinv
  dblmred b, t, tmp, b12, tmp1, b12, q, qinv
  strh t0, [poly, #60]
  strh a12, [poly, #120]
  strh t1, [poly, #240]
  strh t2, [poly, #300]
  strh tmp1, [poly, #420]
  strh b12, [poly, #480]
  strh a0, [poly], #2
.endr
  add poly, poly, #528 
  vmov.w tmp1, s1
  subs.w tmp1, #1
  bne.w b3in
  sub poly, #3228
  vmov.w tmp, s0
  subs.w tmp, #1
  bne.w b3out

  sub poly, #60

// bffive
  mov tmp,  #54
  mov w12,  #1610
  movt w12, #63721
  mov w,    #63262
  movt w,   #63423
//
  nop
  nop
  nop
  nop
  nop
  nop
b5:

.rept 6
  load5 poly, a0, a12, t1, b12, t2, #0, #12, #24, #36, #48
  add t0, a0, a12
  add t0, t0, t1 
  add t0, t0, b12
  add t0, t0, t2
  //reduce t0, tmp1, q, qinv
  strh t0, [poly], #2

  pkhbt a12, a12, t1, LSL #16
  pkhbt b12, b12, t2, LSL #16

  bffive a0, a12, b12, w12, w, t0, t1, t2, tmp1, q, qinv
  
  strh t0, [poly, #10]
  strh t1, [poly, #22]
  strh t2, [poly, #34]
  strh tmp1, [poly, #46]
  
.endr
  add poly, poly, #48
  subs.w tmp, #1
  bne.w b5
  sub.w poly, #3240
  pop     {r4-r11, pc}


.global asm_invntt
.type asm_invntt,%function
.align 4
asm_invntt:
  push    {r4-r11, r14}

  poly        .req r0
  twiddle_ptr .req r1
  a0          .req r2
  a12         .req r3
  b0          .req r4
  b12         .req r5
  w12         .req r6
  w           .req r4
  t0          .req r7
  t1          .req r8
  t2          .req r9
  qinv        .req r10
  q           .req r11
  tmp         .req r12
  tmp1        .req r14
 
  //output
  vmov.w s7, poly
  // inputs
  mov poly, twiddle_ptr
  mov twiddle_ptr, a0
   
  mov q, #4591
  mov qinv, #18015
  movt qinv, #14

// bffive
  mov tmp,  #54
  mov w12,  #63423
  movt w12, #63262
  mov w,    #63721
  movt w,   #1610
//

  nop
  nop
invb5:
  vldm.w twiddle_ptr!, {s1,s2}
.rept 6
  load5 poly, a0, a12, t1, b12, t2, #0, #12, #24, #36, #48
  add tmp1, a0, a12
  add tmp1, tmp1, t1 
  add tmp1, tmp1, b12
  add tmp1, tmp1, t2
  
  pkhbt a12, a12, t1, LSL #16
  pkhbt b12, b12, t2, LSL #16
 
  //reduce tmp1, t1, q, qinv
  strh tmp1, [poly], #2


  bffive a0, a12, b12, w12, w, t0, t1, t2, tmp1, q, qinv
 
  vmov.w a12, s1
  smulbb t0, t0, a12
  reduce t0, b12, q, qinv
  smulbt t1, t1, a12
  reduce t1, b12, q, qinv
  vmov.w a12, s2
  smulbb t2, t2, a12
  reduce t2, b12, q, qinv
  smulbt tmp1, tmp1, a12
  reduce tmp1, b12, q, qinv
  
  strh t0, [poly, #10]
  strh t1, [poly, #22]
  strh t2, [poly, #34]
  strh tmp1, [poly, #46]
  
.endr
  add poly, #48
  subs.w tmp, #1
  bne.w invb5
  sub.w poly, #3240

// The third bfthree
  mov w12, #310 
  movt w12, #65225
  mov tmp, #6
invb3out:
  vmov.w s0, tmp
  mov tmp1, #5
  ldr.w a0, [twiddle_ptr], #4
  ldr.w a12, [twiddle_ptr], #4
  ldr.w b0, [twiddle_ptr], #4
  ldr.w b12, [twiddle_ptr], #4
  vmov.w s2, a0
  vmov.w s3, a12
  vmov.w s4, b0
  vmov.w s5, b12
  nop
  nop
  nop
  nop
invb3in:
  vmov.w s1, tmp1
.rept 6
  ldrsh a0, [poly, #0]
  ldrh  b0, [poly, #60]
  ldrh  t0, [poly, #120]
  pkhbt a12, b0, t0, LSL #16
  ldrsh b0, [poly, #180]
  ldrh  t0, [poly, #240]
  ldrh  t1, [poly, #300]
  pkhbt b12, t0, t1, LSL #16
  ldrsh t0, [poly, #360]
  ldrh  t1, [poly, #420]
  ldrh  t2, [poly, #480]
  pkhbt t1, t1, t2, LSL #16

  bfthreer a0, a12, w12, t2, tmp1, q, qinv
  bfthreer b0, b12, w12, t2, tmp1, q, qinv
  bfthreer t0,  t1, w12, t2, tmp1, q, qinv
  pkhbt b0, b0, t0, LSL #16
  vmov.w tmp, s2
  dblmred b, t, a12, tmp, t0, t2, q, qinv
  vmov.w tmp, s3
  dblmred b, t, b12, tmp, tmp1, tmp, q, qinv
  vmov.w b12, s4
  dblmred b, t,  t1, b12,  a12, b12, q, qinv
  pkhbt tmp1, tmp1, a12, LSL #16
  pkhbt tmp, tmp, b12, LSL #16
  bfthree a0, b0, w12, b12, a12, q, qinv
  bfthree t0, tmp1, w12, b12, a12, q, qinv
  bfthree t2, tmp, w12, b12, a12, q, qinv
  strh t0, [poly, #60]
  strh t2, [poly, #120]
  vmov.w b12, s5
  dblmred b, t, b0, b12, t0, a12, q, qinv
  dblmred b, t, tmp1, b12, t1, t2, q, qinv
  dblmred b, t, tmp, b12, tmp1, b12, q, qinv
  strh t0, [poly, #180]
  strh a12, [poly, #360]
  strh t1, [poly, #240]
  strh t2, [poly, #420]
  strh tmp1, [poly, #300]
  strh b12, [poly, #480]
  strh a0, [poly], #2
.endr
  vmov.w tmp1, s1
  subs.w tmp1, #1
  bne.w invb3in
  add poly, #480
  vmov.w tmp, s0
  subs.w tmp, #1
  bne.w invb3out

  sub poly, #3240

  nop
  nop
  nop
  nop

//
  ldr.w w, [twiddle_ptr]
  mov twiddle_ptr, #29
invlast:

.rept 6

  ldrsh a0, [poly]
  ldrh  a12, [poly, #540]
  ldrh  t1, [poly, #1080]
  ldrsh t0, [poly, #1620]
  ldrh  b12, [poly, #2160]
  ldrh  t2, [poly, #2700]
  pkhbt a12, a12, t1, LSL #16
  pkhbt b12, b12, t2, LSL #16 

  bfthreer a0, a12, w12, t1, t2, q, qinv
  bfthreer t0, b12, w12, t1, t2, q, qinv
  add a0, a0, t0
  sub t0, a0, t0, LSL #1


  dblmred b, t, b12, w, t1, t2, q, qinv 
  pkhbt b12, t1, t2, LSL #16
  ssub16 t1,  a12, b12
  sadd16 a12, a12, b12
  asr t2, t1, #16
  asr b12, a12, #16
  
  strh t2, [poly, #2700]
  strh t1, [poly, #2160]
  strh t0, [poly, #1620]
  strh b12, [poly, #1080]
  strh a12, [poly, #540]
  strh a0, [poly], #2

.endr
  
  subs.w twiddle_ptr, #1
  bne.w invlast
  // Inputs are degree-760 polynomials thus last part (from 1520 to 1620) always equal to zero
  mov tmp1, #16
  nop
  nop
  nop
  nop
invlastrmdr:

.rept 6

  ldrsh a0, [poly]
  ldrh  a12, [poly, #540]
  ldrh  t1, [poly, #1080]
  ldrsh t0, [poly, #1620]
  ldrh  b12, [poly, #2160]
  ldrh  t2, [poly, #2700]
  pkhbt a12, a12, t1, LSL #16
  pkhbt b12, b12, t2, LSL #16 

  bfthreer a0, a12, w12, t1, t2, q, qinv
  bfthreer t0, b12, w12, t1, t2, q, qinv
  add a0, a0, t0
  sub t0, a0, t0, LSL #1

  dblmred b, t, b12, w, t1, t2, q, qinv 
  pkhbt b12, t1, t2, LSL #16
  ssub16 t1,  a12, b12
  sadd16 a12, a12, b12
  asr b12, a12, #16
  
  strh t1, [poly, #2160]
  strh t0, [poly, #1620]
  strh b12, [poly, #1080]
  strh a12, [poly, #540]
  strh a0, [poly], #2

.endr
  
  subs.w tmp1, #1
  bne.w invlastrmdr

  nop
  sub poly, #540

  // polynomial reduction for X^p-X-1
  vmov.w w, s7
  mov tmp, #65519 
  mov twiddle_ptr, #379
  
  // f[0]=f[0]+f[761]
  ldrsh t0, [poly, #1522] // (f[761])
  ldrsh a0, [poly], #2 // f[0]
  add a0, t0
  smulbb a0, a0, tmp
  reduce a0, tmp1, q, qinv
  strh a0, [w], #2

redploop:
  ldr t0, [poly, #1520] // (f[762])(f[761])
  ldr t1, [poly, #1522] // (f[763])(f[762])
  ldr a0, [poly], #4  // (f[2])(f[1])

  sadd16 t0, t0, a0 // (f[2]+f[762])(f[1]+f[761])
  sadd16 a0, t1, t0 // (f[2]+f[762]+f[763])(f[1]+f[761]+f[762])
  dblmredpack b, b, a0, tmp, t0, t1, q, qinv

  str a0, [w], #4
  subs.w twiddle_ptr, #1
  bne redploop
  
  // f[759] and f[760]
  ldr t0, [poly, #1520] // (f[1520])(f[1519])
  ldrh t1, [poly, #1522] // (0)(f[1520])
  ldr a0, [poly], #4  // (f[760])(f[759])

  sadd16 t0, t0, a0 // (f[760]+f[1520])(f[759]+f[1519])
  sadd16 a0, t1, t0 // (f[760]+f[1520])(f[759]+f[1519]+f[1520])
  dblmredpack b, b, a0, tmp, t0, t1, q, qinv

  str a0, [w], #4

  pop     {r4-r11, pc}

.global asm_basemul
.type asm_basemul,%function
.align 2
asm_basemul:
  push    {r4-r11, r14}

  poly0        .req r0
  poly1        .req r1
  twiddle      .req r2
  t            .req r3
  a01          .req r4
  a23          .req r5
  a45          .req r6
  b01          .req r7
  b23          .req r8
  b45          .req r9
  qinv         .req r10
  q            .req r11
  tmp          .req r12
  tmp1         .req r14
   
   vmov.w s0, tmp
   mov q, #4591
   mov qinv, #18015
   movt qinv, #14
   
   mov tmp, #270
   nop
   nop
basemulloop:
   ldrsh t, [twiddle], #2
   vmov.w s0, tmp
   
   ldm.w poly0, {a01, a23, a45} // load polynomial a
   ldm.w poly1!, {b01, b23, b45} // load polynomial b
   
   smuadx tmp1, a23, b45
   smladx tmp1, a45, b23, tmp1
   reduce tmp1, tmp, q, qinv
   smulbb tmp1, tmp1, t
   smladx tmp1, a01, b01, tmp1
   reduce tmp1, tmp, q, qinv
   strh tmp1, [poly0, #2]
   
   smuadx tmp1, a45, b45
   reduce tmp1, tmp, q, qinv
   smulbb tmp1, tmp1, t
   smladx tmp1, a01, b23, tmp1
   smladx tmp1, a23, b01, tmp1
   reduce tmp1, tmp, q, qinv
   strh tmp1, [poly0, #6]

   smuadx tmp1, a23, b23
   smladx tmp1, a01, b45, tmp1
   smladx tmp1, a45, b01, tmp1
   reduce tmp1, tmp, q, qinv
   strh tmp1, [poly0, #10]

   smultb tmp1, b45, t
   reduce tmp1, tmp, q, qinv
   pkhbt b45, b45, b23, LSL #0
   pkhbt b23, b23, b01, LSL #0
   pkhbt b01, b01, tmp1, LSL #16


   smuad tmp1, a45, b45
   reduce tmp1, tmp, q, qinv
   smulbb tmp1, tmp1, t
   smlad tmp1, a01, b23, tmp1
   smlad tmp1, a23, b01, tmp1
   reduce tmp1, tmp, q, qinv
   strh tmp1, [poly0, #4]

   smuad tmp1, a23, b23
   smlad tmp1, a01, b45, tmp1
   smlad tmp1, a45, b01, tmp1
   reduce tmp1, tmp, q, qinv
   strh tmp1, [poly0, #8]

   smuad tmp1, a23, b45
   smlad tmp1, a45, b23, tmp1
   reduce tmp1, tmp, q, qinv
   smulbb tmp1, tmp1, t
   smlad tmp1, a01, b01, tmp1
   reduce tmp1, tmp, q, qinv
   strh tmp1, [poly0], #12
   vmov.w tmp, s0
   subs.w tmp, #1
   bne.w basemulloop

   pop     {r4-r11, pc}

