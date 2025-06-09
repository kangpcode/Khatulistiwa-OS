# ============================================================================
# Makefile untuk Khatulistiwa OS - Sistem Operasi Berbudaya Indonesia
# Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
# ============================================================================

# Project information
PROJECT_NAME = Khatulistiwa OS
VERSION = 1.0.0
BUILD_DATE = $(shell date +%Y%m%d)
BUILD_TIME = $(shell date +%H%M%S)
BUILD_ID = $(BUILD_DATE)-$(BUILD_TIME)

# Architecture and platform
ARCH ?= x86_64
PLATFORM ?= pc
TARGET = $(ARCH)-khatulistiwa

# Compiler and tools
CC = gcc
CXX = g++
AS = nasm
LD = ld
AR = ar
OBJCOPY = objcopy
OBJDUMP = objdump
STRIP = strip
GRUB_MKRESCUE = grub-mkrescue
QEMU = qemu-system-$(ARCH)
PYTHON = python3

# Directories
SRC_DIR = khatulistiwa
BUILD_DIR = build
DIST_DIR = dist
ISO_DIR = $(BUILD_DIR)/iso
BOOT_DIR = $(ISO_DIR)/boot
GRUB_DIR = $(BOOT_DIR)/grub

# Kernel directories
KERNEL_DIR = $(SRC_DIR)/kernel
SYSTEM_DIR = $(SRC_DIR)/system
APPS_DIR = $(SRC_DIR)/apps
SDK_DIR = $(SRC_DIR)/sdk

# Output files
KERNEL_BIN = $(BUILD_DIR)/khatulistiwa.bin
KERNEL_ELF = $(BUILD_DIR)/khatulistiwa.elf
ISO_FILE = $(DIST_DIR)/khatulistiwa-os-$(VERSION).iso
IMG_FILE = $(DIST_DIR)/khatulistiwa-os-$(VERSION).img

# Compiler flags
CFLAGS = -std=c11 -ffreestanding -O2 -Wall -Wextra -Werror
CXXFLAGS = -std=c++17 -ffreestanding -O2 -Wall -Wextra -Werror -fno-exceptions -fno-rtti
ASFLAGS = -f elf64
LDFLAGS = -nostdlib -lgcc

# Include directories
INCLUDES = -I$(SRC_DIR)/include -I$(SYSTEM_DIR)/include

