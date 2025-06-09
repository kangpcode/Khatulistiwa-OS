/*
 * ============================================================================
 * riscv_boot.S - RISC-V Boot Assembly untuk Khatulistiwa OS
 * Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
 * ============================================================================
 * 
 * RISC-V bootloader dengan fitur:
 * 1. RISC-V 64-bit (RV64) architecture support
 * 2. Supervisor Binary Interface (SBI) integration
 * 3. Cultural boot sequence untuk RISC-V devices
 * 4. Page table setup untuk virtual memory
 * 5. Machine mode to supervisor mode transition
 */

.section ".text.init"

// RISC-V constants
.equ MSTATUS_MPP_MASK,      (3 << 11)
.equ MSTATUS_MPP_S,         (1 << 11)
.equ MSTATUS_MPIE,          (1 << 7)
.equ MSTATUS_MIE,           (1 << 3)

.equ SSTATUS_SPP,           (1 << 8)
.equ SSTATUS_SPIE,          (1 << 5)
.equ SSTATUS_SIE,           (1 << 1)

.equ SATP_MODE_SV39,        (8ULL << 60)
.equ SATP_MODE_SV48,        (9ULL << 60)

// Page table constants
.equ PTE_V,                 (1 << 0)    // Valid
.equ PTE_R,                 (1 << 1)    // Read
.equ PTE_W,                 (1 << 2)    // Write
.equ PTE_X,                 (1 << 3)    // Execute
.equ PTE_U,                 (1 << 4)    // User
.equ PTE_G,                 (1 << 5)    // Global
.equ PTE_A,                 (1 << 6)    // Accessed
.equ PTE_D,                 (1 << 7)    // Dirty

// Cultural boot messages
.section ".rodata"
cultural_boot_msg:
    .string "Khatulistiwa OS RISC-V Bootloader\n"
    .string "Sistem Operasi Indonesia untuk RISC-V\n"
    .string "Memulai dengan semangat inovasi...\n"

batik_init_msg:
    .string "Menginisialisasi pola batik RISC-V...\n"

gamelan_init_msg:
    .string "Mempersiapkan audio gamelan RISC-V...\n"

kernel_load_msg:
    .string "Memuat kernel Khatulistiwa RISC-V...\n"

sbi_init_msg:
    .string "Menginisialisasi SBI interface...\n"

.section ".text.init"

// Global symbols
.global _start
.global riscv_cultural_init
.global riscv_setup_paging
.global riscv_load_kernel

// Boot entry point
_start:
    // Disable interrupts
    csrw    sie, zero
    csrw    sip, zero
    
    // Save hart ID and device tree pointer
    mv      s0, a0          // Hart ID
    mv      s1, a1          // Device tree pointer
    
    // Check if we're in machine mode
    csrr    t0, mstatus
    li      t1, MSTATUS_MPP_MASK
    and     t0, t0, t1
    li      t1, MSTATUS_MPP_S
    bne     t0, t1, machine_mode_entry
    
    // Already in supervisor mode
    j       supervisor_mode_entry

machine_mode_entry:
    // Setup stack for machine mode
    la      sp, _machine_stack_top
    
    // Initialize SBI if we're the boot hart
    bnez    s0, secondary_hart
    
    // Primary hart initialization
    call    riscv_sbi_init
    
    // Setup supervisor mode entry
    la      t0, supervisor_mode_entry
    csrw    mepc, t0
    
    // Set mstatus for supervisor mode
    li      t0, MSTATUS_MPP_S | MSTATUS_MPIE
    csrw    mstatus, t0
    
    // Delegate interrupts and exceptions to supervisor mode
    li      t0, 0xffff
    csrw    mideleg, t0
    li      t0, 0xffff
    csrw    medeleg, t0
    
    // Return to supervisor mode
    mret

secondary_hart:
    // Secondary harts wait for primary to complete initialization
    call    wait_for_primary_hart
    j       supervisor_mode_entry

