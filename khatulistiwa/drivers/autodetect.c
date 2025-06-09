/*
 * ============================================================================
 * autodetect.c - Khatulistiwa OS Auto-Detect Driver System
 * Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
 * ============================================================================
 * 
 * Sistem auto-detect driver yang canggih:
 * - PCI device enumeration
 * - USB hotplug detection
 * - Hardware identification
 * - Driver loading otomatis
 * - Coldboot dan hotplug support
 */

#include "autodetect.h"
#include "pci.h"
#include "usb.h"
#include "kernel.h"

// Device database
typedef struct device_entry {
    uint16_t vendor_id;
    uint16_t device_id;
    uint16_t class_code;
    uint16_t subclass;
    const char* name;
    const char* driver_path;
    uint32_t flags;
} device_entry_t;

// Driver flags
#define DRIVER_KERNEL_MODE  0x001
#define DRIVER_USER_MODE    0x002
#define DRIVER_CRITICAL     0x004
#define DRIVER_OPTIONAL     0x008
#define DRIVER_HOTPLUG      0x010

// Device database - Hardware yang didukung
static device_entry_t device_database[] = {
    // Graphics Cards
    {0x10DE, 0x0000, 0x0300, 0x00, "NVIDIA Graphics", "/drivers/nvidia.khat", DRIVER_USER_MODE},
    {0x1002, 0x0000, 0x0300, 0x00, "AMD Graphics", "/drivers/amd.khat", DRIVER_USER_MODE},
    {0x8086, 0x0000, 0x0300, 0x00, "Intel Graphics", "/drivers/intel_gfx.khat", DRIVER_USER_MODE},
    
    // Network Cards
    {0x8086, 0x0000, 0x0200, 0x00, "Intel Ethernet", "/drivers/intel_net.khat", DRIVER_KERNEL_MODE},
    {0x10EC, 0x8139, 0x0200, 0x00, "Realtek RTL8139", "/drivers/rtl8139.khat", DRIVER_KERNEL_MODE},
    {0x10EC, 0x8168, 0x0200, 0x00, "Realtek RTL8168", "/drivers/rtl8168.khat", DRIVER_KERNEL_MODE},
    
    // Audio Devices
    {0x8086, 0x0000, 0x0403, 0x00, "Intel HD Audio", "/drivers/hda.khat", DRIVER_USER_MODE},
    {0x1102, 0x0000, 0x0401, 0x00, "Creative Sound", "/drivers/creative.khat", DRIVER_USER_MODE},
    
    // Storage Controllers
    {0x8086, 0x0000, 0x0101, 0x00, "Intel SATA", "/drivers/ahci.khat", DRIVER_KERNEL_MODE | DRIVER_CRITICAL},
    {0x1095, 0x0000, 0x0101, 0x00, "Silicon Image SATA", "/drivers/sii.khat", DRIVER_KERNEL_MODE},
    
    // USB Controllers
    {0x8086, 0x0000, 0x0C03, 0x00, "Intel USB", "/drivers/ehci.khat", DRIVER_KERNEL_MODE | DRIVER_HOTPLUG},
    {0x1106, 0x0000, 0x0C03, 0x00, "VIA USB", "/drivers/uhci.khat", DRIVER_KERNEL_MODE | DRIVER_HOTPLUG},
    
    // Input Devices
    {0x0000, 0x0000, 0x0900, 0x00, "PS/2 Keyboard", "/drivers/ps2_kbd.khat", DRIVER_KERNEL_MODE},
    {0x0000, 0x0000, 0x0900, 0x01, "PS/2 Mouse", "/drivers/ps2_mouse.khat", DRIVER_KERNEL_MODE},
    
    // End marker
    {0x0000, 0x0000, 0x0000, 0x00, NULL, NULL, 0}
};

// Detected devices list
static detected_device_t detected_devices[MAX_DEVICES];
static int device_count = 0;
static spinlock_t autodetect_lock;

// Initialize auto-detect system
int autodetect_init(void) {
    kernel_log(LOG_INFO, "Initializing auto-detect driver system...");
    
    spinlock_init(&autodetect_lock);
    device_count = 0;
    
    // Initialize PCI subsystem
    if (pci_init() != 0) {
        kernel_log(LOG_ERROR, "Failed to initialize PCI subsystem");
        return -1;
    }
    
    // Initialize USB subsystem
    if (usb_init() != 0) {
        kernel_log(LOG_WARNING, "Failed to initialize USB subsystem");
        // Continue without USB
    }
    
    // Perform coldboot detection
    if (coldboot_detect() != 0) {
        kernel_log(LOG_ERROR, "Coldboot detection failed");
        return -1;
    }
    
    // Setup hotplug monitoring
    if (setup_hotplug_monitoring() != 0) {
        kernel_log(LOG_WARNING, "Failed to setup hotplug monitoring");
        // Continue without hotplug
    }
    
    kernel_log(LOG_INFO, "Auto-detect system initialized, found %d devices", device_count);
    return 0;
}