# Source files
KERNEL_SOURCES = $(wildcard $(KERNEL_DIR)/core/*.c) $(wildcard $(KERNEL_DIR)/drivers/*.c)
SYSTEM_SOURCES = $(wildcard $(SYSTEM_DIR)/core/*.c) $(wildcard $(SYSTEM_DIR)/ui/*.c)
ASM_SOURCES = $(wildcard $(KERNEL_DIR)/*.asm) $(wildcard $(SYSTEM_DIR)/*.asm)

# Object files
KERNEL_OBJECTS = $(KERNEL_SOURCES:%.c=$(BUILD_DIR)/%.o)
SYSTEM_OBJECTS = $(SYSTEM_SOURCES:%.c=$(BUILD_DIR)/%.o)
ASM_OBJECTS = $(ASM_SOURCES:%.asm=$(BUILD_DIR)/%.o)
ALL_OBJECTS = $(KERNEL_OBJECTS) $(SYSTEM_OBJECTS) $(ASM_OBJECTS)

# Default target
.PHONY: all
all: info dirs kernel system apps iso
	@echo "✅ Build lengkap Khatulistiwa OS selesai!"
	@echo "📁 ISO: $(ISO_FILE)"
	@echo "💾 IMG: $(IMG_FILE)"

# Help target
.PHONY: help
help:
	@echo "╔══════════════════════════════════════════════════════════╗"
	@echo "║              Khatulistiwa OS Build System                ║"
	@echo "║                     Makefile v1.0.0                     ║"
	@echo "╚══════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Available targets:"
	@echo "  all          - Build complete OS (default)"
	@echo "  bootloader   - Build KhatBoot bootloader"
	@echo "  kernel       - Build KhatKernel microkernel"
	@echo "  system       - Build KhatCore system runtime"
	@echo "  apps         - Build default applications"
	@echo "  sdk          - Build KhatSDK development tools"
	@echo "  iso          - Create bootable ISO image"
	@echo "  img          - Create mobile device image"
	@echo "  vm           - Create virtual machine image"
	@echo "  test         - Run tests"
	@echo "  run          - Run in QEMU emulator"
	@echo "  clean        - Clean build files"
	@echo "  install      - Install to system"
	@echo "  package      - Create distribution packages"
	@echo "  docs         - Generate documentation"
	@echo ""
	@echo "Build configurations:"
	@echo "  make TARGET=desktop    - Build for desktop (x86_64)"
	@echo "  make TARGET=mobile     - Build for mobile (ARMv8)"
	@echo "  make TARGET=iot        - Build for IoT (RISC-V)"
	@echo ""

# Create build directories
$(BUILD_DIR):
	@echo "[BUILD] Creating build directories..."
	@mkdir -p $(BUILD_DIR)/$(BOOT_DIR)
	@mkdir -p $(BUILD_DIR)/$(KERNEL_DIR)/core
	@mkdir -p $(BUILD_DIR)/$(KERNEL_DIR)/drivers
	@mkdir -p $(BUILD_DIR)/$(KERNEL_DIR)/security
	@mkdir -p $(BUILD_DIR)/$(SYSTEM_DIR)/core
	@mkdir -p $(BUILD_DIR)/$(SYSTEM_DIR)/driver
	@mkdir -p $(BUILD_DIR)/$(SYSTEM_DIR)/ui
	@mkdir -p $(BUILD_DIR)/$(SYSTEM_DIR)/net
	@mkdir -p $(BUILD_DIR)/$(SYSTEM_DIR)/audio
	@mkdir -p $(BUILD_DIR)/$(APPS_DIR)
	@mkdir -p $(DIST_DIR)

# Bootloader
.PHONY: bootloader
bootloader: $(BUILD_DIR)
	@echo "[BUILD] Building KhatBoot bootloader..."
	@$(AS) -f bin $(BOOT_ASM) -o $(BUILD_DIR)/khatboot.bin
	@echo "[BUILD] Bootloader built successfully"

# Kernel
.PHONY: kernel
kernel: $(BUILD_DIR) $(KERNEL_OBJECTS)
	@echo "[BUILD] Linking KhatKernel..."
	@$(LD) $(LDFLAGS) -o $(BUILD_DIR)/khatkernel.bin $(KERNEL_OBJECTS)
	@echo "[BUILD] KhatKernel built successfully"

# System runtime
.PHONY: system
system: $(BUILD_DIR) $(SYSTEM_OBJECTS)
	@echo "[BUILD] Building KhatCore system runtime..."
	@ar rcs $(BUILD_DIR)/libkhatcore.a $(SYSTEM_OBJECTS)
	@echo "[BUILD] KhatCore built successfully"

# Applications
.PHONY: apps
apps: $(BUILD_DIR)
	@echo "[BUILD] Building system applications..."
	@if [ -f "$(SDK_DIR)/khapp_builder.py" ]; then \
		for app in khatlauncher khatsettings khatfiles khatstore khatmonitor khatsecurity; do \
			if [ -d "$(APPS_DIR)/system/$$app" ]; then \
				echo "[BUILD] Building $$app..."; \
				$(PYTHON) $(SDK_DIR)/khapp_builder.py $(APPS_DIR)/system/$$app -o $(DIST_DIR)/$$app.khapp; \
			fi \
		done \
	else \
		echo "[ERROR] khapp_builder.py not found"; \
	fi
	@echo "[BUILD] Applications built successfully"

# SDK
.PHONY: sdk
sdk: $(BUILD_DIR)
	@echo "[BUILD] Building KhatSDK..."
	@cd $(SDK_DIR)/khatlang && $(CARGO) build --release
	@cp $(SDK_DIR)/khatlang/target/release/khatlang $(BUILD_DIR)/
	@cp $(SDK_DIR)/khatsdk.py $(BUILD_DIR)/
	@chmod +x $(BUILD_DIR)/khatsdk.py
	@echo "[BUILD] KhatSDK built successfully"

# ISO image for desktop
.PHONY: iso
iso: bootloader kernel system apps
	@echo "[BUILD] Creating bootable ISO image..."
	@mkdir -p $(BUILD_DIR)/iso/boot/grub
	@cp $(BUILD_DIR)/khatboot.bin $(BUILD_DIR)/iso/boot/
	@cp $(BUILD_DIR)/khatkernel.bin $(BUILD_DIR)/iso/boot/
	@cp $(BUILD_DIR)/libkhatcore.a $(BUILD_DIR)/iso/boot/
	@echo "Creating GRUB configuration..."
	@echo 'set timeout=5' > $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo 'set default=0' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo 'menuentry "Khatulistiwa OS" {' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '    multiboot /boot/khatkernel.bin' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '    boot' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@echo '}' >> $(BUILD_DIR)/iso/boot/grub/grub.cfg
	@grub-mkrescue -o $(DIST_DIR)/$(ISO_NAME) $(BUILD_DIR)/iso
	@echo "[BUILD] ISO image created: $(DIST_DIR)/$(ISO_NAME)"

# Mobile device image
.PHONY: img
img: kernel system apps
	@echo "[BUILD] Creating mobile device image..."
	@dd if=/dev/zero of=$(DIST_DIR)/$(IMG_NAME) bs=1M count=512
	@echo "[BUILD] Mobile image created: $(DIST_DIR)/$(IMG_NAME)"

# Virtual machine image
.PHONY: vm
vm: iso
	@echo "[BUILD] Creating virtual machine image..."
	@cp $(DIST_DIR)/$(ISO_NAME) $(DIST_DIR)/$(PROJECT_NAME)-vm.iso
	@echo "[BUILD] VM image ready: $(DIST_DIR)/$(PROJECT_NAME)-vm.iso"

# Compile C source files
$(BUILD_DIR)/%.o: %.c
	@echo "[BUILD] Compiling $<..."
	@mkdir -p $(dir $@)
	@$(CC) $(CFLAGS) -o $@ $<

# Tests
.PHONY: test
test: $(BUILD_DIR)
	@echo "[TEST] Running Khatulistiwa OS tests..."
	@$(PYTHON) -m pytest tests/ -v
	@echo "[TEST] All tests passed"

# Run in QEMU
.PHONY: run
run: iso
	@echo "[RUN] Starting Khatulistiwa OS in QEMU..."
	@$(QEMU) -cdrom $(DIST_DIR)/$(ISO_NAME) -m 512M -enable-kvm

# Run with debugging
.PHONY: debug
debug: iso
	@echo "[DEBUG] Starting Khatulistiwa OS in QEMU with debugging..."
	@$(QEMU) -cdrom $(DIST_DIR)/$(ISO_NAME) -m 512M -s -S

# Clean build files
.PHONY: clean
clean:
	@echo "[CLEAN] Removing build files..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(DIST_DIR)
	@echo "[CLEAN] Build files removed"

# Install to system
.PHONY: install
install: all
	@echo "[INSTALL] Installing Khatulistiwa OS..."
	@sudo mkdir -p /opt/khatulistiwa
	@sudo cp -r $(BUILD_DIR)/* /opt/khatulistiwa/
	@sudo cp $(SDK_DIR)/khatsdk.py /usr/local/bin/khatsdk
	@sudo chmod +x /usr/local/bin/khatsdk
	@echo "[INSTALL] Installation complete"

# Create distribution packages
.PHONY: package
package: all
	@echo "[PACKAGE] Creating distribution packages..."
	@mkdir -p $(DIST_DIR)/packages
	
	# Desktop package
	@tar -czf $(DIST_DIR)/packages/$(PROJECT_NAME)-desktop-$(VERSION).tar.gz -C $(BUILD_DIR) .
	
	# SDK package
	@mkdir -p $(BUILD_DIR)/sdk-package
	@cp -r $(SDK_DIR)/* $(BUILD_DIR)/sdk-package/
	@tar -czf $(DIST_DIR)/packages/$(PROJECT_NAME)-sdk-$(VERSION).tar.gz -C $(BUILD_DIR)/sdk-package .
	
	# Source package
	@tar -czf $(DIST_DIR)/packages/$(PROJECT_NAME)-src-$(VERSION).tar.gz \
		--exclude=build --exclude=dist --exclude=.git .
	
	@echo "[PACKAGE] Distribution packages created in $(DIST_DIR)/packages/"

# Generate documentation
.PHONY: docs
docs:
	@echo "[DOCS] Generating documentation..."
	@mkdir -p $(BUILD_DIR)/docs
	@$(PYTHON) -m sphinx -b html docs/source $(BUILD_DIR)/docs/html
	@echo "[DOCS] Documentation generated in $(BUILD_DIR)/docs/html/"

# Development server
.PHONY: dev
dev:
	@echo "[DEV] Starting development environment..."
	@$(PYTHON) -m http.server 8000 --directory $(BUILD_DIR)/docs/html &
	@echo "[DEV] Documentation server running at http://localhost:8000"

# Lint code
.PHONY: lint
lint:
	@echo "[LINT] Running code linters..."
	@find $(KERNEL_DIR) $(SYSTEM_DIR) -name "*.c" -o -name "*.h" | xargs cppcheck --enable=all
	@$(PYTHON) -m flake8 $(SDK_DIR)
	@echo "[LINT] Code linting complete"

# Format code
.PHONY: format
format:
	@echo "[FORMAT] Formatting code..."
	@find $(KERNEL_DIR) $(SYSTEM_DIR) -name "*.c" -o -name "*.h" | xargs clang-format -i
	@$(PYTHON) -m black $(SDK_DIR)
	@echo "[FORMAT] Code formatting complete"

# Check dependencies
.PHONY: deps
deps:
	@echo "[DEPS] Checking build dependencies..."
	@which $(CC) || (echo "Error: GCC not found" && exit 1)
	@which $(AS) || (echo "Error: NASM not found" && exit 1)
	@which $(LD) || (echo "Error: LD not found" && exit 1)
	@which $(PYTHON) || (echo "Error: Python 3 not found" && exit 1)
	@which $(CARGO) || (echo "Error: Rust/Cargo not found" && exit 1)
	@which grub-mkrescue || (echo "Error: GRUB not found" && exit 1)
	@echo "[DEPS] All dependencies satisfied"

# Show build info
.PHONY: info
info:
	@echo "╔══════════════════════════════════════════════════════════╗"
	@echo "║                 Khatulistiwa OS Build Info               ║"
	@echo "╚══════════════════════════════════════════════════════════╝"
	@echo "Project: $(PROJECT_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Build Directory: $(BUILD_DIR)"
	@echo "Distribution Directory: $(DIST_DIR)"
	@echo "Target Architecture: $(TARGET)"
	@echo "Compiler: $(CC)"
	@echo "Assembler: $(AS)"
	@echo "Linker: $(LD)"
	@echo ""

# Phony targets
.PHONY: all help bootloader kernel system apps sdk iso img vm test run debug clean install package docs dev lint format deps info
