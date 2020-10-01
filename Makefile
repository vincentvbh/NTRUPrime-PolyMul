OPENCM3DIR  = ./libopencm3
OPENCM3NAME = opencm3_stm32f4
OPENCM3FILE = lib/lib$(OPENCM3NAME).a
LDSCRIPT    = ldscripts/stm32f405x6.ld

PREFIX     ?= arm-none-eabi
CC          = $(PREFIX)-gcc
LD          = $(PREFIX)-gcc
OBJCOPY     = $(PREFIX)-objcopy
SIZE        = $(PREFIX)-size
MKDIR       = mkdir -p

ARCH_FLAGS  = -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 
#-flto 
DEFINES     = -DSTM32F4 -DSIZE761
SNTRUP      = -DSNTRUP
LPR         = -DLPR

EXTRA_FLAGS ?=

CFLAGS     = -O3 \
              -Wall -Wextra -Wimplicit-function-declaration \
              -Wredundant-decls -Wmissing-prototypes -Wstrict-prototypes \
              -Wundef -Wshadow \
              -Iinclude \
              -fno-common $(ARCH_FLAGS) -MD $(DEFINES) $(EXTRA_FLAGS)

LDFLAGS    = --static -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group \
              -T$(LDSCRIPT) -nostartfiles -Wl,--gc-sections \
	      $(ARCH_FLAGS) -Llib -lm -l$(OPENCM3NAME)

COMMONPATH = common
BINPATH    = bin
ELFPATH    = elf
OBJPATH    = obj
IMPLEMENTATION_PATH=.

COMMONINCLUDES = -I$(COMMONPATH) -I$(IMPLEMENTATION_PATH)

