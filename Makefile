#================================#
# Project: Cool assembler        #
# File:    Makefile              #
# Author:  Incremnt              #
#================================#

ASM = fasm
RM = rm -rf

CASM_TARGET = bin/casm
CASM_SRC = src/casm.asm

$(CASM_TARGET): $(CASM_SRC)
	$(ASM) $< $@
	chmod +x $@

all: $(CASM_TARGET)

clean: $(RM) $(BFI_TARGET) $(EMB_TARGET)

.PHONY: all clean
