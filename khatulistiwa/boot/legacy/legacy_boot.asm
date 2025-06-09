; ============================================================================
; legacy_boot.asm - Legacy BIOS Bootloader untuk Khatulistiwa OS
; Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
; ============================================================================
; 
; Legacy BIOS bootloader dengan fitur:
; 1. 16-bit real mode bootloader
; 2. Cultural splash screen dengan Garuda
; 3. Traditional Indonesian boot messages
; 4. Batik pattern loading animation
; 5. Gamelan boot sounds via PC speaker
; 6. Multi-stage boot process

[BITS 16]
[ORG 0x7C00]

; Boot sector constants
STACK_BASE      equ 0x7000
KERNEL_LOAD     equ 0x1000
STAGE2_LOAD     equ 0x0800
VIDEO_MODE      equ 0x13        ; 320x200 256 colors

; Cultural colors (VGA palette)
COLOR_MERAH     equ 0x04        ; Red (Indonesian flag)
COLOR_PUTIH     equ 0x0F        ; White (Indonesian flag)
COLOR_EMAS      equ 0x0E        ; Yellow/Gold (Garuda)
COLOR_HIJAU     equ 0x02        ; Green (nature)
COLOR_BIRU      equ 0x01        ; Blue (ocean)
COLOR_COKLAT    equ 0x06        ; Brown (batik)

; Boot messages in Indonesian
msg_boot_start  db 'KhatBoot Legacy - Bootloader Khatulistiwa OS', 0x0D, 0x0A, 0
msg_loading     db 'Memuat sistem operasi Indonesia...', 0x0D, 0x0A, 0
msg_cultural    db 'Menginisialisasi budaya Nusantara...', 0x0D, 0x0A, 0
msg_kernel      db 'Memuat kernel Khatulistiwa...', 0x0D, 0x0A, 0
msg_stage2      db 'Memuat stage 2 bootloader...', 0x0D, 0x0A, 0
msg_success     db 'Selamat datang di Khatulistiwa OS!', 0x0D, 0x0A, 0
msg_error       db 'Kesalahan: Gagal memuat sistem', 0x0D, 0x0A, 0
msg_garuda      db 'Garuda Pancasila melindungi sistem...', 0x0D, 0x0A, 0

; Cultural ASCII art - Enhanced Garuda
garuda_art:
    db '           _______________', 0x0D, 0x0A
    db '          /               \', 0x0D, 0x0A
    db '         |    PANCASILA    |', 0x0D, 0x0A
    db '          \_______________/', 0x0D, 0x0A
    db '               |     |', 0x0D, 0x0A
    db '        ______|_____|______', 0x0D, 0x0A
    db '       /                   \', 0x0D, 0x0A
    db '      |       GARUDA        |', 0x0D, 0x0A
    db '       \___________________/', 0x0D, 0x0A
    db '         |               |', 0x0D, 0x0A
    db '        /|               |\', 0x0D, 0x0A
    db '       / |               | \', 0x0D, 0x0A
    db '          KHATULISTIWA OS', 0x0D, 0x0A, 0

; Batik pattern data (simplified)
batik_parang:
    db 0x06, 0x0E, 0x06, 0x0E, 0x06, 0x0E, 0x06, 0x0E
    db 0x0E, 0x06, 0x0E, 0x06, 0x0E, 0x06, 0x0E, 0x06
    db 0x06, 0x0E, 0x06, 0x0E, 0x06, 0x0E, 0x06, 0x0E
    db 0x0E, 0x06, 0x0E, 0x06, 0x0E, 0x06, 0x0E, 0x06

; Boot entry point
start:
    ; Setup segments and stack
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, STACK_BASE
    sti
    
    ; Clear screen and set video mode
    call clear_screen
    call set_video_mode
    
    ; Display cultural boot screen
    call display_cultural_splash
    
    ; Play gamelan welcome
    call play_gamelan_welcome
    
    ; Initialize cultural subsystem
    call init_cultural_system
    
    ; Load stage 2 bootloader
    call load_stage2
    
    ; Load kernel
    call load_kernel
    
    ; Jump to kernel
    jmp KERNEL_LOAD

; Clear screen with Indonesian flag colors
clear_screen:
    pusha
    
    ; Set text mode first
    mov ah, 0x00
    mov al, 0x03        ; 80x25 text mode
    int 0x10
    
    ; Clear screen with red background (Indonesian flag)
    mov ah, 0x06        ; Scroll up
    mov al, 0x00        ; Clear entire screen
    mov bh, 0x40        ; Red background, black text
    mov cx, 0x0000      ; Upper left corner
    mov dx, 0x184F      ; Lower right corner (24, 79)
    int 0x10
    
    ; Set cursor to top
    mov ah, 0x02
    mov bh, 0x00
    mov dx, 0x0000
    int 0x10
    
    popa
    ret