// Coldboot device detection
int coldboot_detect(void) {
    kernel_log(LOG_INFO, "Starting coldboot device detection...");
    
    // Scan PCI bus
    if (scan_pci_devices() != 0) {
        kernel_log(LOG_ERROR, "PCI scan failed");
        return -1;
    }
    
    // Scan legacy devices
    if (scan_legacy_devices() != 0) {
        kernel_log(LOG_WARNING, "Legacy device scan failed");
        // Continue anyway
    }
    
    // Load critical drivers first
    load_critical_drivers();
    
    // Load remaining drivers
    load_remaining_drivers();
    
    kernel_log(LOG_INFO, "Coldboot detection completed");
    return 0;
}

// Scan PCI devices
int scan_pci_devices(void) {
    kernel_log(LOG_INFO, "Scanning PCI bus...");
    
    for (int bus = 0; bus < 256; bus++) {
        for (int device = 0; device < 32; device++) {
            for (int function = 0; function < 8; function++) {
                pci_device_t pci_dev;
                
                if (pci_read_device(bus, device, function, &pci_dev) == 0) {
                    // Valid device found
                    if (pci_dev.vendor_id != 0xFFFF) {
                        process_pci_device(&pci_dev);
                    }
                    
                    // If not multi-function, skip other functions
                    if (function == 0 && !(pci_dev.header_type & 0x80)) {
                        break;
                    }
                }
            }
        }
    }
    
    return 0;
}

// Process discovered PCI device
void process_pci_device(pci_device_t* pci_dev) {
    if (device_count >= MAX_DEVICES) {
        kernel_log(LOG_WARNING, "Maximum device limit reached");
        return;
    }
    
    detected_device_t* device = &detected_devices[device_count];
    
    device->bus_type = BUS_TYPE_PCI;
    device->vendor_id = pci_dev->vendor_id;
    device->device_id = pci_dev->device_id;
    device->class_code = pci_dev->class_code;
    device->subclass = pci_dev->subclass;
    device->prog_if = pci_dev->prog_if;
    device->revision = pci_dev->revision;
    device->bus_number = pci_dev->bus;
    device->device_number = pci_dev->device;
    device->function_number = pci_dev->function;
    device->driver_loaded = false;
    device->driver_path[0] = '\0';
    
    // Find matching driver
    device_entry_t* entry = find_device_driver(device);
    if (entry) {
        strncpy(device->name, entry->name, sizeof(device->name) - 1);
        strncpy(device->driver_path, entry->driver_path, sizeof(device->driver_path) - 1);
        device->driver_flags = entry->flags;
        
        kernel_log(LOG_INFO, "Found device: %s (VID:0x%04X DID:0x%04X)",
                   device->name, device->vendor_id, device->device_id);
    } else {
        snprintf(device->name, sizeof(device->name), 
                "Unknown Device (VID:0x%04X DID:0x%04X)", 
                device->vendor_id, device->device_id);
        device->driver_flags = 0;
        
        kernel_log(LOG_WARNING, "Unknown device: VID:0x%04X DID:0x%04X Class:0x%04X",
                   device->vendor_id, device->device_id, device->class_code);
    }
    
    device_count++;
}

// Find driver for device
device_entry_t* find_device_driver(detected_device_t* device) {
    for (int i = 0; device_database[i].name != NULL; i++) {
        device_entry_t* entry = &device_database[i];
        
        // Exact match (vendor + device)
        if (entry->vendor_id == device->vendor_id && 
            entry->device_id == device->device_id) {
            return entry;
        }
        
        // Class match (vendor + class)
        if (entry->vendor_id == device->vendor_id && 
            entry->device_id == 0x0000 &&
            entry->class_code == device->class_code) {
            return entry;
        }
        
        // Generic class match
        if (entry->vendor_id == 0x0000 && 
            entry->device_id == 0x0000 &&
            entry->class_code == device->class_code &&
            entry->subclass == device->subclass) {
            return entry;
        }
    }
    
    return NULL;
}

// Load critical drivers first
void load_critical_drivers(void) {
    kernel_log(LOG_INFO, "Loading critical drivers...");
    
    for (int i = 0; i < device_count; i++) {
        detected_device_t* device = &detected_devices[i];
        
        if ((device->driver_flags & DRIVER_CRITICAL) && 
            device->driver_path[0] != '\0' && 
            !device->driver_loaded) {
            
            if (load_device_driver(device) == 0) {
                kernel_log(LOG_INFO, "Loaded critical driver: %s", device->name);
            } else {
                kernel_log(LOG_ERROR, "Failed to load critical driver: %s", device->name);
            }
        }
    }
}

// Load remaining drivers
void load_remaining_drivers(void) {
    kernel_log(LOG_INFO, "Loading remaining drivers...");
    
    for (int i = 0; i < device_count; i++) {
        detected_device_t* device = &detected_devices[i];
        
        if (!(device->driver_flags & DRIVER_CRITICAL) && 
            device->driver_path[0] != '\0' && 
            !device->driver_loaded) {
            
            if (load_device_driver(device) == 0) {
                kernel_log(LOG_INFO, "Loaded driver: %s", device->name);
            } else {
                kernel_log(LOG_WARNING, "Failed to load driver: %s", device->name);
            }
        }
    }
}

