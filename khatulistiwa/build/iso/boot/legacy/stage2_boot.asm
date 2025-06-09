; ============================================================================
; stage2_boot.asm - Stage 2 Bootloader untuk Khatulistiwa OS
; Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
; ============================================================================
; 
; Stage 2 bootloader dengan fitur:
; 1. Protected mode transition
; 2. Advanced cultural graphics
; 3. Memory detection dan setup
; 4. Cultural hardware initialization
; 5. Kernel parameter setup

[BITS 16]
[ORG 0x0800]

; Constants
GDT_BASE        equ 0x1000
KERNEL_BASE     equ 0x100000    ; 1MB
PAGE_DIR        equ 0x9000
PAGE_TABLE      equ 0xA000

; Cultural messages
msg_stage2      db 'Stage 2: Khatulistiwa Advanced Bootloader', 0x0D, 0x0A, 0
msg_memory      db 'Mendeteksi memori sistem...', 0x0D, 0x0A, 0
msg_cultural    db 'Menginisialisasi budaya tingkat lanjut...', 0x0D, 0x0A, 0
msg_protected   db 'Beralih ke protected mode...', 0x0D, 0x0A, 0
msg_paging      db 'Mengaktifkan virtual memory...', 0x0D, 0x0A, 0
msg_kernel      db 'Mempersiapkan kernel Khatulistiwa...', 0x0D, 0x0A, 0

; Cultural splash data
cultural_splash:
    db '    ╔══════════════════════════════════════════════════════════╗', 0x0D, 0x0A
    db '    ║                KHATULISTIWA OS                           ║', 0x0D, 0x0A
    db '    ║            Sistem Operasi Indonesia                     ║', 0x0D, 0x0A
    db '    ║                                                          ║', 0x0D, 0x0A
    db '    ║        ████████╗ ██╗  ██╗ █████╗ ████████╗              ║', 0x0D, 0x0A
    db '    ║        ╚══██╔══╝ ██║  ██║██╔══██╗╚══██╔══╝              ║', 0x0D, 0x0A
    db '    ║           ██║    ███████║███████║   ██║                 ║', 0x0D, 0x0A
    db '    ║           ██║    ██╔══██║██╔══██║   ██║                 ║', 0x0D, 0x0A
    db '    ║           ██║    ██║  ██║██║  ██║   ██║                 ║', 0x0D, 0x0A
    db '    ║           ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝                 ║', 0x0D, 0x0A
    db '    ║                                                          ║', 0x0D, 0x0A
    db '    ║              "Teknologi Modern, Jiwa Indonesia"         ║', 0x0D, 0x0A
    db '    ╚══════════════════════════════════════════════════════════╝', 0x0D, 0x0A, 0

; Memory map structure
memory_map:
    dd 0                ; Base address low
    dd 0                ; Base address high
    dd 0                ; Length low
    dd 0                ; Length high
    dd 0                ; Type

; Stage 2 entry point
stage2_start:
    ; Setup segments
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov sp, 0x7000
    sti
    
    ; Clear screen with cultural theme
    call clear_screen_cultural
    
    ; Display stage 2 splash
    call display_stage2_splash
    
    ; Detect memory
    call detect_memory
    
    ; Initialize advanced cultural features
    call init_advanced_cultural
    
    ; Setup GDT
    call setup_gdt
    
    ; Enable A20 line
    call enable_a20
    
    ; Setup paging
    call setup_paging
    
    ; Switch to protected mode
    call switch_to_protected_mode

; Clear screen with cultural colors
clear_screen_cultural:
    pusha
    
    ; Set video mode 80x25 with cultural colors
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    
    ; Set cultural color scheme (Indonesian flag inspired)
    mov ah, 0x06
    mov al, 0x00
    mov bh, 0x4F        ; Red background, white text
    mov cx, 0x0000
    mov dx, 0x0C4F      ; Top half
    int 0x10
    
    mov ah, 0x06
    mov al, 0x00
    mov bh, 0xF0        ; White background, black text
    mov cx, 0x0D00
    mov dx, 0x184F      ; Bottom half
    int 0x10
    
    ; Set cursor to top
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0000
    int 0x10
    
    popa
    ret

; Display stage 2 cultural splash
display_stage2_splash:
    pusha
    
    ; Position cursor for splash
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 2
    mov dl, 5
    int 0x10
    
    ; Display cultural splash
    mov si, cultural_splash
    call print_string_cultural
    
    ; Display stage 2 message
    mov ah, 0x02
    mov dh, 18
    mov dl, 20
    int 0x10
    
    mov si, msg_stage2
    call print_string_cultural
    
    ; Animate cultural elements
    call animate_cultural_elements
    
    popa
    ret

; Detect system memory
detect_memory:
    pusha
    
    ; Display memory detection message
    mov si, msg_memory
    call print_string_cultural
    
    ; Use INT 15h, EAX=E820h to detect memory
    xor ebx, ebx
    mov di, memory_map
    
