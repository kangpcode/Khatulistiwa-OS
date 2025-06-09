; ============================================================================
; khatboot.asm - KhatBoot Bootloader dengan Tema Budaya Indonesia
; Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
; ============================================================================
; 
; Bootloader dengan fitur:
; 1. Cultural splash screen dengan Garuda
; 2. Traditional Indonesian boot messages
; 3. Batik pattern loading animation
; 4. Gamelan boot sounds
; 5. Multi-language support (Indonesian/English)

[BITS 16]
[ORG 0x7C00]

; Boot sector constants
STACK_BASE      equ 0x7000
KERNEL_LOAD     equ 0x1000
CULTURAL_DATA   equ 0x8000
VIDEO_MODE      equ 0x13        ; 320x200 256 colors

; Cultural colors (VGA palette)
COLOR_MERAH     equ 0x04        ; Red
COLOR_PUTIH     equ 0x0F        ; White
COLOR_EMAS      equ 0x0E        ; Yellow/Gold
COLOR_HIJAU     equ 0x02        ; Green
COLOR_BIRU      equ 0x01        ; Blue

; Boot messages in Indonesian
msg_boot_start  db 'KhatBoot - Bootloader Khatulistiwa OS', 0x0D, 0x0A, 0
msg_loading     db 'Memuat sistem...', 0x0D, 0x0A, 0
msg_cultural    db 'Menginisialisasi budaya Indonesia...', 0x0D, 0x0A, 0
msg_kernel      db 'Memuat kernel Khatulistiwa...', 0x0D, 0x0A, 0
msg_success     db 'Selamat datang di Khatulistiwa OS!', 0x0D, 0x0A, 0
msg_error       db 'Kesalahan: Gagal memuat sistem', 0x0D, 0x0A, 0

; Cultural ASCII art - Simplified Garuda
garuda_art:
    db '        ___', 0x0D, 0x0A
    db '       /   \', 0x0D, 0x0A  
    db '      | ^ ^ |', 0x0D, 0x0A
    db '       \\_-_/', 0x0D, 0x0A
    db '     ___| |___', 0x0D, 0x0A
    db '    /         \', 0x0D, 0x0A
    db '   |  GARUDA   |', 0x0D, 0x0A
    db '    \_________/', 0x0D, 0x0A
    db '      |     |', 0x0D, 0x0A
    db '     /|     |\', 0x0D, 0x0A, 0

; Boot entry point
start:
    ; Setup segments
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, STACK_BASE
    sti
    
    ; Clear screen
    call clear_screen
    
    ; Display cultural boot screen
    call display_cultural_splash
    
    ; Initialize cultural subsystem
    call init_cultural_system
    
    ; Load kernel
    call load_kernel
    
    ; Jump to kernel
    jmp KERNEL_LOAD

; Clear screen with cultural background
clear_screen:
    pusha
    
    ; Set video mode
    mov ah, 0x00
    mov al, VIDEO_MODE
    int 0x10
    
    ; Fill screen with cultural pattern
    call draw_batik_background
    
    popa
    ret

; Display cultural splash screen
display_cultural_splash:
    pusha
    
    ; Set cursor position for title
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 2       ; Row
    mov dl, 20      ; Column
    int 0x10
    
    ; Display title with cultural colors
    mov si, msg_boot_start
    mov bl, COLOR_EMAS
    call print_colored_string
    
    ; Display Garuda ASCII art
    mov ah, 0x02
    mov dh, 5
    mov dl, 25
    int 0x10
    
    mov si, garuda_art
    mov bl, COLOR_MERAH
    call print_colored_string
    
    ; Display loading message
    mov ah, 0x02
    mov dh, 18
    mov dl, 25
    int 0x10
    
    mov si, msg_loading
    mov bl, COLOR_HIJAU
    call print_colored_string
    
    ; Animate loading with batik pattern
    call animate_batik_loading
    
    popa
    ret

; Draw batik background pattern
draw_batik_background:
    pusha
    
    ; Simple batik-inspired pattern using VGA mode
    mov ax, 0xA000      ; VGA memory segment
    mov es, ax
    xor di, di          ; Start at beginning of video memory
    
    mov cx, 64000       ; 320x200 pixels
    mov al, 0x08        ; Dark gray base color
    
draw_bg_loop:
    stosb               ; Store pixel
    
    ; Create simple pattern
    test di, 0x0F       ; Every 16 pixels
    jnz skip_pattern
    mov al, 0x06        ; Brown accent
    stosb
    mov al, 0x08        ; Back to base
    jmp continue_bg
    
skip_pattern:
    test di, 0x1F       ; Every 32 pixels  
    jnz continue_bg
    mov al, 0x0E        ; Yellow accent
    stosb
    mov al, 0x08        ; Back to base
    
continue_bg:
    loop draw_bg_loop
    
    popa
    ret

; Animate batik loading pattern
animate_batik_loading:
    pusha
    
    mov cx, 10          ; 10 animation frames
    
animate_loop:
    push cx
    
    ; Draw loading bar with batik pattern
    call draw_loading_bar
    
    ; Delay
    mov cx, 0xFFFF
delay_loop:
    nop
    loop delay_loop
    
    pop cx
    loop animate_loop
    
    popa
    ret

; Draw loading bar with cultural pattern
draw_loading_bar:
    pusha
    
    ; Position for loading bar
    mov ah, 0x02
    mov dh, 20          ; Row
    mov dl, 15          ; Column
    int 0x10
    
    ; Draw loading bar frame
    mov al, '['
    mov bl, COLOR_PUTIH
    call print_colored_char
    
    ; Draw progress with batik pattern
    mov cx, 30          ; Bar width
    mov al, '='
    mov bl, COLOR_EMAS
    