supervisor_mode_entry:
    // Setup supervisor stack
    la      sp, _supervisor_stack_top
    
    // Only primary hart continues with boot process
    bnez    s0, secondary_hart_idle
    
    // Clear BSS section
    la      t0, __bss_start
    la      t1, __bss_end
    call    clear_bss
    
    // Cultural initialization
    call    riscv_cultural_init
    
    // Parse device tree
    mv      a0, s1
    call    parse_device_tree_riscv
    
    // Setup virtual memory
    call    riscv_setup_paging
    
    // Initialize cultural hardware
    call    init_cultural_hardware_riscv
    
    // Load kernel
    call    riscv_load_kernel
    
    // Should not reach here
    j       halt_riscv

secondary_hart_idle:
    // Secondary harts wait for IPI from primary
    wfi
    j       secondary_hart_idle

// Cultural initialization for RISC-V
riscv_cultural_init:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    
    // Print cultural boot message
    la      a0, cultural_boot_msg
    call    sbi_console_putstr
    
    // Initialize batik patterns
    la      a0, batik_init_msg
    call    sbi_console_putstr
    call    init_batik_patterns_riscv
    
    // Initialize gamelan audio
    la      a0, gamelan_init_msg
    call    sbi_console_putstr
    call    init_gamelan_riscv
    
    // Display Garuda ASCII art
    call    display_garuda_ascii_riscv
    
    ld      ra, 8(sp)
    addi    sp, sp, 16
    ret

// Setup paging for RISC-V
riscv_setup_paging:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    
    // Setup page tables
    call    setup_page_tables_riscv
    
    // Enable SV39 paging
    la      t0, page_table_l1
    srli    t0, t0, 12          // Convert to PPN
    li      t1, SATP_MODE_SV39
    or      t0, t0, t1
    csrw    satp, t0
    
    // Flush TLB
    sfence.vma
    
    ld      ra, 8(sp)
    addi    sp, sp, 16
    ret

// Load Khatulistiwa kernel for RISC-V
riscv_load_kernel:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    
    // Print kernel loading message
    la      a0, kernel_load_msg
    call    sbi_console_putstr
    
    // Load kernel from storage
    la      a0, KERNEL_LOAD_ADDRESS
    call    load_kernel_from_storage_riscv
    
    // Verify kernel signature
    la      a0, KERNEL_LOAD_ADDRESS
    call    verify_kernel_signature_riscv
    bnez    a0, kernel_load_error
    
    // Setup kernel parameters
    call    setup_kernel_parameters_riscv
    
    // Jump to kernel
    la      t0, KERNEL_LOAD_ADDRESS
    mv      a0, s0              // Hart ID
    mv      a1, s1              // Device tree pointer
    jr      t0

kernel_load_error:
    la      a0, kernel_error_msg
    call    sbi_console_putstr
    j       halt_riscv

// Initialize SBI interface
riscv_sbi_init:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    
    // Print SBI initialization message
    la      a0, sbi_init_msg
    call    sbi_console_putstr
    
    // Check SBI version
    li      a7, 0x10            // SBI_EXT_BASE
    li      a6, 0               // SBI_BASE_GET_SPEC_VERSION
    ecall
    
    // Store SBI version
    la      t0, sbi_version
    sd      a0, 0(t0)
    
    // Initialize timer
    call    sbi_timer_init
    
    ld      ra, 8(sp)
    addi    sp, sp, 16
    ret

// Initialize batik patterns for RISC-V
init_batik_patterns_riscv:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    
    // Check for framebuffer
    call    get_framebuffer_info_riscv
    beqz    a0, no_framebuffer_riscv
    
    // Initialize batik renderer
    call    init_batik_renderer_riscv
    
    // Draw default parang pattern
    la      a0, parang_pattern_data
    call    draw_batik_pattern_riscv
    
no_framebuffer_riscv:
    ld      ra, 8(sp)
    addi    sp, sp, 16
    ret