memory_detect_loop:
    mov eax, 0xE820
    mov ecx, 24
    mov edx, 0x534D4150  ; 'SMAP'
    int 0x15
    
    jc memory_detect_done
    
    ; Process memory map entry
    call process_memory_entry
    
    ; Move to next entry
    add di, 24
    test ebx, ebx
    jnz memory_detect_loop
    
memory_detect_done:
    ; Store memory information for kernel
    call store_memory_info
    
    popa
    ret

; Initialize advanced cultural features
init_advanced_cultural:
    pusha
    
    ; Display cultural initialization message
    mov si, msg_cultural
    call print_string_cultural
    
    ; Initialize cultural graphics subsystem
    call init_cultural_graphics
    
    ; Initialize cultural audio subsystem
    call init_cultural_audio
    
    ; Setup cultural hardware detection
    call setup_cultural_hardware_detection
    
    ; Load cultural assets
    call load_cultural_assets
    
    popa
    ret

; Setup Global Descriptor Table
setup_gdt:
    pusha
    
    ; Clear GDT area
    mov di, GDT_BASE
    mov cx, 256
    xor ax, ax
    rep stosw
    
    ; Setup GDT entries
    mov di, GDT_BASE
    
    ; Null descriptor (0x00)
    mov dword [di], 0
    mov dword [di+4], 0
    add di, 8
    
    ; Code segment descriptor (0x08)
    mov dword [di], 0x0000FFFF  ; Limit 0-15, Base 0-15
    mov dword [di+4], 0x00CF9A00 ; Base 16-31, Access, Granularity, Limit 16-19
    add di, 8
    
    ; Data segment descriptor (0x10)
    mov dword [di], 0x0000FFFF  ; Limit 0-15, Base 0-15
    mov dword [di+4], 0x00CF9200 ; Base 16-31, Access, Granularity, Limit 16-19
    add di, 8
    
    ; Cultural segment descriptor (0x18) - Special for cultural data
    mov dword [di], 0x0000FFFF
    mov dword [di+4], 0x00CF9600 ; Special access rights for cultural data
    
    ; Load GDT
    mov word [gdt_descriptor], 31  ; GDT limit
    mov dword [gdt_descriptor+2], GDT_BASE
    lgdt [gdt_descriptor]
    
    popa
    ret

; Enable A20 line
enable_a20:
    pusha
    
    ; Method 1: BIOS
    mov ax, 0x2401
    int 0x15
    jnc a20_enabled
    
    ; Method 2: Keyboard controller
    call wait_8042
    mov al, 0xAD
    out 0x64, al
    
    call wait_8042
    mov al, 0xD0
    out 0x64, al
    
    call wait_8042_data
    in al, 0x60
    push ax
    
    call wait_8042
    mov al, 0xD1
    out 0x64, al
    
    call wait_8042
    pop ax
    or al, 2
    out 0x60, al
    
    call wait_8042
    mov al, 0xAE
    out 0x64, al
    
a20_enabled:
    popa
    ret

; Wait for keyboard controller
wait_8042:
    in al, 0x64
    test al, 2
    jnz wait_8042
    ret

wait_8042_data:
    in al, 0x64
    test al, 1
    jz wait_8042_data
    ret

; Setup paging for cultural memory management
setup_paging:
    pusha
    
    ; Display paging message
    mov si, msg_paging
    call print_string_cultural
    
    ; Clear page directory
    mov edi, PAGE_DIR
    mov ecx, 1024
    xor eax, eax
    rep stosd
    
    ; Clear page table
    mov edi, PAGE_TABLE
    mov ecx, 1024
    xor eax, eax
    rep stosd
    
    ; Setup page directory entry
    mov dword [PAGE_DIR], PAGE_TABLE | 3  ; Present, Read/Write
    
    ; Setup page table entries (identity mapping for first 4MB)
    mov edi, PAGE_TABLE
    mov eax, 3          ; Present, Read/Write
    mov ecx, 1024
    
setup_page_loop:
    stosd
    add eax, 4096       ; Next page
    loop setup_page_loop
    
    ; Load page directory
    mov eax, PAGE_DIR
    mov cr3, eax
    
    ; Enable paging
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax
    
    popa
    ret

; Switch to protected mode
switch_to_protected_mode:
    ; Display protected mode message
    mov si, msg_protected
    call print_string_cultural
    
    ; Disable interrupts
    cli
    
    ; Enable protected mode
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    ; Far jump to flush pipeline and load CS
    jmp 0x08:protected_mode_entry

