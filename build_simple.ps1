# ============================================================================
# Simple Build Script untuk Khatulistiwa OS - Windows PowerShell
# Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
# ============================================================================

param(
    [string]$Target = "all"
)

# Project information
$PROJECT_NAME = "Khatulistiwa OS"
$VERSION = "1.0.0"
$BUILD_DATE = Get-Date -Format "yyyyMMdd"
$BUILD_TIME = Get-Date -Format "HHmmss"
$BUILD_ID = "$BUILD_DATE-$BUILD_TIME"

# Directories
$SRC_DIR = "khatulistiwa"
$BUILD_DIR = "build"
$DIST_DIR = "dist"
$APPS_DIR = "$SRC_DIR/apps"
$SDK_DIR = "$SRC_DIR/sdk"

Write-Host "=============================================="
Write-Host "KHATULISTIWA OS - SISTEM OPERASI INDONESIA"
Write-Host "=============================================="
Write-Host "Project: $PROJECT_NAME"
Write-Host "Version: $VERSION"
Write-Host "Build ID: $BUILD_ID"
Write-Host "Target: $Target"
Write-Host "=============================================="

if ($Target -eq "help") {
    Write-Host "Available targets:"
    Write-Host "  all      - Build complete OS (default)"
    Write-Host "  dirs     - Create build directories"
    Write-Host "  system   - Build system components"
    Write-Host "  apps     - Build applications"
    Write-Host "  clean    - Clean build files"
    Write-Host "  status   - Show build status"
    Write-Host "  help     - Show this help"
    exit 0
}

if ($Target -eq "clean") {
    Write-Host "Cleaning build files..."
    
    if (Test-Path $BUILD_DIR) {
        Remove-Item -Recurse -Force $BUILD_DIR
        Write-Host "Removed $BUILD_DIR"
    }
    
    if (Test-Path $DIST_DIR) {
        Remove-Item -Recurse -Force $DIST_DIR
        Write-Host "Removed $DIST_DIR"
    }
    
    Write-Host "Clean completed"
    exit 0
}

