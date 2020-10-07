.macro montgomery_mul a, b, lower, upper, tmp, Mprime, M
    smull.w \lower, \upper, \a, \b
    mul.w \tmp, \lower, \Mprime
    smlal.w \lower, \upper, \tmp, \M
.endm

.macro central_reduce target, Mhalf, M
    cmp \target, \Mhalf
    it gt
    subgt \target, \M
    cmn \target, \Mhalf
    it lt
    addlt \target, \M
.endm

.macro barrett a, O_Mbar, O_M, tmp
    smmulr.w \tmp, \a, \O_Mbar
    mls.w \a, \tmp, \O_M, \a
.endm

// ================================================================

.syntax unified
.cpu cortex-m4

table:
    .word 6984193

.align 2
.global __asm_final_map_and_pack
.type __asm_final_map_and_pack, %function
__asm_final_map_and_pack:
    vldm.w sp, {s11-s15}
    push.w {r4-r12, lr}
    vmov.w r11, r12, s11, s12
    adr.w r10, table
    vldr.w s10, [r10]

    add.w r2, #8

    ldr.w r5, [r3, #2052]
    ldr.w r7, [r2, #988]
    ldr.w r8, [r3, #1000]
    ldr.w r4, [r3], #24

    add.w r4, r7
    add r5, r7
    add r5, r8

    vmov.w r6, r7, s14, s15

    montgomery_mul r4, r1, r10, r4, r14, r6, r7
    montgomery_mul r5, r1, r10, r5, r14, r6, r7

    vmov.w r14, s13
    vmov.w r10, s10

    central_reduce r4, r14, r10
    central_reduce r5, r14, r10

    barrett r4, r12, r11, r14
    barrett r5, r12, r11, r14

    pkhbt r4, r4, r5, lsl #16

    ldr.w r5, [r2], #24
    ldr.w r6, [r3, #-12]
    ldr.w r7, [r3, #3028]
    ldr.w r9, [r2, #976]

    add r5, r8
    add r5, r7
    add r6, r7
    add r6, r9

    vmov.w r7, r8, s14, s15

    montgomery_mul r5, r1, r12, r5, r14, r7, r8
    montgomery_mul r6, r1, r12, r6, r14, r7, r8

    vmov.w r14, s13
    vmov.w r12, s10

    central_reduce r5, r14, r12
    central_reduce r6, r14, r12

    vmov.w r12, s12

    barrett r5, r12, r11, r14
    barrett r6, r12, r11, r14

    pkhbt r5, r5, r6, lsl #16

    ldr.w r6, [r3, #2040]
    ldr.w r7, [r2, #-12]
    ldr.w r8, [r3, #988]
    ldr.w r10, [r3, #3040]

    add r6, r9
    add r6, r8
    add r7, r8
    add r7, r10

    vmov.w r8, r9, s14, s15

    montgomery_mul r6, r1, r12, r6, r14, r8, r9
    montgomery_mul r7, r1, r12, r7, r14, r8, r9

    vmov.w r14, s13
    vmov.w r12, s10

    central_reduce r6, r14, r12
    central_reduce r7, r14, r12

    vmov.w r11, r12, s11, s12

    barrett r6, r12, r11, r14
    barrett r7, r12, r11, r14

    pkhbt r6, r6, r7, lsl #16

    stm.w r0!, {r4-r6}

    add.w r4, r0, #504
    vmov.w s0, r4

    bl.w __asm_map_and_pack_loop1_round

    sub.w r3, #1024
    sub.w r2, #1036

    ldr.w r4, [r3, #1024]
    ldr.w r5, [r3, #3076]
    ldr.w r7, [r2, #2024]
    ldr.w r8, [r3, #2024]

    add r4, r10
    add r4, r7
    add r5, r7
    add r5, r8

    vmov.w r6, r7, s14, s15

    montgomery_mul r4, r1, r10, r4, r14, r6, r7
    montgomery_mul r5, r1, r10, r5, r14, r6, r7

    vmov.w r14, s13
    vmov.w r10, s10

    central_reduce r4, r14, r10
    central_reduce r5, r14, r10

    barrett r4, r12, r11, r14
    barrett r5, r12, r11, r14

    pkhbt r4, r4, r5, lsl #16

    ldr.w r5, [r2, #1036]
    ldr.w r6, [r3, #1036]
    ldr.w r7, [r3, #4076]
    ldr.w r9, [r2, #2036]

    add r5, r8
    add r5, r7
    add r6, r7
    add r6, r9

    vmov.w r7, r8, s14, s15

    montgomery_mul r5, r1, r12, r5, r14, r7, r8
    montgomery_mul r6, r1, r12, r6, r14, r7, r8

    vmov.w r14, s13
    vmov.w r12, s10

    central_reduce r5, r14, r12
    central_reduce r6, r14, r12

    vmov.w r12, s12

    barrett r5, r12, r11, r14
    barrett r6, r12, r11, r14

    pkhbt r5, r5, r6, lsl #16

    ldr.w r6, [r3, #3088]
    ldr.w r7, [r2, #1048]
    ldr.w r8, [r3, #2036]
    ldr.w r10, [r3, #2040]

    add r6, r9
    add r6, r8
    add r7, r8
    add r7, r10

    vmov.w r8, r9, s14, s15

    montgomery_mul r6, r1, r12, r6, r14, r8, r9
    montgomery_mul r7, r1, r12, r7, r14, r8, r9

    vmov.w r14, s13
    vmov.w r12, s10

    central_reduce r6, r14, r12
    central_reduce r7, r14, r12

    vmov.w r11, r12, s11, s12

    barrett r6, r12, r11, r14
    barrett r7, r12, r11, r14

    pkhbt r6, r6, r7, lsl #16

    stm.w r0!, {r4-r6}

// ================================

    add.w r4, r0, #492
    vmov.w s0, r4

    bl.w __asm_map_and_pack_loop2_round

    sub.w r3, #976
    sub.w r2, #976

    ldr.w r4, [r3, #2024]
    ldr.w r5, [r3, #4076]
    ldr.w r7, [r2, #976]
    ldr.w r8, [r3, #976]

    add r4, r10
    add r4, r7
    add r5, r7
    add r5, r8

    vmov.w r6, r7, s14, s15

    montgomery_mul r4, r1, r10, r4, r14, r6, r7
    montgomery_mul r5, r1, r10, r5, r14, r6, r7

    vmov.w r14, s13
    vmov.w r10, s10

    central_reduce r4, r14, r10
    central_reduce r5, r14, r10

    barrett r4, r12, r11, r14
    barrett r5, r12, r11, r14

    pkhbt r4, r4, r5, lsl #16

    ldr.w r5, [r2, #-12]
    ldr.w r6, [r3, #-12]
    ldr.w r7, [r3, #3028]
    ldr.w r9, [r2, #988]

    add r5, r8
    add r5, r7
    add r6, r7
    add r6, r9

    vmov.w r7, r8, s14, s15

    montgomery_mul r5, r1, r12, r5, r14, r7, r8
    montgomery_mul r6, r1, r12, r6, r14, r7, r8

    vmov.w r14, s13
    vmov.w r12, s10

    central_reduce r5, r14, r12
    central_reduce r6, r14, r12

    vmov.w r12, s12

    barrett r5, r12, r11, r14
    barrett r6, r12, r11, r14

    pkhbt r5, r5, r6, lsl #16

    ldr.w r6, [r3, #2040]
    ldr.w r7, [r2], #12
    ldr.w r8, [r3, #988]
    ldr.w r10, [r3, #3040]

    add r6, r9
    add r6, r8
    add r7, r8
    add r7, r10

    vmov.w r8, r9, s14, s15

    montgomery_mul r6, r1, r12, r6, r14, r8, r9
    montgomery_mul r7, r1, r12, r7, r14, r8, r9

    vmov.w r14, s13
    vmov.w r12, s10

    central_reduce r6, r14, r12
    central_reduce r7, r14, r12

    vmov.w r11, r12, s11, s12

    barrett r6, r12, r11, r14
    barrett r7, r12, r11, r14

    pkhbt r6, r6, r7, lsl #16

    stm.w r0!, {r4-r6}

// ================================

    add.w r4, r0, #480
    vmov.w s0, r4

    bl.w __asm_map_and_pack_loop1_round

    ldr.w r4, [r3]
    ldr.w r5, [r3, #2052]
    ldr.w r7, [r2, #988]
    ldr.w r8, [r3, #1000]

    add r4, r10
    add r4, r7
    add r5, r7
    add r5, r8

    vmov.w r6, r7, s14, s15

    montgomery_mul r4, r1, r10, r4, r14, r6, r7
    montgomery_mul r5, r1, r10, r5, r14, r6, r7

    vmov.w r14, s13
    vmov.w r10, s10

    central_reduce r4, r14, r10
    central_reduce r5, r14, r10

    barrett r4, r12, r11, r14
    barrett r5, r12, r11, r14

    pkhbt r4, r4, r5, lsl #16

    ldr.w r5, [r2]
    ldr.w r6, [r3, #12]
    ldr.w r7, [r3, #3052]
    ldr.w r9, [r2, #1000]

    add r5, r8
    add r5, r7
    add r6, r7
    add r6, r9

    vmov.w r7, r8, s14, s15

    montgomery_mul r5, r1, r12, r5, r14, r7, r8
    montgomery_mul r6, r1, r12, r6, r14, r7, r8

    vmov.w r14, s13
    vmov.w r12, s10

    central_reduce r5, r14, r12
    central_reduce r6, r14, r12

    vmov.w r12, s12

    barrett r5, r12, r11, r14
    barrett r6, r12, r11, r14

    pkhbt r5, r5, r6, lsl #16

    ldr.w r6, [r3, #2064]

    add.w r6, r9

    vmov.w r8, r9, s14, s15

    montgomery_mul r6, r1, r10, r6, r14, r8, r9

    vmov.w r14, s13
    vmov.w r10, s10

    central_reduce r6, r14, r10

    barrett r6, r12, r11, r14

    stm.w r0, {r4-r5}
    strh.w r6, [r0, #8]

// ================================

    pop.w {r4-r12, pc}

// ================================================================

.align 4
padba:
    nop.w

.align 2
__asm_map_and_pack_loop1_round:
    vmov.w s10, r14

    map_and_pack_loop1:

    ldr.w r5, [r3, #2052]
    ldr.w r7, [r2, #988]
    ldr.w r8, [r3, #1000]
    ldr.w r4, [r3], #24

    add r4, r10
    add r4, r7
    add r5, r7
    add r5, r8

    vmov.w r6, r7, s14, s15

    montgomery_mul r4, r1, r10, r4, r14, r6, r7
    montgomery_mul r5, r1, r10, r5, r14, r6, r7

    vmov.w r14, s13
    vmov.w r10, s10

    central_reduce r4, r14, r10
    central_reduce r5, r14, r10

    barrett r4, r12, r11, r14
    barrett r5, r12, r11, r14

    pkhbt r4, r4, r5, lsl #16

    ldr.w r5, [r2], #24
    ldr.w r6, [r3, #-12]
    ldr.w r7, [r3, #3028]
    ldr.w r9, [r2, #976]

    add r5, r8
    add r5, r7
    add r6, r7
    add r6, r9

    vmov.w r7, r8, s14, s15

    montgomery_mul r5, r1, r12, r5, r14, r7, r8
    montgomery_mul r6, r1, r12, r6, r14, r7, r8

    vmov.w r14, s13
    vmov.w r12, s10

    central_reduce r5, r14, r12
    central_reduce r6, r14, r12

    vmov.w r12, s12

    barrett r5, r12, r11, r14
    barrett r6, r12, r11, r14

    pkhbt r5, r5, r6, lsl #16

    ldr.w r6, [r3, #2040]
    ldr.w r7, [r2, #-12]
    ldr.w r8, [r3, #988]
    ldr.w r10, [r3, #3040]

    add r6, r9
    add r6, r8
    add r7, r8
    add r7, r10

    vmov.w r8, r9, s14, s15

    montgomery_mul r6, r1, r12, r6, r14, r8, r9
    montgomery_mul r7, r1, r12, r7, r14, r8, r9

    vmov.w r14, s13
    vmov.w r12, s10

    central_reduce r6, r14, r12
    central_reduce r7, r14, r12

    vmov.w r11, r12, s11, s12

    barrett r6, r12, r11, r14
    barrett r7, r12, r11, r14

    pkhbt r6, r6, r7, lsl #16

    str.w r6, [r0, #8]
    str.w r5, [r0, #4]
    str.w r4, [r0], #12

// ================================

    vmov.w r4, s0
    cmp.w r4, r0
    bne.w map_and_pack_loop1

    vmov.w r14, s10
    bx lr

// ================================================================

.align 4
padbb:
    nop.w

.align 2
__asm_map_and_pack_loop2_round:
    vmov.w s10, r14

    map_and_pack_loop2:

    ldr.w r4, [r3, #1048]
    ldr.w r5, [r3, #3100]
    ldr.w r7, [r2], #24
    ldr.w r8, [r3], #24

    add r4, r10
    add r4, r7
    add r5, r7
    add r5, r8

    vmov.w r6, r7, s14, s15

    montgomery_mul r4, r1, r10, r4, r14, r6, r7
    montgomery_mul r5, r1, r10, r5, r14, r6, r7

    vmov.w r14, s13
    vmov.w r10, s10

    central_reduce r4, r14, r10
    central_reduce r5, r14, r10

    barrett r4, r12, r11, r14
    barrett r5, r12, r11, r14

    pkhbt r4, r4, r5, lsl #16

    ldr.w r5, [r2, #1036]
    ldr.w r6, [r3, #1036]
    ldr.w r7, [r3, #2028]
    ldr.w r9, [r2, #-12]

    add r5, r8
    add r5, r7
    add r6, r7
    add r6, r9

    vmov.w r7, r8, s14, s15

    montgomery_mul r5, r1, r12, r5, r14, r7, r8
    montgomery_mul r6, r1, r12, r6, r14, r7, r8

    vmov.w r14, s13
    vmov.w r12, s10

    central_reduce r5, r14, r12
    central_reduce r6, r14, r12

    vmov.w r12, s12

    barrett r5, r12, r11, r14
    barrett r6, r12, r11, r14

    pkhbt r5, r5, r6, lsl #16

    ldr.w r6, [r3, #3088]
    ldr.w r7, [r2, #1048]
    ldr.w r8, [r3, #-12]
    ldr.w r10, [r3, #2040]

    add r6, r9
    add r6, r8
    add r7, r8
    add r7, r10

    vmov.w r8, r9, s14, s15

    montgomery_mul r6, r1, r12, r6, r14, r8, r9
    montgomery_mul r7, r1, r12, r7, r14, r8, r9

    vmov.w r14, s13
    vmov.w r12, s10

    central_reduce r6, r14, r12
    central_reduce r7, r14, r12

    vmov.w r11, r12, s11, s12

    barrett r6, r12, r11, r14
    barrett r7, r12, r11, r14

    pkhbt r6, r6, r7, lsl #16

    str.w r6, [r0, #8]
    str.w r5, [r0, #4]
    str.w r4, [r0], #12

// ================================

    vmov.w r4, s0
    cmp.w r4, r0
    bne.w map_and_pack_loop2

    vmov.w r14, s10
    bx lr