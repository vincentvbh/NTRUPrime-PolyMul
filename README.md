## Polynomial Multiplication in NTRU Prime
### Comparison of Optimization Strategies on Cortex-M4

This repository contains ARM Cortex-M4 implementation of three polynomial multiplication for NTRU Prime, an alternate candidate for NIST post-quantum standardization project.

To perform polynomial multiplication in Z_{4591}/(X^{761}-X-1), the implementation uses of following ring operations:
- Polynomial multiplication in Z_{6984193}/(X^{1536}-1) (\_\_asm\_my\_mul.S final\_map\_and\_pack.S NTT.S NTT\_inv.S)
- Polynomial multiplication in Z_{4591}/(X^{1530}-1) (fft9.S ifft9.S byteToShort.S ntt17\_rader.S intt17\_rader\_mr.S polymul\_10x10\_153\_mr.S mod\_reduce.S)
- Polynomial multiplication in Z_{4591}/(X^{1620}-1) (nttasm.S)

Those polynomial multiplication implementations can be chosen at compile time with preprocessing macros GOODS, MIXED1, and MIXED, respectively. 

## Setup
The implementation targets STM32F4 Discovery board, and it uses following tools:
- arm-none-eabi toolchain for compiling the code (version 9.2.1 used for development).
- STLINK to flash binaries to the board (version v1.5.1 used for development).
- libopencm3 for main library functions.
- A shell script provided in test/monitor.sh to read output of tests and benchmarks.
- Alternatively read_guest.py from PQM4 can be used to read output of tests and benchmarks. This script requires Python >= 3.6, and pyserial. 

For convinience libopencm3 is compiled and relevant header files and the shared object placed in lib directory.

To compile the codes, simply run make command in main directory. This command will generate all binaries for testing the software as well as benchmarking different implementations.

Benchmarking binaries:
- ntrulpr761\_gs\_speed.bin: GOODS macro activated NTRU Prime scheme
- sntrup761\_gs\_speed.bin: GOODS macro activated Streamlined NTRU Prime scheme
- ntrulpr761\_mr1\_speed.bin: MIXED1 macro activated NTRU Prime scheme
- sntrup761\_mr1\_speed.bin: MIXED1 macro activated Streamlined NTRU Prime scheme
- ntrulpr761\_mr\_speed.bin: MIXED macro activated NTRU Prime scheme
- sntrup761\_mr\_speed.bin: MIXED macro activated Streamlined NTRU Prime scheme

Stack usage measurements:
- ntrulpr761\_gs\_stack.bin: GOODS macro activated NTRU Prime scheme
- sntrup761\_gs\_stack.bin: GOODS macro activated Streamlined NTRU Prime scheme
- ntrulpr761\_mr1\_stack.bin: MIXED1 macro activated NTRU Prime scheme
- sntrup761\_mr1\_stack.bin: MIXED1 macro activated Streamlined NTRU Prime scheme
- ntrulpr761\_mr\_stack.bin: MIXED macro activated NTRU Prime scheme
- sntrup761\_mr\_stack.bin: MIXED macro activated Streamlined NTRU Prime scheme

Testing binaries:
- ntrulpr761\_gs\_test.bin: GOODS macro activated NTRU Prime scheme
- sntrup761\_gs\_test.bin: GOODS macro activated Streamlined NTRU Prime scheme
- ntrulpr761\_mr1\_test.bin: MIXED1 macro activated NTRU Prime scheme
- sntrup761\_mr1\_test.bin: MIXED1 macro activated Streamlined NTRU Prime scheme
- ntrulpr761\_mr\_test.bin: MIXED macro activated NTRU Prime scheme
- sntrup761\_mr\_test.bin: MIXED macro activated Streamlined NTRU Prime scheme

To load the binaries to the board and read the output, one can simply run make runXXX, where XXX can be Speed, Stack, Test or All for running all three of them. After running any .bin file the output also recorded in .bin.log files in obj directory. A shell script called benchmark.sh provided to generate table 5 and table 6 in our paper in commandline interface.

## Implementation details

To use parts of the codes we provide brief description of the files in here
- ./src/common is taken from PQM4 library which includes
  - AES implementation
  - fips202 implementation of SHA3
  - randombytes implementation to generate arbitrary lenght random byte arrays
  - hal-stm32f4.c which includes several wrapper functions for stm32 discovery boards.
- ./src/intsort directory includes djbsort implementation integer arrays, more details about the algorithm can be found in [here](https://sorting.cr.yp.to/).
- ./src/polyinv directory includes GCD based polynomial inversion implementation from the [paper](https://doi.org/10.13154/tches.v2019.i3.340-398) by Daniel J. Bernstein and Bo-Yin Yang.
- Decode\_asm.S, Decode.c, Encode\_asm.S, and Encode.c are implementations of encoding and decoding functions for polynomials.
- kem.c includes all high level functions for implementing NTRU LPRime and Streamlined NTRU Prime key encapsulation.
- Rq_fromR3.S, Rq_mov.S, copy_p_F3_mod3.S, Short_fromlist_asm_ntrulpr761.S, and Short_fromlist_asm_sntrup761.S are implementations of functions needed for transforming polynomials 
- Rq_mult3_asm.S, Rq_modp.S includes multiplication of polynomials with 3 and polynomial reduction modulo X^{761}-X-1
- Weightw_mask_asm.S is the implementations of a function to check the weight of input polynomial.
- sha512_constants.c, sha512_hash.c, sha512_inner32.s files are implementation of SHA512 which is used in the original scheme.
- Rqmul_1530_byteToShort.S, Rqmul_1530_radix17_rader.S, Rqmul_1530_mod_reduce.S, Rqmul_1530_radix3x2_inv.S, Rqmul_1530_basemul.S, Rqmul_1530_radix17_rader_inv.S, Rqmul_1530_radix3x2.S, includes functions that are required to implement polynomial multiplication in Z_q/(X^{761}-X-1) with using NTT based polynomial multiplication in Z_q/(X^{1530}-1).
- Rqmul_gs_basemul.S, Rqmul_gs_ntt.S, Rqmul_gs_map.S, Rqmul_gs_invntt.S includes functions that are required to implement polynomial multiplication in Z_q/(X^{761}-X-1) with using NTT based polynomial multiplication in Z_q'/(X^{1536}-1).  
- Rqmul_mixedradix_1620.S includes functions that are required to implement polynomial multiplication in Z_q/(X^{761}-X-1) with using NTT based polynomial multiplication in Z_q/(X^{1620}-1).
-- Rq_mult.c includes high level functions to use above polynomial multiplications in kem.c.   


## Authors
* Erdem Alkim, Ondokuz Mayıs University (Samsun, Turkey) and Fraunhofer SIT (Darmstadt, Germany), 
* Dean Yun-Li Cheng, Academia Sinica and National Taiwan University (both Taipei, Taiwan) 
* Chi-Ming Marvin Chung, Academia Sinica 
* Hülya Evkan, Fraunhofer SIT
* Leo Wei-Lun Huang, Academia Sinica 
* Vincent Hwang, Academia Sinica and National Taiwan University
* Ching-Lin Trista Li, Academia Sinica and National Taiwan University
* Ruben Niederhagen, University of Southern Denmark (Odense, Denmark) 
* Cheng-Jhih Shih, Academia Sinica 
* Julian Wälde, Fraunhofer SIT
* Bo-Yin Yang, Academia Sinica
