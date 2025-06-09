# ============================================================================
# Build Script untuk Khatulistiwa OS - Windows PowerShell
# Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
# ============================================================================

param(
    [string]$Target = "all",
    [switch]$Help,
    [switch]$Clean,
    [switch]$Verbose
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

function Show-Header {
    Write-Host "🌍 ==============================================" -ForegroundColor Yellow
    Write-Host "🌍 KHATULISTIWA OS - SISTEM OPERASI INDONESIA" -ForegroundColor Yellow
    Write-Host "🌍 ==============================================" -ForegroundColor Yellow
    Write-Host "📦 Project: $PROJECT_NAME" -ForegroundColor Cyan
    Write-Host "🔢 Version: $VERSION" -ForegroundColor Cyan
    Write-Host "🏗️  Build ID: $BUILD_ID" -ForegroundColor Cyan
    Write-Host "🎯 Target: $Target" -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Yellow
}

function Show-Help {
    Write-Host "🌍 Khatulistiwa OS Build System" -ForegroundColor Yellow
    Write-Host "================================" -ForegroundColor Yellow
    Write-Host "Available targets:" -ForegroundColor White
    Write-Host "  all      - Build complete OS (default)" -ForegroundColor Green
    Write-Host "  dirs     - Create build directories" -ForegroundColor Green
    Write-Host "  system   - Build system components" -ForegroundColor Green
    Write-Host "  apps     - Build applications" -ForegroundColor Green
    Write-Host "  clean    - Clean build files" -ForegroundColor Green
    Write-Host "  status   - Show build status" -ForegroundColor Green
    Write-Host "  help     - Show this help" -ForegroundColor Green
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -Clean   - Clean before build" -ForegroundColor Green
    Write-Host "  -Verbose - Verbose output" -ForegroundColor Green
    Write-Host "  -Help    - Show this help" -ForegroundColor Green
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  .\build.ps1 all" -ForegroundColor Cyan
    Write-Host "  .\build.ps1 apps -Verbose" -ForegroundColor Cyan
    Write-Host "  .\build.ps1 clean" -ForegroundColor Cyan
}

function New-BuildDirectories {
    Write-Host "📁 Creating build directories..." -ForegroundColor Yellow
    
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
            if ($Verbose) {
                Write-Host "  ✅ Created: $dir" -ForegroundColor Green
            }
        }
    }
    
    Write-Host "✅ Build directories created successfully" -ForegroundColor Green
}

function Build-SystemComponents {
    Write-Host "🔧 Building system components..." -ForegroundColor Yellow
    
    # Copy runtime files
    Write-Host "  📦 Building KhatCore Runtime..." -ForegroundColor Cyan
    if (Test-Path "$SRC_DIR/system/core/khatcore_runtime.khat") {
        Copy-Item "$SRC_DIR/system/core/khatcore_runtime.khat" "$BUILD_DIR/khatcore_runtime.khat"
        Write-Host "    [OK] khatcore_runtime.khat" -ForegroundColor Green
    } else {
        Write-Host "    [X] khatcore_runtime.khat not found" -ForegroundColor Red
    }
    
    Write-Host "  🎨 Building KhatUI Runtime..." -ForegroundColor Cyan
    if (Test-Path "$SRC_DIR/system/ui/khatui_runtime.khat") {
        Copy-Item "$SRC_DIR/system/ui/khatui_runtime.khat" "$BUILD_DIR/khatui_runtime.khat"
        Write-Host "    [OK] khatui_runtime.khat" -ForegroundColor Green
    } else {
        Write-Host "    [X] khatui_runtime.khat not found" -ForegroundColor Red
    }
    
    Write-Host "  🔍 Building Init Check..." -ForegroundColor Cyan
    if (Test-Path "$SRC_DIR/system/init_check/init_check.khat") {
        Copy-Item "$SRC_DIR/system/init_check/init_check.khat" "$BUILD_DIR/init_check.khat"
        Write-Host "    [OK] init_check.khat" -ForegroundColor Green
    } else {
        Write-Host "    [X] init_check.khat not found" -ForegroundColor Red
    }
    
    Write-Host "✅ System components built successfully" -ForegroundColor Green
}