; Set graphics video mode for splash
set_video_mode:
    pusha
    
    ; Set VGA 320x200 256 color mode
    mov ah, 0x00
    mov al, VIDEO_MODE
    int 0x10
    
    popa
    ret

; Display cultural splash screen
display_cultural_splash:
    pusha
    
    ; Draw Indonesian flag background
    call draw_indonesian_flag
    
    ; Draw Garuda in center
    call draw_garuda_graphics
    
    ; Draw batik border
    call draw_batik_border
    
    ; Display text overlay
    call display_boot_text
    
    ; Animate loading
    call animate_cultural_loading
    
    popa
    ret

; Draw Indonesian flag as background
draw_indonesian_flag:
    pusha
    
    mov ax, 0xA000      ; VGA memory segment
    mov es, ax
    
    ; Draw red portion (top half)
    xor di, di
    mov cx, 32000       ; 320x100 pixels
    mov al, COLOR_MERAH
    
red_loop:
    stosb
    loop red_loop
    
    ; Draw white portion (bottom half)
    mov cx, 32000       ; 320x100 pixels
    mov al, COLOR_PUTIH
    
white_loop:
    stosb
    loop white_loop
    
    popa
    ret

; Draw Garuda graphics (simplified)
draw_garuda_graphics:
    pusha
    
    mov ax, 0xA000
    mov es, ax
    
    ; Draw Garuda silhouette in center
    mov di, 160 * 100 + 160 - 25  ; Center position
    mov cx, 50          ; Width
    mov dx, 50          ; Height
    
garuda_y_loop:
    push cx
    push di
    
garuda_x_loop:
    ; Simple Garuda shape
    mov al, COLOR_EMAS
    stosb
    loop garuda_x_loop
    
    pop di
    add di, 320         ; Next line
    pop cx
    dec dx
    jnz garuda_y_loop
    
    popa
    ret

; Draw batik border pattern
draw_batik_border:
    pusha
    
    mov ax, 0xA000
    mov es, ax
    
    ; Draw top border
    xor di, di
    mov cx, 320
    mov si, batik_parang
    
top_border:
    mov al, [si]
    stosb
    inc si
    and si, 7           ; Wrap pattern
    add si, batik_parang
    loop top_border
    
    ; Draw bottom border
    mov di, 320 * 199
    mov cx, 320
    mov si, batik_parang
    
bottom_border:
    mov al, [si]
    stosb
    inc si
    and si, 7
    add si, batik_parang
    loop bottom_border
    
    popa
    ret

; Display boot text overlay
display_boot_text:
    pusha
    
    ; Switch back to text mode for messages
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    
    ; Set cursor position for title
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 2           ; Row
    mov dl, 15          ; Column
    int 0x10
    
    ; Display title with Indonesian colors
    mov si, msg_boot_start
    mov bl, COLOR_EMAS
    call print_colored_string
    
    ; Display Garuda ASCII art
    mov ah, 0x02
    mov dh, 5
    mov dl, 20
    int 0x10
    
    mov si, garuda_art
    mov bl, COLOR_MERAH
    call print_colored_string
    
    ; Display cultural message
    mov ah, 0x02
    mov dh, 20
    mov dl, 15
    int 0x10
    
    mov si, msg_garuda
    mov bl, COLOR_HIJAU
    call print_colored_string
    
    popa
    ret

; Animate cultural loading
animate_cultural_loading:
    pusha
    
    mov cx, 20          ; 20 animation frames
    
animate_loop:
    push cx
    
    ; Draw loading bar with batik pattern
    call draw_cultural_loading_bar
    
    ; Play loading sound
    call play_loading_sound
    
    ; Delay
    mov cx, 0x8FFF
delay_loop:
    nop
    loop delay_loop
    
    pop cx
    loop animate_loop
    
    popa
    ret

; Draw cultural loading bar
draw_cultural_loading_bar:
    pusha
    
    ; Position for loading bar
    mov ah, 0x02
    mov dh, 22          ; Row
    mov dl, 10          ; Column
    int 0x10
    
    ; Draw loading bar frame
    mov al, '['
    mov bl, COLOR_PUTIH
    call print_colored_char
    
    ; Draw progress with batik pattern
    mov cx, 40          ; Bar width
    mov al, '='
    mov bl, COLOR_EMAS
    
progress_loop:
    call print_colored_char
    
    ; Alternate colors for batik effect
    cmp bl, COLOR_EMAS
    je use_brown
    mov bl, COLOR_EMAS
    jmp continue_progress
    
use_brown:
    mov bl, COLOR_COKLAT
    
continue_progress:
    push cx
    mov cx, 0x0FFF      ; Small delay
delay_progress:
    nop
    loop delay_progress
    pop cx
    loop progress_loop
    
    ; Close loading bar
    mov al, ']'
    mov bl, COLOR_PUTIH
    call print_colored_char
    
    popa
    ret

