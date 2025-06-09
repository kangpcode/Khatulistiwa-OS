/*
 * ============================================================================
 * cultural_splash.c - Cultural Splash Screen untuk Khatulistiwa OS
 * Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
 * ============================================================================
 * 
 * Advanced splash screen dengan fitur:
 * 1. High-resolution cultural graphics
 * 2. Animated Garuda dengan sayap bergerak
 * 3. Dynamic batik patterns
 * 4. Gamelan audio synchronization
 * 5. Multi-language boot messages
 * 6. Progress bar dengan ornamen Indonesia
 */

#include <stdint.h>
#include <stdbool.h>
#include <string.h>

// Splash screen constants
#define SPLASH_WIDTH        1024
#define SPLASH_HEIGHT       768
#define SPLASH_BPP          32
#define ANIMATION_FRAMES    60
#define BATIK_PATTERNS      8
#define GAMELAN_NOTES       12

// Indonesian flag colors
#define COLOR_MERAH         0xFFFF0000
#define COLOR_PUTIH         0xFFFFFFFF
#define COLOR_EMAS          0xFFFFD700
#define COLOR_HIJAU         0xFF00FF00
#define COLOR_BIRU          0xFF0000FF
#define COLOR_COKLAT        0xFF8B4513
#define COLOR_HITAM         0xFF000000

// Cultural themes
typedef enum {
    THEME_PARANG = 0,
    THEME_KAWUNG,
    THEME_MEGA_MENDUNG,
    THEME_CEPLOK,
    THEME_NITIK,
    THEME_TRUNTUM,
    THEME_SOGAN,
    THEME_SEKAR_JAGAD
} cultural_theme_t;

// Splash screen state
typedef struct {
    uint32_t *framebuffer;
    uint32_t width;
    uint32_t height;
    uint32_t current_frame;
    cultural_theme_t current_theme;
    bool animation_enabled;
    bool audio_enabled;
    float progress;
    char status_message[256];
    char cultural_message[256];
} splash_state_t;

// Garuda animation state
typedef struct {
    float x, y;
    float wing_angle;
    float scale;
    float rotation;
    uint32_t color;
    bool flying;
} garuda_state_t;

// Batik pattern data
typedef struct {
    uint32_t pattern_id;
    uint32_t colors[4];
    uint8_t pattern_data[64][64];
    float animation_phase;
} batik_pattern_t;

// Gamelan note structure
typedef struct {
    uint16_t frequency;
    uint16_t duration;
    uint8_t instrument;
    float volume;
} gamelan_note_t;

// Global splash state
static splash_state_t g_splash;
static garuda_state_t g_garuda;
static batik_pattern_t g_batik_patterns[BATIK_PATTERNS];
static gamelan_note_t g_gamelan_sequence[GAMELAN_NOTES];

// Cultural messages in multiple languages
static const char* boot_messages_id[] = {
    "Selamat datang di Khatulistiwa OS",
    "Sistem Operasi Indonesia",
    "Memuat komponen sistem...",
    "Menginisialisasi budaya Nusantara...",
    "Mengaktifkan driver perangkat...",
    "Mempersiapkan antarmuka pengguna...",
    "Sistem siap digunakan!"
};

static const char* boot_messages_en[] = {
    "Welcome to Khatulistiwa OS",
    "Indonesian Operating System",
    "Loading system components...",
    "Initializing Indonesian culture...",
    "Activating device drivers...",
    "Preparing user interface...",
    "System ready!"
};

static const char* cultural_quotes[] = {
    "Bhinneka Tunggal Ika - Unity in Diversity",
    "Gotong Royong - Working Together",
    "Teknologi Modern, Jiwa Indonesia",
    "Garuda Pancasila melindungi sistem",
    "Budaya Nusantara dalam era digital"
};

// Function prototypes
int splash_init(uint32_t *framebuffer, uint32_t width, uint32_t height);
void splash_update(float progress, const char* message);
void splash_render_frame(void);
void splash_cleanup(void);

// Garuda animation functions
void garuda_init(void);
void garuda_update(float delta_time);
void garuda_render(uint32_t *fb, uint32_t width, uint32_t height);

// Batik pattern functions
void batik_init_patterns(void);
void batik_update_animation(float delta_time);
void batik_render_background(uint32_t *fb, uint32_t width, uint32_t height);

// Gamelan audio functions
void gamelan_init_sequence(void);
void gamelan_play_welcome(void);
void gamelan_play_progress_note(float progress);