[BITS 32]
; Protected mode entry point
protected_mode_entry:
    ; Setup data segments
    mov ax, 0x10        ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Setup stack
    mov esp, 0x90000
    
    ; Setup cultural segment
    mov ax, 0x18        ; Cultural segment selector
    mov fs, ax          ; Use FS for cultural data access
    
    ; Initialize protected mode cultural features
    call init_protected_cultural
    
    ; Setup kernel parameters
    call setup_kernel_parameters
    
    ; Jump to kernel
    mov eax, KERNEL_BASE
    jmp eax

; Initialize cultural features in protected mode
init_protected_cultural:
    ; Setup cultural memory regions
    call setup_cultural_memory
    
    ; Initialize cultural hardware in protected mode
    call init_cultural_hardware_protected
    
    ; Setup cultural interrupts
    call setup_cultural_interrupts
    
    ret

; Setup cultural memory regions
setup_cultural_memory:
    ; Reserve memory for cultural assets
    ; Batik patterns: 0x200000 - 0x210000 (64KB)
    ; Gamelan samples: 0x210000 - 0x220000 (64KB)
    ; Wayang graphics: 0x220000 - 0x230000 (64KB)
    
    ret

; Setup kernel parameters
setup_kernel_parameters:
    ; Setup parameter block at 0x8000
    mov edi, 0x8000
    
    ; Kernel signature
    mov dword [edi], 0x4B484154  ; 'KHAT'
    add edi, 4
    
    ; Memory size
    mov dword [edi], 0x1000000   ; 16MB default
    add edi, 4
    
    ; Cultural mode flag
    mov dword [edi], 1           ; Enable cultural mode
    add edi, 4
    
    ; Boot device
    mov dword [edi], 0x80        ; First hard disk
    add edi, 4
    
    ; Cultural assets base
    mov dword [edi], 0x200000    ; Cultural memory base
    
    ret

[BITS 16]
; Cultural helper functions

; Print string with cultural colors
print_string_cultural:
    pusha
    
print_cultural_loop:
    lodsb
    test al, al
    jz print_cultural_done
    
    ; Use cultural colors based on character
    mov bl, 0x0E        ; Yellow on red
    cmp al, 'K'
    je use_special_color
    cmp al, 'H'
    je use_special_color
    cmp al, 'A'
    je use_special_color
    cmp al, 'T'
    je use_special_color
    jmp normal_color
    
use_special_color:
    mov bl, 0x0C        ; Bright red
    
normal_color:
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    jmp print_cultural_loop
    
print_cultural_done:
    popa
    ret

; Animate cultural elements
animate_cultural_elements:
    pusha
    
    mov cx, 10          ; 10 animation frames
    
animate_loop:
    push cx
    
    ; Animate batik pattern
    call animate_batik_pattern
    
    ; Play cultural sound
    call play_cultural_sound
    
    ; Delay
    mov dx, 0x1000
delay_animate:
    dec dx
    jnz delay_animate
    
    pop cx
    loop animate_loop
    
    popa
    ret

; Animate batik pattern
animate_batik_pattern:
    ; Simple batik animation using text characters
    mov ah, 0x02
    mov dh, 20
    mov dl, 30
    int 0x10
    
    ; Cycle through batik characters
    mov al, '▓'
    mov bl, 0x06        ; Brown
    mov ah, 0x0E
    int 0x10
    
    mov al, '▒'
    mov bl, 0x0E        ; Yellow
    int 0x10
    
    mov al, '░'
    mov bl, 0x06        ; Brown
    int 0x10
    
    ret

; Play cultural sound
play_cultural_sound:
    ; Play a note from gamelan scale
    mov ax, 523         ; C note
    call play_tone_short
    ret

; Play tone (from stage 1)
play_tone_short:
    pusha
    
    mov al, 0xB6
    out 0x43, al
    out 0x42, al
    mov al, ah
    out 0x42, al
    
    in al, 0x61
    or al, 3
    out 0x61, al
    
    mov cx, 0x800
short_tone_delay:
    nop
    loop short_tone_delay
    
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
    popa
    ret

; Initialize cultural graphics
init_cultural_graphics:
    ; Setup VGA for cultural graphics
    ret

; Initialize cultural audio
init_cultural_audio:
    ; Setup audio hardware for gamelan
    ret

; Setup cultural hardware detection
setup_cultural_hardware_detection:
    ; Detect cultural-specific hardware
    ret

; Load cultural assets
load_cultural_assets:
    ; Load batik patterns, gamelan samples, wayang graphics
    ret

; Process memory entry
process_memory_entry:
    ; Process memory map entry
    ret

; Store memory info
store_memory_info:
    ; Store memory information for kernel
    ret

; Initialize cultural hardware in protected mode
init_cultural_hardware_protected:
    ret

; Setup cultural interrupts
setup_cultural_interrupts:
    ret

; Data section
gdt_descriptor:
    dw 0                ; GDT limit
    dd 0                ; GDT base

; Padding to sector boundary
times 4096-($-$$) db 0
