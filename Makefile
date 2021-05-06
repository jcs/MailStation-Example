#
# MailStation example program
# Copyright (c) 2019-2021 joshua stein <jcs@jcs.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

# the name of your program
PROG=		hello

# your c source files
SRCS=		main.c

# your asm source files
ASM_SRCS=

# default to build running from ram
LOC?=		ram


ASZ80?=		sdasz80 -l -ff
SDCC?=		sdcc -mz80 --opt-code-size

SRCDIR?=	${.CURDIR}

OBJ?=		${SRCDIR}/obj

.if ${LOC:L} == "flash"
BASE_ADDR=	0x4000
DEFS+=		-DLOC_FLASH
.elif ${LOC:L} == "ram"
BASE_ADDR=	0x8000
DEFS+=		-DLOC_RAM
.else
.BEGIN:
	@echo 'LOC must be "flash" or "ram"'
	@exit 1
.endif

all: checkobj $(PROG).bin

obj: .PHONY
	mkdir $(OBJ)

# it would be nice to just make this ourselves but if it doesn't exist before
# make is invoked, it screws things up
checkobj: .PHONY
	@if [ ! -d $(OBJ) ]; then \
		echo "\"${MAKE} obj\" first"; \
		exit 1; \
	fi

clean:
	rm -rf $(OBJ)/*

# assembly

ADDRS_INC=	${SRCDIR}/lib/addrs-${LOC}.inc

crt0.rel: lib/crt0.s
	$(ASZ80) -o ${.TARGET} ${ADDRS_INC} $>

getchar.rel: lib/getchar.s
	$(ASZ80) -o ${.TARGET} ${ADDRS_INC} $>

putchar.rel: lib/putchar.s lib/font/spleen-5x8.inc
	$(ASZ80) -o ${.TARGET} ${ADDRS_INC} $(SRCDIR)/lib/putchar.s

wifi.rel: lib/wifi.s
	$(ASZ80) -o ${.TARGET} ${ADDRS_INC} $>

# generated code

$(SRCDIR)/lib/font/spleen-5x8.inc: $(SRCDIR)/lib/font/spleen-5x8.hex
	ruby $(SRCDIR)/lib/tools/hexfont2inc.rb $> > ${.TARGET}

# all relocation files for final ihx
REL_FILES=	crt0.rel putchar.rel getchar.rel wifi.rel

.for S in $(SRCS)
REL_FILES+=	${S:R}.rel
${S:R}.rel: $(S)
	$(SDCC) $(DEFS) -c ${.TARGET} $(SRCDIR)/$(S)
.endfor

.for S in $(ASM_SRCS)
REL_FILES+=	${S:R}.rel
${S:R}.rel: $(S)
	$(ASZ80) $(DEFS) -o ${.TARGET} ${ADDRS_INC} $>
.endfor

# link

$(PROG).ihx: $(REL_FILES)
	@SDCC="$(SDCC) --no-std-crt0" TARGET="$(.TARGET)" \
		BASE_ADDR="$(BASE_ADDR)" CODE_OFF="$(CODE_OFF)" \
		PROG_MAP="$(PROG).map" \
		ruby $(SRCDIR)/lib/tools/relink_packed.rb $>

# convert to binary

$(PROG).bin: $(PROG).ihx
	objcopy -Iihex -Obinary $> $@
	@if [ `stat -f '%z' ${.TARGET}` -gt 16384 ]; then \
		ls -l ${.TARGET}; \
		echo "${.TARGET} overflows a ${LOC} page, must be <= 16384; increase DATA_SIZE"; \
		exit 1; \
	fi

# helpers

disasm: $(PROG).bin
	z80dasm -al -g ${BASE_ADDR} $> > $(PROG).dasm