progress_loop:
    call print_colored_char
    push cx
    mov cx, 0x1FFF      ; Small delay
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

; Initialize cultural system
init_cultural_system:
    pusha
    
    ; Display cultural initialization message
    mov ah, 0x02
    mov dh, 22
    mov dl, 10
    int 0x10
    
    mov si, msg_cultural
    mov bl, COLOR_BIRU
    call print_colored_string
    
    ; Load cultural data
    call load_cultural_data
    
    ; Initialize gamelan sound system (placeholder)
    call init_gamelan_system
    
    popa
    ret

; Load cultural data
load_cultural_data:
    pusha
    
    ; Read cultural data from disk
    mov ah, 0x02        ; Read sectors
    mov al, 4           ; Number of sectors
    mov ch, 0           ; Cylinder
    mov cl, 3           ; Sector (after boot sector and kernel)
    mov dh, 0           ; Head
    mov dl, 0x80        ; Drive
    mov bx, CULTURAL_DATA ; Buffer
    int 0x13
    
    jc cultural_load_error
    
    ; Verify cultural data signature
    mov si, CULTURAL_DATA
    cmp word [si], 0x4B48   ; 'KH' signature
    jne cultural_load_error
    
    jmp cultural_load_success
    
cultural_load_error:
    ; Display error but continue
    mov si, msg_error
    mov bl, COLOR_MERAH
    call print_colored_string
    
cultural_load_success:
    popa
    ret

; Initialize gamelan sound system
init_gamelan_system:
    pusha
    
    ; Initialize PC speaker for basic gamelan sounds
    ; Play a simple welcome tone
    mov al, 0xB6        ; Configure timer
    out 0x43, al
    
    ; Play Gamelan-inspired tone sequence
    mov cx, 3           ; 3 tones
    
gamelan_loop:
    push cx
    
    ; Calculate frequency (simplified gamelan scale)
    mov ax, cx
    shl ax, 8           ; Multiply by 256
    add ax, 1000        ; Base frequency
    
    ; Set frequency
    out 0x42, al
    mov al, ah
    out 0x42, al
    
    ; Turn on speaker
    in al, 0x61
    or al, 3
    out 0x61, al
    
    ; Delay
    mov dx, 0x1000
gamelan_delay:
    dec dx
    jnz gamelan_delay
    
    ; Turn off speaker
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
    ; Short pause between tones
    mov dx, 0x800
gamelan_pause:
    dec dx
    jnz gamelan_pause
    
    pop cx
    loop gamelan_loop
    
    popa
    ret

; Load kernel from disk
load_kernel:
    pusha
    
    ; Display kernel loading message
    mov ah, 0x02
    mov dh, 23
    mov dl, 10
    int 0x10
    
    mov si, msg_kernel
    mov bl, COLOR_HIJAU
    call print_colored_string
    
    ; Load kernel sectors
    mov ah, 0x02        ; Read sectors
    mov al, 32          ; Number of sectors (16KB kernel)
    mov ch, 0           ; Cylinder
    mov cl, 2           ; Sector (after boot sector)
    mov dh, 0           ; Head
    mov dl, 0x80        ; Drive
    mov bx, KERNEL_LOAD ; Buffer
    int 0x13
    
    jc kernel_load_error
    
    ; Verify kernel signature
    mov si, KERNEL_LOAD
    cmp dword [si], 0x4B484154  ; 'KHAT' signature
    jne kernel_load_error
    
    ; Display success message
    mov ah, 0x02
    mov dh, 24
    mov dl, 15
    int 0x10
    
    mov si, msg_success
    mov bl, COLOR_EMAS
    call print_colored_string
    
    ; Final gamelan flourish
    call play_success_gamelan
    
    jmp kernel_load_done
    
kernel_load_error:
    ; Display error and halt
    mov si, msg_error
    mov bl, COLOR_MERAH
    call print_colored_string
    
    ; Halt system
    cli
    hlt
    
kernel_load_done:
    popa
    ret

; Play success gamelan sequence
play_success_gamelan:
    pusha
    
    ; Play ascending gamelan-inspired sequence
    mov cx, 5
    mov dx, 800         ; Base frequency
    
success_gamelan_loop:
    push cx
    
    ; Configure timer
    mov al, 0xB6
    out 0x43, al
    
    ; Set frequency
    mov ax, dx
    out 0x42, al
    mov al, ah
    out 0x42, al
    
    ; Turn on speaker
    in al, 0x61
    or al, 3
    out 0x61, al
    
    ; Delay
    push dx
    mov dx, 0x2000
success_delay:
    dec dx
    jnz success_delay
    pop dx
    
    ; Turn off speaker
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
    ; Increase frequency for next note
    add dx, 200
    
    pop cx
    loop success_gamelan_loop
    
    popa
    ret

; Print colored string
print_colored_string:
    pusha
    
print_loop:
    lodsb               ; Load character
    test al, al         ; Check for null terminator
    jz print_done
    
    call print_colored_char
    jmp print_loop
    
print_done:
    popa
    ret

; Print colored character
print_colored_char:
    pusha
    
    mov ah, 0x0E        ; Teletype output
    mov bh, 0x00        ; Page number
    ; bl already contains color
    int 0x10
    
    popa
    ret

; Boot sector signature
times 510-($-$$) db 0
dw 0xAA55