// Initialize gamelan audio for RISC-V
init_gamelan_riscv:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    
    // Detect audio hardware
    call    detect_audio_hardware_riscv
    beqz    a0, no_audio_riscv
    
    // Initialize audio subsystem
    call    init_audio_subsystem_riscv
    
    // Load gamelan samples
    la      a0, gamelan_samples_data
    call    load_gamelan_samples_riscv
    
    // Play welcome sequence
    li      a0, GAMELAN_WELCOME_SEQUENCE
    call    play_gamelan_sequence_riscv
    
no_audio_riscv:
    ld      ra, 8(sp)
    addi    sp, sp, 16
    ret

// Display Garuda ASCII art for RISC-V
display_garuda_ascii_riscv:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    
    la      a0, garuda_ascii_art
    call    sbi_console_putstr
    
    ld      ra, 8(sp)
    addi    sp, sp, 16
    ret

// Parse device tree for RISC-V
parse_device_tree_riscv:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    sd      a0, 0(sp)           // Save DTB pointer
    
    // Verify DTB magic
    lw      t0, 0(a0)
    li      t1, 0xd00dfeed
    bne     t0, t1, dtb_error_riscv
    
    // Parse memory nodes
    call    parse_memory_nodes_riscv
    
    // Parse CPU nodes
    call    parse_cpu_nodes_riscv
    
    // Parse cultural hardware nodes
    call    parse_cultural_hardware_nodes_riscv
    
    ld      a0, 0(sp)           // Restore DTB pointer
    ld      ra, 8(sp)
    addi    sp, sp, 16
    ret

dtb_error_riscv:
    la      a0, dtb_error_msg
    call    sbi_console_putstr
    j       halt_riscv

// Setup page tables for RISC-V SV39
setup_page_tables_riscv:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    
    // Clear page tables
    la      a0, page_table_l1
    li      a1, 4096
    call    memzero_riscv
    
    la      a0, page_table_l2
    li      a1, 4096
    call    memzero_riscv
    
    // Setup L1 page table
    la      t0, page_table_l1
    la      t1, page_table_l2
    srli    t1, t1, 12          // Convert to PPN
    slli    t1, t1, 10          // Shift to PPN field
    ori     t1, t1, PTE_V       // Set valid bit
    sd      t1, 0(t0)
    
    // Setup L2 page table for identity mapping
    la      t0, page_table_l2
    li      t1, 0               // Physical address
    li      t2, 512             // Number of entries
    
setup_l2_loop_riscv:
    srli    t3, t1, 12          // Convert to PPN
    slli    t3, t3, 10          // Shift to PPN field
    li      t4, PTE_V | PTE_R | PTE_W | PTE_X | PTE_A | PTE_D
    or      t3, t3, t4
    sd      t3, 0(t0)
    
    addi    t0, t0, 8           // Next entry
    li      t4, 0x200000        // 2MB
    add     t1, t1, t4          // Next physical address
    addi    t2, t2, -1
    bnez    t2, setup_l2_loop_riscv
    
    ld      ra, 8(sp)
    addi    sp, sp, 16
    ret

// Initialize cultural hardware for RISC-V
init_cultural_hardware_riscv:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    
    // Initialize GPIO for cultural LEDs
    call    init_cultural_gpio_riscv
    
    // Initialize I2C for cultural sensors
    call    init_cultural_i2c_riscv
    
    // Initialize SPI for cultural displays
    call    init_cultural_spi_riscv
    
    ld      ra, 8(sp)
    addi    sp, sp, 16
    ret

// Setup kernel parameters for RISC-V
setup_kernel_parameters_riscv:
    addi    sp, sp, -16
    sd      ra, 8(sp)
    
    // Setup kernel command line
    la      a0, kernel_cmdline
    la      a1, default_cmdline_riscv
    call    strcpy_riscv
    
    // Add cultural parameters
    la      a0, kernel_cmdline
    la      a1, cultural_params_riscv
    call    strcat_riscv
    
    ld      ra, 8(sp)
    addi    sp, sp, 16
    ret