// Load individual device driver
int load_device_driver(detected_device_t* device) {
    if (device->driver_loaded) {
        return 0; // Already loaded
    }
    
    kernel_log(LOG_DEBUG, "Loading driver: %s", device->driver_path);
    
    // Check if driver file exists
    if (!file_exists(device->driver_path)) {
        kernel_log(LOG_WARNING, "Driver file not found: %s", device->driver_path);
        return -1;
    }
    
    // Load driver based on type
    if (device->driver_flags & DRIVER_KERNEL_MODE) {
        // Load as kernel module
        if (load_kernel_module(device->driver_path, device) != 0) {
            kernel_log(LOG_ERROR, "Failed to load kernel driver: %s", device->driver_path);
            return -1;
        }
    } else {
        // Load as user-mode driver
        if (load_user_driver(device->driver_path, device) != 0) {
            kernel_log(LOG_ERROR, "Failed to load user driver: %s", device->driver_path);
            return -1;
        }
    }
    
    device->driver_loaded = true;
    return 0;
}

// Setup hotplug monitoring
int setup_hotplug_monitoring(void) {
    kernel_log(LOG_INFO, "Setting up hotplug monitoring...");
    
    // Setup PCI hotplug
    if (pci_setup_hotplug(hotplug_callback) != 0) {
        kernel_log(LOG_WARNING, "Failed to setup PCI hotplug");
    }
    
    // Setup USB hotplug
    if (usb_setup_hotplug(hotplug_callback) != 0) {
        kernel_log(LOG_WARNING, "Failed to setup USB hotplug");
    }
    
    return 0;
}

// Hotplug callback
void hotplug_callback(hotplug_event_t* event) {
    spinlock_acquire(&autodetect_lock);
    
    if (event->type == HOTPLUG_DEVICE_ADDED) {
        kernel_log(LOG_INFO, "Device added: VID:0x%04X DID:0x%04X",
                   event->vendor_id, event->device_id);
        
        // Process new device
        detected_device_t device;
        device.vendor_id = event->vendor_id;
        device.device_id = event->device_id;
        device.class_code = event->class_code;
        device.subclass = event->subclass;
        device.driver_loaded = false;
        
        // Find and load driver
        device_entry_t* entry = find_device_driver(&device);
        if (entry && (entry->flags & DRIVER_HOTPLUG)) {
            strncpy(device.driver_path, entry->driver_path, sizeof(device.driver_path) - 1);
            device.driver_flags = entry->flags;
            
            if (load_device_driver(&device) == 0) {
                kernel_log(LOG_INFO, "Hotplug driver loaded: %s", entry->name);
            }
        }
        
    } else if (event->type == HOTPLUG_DEVICE_REMOVED) {
        kernel_log(LOG_INFO, "Device removed: VID:0x%04X DID:0x%04X",
                   event->vendor_id, event->device_id);
        
        // Unload driver if necessary
        unload_hotplug_driver(event);
    }
    
    spinlock_release(&autodetect_lock);
}

// Scan legacy devices (ISA, etc.)
int scan_legacy_devices(void) {
    kernel_log(LOG_INFO, "Scanning legacy devices...");
    
    // Check for PS/2 keyboard
    if (check_ps2_keyboard()) {
        add_legacy_device("PS/2 Keyboard", "/drivers/ps2_kbd.khat", DRIVER_KERNEL_MODE);
    }
    
    // Check for PS/2 mouse
    if (check_ps2_mouse()) {
        add_legacy_device("PS/2 Mouse", "/drivers/ps2_mouse.khat", DRIVER_KERNEL_MODE);
    }
    
    // Check for serial ports
    scan_serial_ports();
    
    // Check for parallel ports
    scan_parallel_ports();
    
    return 0;
}

// Get detected devices list
int autodetect_get_devices(detected_device_t* devices, int max_devices) {
    spinlock_acquire(&autodetect_lock);
    
    int count = (device_count < max_devices) ? device_count : max_devices;
    memcpy(devices, detected_devices, count * sizeof(detected_device_t));
    
    spinlock_release(&autodetect_lock);
    
    return count;
}

// Get driver statistics
driver_stats_t autodetect_get_stats(void) {
    driver_stats_t stats;
    
    spinlock_acquire(&autodetect_lock);
    
    stats.total_devices = device_count;
    stats.loaded_drivers = 0;
    stats.failed_drivers = 0;
    stats.critical_drivers = 0;
    
    for (int i = 0; i < device_count; i++) {
        if (detected_devices[i].driver_loaded) {
            stats.loaded_drivers++;
        } else if (detected_devices[i].driver_path[0] != '\0') {
            stats.failed_drivers++;
        }
        
        if (detected_devices[i].driver_flags & DRIVER_CRITICAL) {
            stats.critical_drivers++;
        }
    }
    
    spinlock_release(&autodetect_lock);
    
    return stats;
}
