ASM=nasm
ASMFLAGS=-f bin

BUILD_DIR=build
BOOTLOADER=$(BUILD_DIR)/boot.bin

all: $(BOOTLOADER)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOTLOADER): src/boot.asm | $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) $< -o $@

run: $(BOOTLOADER)
	qemu-system-i386 -drive format=raw,file=$(BOOTLOADER)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all run clean