// SBI console putstring
sbi_console_putstr:
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      a0, 16(sp)
    
sbi_putstr_loop:
    lb      a0, 0(a0)
    beqz    a0, sbi_putstr_done
    
    // SBI console putchar
    li      a7, 0x01            // SBI_EXT_CONSOLE_PUTCHAR
    ecall
    
    ld      a0, 16(sp)
    addi    a0, a0, 1
    sd      a0, 16(sp)
    j       sbi_putstr_loop
    
sbi_putstr_done:
    ld      ra, 24(sp)
    addi    sp, sp, 32
    ret

// Memory zero function for RISC-V
memzero_riscv:
    beqz    a1, memzero_done_riscv
memzero_loop_riscv:
    sd      zero, 0(a0)
    addi    a0, a0, 8
    addi    a1, a1, -8
    bgtz    a1, memzero_loop_riscv
memzero_done_riscv:
    ret

// String copy for RISC-V
strcpy_riscv:
strcpy_loop_riscv:
    lb      t0, 0(a1)
    sb      t0, 0(a0)
    addi    a0, a0, 1
    addi    a1, a1, 1
    bnez    t0, strcpy_loop_riscv
    ret

// String concatenate for RISC-V
strcat_riscv:
    // Find end of destination
strcat_find_end_riscv:
    lb      t0, 0(a0)
    beqz    t0, strcat_copy_riscv
    addi    a0, a0, 1
    j       strcat_find_end_riscv
    
    // Copy source
strcat_copy_riscv:
    lb      t0, 0(a1)
    sb      t0, 0(a0)
    addi    a0, a0, 1
    addi    a1, a1, 1
    bnez    t0, strcat_copy_riscv
    ret

// Clear BSS section
clear_bss:
    bgeu    t0, t1, clear_bss_done
clear_bss_loop:
    sd      zero, 0(t0)
    addi    t0, t0, 8
    bltu    t0, t1, clear_bss_loop
clear_bss_done:
    ret

// Wait for primary hart
wait_for_primary_hart:
    la      t0, primary_hart_ready
    lw      t1, 0(t0)
    beqz    t1, wait_for_primary_hart
    ret

// Halt system
halt_riscv:
    wfi
    j       halt_riscv

// Data section
.section ".data"

// SBI version
sbi_version:
    .dword  0

// Primary hart ready flag
primary_hart_ready:
    .word   0

// Kernel command line
kernel_cmdline:
    .space  512

default_cmdline_riscv:
    .string "root=/dev/mmcblk0p2 rootwait console=ttyS0,115200"

cultural_params_riscv:
    .string " cultural_mode=on batik_theme=parang gamelan=on wayang=on"

// Error messages
dtb_error_msg:
    .string "Error: Invalid device tree blob\n"

kernel_error_msg:
    .string "Error: Kernel loading failed\n"

// Garuda ASCII art
garuda_ascii_art:
    .string "        ___\n"
    .string "       /   \\\n"
    .string "      | ^ ^ |\n"
    .string "       \\_-_/\n"
    .string "     ___| |___\n"
    .string "    /         \\\n"
    .string "   |  GARUDA   |\n"
    .string "    \\_________/\n"
    .string "      |     |\n"
    .string "     /|     |\\\n"
    .string "Khatulistiwa OS RISC-V\n"

// BSS section
.section ".bss"

// Page tables (aligned to 4KB)
.align 12
page_table_l1:
    .space  4096

.align 12
page_table_l2:
    .space  4096

// Stacks
.align 4
_machine_stack_bottom:
    .space  8192
_machine_stack_top:

.align 4
_supervisor_stack_bottom:
    .space  16384
_supervisor_stack_top:

// Constants
.equ KERNEL_LOAD_ADDRESS,       0x80200000
.equ GAMELAN_WELCOME_SEQUENCE,  1