COMMONSOURCES          = $(COMMONPATH)/randombytes.c $(COMMONPATH)/fips202.c $(COMMONPATH)/keccakf1600.S $(COMMONPATH)/hal-stm32f4.c $(COMMONPATH)/aes.c $(COMMONPATH)/aes.S
IMPLEMENTATION_HEADERS = $(IMPLEMENTATION_PATH)/*.h
INVERSION_SOURCES = jump128divsteps.c jump1521divsteps.c jump16divsteps.c jump256divsteps.c jump32divsteps.c jump4divsteps.S jump512divsteps.c jump64divsteps.c jump753divsteps.c jump768divsteps.c jump8divsteps.c polyinverse4591761.c 
INVERSION_SOURCES += jump128divsteps_mod3.c jump1521divsteps_mod3.c jump16divsteps_mod3.c jump256divsteps_mod3.c jump32divsteps_mod3.c jump512divsteps_mod3.c jump64divsteps_mod3.c jump753divsteps_mod3.c jump768divsteps_mod3.c jump8divsteps_mod3.S polyinverse761_mod3.c
SORTING_SOURCES = int32_sort.c uint32_sort.c
SOURCES = kem.c copy_p_F3_mod3.S Decode.c Decode_asm.S Encode.c Encode_asm.S Rq_mov.S Rq_mult3_asm.S Rq_redp.S Weightw_mask_asm.S sha512_constants.c sha512_hash.c sha512_inner32.s 
SNTRUP_SOURCES = Short_fromlist_asm_sntrup761.S
NTRULPR_SOURCES = Short_fromlist_asm_ntrulpr761.S
PMUL_SOURCES = polymul_128x128.S polymul_16x16_nr.S polymul_192x192.S polymul_256x256.S polymul_256x512.c polymul_32x32.S  polymul_48x48.S polymul_64x64.S polymul_768x768.S polymul_8x8_nr.S polymul_4x4_nr7.S
PMUL_SOURCES += polymul_128x128_mod3.S polymul_16x16_mod3.S polymul_256x256_mod3.S polymul_256x512_mod3.c polymul_32x32_mod3.S  polymul_64x64_mod3.S polymul_768x768_mod3.S polymul_8x8_mod3.S
MIXEDRAD_SOURCES = nttasm.S
MIXEDRAD1_SOURCES = fft9.S ifft9.S byteToShort.S ntt17_rader.S intt17_rader_mr.S polymul_10x10_153_mr.S mod_reduce.S
GOODS_SOURCES = __asm_my_mul.S final_map_and_pack.S NTT.S NTT_inv.S

.PHONY: clean all speed
all: test speed stack

speed: ntrulpr761_mr1_speed.bin sntrup761_mr1_speed.bin ntrulpr761_mr_speed.bin sntrup761_mr_speed.bin ntrulpr761_gs_speed.bin sntrup761_gs_speed.bin 

test: ntrulpr761_mr1_test.bin sntrup761_mr1_test.bin ntrulpr761_mr_test.bin sntrup761_mr_test.bin ntrulpr761_gs_test.bin sntrup761_gs_test.bin 

stack: ntrulpr761_mr1_stack.bin sntrup761_mr1_stack.bin ntrulpr761_mr_stack.bin sntrup761_mr_stack.bin ntrulpr761_gs_stack.bin sntrup761_gs_stack.bin 

ntrulpr761_mr_speed.bin: ntrulpr761_mr_speed.elf
	$(SIZE) ntrulpr761_mr_speed.elf
	$(OBJCOPY) -S -Obinary ntrulpr761_mr_speed.elf ntrulpr761_mr_speed.bin

ntrulpr761_mr_speed.elf: test/speed.c $(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED \
	test/speed.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

sntrup761_mr_speed.bin: sntrup761_mr_speed.elf
	$(SIZE) sntrup761_mr_speed.elf
	$(OBJCOPY) -S -Obinary sntrup761_mr_speed.elf sntrup761_mr_speed.bin

sntrup761_mr_speed.elf: test/speed.c $(COMMONSOURCES) $(SOURCES) $(INVERSION_SOURCES) $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED \
	test/speed.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(INVERSION_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

ntrulpr761_mr1_speed.bin: ntrulpr761_mr1_speed.elf
	$(SIZE) ntrulpr761_mr1_speed.elf
	$(OBJCOPY) -S -Obinary ntrulpr761_mr1_speed.elf ntrulpr761_mr1_speed.bin

ntrulpr761_mr1_speed.elf: test/speed.c $(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED1 \
	test/speed.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

sntrup761_mr1_speed.bin: sntrup761_mr1_speed.elf
	$(SIZE) sntrup761_mr1_speed.elf
	$(OBJCOPY) -S -Obinary sntrup761_mr1_speed.elf sntrup761_mr1_speed.bin

sntrup761_mr1_speed.elf: test/speed.c $(COMMONSOURCES) $(SOURCES) $(INVERSION_SOURCES) $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED1 \
	test/speed.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(INVERSION_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

ntrulpr761_gs_speed.bin: ntrulpr761_gs_speed.elf
	$(SIZE) ntrulpr761_gs_speed.elf
	$(OBJCOPY) -S -Obinary ntrulpr761_gs_speed.elf ntrulpr761_gs_speed.bin

ntrulpr761_gs_speed.elf: test/speed.c $(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DGOODS \
	test/speed.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

sntrup761_gs_speed.bin: sntrup761_gs_speed.elf
	$(SIZE) sntrup761_gs_speed.elf
	$(OBJCOPY) -S -Obinary sntrup761_gs_speed.elf sntrup761_gs_speed.bin

sntrup761_gs_speed.elf: test/speed.c $(COMMONSOURCES) $(SOURCES) $(INVERSION_SOURCES) $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DGOODS \
	test/speed.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(INVERSION_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

ntrulpr761_mr_stack.bin: ntrulpr761_mr_stack.elf
	$(SIZE) ntrulpr761_mr_stack.elf
	$(OBJCOPY) -S -Obinary ntrulpr761_mr_stack.elf ntrulpr761_mr_stack.bin

ntrulpr761_mr_stack.elf: test/stack.c $(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED \
	test/stack.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

sntrup761_mr_stack.bin: sntrup761_mr_stack.elf
	$(SIZE) sntrup761_mr_stack.elf
	$(OBJCOPY) -S -Obinary sntrup761_mr_stack.elf sntrup761_mr_stack.bin

sntrup761_mr_stack.elf: test/stack.c $(COMMONSOURCES) $(SOURCES) $(INVERSION_SOURCES) $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED \
	test/stack.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(INVERSION_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

ntrulpr761_mr1_stack.bin: ntrulpr761_mr1_stack.elf
	$(SIZE) ntrulpr761_mr1_stack.elf
	$(OBJCOPY) -S -Obinary ntrulpr761_mr1_stack.elf ntrulpr761_mr1_stack.bin

ntrulpr761_mr1_stack.elf: test/stack.c $(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED1 \
	test/stack.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

sntrup761_mr1_stack.bin: sntrup761_mr1_stack.elf
	$(SIZE) sntrup761_mr1_stack.elf
	$(OBJCOPY) -S -Obinary sntrup761_mr1_stack.elf sntrup761_mr1_stack.bin

sntrup761_mr1_stack.elf: test/stack.c $(COMMONSOURCES) $(SOURCES) $(INVERSION_SOURCES) $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED1 \
	test/stack.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(INVERSION_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)


ntrulpr761_gs_stack.bin: ntrulpr761_gs_stack.elf
	$(SIZE) ntrulpr761_gs_stack.elf
	$(OBJCOPY) -S -Obinary ntrulpr761_gs_stack.elf ntrulpr761_gs_stack.bin

ntrulpr761_gs_stack.elf: test/stack.c $(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DGOODS \
	test/stack.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

sntrup761_gs_stack.bin: sntrup761_gs_stack.elf
	$(SIZE) sntrup761_gs_stack.elf
	$(OBJCOPY) -S -Obinary sntrup761_gs_stack.elf sntrup761_gs_stack.bin

sntrup761_gs_stack.elf: test/stack.c $(COMMONSOURCES) $(SOURCES) $(INVERSION_SOURCES) $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DGOODS \
	test/stack.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(INVERSION_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

ntrulpr761_mr_test.bin: ntrulpr761_mr_test.elf
	$(SIZE) ntrulpr761_mr_test.elf
	$(OBJCOPY) -S -Obinary ntrulpr761_mr_test.elf ntrulpr761_mr_test.bin

ntrulpr761_mr_test.elf: test/test.c $(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED \
	test/test.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

sntrup761_mr_test.bin: sntrup761_mr_test.elf
	$(SIZE) sntrup761_mr_test.elf
	$(OBJCOPY) -S -Obinary sntrup761_mr_test.elf sntrup761_mr_test.bin

sntrup761_mr_test.elf: test/test.c $(COMMONSOURCES) $(SOURCES) $(INVERSION_SOURCES) $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED \
	test/test.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(INVERSION_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

ntrulpr761_mr1_test.bin: ntrulpr761_mr1_test.elf
	$(SIZE) ntrulpr761_mr1_test.elf
	$(OBJCOPY) -S -Obinary ntrulpr761_mr1_test.elf ntrulpr761_mr1_test.bin

ntrulpr761_mr1_test.elf: test/test.c $(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED1 \
	test/test.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

sntrup761_mr1_test.bin: sntrup761_mr1_test.elf
	$(SIZE) sntrup761_mr1_test.elf
	$(OBJCOPY) -S -Obinary sntrup761_mr1_test.elf sntrup761_mr1_test.bin

sntrup761_mr1_test.elf: test/test.c $(COMMONSOURCES) $(SOURCES) $(INVERSION_SOURCES) $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED1 \
	test/test.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(INVERSION_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD1_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

ntrulpr761_gs_test.bin: ntrulpr761_gs_test.elf
	$(SIZE) ntrulpr761_gs_test.elf
	$(OBJCOPY) -S -Obinary ntrulpr761_gs_test.elf ntrulpr761_gs_test.bin

ntrulpr761_gs_test.elf: test/test.c $(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DGOODS \
	test/test.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

sntrup761_gs_test.bin: sntrup761_gs_test.elf
	$(SIZE) sntrup761_gs_test.elf
	$(OBJCOPY) -S -Obinary sntrup761_gs_test.elf sntrup761_gs_test.bin

sntrup761_gs_test.elf: test/test.c $(COMMONSOURCES) $(SOURCES) $(INVERSION_SOURCES) $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(IMPLEMENTATION_HEADERS) $(OPENCM3FILE)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DGOODS \
	test/test.c \
	$(COMMONSOURCES) $(SOURCES) $(SORTING_SOURCES) $(INVERSION_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)


$(OBJPATH)/%.o: $(IMPLEMENTATION_PATH)/%.c $(IMPLEMENTATION_HEADERS)
	$(MKDIR) $(OBJPATH)
	$(CC) -o $@ -c $(CFLAGS) -I$(IMPLEMENTATION_PATH) $(COMMONINCLUDES) $<

$(OBJPATH)/%.o: $(IMPLEMENTATION_PATH)/%.S $(IMPLEMENTATION_HEADERS)
	$(MKDIR) $(OBJPATH)
	$(CC) -o $@ -c $(CFLAGS) -I$(IMPLEMENTATION_PATH) $(COMMONINCLUDES) $<


runAll:	runSpeed runStack runTest

runSpeed:
	python3 read_guest.py ntrulpr761_mr_speed.bin 
	python3 read_guest.py sntrup761_mr_speed.bin 
	python3 read_guest.py ntrulpr761_mr1_speed.bin 
	python3 read_guest.py sntrup761_mr1_speed.bin 
	python3 read_guest.py ntrulpr761_gs_speed.bin  
	python3 read_guest.py sntrup761_gs_speed.bin

runTest:
	python3 read_guest.py ntrulpr761_mr_test.bin 
	python3 read_guest.py sntrup761_mr_test.bin 
	python3 read_guest.py ntrulpr761_mr1_test.bin 
	python3 read_guest.py sntrup761_mr1_test.bin
	python3 read_guest.py ntrulpr761_gs_test.bin  
	python3 read_guest.py sntrup761_gs_test.bin

runStack:
	python3 read_guest.py ntrulpr761_mr_stack.bin 
	python3 read_guest.py sntrup761_mr_stack.bin 
	python3 read_guest.py ntrulpr761_mr1_stack.bin 
	python3 read_guest.py sntrup761_mr1_stack.bin
	python3 read_guest.py ntrulpr761_gs_stack.bin  
	python3 read_guest.py sntrup761_gs_stack.bin


clean:
	-rm -rf $(OBJPATH)
	-rm -rf *.d *.bin *.elf