; Play gamelan welcome sequence
play_gamelan_welcome:
    pusha
    
    ; Play traditional Indonesian gamelan-inspired sequence
    ; Using PC speaker to simulate gamelan sounds
    
    ; Gong sound (low frequency)
    mov ax, 200         ; Low frequency
    call play_tone
    
    ; Kendang rhythm
    mov cx, 3
kendang_loop:
    mov ax, 400
    call play_tone_short
    mov ax, 300
    call play_tone_short
    loop kendang_loop
    
    ; Saron melody
    mov ax, 600
    call play_tone
    mov ax, 700
    call play_tone
    mov ax, 800
    call play_tone
    
    popa
    ret

; Play tone using PC speaker
play_tone:
    pusha
    
    ; Configure timer
    mov al, 0xB6
    out 0x43, al
    
    ; Set frequency
    out 0x42, al
    mov al, ah
    out 0x42, al
    
    ; Turn on speaker
    in al, 0x61
    or al, 3
    out 0x61, al
    
    ; Delay
    mov cx, 0x4000
tone_delay:
    nop
    loop tone_delay
    
    ; Turn off speaker
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
    popa
    ret

; Play short tone
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
    
    mov cx, 0x1000      ; Shorter delay
short_delay:
    nop
    loop short_delay
    
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
    popa
    ret

; Play loading sound
play_loading_sound:
    pusha
    
    ; Quick beep for loading progress
    mov ax, 1000
    call play_tone_short
    
    popa
    ret

; Initialize cultural system
init_cultural_system:
    pusha
    
    ; Display cultural initialization message
    mov ah, 0x02
    mov dh, 23
    mov dl, 5
    int 0x10
    
    mov si, msg_cultural
    mov bl, COLOR_BIRU
    call print_colored_string
    
    ; Initialize cultural data structures
    call init_cultural_data
    
    ; Setup cultural hardware
    call setup_cultural_hardware
    
    popa
    ret

; Load stage 2 bootloader
load_stage2:
    pusha
    
    ; Display stage 2 loading message
    mov si, msg_stage2
    call print_string
    
    ; Load stage 2 from disk
    mov ah, 0x02        ; Read sectors
    mov al, 8           ; Number of sectors
    mov ch, 0           ; Cylinder
    mov cl, 2           ; Sector (after boot sector)
    mov dh, 0           ; Head
    mov dl, 0x80        ; Drive
    mov bx, STAGE2_LOAD ; Buffer
    int 0x13
    
    jc stage2_error
    
    ; Jump to stage 2
    jmp STAGE2_LOAD
    
stage2_error:
    mov si, msg_error
    call print_string
    jmp halt
    
    popa
    ret

; Load kernel from disk
load_kernel:
    pusha
    
    ; Display kernel loading message
    mov si, msg_kernel
    call print_string
    
    ; Load kernel sectors
    mov ah, 0x02        ; Read sectors
    mov al, 64          ; Number of sectors (32KB kernel)
    mov ch, 0           ; Cylinder
    mov cl, 10          ; Sector (after boot and stage2)
    mov dh, 0           ; Head
    mov dl, 0x80        ; Drive
    mov bx, KERNEL_LOAD ; Buffer
    int 0x13
    
    jc kernel_error
    
    ; Verify kernel signature
    mov si, KERNEL_LOAD
    cmp dword [si], 0x4B484154  ; 'KHAT' signature
    jne kernel_error
    
    ; Display success message
    mov si, msg_success
    call print_string
    
    ; Final gamelan flourish
    call play_success_gamelan
    
    jmp kernel_loaded
    
kernel_error:
    mov si, msg_error
    call print_string
    jmp halt
    
kernel_loaded:
    popa
    ret

; Play success gamelan sequence
play_success_gamelan:
    pusha
    
    ; Play triumphant gamelan sequence
    mov cx, 5
    mov dx, 600         ; Base frequency
    
success_loop:
    push cx
    
    mov ax, dx
    call play_tone
    
    add dx, 100         ; Increase frequency
    
    pop cx
    loop success_loop
    
    ; Final gong
    mov ax, 150
    call play_tone
    
    popa
    ret

; Print colored string
print_colored_string:
    pusha
    
print_color_loop:
    lodsb
    test al, al
    jz print_color_done
    
    call print_colored_char
    jmp print_color_loop
    
print_color_done:
    popa
    ret

; Print colored character
print_colored_char:
    pusha
    
    mov ah, 0x0E        ; Teletype output
    mov bh, 0x00        ; Page number
    int 0x10
    
    popa
    ret

; Print string (simple)
print_string:
    pusha
    
print_loop:
    lodsb
    test al, al
    jz print_done
    
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    jmp print_loop
    
print_done:
    popa
    ret

; Initialize cultural data
init_cultural_data:
    ; Placeholder for cultural data initialization
    ret

; Setup cultural hardware
setup_cultural_hardware:
    ; Placeholder for cultural hardware setup
    ret

; Halt system
halt:
    cli
    hlt
    jmp halt

; Boot sector signature
times 510-($-$$) db 0
dw 0xAA55
