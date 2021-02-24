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

COMMONPATH = src/common
BINPATH    = bin
ELFPATH    = elf
OBJPATH    = obj
IMP_PATH   = src
INV_PATH   = polyinv
SORT_PATH  = intsort

COMMON_SOURCES  = $(wildcard $(COMMONPATH)/*)
INV_SOURCES = $(wildcard $(IMP_PATH)/$(INV_PATH)/*)
SORTING_SOURCES = $(addprefix $(IMP_PATH)/$(SORT_PATH)/,$(notdir int32_sort.c uint32_sort.c))
KEMSOURCES  =  copy_p_F3_mod3.S kem.c Decode.c Decode_asm.S Encode.c Encode_asm.S Rq_mov.S Weightw_mask_asm.S sha512_constants.c sha512_hash.c sha512_inner32.s
SOURCES = $(addprefix $(IMP_PATH)/,$(KEMSOURCES))
SNTRUP_SOURCES = $(IMP_PATH)/Short_fromlist_asm_sntrup761.S $(INV_SOURCES)
NTRULPR_SOURCES = $(IMP_PATH)/Short_fromlist_asm_ntrulpr761.S
PMUL_SOURCES =  $(addprefix $(IMP_PATH)/, Rq_mult3_asm.S Rq_redp.S)
MIXEDRAD_SOURCES = $(IMP_PATH)/Rq_mult.c $(wildcard $(IMP_PATH)/*1620*)
RADER_SOURCES = $(IMP_PATH)/Rq_mult.c $(wildcard $(IMP_PATH)/Rqmul_1530_*)
GOODS_SOURCES = $(IMP_PATH)/Rq_mult.c $(wildcard $(IMP_PATH)/Rqmul_gs_*)


.PHONY: clean all speed
all: test speed stack

speed: obj/ntrulpr761_rader_speed.bin obj/sntrup761_rader_speed.bin obj/ntrulpr761_mr_speed.bin obj/sntrup761_mr_speed.bin obj/ntrulpr761_gs_speed.bin obj/sntrup761_gs_speed.bin

test: obj/ntrulpr761_rader_test.bin obj/sntrup761_rader_test.bin obj/ntrulpr761_mr_test.bin obj/sntrup761_mr_test.bin obj/ntrulpr761_gs_test.bin obj/sntrup761_gs_test.bin

stack: obj/ntrulpr761_rader_stack.bin obj/sntrup761_rader_stack.bin obj/ntrulpr761_mr_stack.bin obj/sntrup761_mr_stack.bin obj/ntrulpr761_gs_stack.bin obj/sntrup761_gs_stack.bin

%.bin: %.elf
	$(SIZE) $<
	$(OBJCOPY) -S -Obinary $< $@

obj/ntrulpr761_mr_speed.elf: test/speed.c $(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED \
	test/speed.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/sntrup761_mr_speed.elf: test/speed.c $(COMMON_SOURCES) $(SOURCES)  $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED \
	test/speed.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES)  $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/ntrulpr761_rader_speed.elf: test/speed.c $(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED1 \
	test/speed.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/sntrup761_rader_speed.elf: test/speed.c $(COMMON_SOURCES) $(SOURCES)  $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED1 \
	test/speed.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES)  $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/ntrulpr761_gs_speed.elf: test/speed.c $(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DGOODS \
	test/speed.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/sntrup761_gs_speed.elf: test/speed.c $(COMMON_SOURCES) $(SOURCES)  $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DGOODS \
	test/speed.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES)  $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/ntrulpr761_mr_stack.elf: test/stack.c $(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED \
	test/stack.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/sntrup761_mr_stack.elf: test/stack.c $(COMMON_SOURCES) $(SOURCES)  $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED \
	test/stack.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES)  $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/ntrulpr761_rader_stack.elf: test/stack.c $(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED1 \
	test/stack.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/sntrup761_rader_stack.elf: test/stack.c $(COMMON_SOURCES) $(SOURCES)  $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED1 \
	test/stack.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES)  $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/ntrulpr761_gs_stack.elf: test/stack.c $(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DGOODS \
	test/stack.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/sntrup761_gs_stack.elf: test/stack.c $(COMMON_SOURCES) $(SOURCES)  $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DGOODS \
	test/stack.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES)  $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/ntrulpr761_mr_test.elf: test/test.c $(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED \
	test/test.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/sntrup761_mr_test.elf: test/test.c $(COMMON_SOURCES) $(SOURCES)  $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED \
	test/test.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES)  $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(MIXEDRAD_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/ntrulpr761_rader_test.elf: test/test.c $(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DMIXED1 \
	test/test.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/sntrup761_rader_test.elf: test/test.c $(COMMON_SOURCES) $(SOURCES)  $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DMIXED1 \
	test/test.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES)  $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(RADER_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/ntrulpr761_gs_test.elf: test/test.c $(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(LPR) -DGOODS \
	test/test.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES) $(NTRULPR_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)

obj/sntrup761_gs_test.elf: test/test.c $(COMMON_SOURCES) $(SOURCES)  $(SORTING_SOURCES) $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES)  $(OPENCM3FILE)
	@mkdir -p $(@D)
	$(CC) -o $@ $(CFLAGS) $(SNTRUP) -DGOODS \
	test/test.c \
	$(COMMON_SOURCES) $(SOURCES) $(SORTING_SOURCES)  $(SNTRUP_SOURCES) $(PMUL_SOURCES) $(GOODS_SOURCES) $(COMMONINCLUDES) $(LDFLAGS)


%.o: %.c
	$(MKDIR) $(OBJPATH)
	$(CC) -o $@ -c $(CFLAGS) $(COMMONINCLUDES) $<

%.o: %.S
	$(MKDIR) $(OBJPATH)
	$(CC) -o $@ -c $(CFLAGS) $(COMMONINCLUDES) $<


runAll:	runTest runSpeed runStack
	./benchmark.sh

runSpeed:
	./test/monitor.sh -b=obj/ntrulpr761_mr_speed.bin
	./test/monitor.sh -b=obj/sntrup761_mr_speed.bin
	./test/monitor.sh -b=obj/ntrulpr761_rader_speed.bin
	./test/monitor.sh -b=obj/sntrup761_rader_speed.bin
	./test/monitor.sh -b=obj/ntrulpr761_gs_speed.bin
	./test/monitor.sh -b=obj/sntrup761_gs_speed.bin

runTest:
	./test/monitor.sh -b=obj/ntrulpr761_mr_test.bin
	./test/monitor.sh -b=obj/sntrup761_mr_test.bin
	./test/monitor.sh -b=obj/ntrulpr761_rader_test.bin
	./test/monitor.sh -b=obj/sntrup761_rader_test.bin
	./test/monitor.sh -b=obj/ntrulpr761_gs_test.bin
	./test/monitor.sh -b=obj/sntrup761_gs_test.bin

runStack:
	./test/monitor.sh -b=obj/ntrulpr761_mr_stack.bin
	./test/monitor.sh -b=obj/sntrup761_mr_stack.bin
	./test/monitor.sh -b=obj/ntrulpr761_rader_stack.bin
	./test/monitor.sh -b=obj/sntrup761_rader_stack.bin
	./test/monitor.sh -b=obj/ntrulpr761_gs_stack.bin
	./test/monitor.sh -b=obj/sntrup761_gs_stack.bin


clean:
	-rm -rf $(OBJPATH)