if ($Target -eq "status") {
    Write-Host "Khatulistiwa OS Build Status"
    Write-Host "==============================="
    Write-Host "Project: $PROJECT_NAME v$VERSION"
    Write-Host "Build ID: $BUILD_ID"
    Write-Host ""
    Write-Host "Files:"
    
    # Check system files
    if (Test-Path "$BUILD_DIR/khatcore_runtime.khat") {
        Write-Host "  KhatCore Runtime: [OK] Built"
    } else {
        Write-Host "  KhatCore Runtime: [X] Not built"
    }
    
    if (Test-Path "$BUILD_DIR/khatui_runtime.khat") {
        Write-Host "  KhatUI Runtime: [OK] Built"
    } else {
        Write-Host "  KhatUI Runtime: [X] Not built"
    }
    
    if (Test-Path "$BUILD_DIR/init_check.khat") {
        Write-Host "  Init Check: [OK] Built"
    } else {
        Write-Host "  Init Check: [X] Not built"
    }
    
    # Check application files
    if (Test-Path "$DIST_DIR/khatlauncher.khapp") {
        $size = (Get-Item "$DIST_DIR/khatlauncher.khapp").Length
        Write-Host "  KhatLauncher: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatLauncher: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/khatsettings.khapp") {
        $size = (Get-Item "$DIST_DIR/khatsettings.khapp").Length
        Write-Host "  KhatSettings: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatSettings: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/khatfiles.khapp") {
        $size = (Get-Item "$DIST_DIR/khatfiles.khapp").Length
        Write-Host "  KhatFiles: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatFiles: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/khatstore.khapp") {
        $size = (Get-Item "$DIST_DIR/khatstore.khapp").Length
        Write-Host "  KhatStore: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatStore: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/khatmonitor.khapp") {
        $size = (Get-Item "$DIST_DIR/khatmonitor.khapp").Length
        Write-Host "  KhatMonitor: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatMonitor: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/khatsecurity.khapp") {
        $size = (Get-Item "$DIST_DIR/khatsecurity.khapp").Length
        Write-Host "  KhatSecurity: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatSecurity: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/khatnotif.khapp") {
        $size = (Get-Item "$DIST_DIR/khatnotif.khapp").Length
        Write-Host "  KhatNotif: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatNotif: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/khatcalendar.khapp") {
        $size = (Get-Item "$DIST_DIR/khatcalendar.khapp").Length
        Write-Host "  KhatCalendar: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatCalendar: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/khatnotes.khapp") {
        $size = (Get-Item "$DIST_DIR/khatnotes.khapp").Length
        Write-Host "  KhatNotes: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatNotes: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/khatnetwork.khapp") {
        $size = (Get-Item "$DIST_DIR/khatnetwork.khapp").Length
        Write-Host "  KhatNetwork: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatNetwork: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/devicemanager.khapp") {
        $size = (Get-Item "$DIST_DIR/devicemanager.khapp").Length
        Write-Host "  DeviceManager: [OK] Built ($size bytes)"
    } else {
        Write-Host "  DeviceManager: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/builder_gui.khapp") {
        $size = (Get-Item "$DIST_DIR/builder_gui.khapp").Length
        Write-Host "  Builder GUI: [OK] Built ($size bytes)"
    } else {
        Write-Host "  Builder GUI: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/diskmanager.khapp") {
        $size = (Get-Item "$DIST_DIR/diskmanager.khapp").Length
        Write-Host "  DiskManager: [OK] Built ($size bytes)"
    } else {
        Write-Host "  DiskManager: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/appmanager.khapp") {
        $size = (Get-Item "$DIST_DIR/appmanager.khapp").Length
        Write-Host "  AppManager: [OK] Built ($size bytes)"
    } else {
        Write-Host "  AppManager: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/drivermanager.khapp") {
        $size = (Get-Item "$DIST_DIR/drivermanager.khapp").Length
        Write-Host "  DriverManager: [OK] Built ($size bytes)"
    } else {
        Write-Host "  DriverManager: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/khatmultitask.khapp") {
        $size = (Get-Item "$DIST_DIR/khatmultitask.khapp").Length
        Write-Host "  KhatMultitask: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatMultitask: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/khatcalc.khapp") {
        $size = (Get-Item "$DIST_DIR/khatcalc.khapp").Length
        Write-Host "  KhatCalc: [OK] Built ($size bytes)"
    } else {
        Write-Host "  KhatCalc: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/resetmanager.khapp") {
        $size = (Get-Item "$DIST_DIR/resetmanager.khapp").Length
        Write-Host "  ResetManager: [OK] Built ($size bytes)"
    } else {
        Write-Host "  ResetManager: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/devsandbox.khapp") {
        $size = (Get-Item "$DIST_DIR/devsandbox.khapp").Length
        Write-Host "  DevSandbox: [OK] Built ($size bytes)"
    } else {
        Write-Host "  DevSandbox: [X] Not built"
    }

    if (Test-Path "$DIST_DIR/versionupdate.khapp") {
        $size = (Get-Item "$DIST_DIR/versionupdate.khapp").Length
        Write-Host "  VersionUpdate: [OK] Built ($size bytes)"
    } else {
        Write-Host "  VersionUpdate: [X] Not built"
    }
    
    Write-Host ""
    Write-Host "Statistics:"
    
    # Count source files
    $khatFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.khat" -Recurse | Measure-Object
    $jsonFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.json" -Recurse | Measure-Object
    $pyFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.py" -Recurse | Measure-Object
    
    Write-Host "  Khat sources: $($khatFiles.Count)"
    Write-Host "  JSON files: $($jsonFiles.Count)"
    Write-Host "  Python files: $($pyFiles.Count)"
    
    exit 0
}