// Graphics helper functions
void draw_pixel(uint32_t *fb, int x, int y, uint32_t color, uint32_t width);
void draw_line(uint32_t *fb, int x1, int y1, int x2, int y2, uint32_t color, uint32_t width, uint32_t height);
void draw_circle(uint32_t *fb, int cx, int cy, int radius, uint32_t color, uint32_t width, uint32_t height);
void draw_filled_rect(uint32_t *fb, int x, int y, int w, int h, uint32_t color, uint32_t width, uint32_t height);
void draw_text(uint32_t *fb, int x, int y, const char* text, uint32_t color, uint32_t width, uint32_t height);

// Initialize splash screen
int splash_init(uint32_t *framebuffer, uint32_t width, uint32_t height) {
    if (!framebuffer || width == 0 || height == 0) {
        return -1;
    }
    
    // Initialize splash state
    g_splash.framebuffer = framebuffer;
    g_splash.width = width;
    g_splash.height = height;
    g_splash.current_frame = 0;
    g_splash.current_theme = THEME_PARANG;
    g_splash.animation_enabled = true;
    g_splash.audio_enabled = true;
    g_splash.progress = 0.0f;
    strcpy(g_splash.status_message, boot_messages_id[0]);
    strcpy(g_splash.cultural_message, cultural_quotes[0]);
    
    // Initialize cultural components
    garuda_init();
    batik_init_patterns();
    gamelan_init_sequence();
    
    // Clear framebuffer with Indonesian flag gradient
    for (uint32_t y = 0; y < height; y++) {
        for (uint32_t x = 0; x < width; x++) {
            uint32_t color;
            if (y < height / 2) {
                // Red portion (top half)
                color = COLOR_MERAH;
            } else {
                // White portion (bottom half)
                color = COLOR_PUTIH;
            }
            draw_pixel(framebuffer, x, y, color, width);
        }
    }
    
    // Play welcome gamelan
    if (g_splash.audio_enabled) {
        gamelan_play_welcome();
    }
    
    return 0;
}

// Update splash screen
void splash_update(float progress, const char* message) {
    g_splash.progress = progress;
    
    if (message) {
        strncpy(g_splash.status_message, message, sizeof(g_splash.status_message) - 1);
        g_splash.status_message[sizeof(g_splash.status_message) - 1] = '\0';
    }
    
    // Update cultural quote based on progress
    int quote_index = (int)(progress * (sizeof(cultural_quotes) / sizeof(cultural_quotes[0])));
    if (quote_index >= sizeof(cultural_quotes) / sizeof(cultural_quotes[0])) {
        quote_index = sizeof(cultural_quotes) / sizeof(cultural_quotes[0]) - 1;
    }
    strcpy(g_splash.cultural_message, cultural_quotes[quote_index]);
    
    // Update animations
    float delta_time = 1.0f / 60.0f; // Assume 60 FPS
    
    if (g_splash.animation_enabled) {
        garuda_update(delta_time);
        batik_update_animation(delta_time);
    }
    
    // Play progress audio
    if (g_splash.audio_enabled) {
        gamelan_play_progress_note(progress);
    }
    
    g_splash.current_frame++;
}

// Render splash screen frame
void splash_render_frame(void) {
    uint32_t *fb = g_splash.framebuffer;
    uint32_t width = g_splash.width;
    uint32_t height = g_splash.height;
    
    // Render batik background
    batik_render_background(fb, width, height);
    
    // Render Garuda
    garuda_render(fb, width, height);
    
    // Render title
    draw_text(fb, width/2 - 200, 100, "KHATULISTIWA OS", COLOR_EMAS, width, height);
    draw_text(fb, width/2 - 150, 140, "Sistem Operasi Indonesia", COLOR_PUTIH, width, height);
    
    // Render cultural message
    draw_text(fb, width/2 - 200, height - 200, g_splash.cultural_message, COLOR_HIJAU, width, height);
    
    // Render status message
    draw_text(fb, width/2 - 150, height - 160, g_splash.status_message, COLOR_PUTIH, width, height);
    
    // Render progress bar with batik ornaments
    render_cultural_progress_bar(fb, width, height);
    
    // Render Indonesian ornaments
    render_indonesian_ornaments(fb, width, height);
}