function Build-Applications {
    Write-Host "📱 Building applications..." -ForegroundColor Yellow
    
    # Check if Python is available
    try {
        $pythonVersion = python --version 2>&1
        Write-Host "  🐍 Python: $pythonVersion" -ForegroundColor Cyan
    } catch {
        Write-Host "  ❌ Python not found. Please install Python 3.x" -ForegroundColor Red
        return $false
    }
    
    # Check if khapp_builder.py exists
    if (!(Test-Path "$SDK_DIR/khapp_builder.py")) {
        Write-Host "  ❌ khapp_builder.py not found in $SDK_DIR" -ForegroundColor Red
        return $false
    }
    
    # Build KhatLauncher
    Write-Host "  🚀 Building KhatLauncher..." -ForegroundColor Cyan
    if (Test-Path "$APPS_DIR/system/khatlauncher") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatlauncher" -o "$DIST_DIR/khatlauncher.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatlauncher.khapp" -ForegroundColor Green
        } else {
            Write-Host "    [X] Failed to build khatlauncher.khapp" -ForegroundColor Red
        }
    } else {
        Write-Host "    ❌ KhatLauncher source not found" -ForegroundColor Red
    }
    
    # Build KhatSettings
    Write-Host "  ⚙️  Building KhatSettings..." -ForegroundColor Cyan
    if (Test-Path "$APPS_DIR/system/khatsettings") {
        $result = python "$SDK_DIR/khapp_builder.py" "$APPS_DIR/system/khatsettings" -o "$DIST_DIR/khatsettings.khapp"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    [OK] khatsettings.khapp" -ForegroundColor Green
        } else {
            Write-Host "    [X] Failed to build khatsettings.khapp" -ForegroundColor Red
        }
    } else {
        Write-Host "    ❌ KhatSettings source not found" -ForegroundColor Red
    }
    
    Write-Host "✅ Applications built successfully" -ForegroundColor Green
    return $true
}

function Remove-BuildFiles {
    Write-Host "🧹 Cleaning build files..." -ForegroundColor Yellow
    
    if (Test-Path $BUILD_DIR) {
        Remove-Item -Recurse -Force $BUILD_DIR
        Write-Host "  ✅ Removed $BUILD_DIR" -ForegroundColor Green
    }
    
    if (Test-Path $DIST_DIR) {
        Remove-Item -Recurse -Force $DIST_DIR
        Write-Host "  ✅ Removed $DIST_DIR" -ForegroundColor Green
    }
    
    Write-Host "✅ Clean completed" -ForegroundColor Green
}

function Show-BuildStatus {
    Write-Host "🌍 Khatulistiwa OS Build Status" -ForegroundColor Yellow
    Write-Host "===============================" -ForegroundColor Yellow
    Write-Host "📦 Project: $PROJECT_NAME v$VERSION" -ForegroundColor Cyan
    Write-Host "🏗️  Build ID: $BUILD_ID" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📁 Files:" -ForegroundColor White
    
    # Check system files
    $systemFiles = @(
        @{Name="KhatCore Runtime"; Path="$BUILD_DIR/khatcore_runtime.khat"},
        @{Name="KhatUI Runtime"; Path="$BUILD_DIR/khatui_runtime.khat"},
        @{Name="Init Check"; Path="$BUILD_DIR/init_check.khat"}
    )
    
    foreach ($file in $systemFiles) {
        if (Test-Path $file.Path) {
            Write-Host "  $($file.Name): [OK] Built" -ForegroundColor Green
        } else {
            Write-Host "  $($file.Name): [X] Not built" -ForegroundColor Red
        }
    }
    
    # Check application files
    $appFiles = @(
        @{Name="KhatLauncher"; Path="$DIST_DIR/khatlauncher.khapp"},
        @{Name="KhatSettings"; Path="$DIST_DIR/khatsettings.khapp"}
    )
    
    foreach ($app in $appFiles) {
        if (Test-Path $app.Path) {
            $size = (Get-Item $app.Path).Length
            $sizeStr = "$size bytes"
            Write-Host "  $($app.Name): [OK] Built ($sizeStr)" -ForegroundColor Green
        } else {
            Write-Host "  $($app.Name): [X] Not built" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "📊 Statistics:" -ForegroundColor White
    
    # Count source files
    $khatFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.khat" -Recurse | Measure-Object
    $jsonFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.json" -Recurse | Measure-Object
    $pyFiles = Get-ChildItem -Path $SRC_DIR -Filter "*.py" -Recurse | Measure-Object
    
    Write-Host "  Khat sources: $($khatFiles.Count)" -ForegroundColor Cyan
    Write-Host "  JSON files: $($jsonFiles.Count)" -ForegroundColor Cyan
    Write-Host "  Python files: $($pyFiles.Count)" -ForegroundColor Cyan
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

Show-Header

if ($Clean) {
    Remove-BuildFiles
}

switch ($Target.ToLower()) {
    "all" {
        New-BuildDirectories
        Build-SystemComponents
        Build-Applications
        Write-Host "✅ Build lengkap Khatulistiwa OS selesai!" -ForegroundColor Green
    }
    "dirs" {
        New-BuildDirectories
    }
    "system" {
        New-BuildDirectories
        Build-SystemComponents
    }
    "apps" {
        New-BuildDirectories
        Build-SystemComponents
        Build-Applications
    }
    "clean" {
        Remove-BuildFiles
    }
    "status" {
        Show-BuildStatus
    }
    "help" {
        Show-Help
    }
    default {
        Write-Host "❌ Unknown target: $Target" -ForegroundColor Red
        Write-Host "Use '.\build.ps1 help' for available targets" -ForegroundColor Yellow
        exit 1
    }
}