# Create directories
if ($Target -eq "dirs" -or $Target -eq "all" -or $Target -eq "system" -or $Target -eq "apps") {
    Write-Host "Creating build directories..."
    
    $directories = @(
        $BUILD_DIR,
        "$BUILD_DIR/$SRC_DIR/kernel/core",
        "$BUILD_DIR/$SRC_DIR/kernel/drivers", 
        "$BUILD_DIR/$SRC_DIR/kernel/security",
        "$BUILD_DIR/$SRC_DIR/system/core",
        "$BUILD_DIR/$SRC_DIR/system/ui",
        "$BUILD_DIR/$SRC_DIR/system/init_check",
        "$BUILD_DIR/$SRC_DIR/apps/system",
        "$BUILD_DIR/$SRC_DIR/apps/games",
        "$BUILD_DIR/$SRC_DIR/apps/productivity",
        $DIST_DIR
    )
    
    foreach ($dir in $directories) {
        if (!(Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    
    Write-Host "Build directories created successfully"
}

# Build system components
if ($Target -eq "system" -or $Target -eq "all" -or $Target -eq "apps") {
    Write-Host "Building system components..."
    
    # Copy runtime files
    Write-Host "  Building KhatCore Runtime..."
    if (Test-Path "$SRC_DIR/system/core/khatcore_runtime.khat") {
        Copy-Item "$SRC_DIR/system/core/khatcore_runtime.khat" "$BUILD_DIR/khatcore_runtime.khat"
        Write-Host "    [OK] khatcore_runtime.khat"
    } else {
        Write-Host "    [X] khatcore_runtime.khat not found"
    }
    
    Write-Host "  Building KhatUI Runtime..."
    if (Test-Path "$SRC_DIR/system/ui/khatui_runtime.khat") {
        Copy-Item "$SRC_DIR/system/ui/khatui_runtime.khat" "$BUILD_DIR/khatui_runtime.khat"
        Write-Host "    [OK] khatui_runtime.khat"
    } else {
        Write-Host "    [X] khatui_runtime.khat not found"
    }
    
    Write-Host "  Building Init Check..."
    if (Test-Path "$SRC_DIR/system/init_check/init_check.khat") {
        Copy-Item "$SRC_DIR/system/init_check/init_check.khat" "$BUILD_DIR/init_check.khat"
        Write-Host "    [OK] init_check.khat"
    } else {
        Write-Host "    [X] init_check.khat not found"
    }
    
    Write-Host "System components built successfully"
}

# Build applications
if ($Target -eq "apps" -or $Target -eq "all") {
    Write-Host "Building applications..."
    
    # Check if Python is available
    try {
        $pythonVersion = python --version 2>&1
        Write-Host "  Python: $pythonVersion"
    } catch {
        Write-Host "  [X] Python not found. Please install Python 3.x"
        exit 1
    }
    
    # Check if khapp_builder.py exists
    if (!(Test-Path "$SDK_DIR/khapp_builder.py")) {
        Write-Host "  [X] khapp_builder.py not found in $SDK_DIR"
        exit 1
    }
    
    # Build KhatLauncher
    Write-Host "  Building KhatLauncher..."
    if (Test-Path "$APPS_DIR/system/khatlauncher") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatlauncher" -o "$DIST_DIR/khatlauncher.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatlauncher.khapp"
        } else {
            Write-Host "    [X] Failed to build khatlauncher.khapp"
        }
    } else {
        Write-Host "    [X] KhatLauncher source not found"
    }
    
    # Build KhatSettings
    Write-Host "  Building KhatSettings..."
    if (Test-Path "$APPS_DIR/system/khatsettings") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatsettings" -o "$DIST_DIR/khatsettings.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatsettings.khapp"
        } else {
            Write-Host "    [X] Failed to build khatsettings.khapp"
        }
    } else {
        Write-Host "    [X] KhatSettings source not found"
    }

    # Build KhatFiles
    Write-Host "  Building KhatFiles..."
    if (Test-Path "$APPS_DIR/system/khatfiles") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatfiles" -o "$DIST_DIR/khatfiles.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatfiles.khapp"
        } else {
            Write-Host "    [X] Failed to build khatfiles.khapp"
        }
    } else {
        Write-Host "    [X] KhatFiles source not found"
    }

    # Build KhatStore
    Write-Host "  Building KhatStore..."
    if (Test-Path "$APPS_DIR/system/khatstore") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatstore" -o "$DIST_DIR/khatstore.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatstore.khapp"
        } else {
            Write-Host "    [X] Failed to build khatstore.khapp"
        }
    } else {
        Write-Host "    [X] KhatStore source not found"
    }

    # Build KhatMonitor
    Write-Host "  Building KhatMonitor..."
    if (Test-Path "$APPS_DIR/system/khatmonitor") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatmonitor" -o "$DIST_DIR/khatmonitor.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatmonitor.khapp"
        } else {
            Write-Host "    [X] Failed to build khatmonitor.khapp"
        }
    } else {
        Write-Host "    [X] KhatMonitor source not found"
    }

    # Build KhatSecurity
    Write-Host "  Building KhatSecurity..."
    if (Test-Path "$APPS_DIR/system/khatsecurity") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatsecurity" -o "$DIST_DIR/khatsecurity.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatsecurity.khapp"
        } else {
            Write-Host "    [X] Failed to build khatsecurity.khapp"
        }
    } else {
        Write-Host "    [X] KhatSecurity source not found"
    }

    # Build KhatNotif
    Write-Host "  Building KhatNotif..."
    if (Test-Path "$APPS_DIR/system/khatnotif") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatnotif" -o "$DIST_DIR/khatnotif.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatnotif.khapp"
        } else {
            Write-Host "    [X] Failed to build khatnotif.khapp"
        }
    } else {
        Write-Host "    [X] KhatNotif source not found"
    }

    # Build KhatCalendar
    Write-Host "  Building KhatCalendar..."
    if (Test-Path "$APPS_DIR/system/khatcalendar") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatcalendar" -o "$DIST_DIR/khatcalendar.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatcalendar.khapp"
        } else {
            Write-Host "    [X] Failed to build khatcalendar.khapp"
        }
    } else {
        Write-Host "    [X] KhatCalendar source not found"
    }

    # Build KhatNotes
    Write-Host "  Building KhatNotes..."
    if (Test-Path "$APPS_DIR/system/khatnotes") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatnotes" -o "$DIST_DIR/khatnotes.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatnotes.khapp"
        } else {
            Write-Host "    [X] Failed to build khatnotes.khapp"
        }
    } else {
        Write-Host "    [X] KhatNotes source not found"
    }

    # Build KhatNetwork
    Write-Host "  Building KhatNetwork..."
    if (Test-Path "$APPS_DIR/system/khatnetwork") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatnetwork" -o "$DIST_DIR/khatnetwork.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatnetwork.khapp"
        } else {
            Write-Host "    [X] Failed to build khatnetwork.khapp"
        }
    } else {
        Write-Host "    [X] KhatNetwork source not found"
    }

    # Build DeviceManager
    Write-Host "  Building DeviceManager..."
    if (Test-Path "$APPS_DIR/system/devicemanager") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/devicemanager" -o "$DIST_DIR/devicemanager.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] devicemanager.khapp"
        } else {
            Write-Host "    [X] Failed to build devicemanager.khapp"
        }
    } else {
        Write-Host "    [X] DeviceManager source not found"
    }

    # Build Builder GUI
    Write-Host "  Building Builder GUI..."
    if (Test-Path "$APPS_DIR/system/builder_gui") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/builder_gui" -o "$DIST_DIR/builder_gui.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] builder_gui.khapp"
        } else {
            Write-Host "    [X] Failed to build builder_gui.khapp"
        }
    } else {
        Write-Host "    [X] Builder GUI source not found"
    }

    # Build DiskManager
    Write-Host "  Building DiskManager..."
    if (Test-Path "$APPS_DIR/system/diskmanager") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/diskmanager" -o "$DIST_DIR/diskmanager.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] diskmanager.khapp"
        } else {
            Write-Host "    [X] Failed to build diskmanager.khapp"
        }
    } else {
        Write-Host "    [X] DiskManager source not found"
    }

    # Build AppManager
    Write-Host "  Building AppManager..."
    if (Test-Path "$APPS_DIR/system/appmanager") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/appmanager" -o "$DIST_DIR/appmanager.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] appmanager.khapp"
        } else {
            Write-Host "    [X] Failed to build appmanager.khapp"
        }
    } else {
        Write-Host "    [X] AppManager source not found"
    }

    # Build DriverManager
    Write-Host "  Building DriverManager..."
    if (Test-Path "$APPS_DIR/system/drivermanager") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/drivermanager" -o "$DIST_DIR/drivermanager.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] drivermanager.khapp"
        } else {
            Write-Host "    [X] Failed to build drivermanager.khapp"
        }
    } else {
        Write-Host "    [X] DriverManager source not found"
    }

    # Build KhatMultitask
    Write-Host "  Building KhatMultitask..."
    if (Test-Path "$APPS_DIR/system/khatmultitask") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatmultitask" -o "$DIST_DIR/khatmultitask.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatmultitask.khapp"
        } else {
            Write-Host "    [X] Failed to build khatmultitask.khapp"
        }
    } else {
        Write-Host "    [X] KhatMultitask source not found"
    }

    # Build KhatCalc
    Write-Host "  Building KhatCalc..."
    if (Test-Path "$APPS_DIR/system/khatcalc") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatcalc" -o "$DIST_DIR/khatcalc.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatcalc.khapp"
        } else {
            Write-Host "    [X] Failed to build khatcalc.khapp"
        }
    } else {
        Write-Host "    [X] KhatCalc source not found"
    }

    # Build ResetManager
    Write-Host "  Building ResetManager..."
    if (Test-Path "$APPS_DIR/system/resetmanager") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/resetmanager" -o "$DIST_DIR/resetmanager.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] resetmanager.khapp"
        } else {
            Write-Host "    [X] Failed to build resetmanager.khapp"
        }
    } else {
        Write-Host "    [X] ResetManager source not found"
    }

    # Build DevSandbox
    Write-Host "  Building DevSandbox..."
    if (Test-Path "$APPS_DIR/system/devsandbox") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/devsandbox" -o "$DIST_DIR/devsandbox.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] devsandbox.khapp"
        } else {
            Write-Host "    [X] Failed to build devsandbox.khapp"
        }
    } else {
        Write-Host "    [X] DevSandbox source not found"
    }

    # Build VersionUpdate
    Write-Host "  Building VersionUpdate..."
    if (Test-Path "$APPS_DIR/system/versionupdate") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/versionupdate" -o "$DIST_DIR/versionupdate.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] versionupdate.khapp"
        } else {
            Write-Host "    [X] Failed to build versionupdate.khapp"
        }
    } else {
        Write-Host "    [X] VersionUpdate source not found"
    }

    Write-Host "Applications built successfully"
}

if ($Target -eq "all") {
    Write-Host "Build lengkap Khatulistiwa OS selesai!"
}

Write-Host "=============================================="