// Render cultural progress bar
void render_cultural_progress_bar(uint32_t *fb, uint32_t width, uint32_t height) {
    int bar_width = 400;
    int bar_height = 20;
    int bar_x = (width - bar_width) / 2;
    int bar_y = height - 100;
    
    // Draw progress bar background with batik pattern
    draw_filled_rect(fb, bar_x - 5, bar_y - 5, bar_width + 10, bar_height + 10, COLOR_COKLAT, width, height);
    draw_filled_rect(fb, bar_x, bar_y, bar_width, bar_height, COLOR_HITAM, width, height);
    
    // Draw progress with gradient
    int progress_width = (int)(bar_width * g_splash.progress);
    for (int x = 0; x < progress_width; x++) {
        uint32_t color = COLOR_EMAS;
        // Add batik pattern to progress bar
        if ((x + g_splash.current_frame / 4) % 8 < 4) {
            color = COLOR_MERAH;
        }
        draw_filled_rect(fb, bar_x + x, bar_y, 1, bar_height, color, width, height);
    }
    
    // Draw ornamental borders
    for (int i = 0; i < bar_width; i += 20) {
        draw_circle(fb, bar_x + i, bar_y - 10, 3, COLOR_EMAS, width, height);
        draw_circle(fb, bar_x + i, bar_y + bar_height + 10, 3, COLOR_EMAS, width, height);
    }
    
    // Draw progress percentage
    char progress_text[32];
    sprintf(progress_text, "%.0f%%", g_splash.progress * 100);
    draw_text(fb, bar_x + bar_width + 20, bar_y + 5, progress_text, COLOR_PUTIH, width, height);
}

// Render Indonesian ornaments
void render_indonesian_ornaments(uint32_t *fb, uint32_t width, uint32_t height) {
    // Draw corner ornaments inspired by traditional Indonesian art
    
    // Top-left ornament
    for (int i = 0; i < 50; i++) {
        float angle = (float)i / 50.0f * 3.14159f / 2;
        int x = (int)(50 * cos(angle));
        int y = (int)(50 * sin(angle));
        draw_circle(fb, 50 + x, 50 + y, 2, COLOR_EMAS, width, height);
    }
    
    // Top-right ornament
    for (int i = 0; i < 50; i++) {
        float angle = 3.14159f / 2 + (float)i / 50.0f * 3.14159f / 2;
        int x = (int)(50 * cos(angle));
        int y = (int)(50 * sin(angle));
        draw_circle(fb, width - 50 + x, 50 + y, 2, COLOR_EMAS, width, height);
    }
    
    // Bottom ornaments with batik pattern
    for (int x = 100; x < width - 100; x += 30) {
        int y = height - 50;
        uint32_t color = ((x / 30) % 2) ? COLOR_MERAH : COLOR_EMAS;
        draw_circle(fb, x, y, 5, color, width, height);
        
        // Add traditional pattern
        draw_line(fb, x - 10, y, x + 10, y, color, width, height);
        draw_line(fb, x, y - 10, x, y + 10, color, width, height);
    }
}

// Initialize Garuda animation
void garuda_init(void) {
    g_garuda.x = g_splash.width / 2.0f;
    g_garuda.y = g_splash.height / 2.0f - 50;
    g_garuda.wing_angle = 0.0f;
    g_garuda.scale = 1.0f;
    g_garuda.rotation = 0.0f;
    g_garuda.color = COLOR_EMAS;
    g_garuda.flying = true;
}

// Update Garuda animation
void garuda_update(float delta_time) {
    // Animate wing flapping
    g_garuda.wing_angle += delta_time * 5.0f; // 5 rad/sec
    
    // Gentle floating motion
    g_garuda.y += sin(g_garuda.wing_angle * 0.5f) * 0.5f;
    
    // Slight rotation for dynamic effect
    g_garuda.rotation = sin(g_garuda.wing_angle * 0.3f) * 0.1f;
    
    // Scale pulsing
    g_garuda.scale = 1.0f + sin(g_garuda.wing_angle * 0.8f) * 0.05f;
}

// Render Garuda
void garuda_render(uint32_t *fb, uint32_t width, uint32_t height) {
    int cx = (int)g_garuda.x;
    int cy = (int)g_garuda.y;
    int size = (int)(60 * g_garuda.scale);
    
    // Draw Garuda body
    draw_filled_rect(fb, cx - size/4, cy - size/2, size/2, size, g_garuda.color, width, height);
    
    // Draw Garuda head
    draw_circle(fb, cx, cy - size/2 - 10, size/4, g_garuda.color, width, height);
    
    // Draw animated wings
    float wing_offset = sin(g_garuda.wing_angle) * 20;
    
    // Left wing
    for (int i = 0; i < size/2; i++) {
        int wing_x = cx - size/2 - i;
        int wing_y = cy + (int)(wing_offset * sin((float)i / size * 3.14159f));
        draw_circle(fb, wing_x, wing_y, 3, g_garuda.color, width, height);
    }
    
    // Right wing
    for (int i = 0; i < size/2; i++) {
        int wing_x = cx + size/2 + i;
        int wing_y = cy + (int)(wing_offset * sin((float)i / size * 3.14159f));
        draw_circle(fb, wing_x, wing_y, 3, g_garuda.color, width, height);
    }
    
    // Draw tail feathers
    for (int i = 0; i < 5; i++) {
        int tail_x = cx + (i - 2) * 5;
        int tail_y = cy + size/2 + 10 + i * 3;
        draw_line(fb, tail_x, tail_y, tail_x, tail_y + 15, g_garuda.color, width, height);
    }
}

// Initialize batik patterns
void batik_init_patterns(void) {
    for (int i = 0; i < BATIK_PATTERNS; i++) {
        g_batik_patterns[i].pattern_id = i;
        g_batik_patterns[i].animation_phase = 0.0f;
        
        // Set colors based on pattern type
        switch (i) {
            case THEME_PARANG:
                g_batik_patterns[i].colors[0] = COLOR_COKLAT;
                g_batik_patterns[i].colors[1] = COLOR_EMAS;
                g_batik_patterns[i].colors[2] = COLOR_MERAH;
                g_batik_patterns[i].colors[3] = COLOR_PUTIH;
                break;
            case THEME_KAWUNG:
                g_batik_patterns[i].colors[0] = COLOR_HIJAU;
                g_batik_patterns[i].colors[1] = COLOR_PUTIH;
                g_batik_patterns[i].colors[2] = COLOR_COKLAT;
                g_batik_patterns[i].colors[3] = COLOR_EMAS;
                break;
            // Add more patterns...
            default:
                g_batik_patterns[i].colors[0] = COLOR_COKLAT;
                g_batik_patterns[i].colors[1] = COLOR_EMAS;
                g_batik_patterns[i].colors[2] = COLOR_MERAH;
                g_batik_patterns[i].colors[3] = COLOR_PUTIH;
                break;
        }
        
        // Generate pattern data
        generate_batik_pattern_data(&g_batik_patterns[i]);
    }
}

// Generate batik pattern data
void generate_batik_pattern_data(batik_pattern_t *pattern) {
    for (int y = 0; y < 64; y++) {
        for (int x = 0; x < 64; x++) {
            // Generate pattern based on type
            switch (pattern->pattern_id) {
                case THEME_PARANG:
                    // Diagonal stripes pattern
                    pattern->pattern_data[y][x] = ((x + y) / 8) % 4;
                    break;
                case THEME_KAWUNG:
                    // Circular pattern
                    int dx = x - 32;
                    int dy = y - 32;
                    int dist = (int)sqrt(dx*dx + dy*dy);
                    pattern->pattern_data[y][x] = (dist / 8) % 4;
                    break;
                default:
                    pattern->pattern_data[y][x] = (x + y) % 4;
                    break;
            }
        }
    }
}

// Update batik animation
void batik_update_animation(float delta_time) {
    for (int i = 0; i < BATIK_PATTERNS; i++) {
        g_batik_patterns[i].animation_phase += delta_time * 0.5f;
        if (g_batik_patterns[i].animation_phase > 6.28318f) {
            g_batik_patterns[i].animation_phase -= 6.28318f;
        }
    }
}

// Render batik background
void batik_render_background(uint32_t *fb, uint32_t width, uint32_t height) {
    batik_pattern_t *pattern = &g_batik_patterns[g_splash.current_theme];
    
    // Render tiled batik pattern
    for (uint32_t y = 0; y < height; y += 64) {
        for (uint32_t x = 0; x < width; x += 64) {
            render_batik_tile(fb, x, y, pattern, width, height);
        }
    }
}

// Render single batik tile
void render_batik_tile(uint32_t *fb, uint32_t tile_x, uint32_t tile_y, 
                      batik_pattern_t *pattern, uint32_t width, uint32_t height) {
    for (int y = 0; y < 64 && tile_y + y < height; y++) {
        for (int x = 0; x < 64 && tile_x + x < width; x++) {
            uint8_t color_index = pattern->pattern_data[y][x];
            
            // Add animation effect
            color_index = (color_index + (int)(pattern->animation_phase * 4)) % 4;
            
            uint32_t color = pattern->colors[color_index];
            
            // Add transparency for overlay effect
            color = (color & 0x00FFFFFF) | 0x80000000;
            
            draw_pixel(fb, tile_x + x, tile_y + y, color, width);
        }
    }
}

// Initialize gamelan sequence
void gamelan_init_sequence(void) {
    // Traditional Indonesian gamelan welcome sequence
    g_gamelan_sequence[0] = (gamelan_note_t){220, 500, 0, 0.8f};  // Gong
    g_gamelan_sequence[1] = (gamelan_note_t){330, 250, 1, 0.6f};  // Saron
    g_gamelan_sequence[2] = (gamelan_note_t){440, 250, 1, 0.6f};  // Saron
    g_gamelan_sequence[3] = (gamelan_note_t){550, 500, 2, 0.7f};  // Bonang
    g_gamelan_sequence[4] = (gamelan_note_t){660, 250, 3, 0.5f};  // Suling
    g_gamelan_sequence[5] = (gamelan_note_t){440, 250, 1, 0.6f};  // Saron
    g_gamelan_sequence[6] = (gamelan_note_t){330, 500, 1, 0.6f};  // Saron
    g_gamelan_sequence[7] = (gamelan_note_t){220, 1000, 0, 0.8f}; // Gong
    // Add more notes...
}

// Play gamelan welcome
void gamelan_play_welcome(void) {
    // Play welcome sequence (implementation depends on audio hardware)
    for (int i = 0; i < 8; i++) {
        play_gamelan_note(&g_gamelan_sequence[i]);
    }
}

// Play progress note
void gamelan_play_progress_note(float progress) {
    // Play note based on progress
    int note_index = (int)(progress * 7);
    if (note_index < 8) {
        play_gamelan_note(&g_gamelan_sequence[note_index]);
    }
}

// Play single gamelan note (placeholder)
void play_gamelan_note(gamelan_note_t *note) {
    // Implementation depends on audio hardware
    // This would interface with the audio driver
}

// Graphics helper functions
void draw_pixel(uint32_t *fb, int x, int y, uint32_t color, uint32_t width) {
    if (x >= 0 && x < (int)width && y >= 0) {
        fb[y * width + x] = color;
    }
}

void draw_line(uint32_t *fb, int x1, int y1, int x2, int y2, uint32_t color, uint32_t width, uint32_t height) {
    // Bresenham's line algorithm
    int dx = abs(x2 - x1);
    int dy = abs(y2 - y1);
    int sx = (x1 < x2) ? 1 : -1;
    int sy = (y1 < y2) ? 1 : -1;
    int err = dx - dy;
    
    while (true) {
        draw_pixel(fb, x1, y1, color, width);
        
        if (x1 == x2 && y1 == y2) break;
        
        int e2 = 2 * err;
        if (e2 > -dy) {
            err -= dy;
            x1 += sx;
        }
        if (e2 < dx) {
            err += dx;
            y1 += sy;
        }
    }
}

void draw_circle(uint32_t *fb, int cx, int cy, int radius, uint32_t color, uint32_t width, uint32_t height) {
    // Midpoint circle algorithm
    int x = 0;
    int y = radius;
    int d = 1 - radius;
    
    while (x <= y) {
        draw_pixel(fb, cx + x, cy + y, color, width);
        draw_pixel(fb, cx - x, cy + y, color, width);
        draw_pixel(fb, cx + x, cy - y, color, width);
        draw_pixel(fb, cx - x, cy - y, color, width);
        draw_pixel(fb, cx + y, cy + x, color, width);
        draw_pixel(fb, cx - y, cy + x, color, width);
        draw_pixel(fb, cx + y, cy - x, color, width);
        draw_pixel(fb, cx - y, cy - x, color, width);
        
        if (d < 0) {
            d += 2 * x + 3;
        } else {
            d += 2 * (x - y) + 5;
            y--;
        }
        x++;
    }
}

void draw_filled_rect(uint32_t *fb, int x, int y, int w, int h, uint32_t color, uint32_t width, uint32_t height) {
    for (int j = y; j < y + h && j < (int)height; j++) {
        for (int i = x; i < x + w && i < (int)width; i++) {
            if (i >= 0 && j >= 0) {
                draw_pixel(fb, i, j, color, width);
            }
        }
    }
}

void draw_text(uint32_t *fb, int x, int y, const char* text, uint32_t color, uint32_t width, uint32_t height) {
    // Simple text rendering (would use a proper font in real implementation)
    int char_width = 8;
    int char_height = 16;
    
    for (int i = 0; text[i] != '\0'; i++) {
        // Draw simple character representation
        draw_filled_rect(fb, x + i * char_width, y, char_width - 1, char_height, color, width, height);
    }
}

// Cleanup splash screen
void splash_cleanup(void) {
    // Cleanup resources
    g_splash.framebuffer = NULL;
    g_splash.animation_enabled = false;
    g_splash.audio_enabled = false;
}
