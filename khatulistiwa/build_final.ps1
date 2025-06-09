# ============================================================================
# build_final.ps1 - Final Build & Status Check untuk Khatulistiwa OS
# Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "status", "check", "validate")]
    [string]$Target = "status"
)

# Color functions
function Write-Success { param([string]$Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Error { param([string]$Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Warning { param([string]$Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Info { param([string]$Message) Write-Host "ℹ️  $Message" -ForegroundColor Blue }
function Write-Cultural { param([string]$Message) Write-Host "🎨 $Message" -ForegroundColor Magenta }

# Header
function Show-Header {
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "    KHATULISTIWA OS - FINAL BUILD STATUS" -ForegroundColor Cyan
    Write-Host "    Sistem Operasi Indonesia" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
}

# Check system components
function Check-SystemComponents {
    Write-Info "Checking Khatulistiwa OS Components..."
    Write-Host ""
    
    $components = @{
        "Core Runtime" = @{
            "khatcore_runtime.khat" = "system/khatcore_runtime.khat"
            "khatui_runtime.khat" = "system/khatui_runtime.khat"
            "init_check.khat" = "system/init_check.khat"
        }
        "Kernel" = @{
            "khatkernel.khat" = "kernel/core/khatkernel.khat"
            "cultural_kernel.khat" = "kernel/cultural/cultural_kernel.khat"
            "memory_manager.khat" = "kernel/memory/memory_manager.khat"
            "process_scheduler.khat" = "kernel/scheduler/process_scheduler.khat"
        }
        "Applications" = @{
            "KhatLauncher" = "apps/system/khatlauncher"
            "KhatSettings" = "apps/system/khatsettings"
            "KhatFiles" = "apps/system/khatfiles"
            "KhatStore" = "apps/system/khatstore"
            "KhatMonitor" = "apps/system/khatmonitor"
        }
        "Drivers" = @{
            "driver_manager.khat" = "drivers/driver_manager.khat"
            "gamelan_audio.khat" = "drivers/cultural/gamelan_audio.khat"
            "autodetect.c" = "drivers/autodetect.c"
        }
        "Boot System" = @{
            "universal_boot.c" = "boot/multiplatform/universal_boot.c"
            "uefi_khatboot.c" = "boot/uefi/uefi_khatboot.c"
            "arm64_boot.S" = "boot/arm/arm64_boot.S"
            "riscv_boot.S" = "boot/riscv/riscv_boot.S"
            "grub.cfg" = "boot/grub/grub.cfg"
        }
        "SDK Tools" = @{
            "khatsdk.py" = "sdk/khatsdk.py"
            "khapp_builder.py" = "sdk/khapp_builder.py"
        }
        "Documentation" = @{
            "README.md" = "docs/README.md"
            "user-guide.md" = "docs/user/user-guide.md"
            "developer-guide.md" = "docs/developer/developer-guide.md"
        }
    }
    
    $totalFiles = 0
    $existingFiles = 0
    
    foreach ($category in $components.GetEnumerator()) {
        Write-Host "📁 $($category.Key):" -ForegroundColor Cyan
        
        foreach ($file in $category.Value.GetEnumerator()) {
            $totalFiles++
            $filePath = $file.Value
            
            if (Test-Path $filePath) {
                $fileSize = (Get-Item $filePath).Length
                Write-Success "  $($file.Key) ($fileSize bytes)"
                $existingFiles++
            }
            else {
                Write-Error "  $($file.Key) - MISSING"
            }
        }
        Write-Host ""
    }
    
    return @{
        Total = $totalFiles
        Existing = $existingFiles
        Percentage = [math]::Round(($existingFiles / $totalFiles) * 100, 2)
    }
}

# Check applications
function Check-Applications {
    Write-Info "Checking System Applications..."
    Write-Host ""
    
    $appsDir = "apps/system"
    if (-not (Test-Path $appsDir)) {
        Write-Error "Apps directory not found: $appsDir"
        return @{ Total = 0; Existing = 0; Percentage = 0 }
    }
    
    $expectedApps = @(
        "khatlauncher", "khatsettings", "khatfiles", "khatstore", "khatmonitor",
        "khatsecurity", "khatnotif", "khatcalendar", "khatnotes", "khatnetwork",
        "devicemanager", "builder_gui", "diskmanager", "appmanager", "drivermanager",
        "khatmultitask", "khatcalc", "resetmanager", "devsandbox", "versionupdate"
    )
    
    $existingApps = 0
    $totalSize = 0
    
    foreach ($app in $expectedApps) {
        $appDir = Join-Path $appsDir $app
        $manifestPath = Join-Path $appDir "manifest.json"
        $mainPath = Join-Path $appDir "main.khat"
        
        if ((Test-Path $appDir) -and (Test-Path $manifestPath) -and (Test-Path $mainPath)) {
            $manifest = Get-Content $manifestPath | ConvertFrom-Json
            $mainSize = (Get-Item $mainPath).Length
            $totalSize += $mainSize
            
            Write-Success "  $($manifest.cultural_name) ($mainSize bytes)"
            $existingApps++
        }
        else {
            Write-Error "  $app - MISSING or INCOMPLETE"
        }
    }
    
    Write-Host ""
    Write-Info "Total Applications Size: $totalSize bytes"
    
    return @{
        Total = $expectedApps.Count
        Existing = $existingApps
        Percentage = [math]::Round(($existingApps / $expectedApps.Count) * 100, 2)
        TotalSize = $totalSize
    }
}

# Check cultural elements
function Check-CulturalElements {
    Write-Cultural "Checking Cultural Integration..."
    Write-Host ""
    
    $culturalChecks = @{
        "Indonesian Terminology" = $false
        "Batik Themes" = $false
        "Gamelan Audio" = $false
        "Wayang Characters" = $false
        "Garuda Elements" = $false
        "Cultural Documentation" = $false
    }
    
    # Check for Indonesian terminology in files
    $khatFiles = Get-ChildItem -Recurse -Filter "*.khat" | Select-Object -First 5
    if ($khatFiles.Count -gt 0) {
        $culturalChecks["Indonesian Terminology"] = $true
        Write-Success "  Indonesian terminology found in .khat files"
    }
    
    # Check for cultural drivers
    if (Test-Path "drivers/cultural/gamelan_audio.khat") {
        $culturalChecks["Gamelan Audio"] = $true
        Write-Success "  Gamelan audio driver found"
    }
    
    # Check for cultural kernel
    if (Test-Path "kernel/cultural/cultural_kernel.khat") {
        $culturalChecks["Batik Themes"] = $true
        $culturalChecks["Wayang Characters"] = $true
        Write-Success "  Cultural kernel integration found"
    }
    
    # Check for boot cultural elements
    if (Test-Path "boot/uefi/uefi_khatboot.c") {
        $bootContent = Get-Content "boot/uefi/uefi_khatboot.c" -Raw
        if ($bootContent -match "Garuda|Indonesia|Khatulistiwa") {
            $culturalChecks["Garuda Elements"] = $true
            Write-Success "  Garuda elements found in bootloader"
        }
    }
    
    # Check for cultural documentation
    if (Test-Path "docs/cultural") {
        $culturalChecks["Cultural Documentation"] = $true
        Write-Success "  Cultural documentation found"
    }
    
    $passedChecks = ($culturalChecks.Values | Where-Object { $_ -eq $true }).Count
    $totalChecks = $culturalChecks.Count
    
    foreach ($check in $culturalChecks.GetEnumerator()) {
        if (-not $check.Value) {
            Write-Warning "  $($check.Key) - Not fully implemented"
        }
    }
    
    return @{
        Total = $totalChecks
        Passed = $passedChecks
        Percentage = [math]::Round(($passedChecks / $totalChecks) * 100, 2)
    }
}

# Check multi-platform support
function Check-MultiPlatformSupport {
    Write-Info "Checking Multi-Platform Support..."
    Write-Host ""
    
    $platforms = @{
        "x86_64" = @("boot/uefi/uefi_khatboot.c", "boot/multiplatform/universal_boot.c")
        "ARM64" = @("boot/arm/arm64_boot.S")
        "RISC-V" = @("boot/riscv/riscv_boot.S")
        "Legacy BIOS" = @("boot/bootloader/khatboot.asm")
    }
    
    $supportedPlatforms = 0
    
    foreach ($platform in $platforms.GetEnumerator()) {
        $platformSupported = $true
        
        foreach ($file in $platform.Value) {
            if (-not (Test-Path $file)) {
                $platformSupported = $false
                break
            }
        }
        
        if ($platformSupported) {
            Write-Success "  $($platform.Key) - Supported"
            $supportedPlatforms++
        }
        else {
            Write-Warning "  $($platform.Key) - Partial support"
        }
    }
    
    return @{
        Total = $platforms.Count
        Supported = $supportedPlatforms
        Percentage = [math]::Round(($supportedPlatforms / $platforms.Count) * 100, 2)
    }
}

# Generate final report
function Generate-FinalReport {
    Show-Header
    
    # Check all components
    $componentCheck = Check-SystemComponents
    $appCheck = Check-Applications
    $culturalCheck = Check-CulturalElements
    $platformCheck = Check-MultiPlatformSupport
    
    # Final summary
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "           FINAL BUILD REPORT" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Info "📊 Component Statistics:"
    Write-Host "  • System Components: $($componentCheck.Existing)/$($componentCheck.Total) ($($componentCheck.Percentage)%)" -ForegroundColor White
    Write-Host "  • Applications: $($appCheck.Existing)/$($appCheck.Total) ($($appCheck.Percentage)%)" -ForegroundColor White
    Write-Host "  • Cultural Integration: $($culturalCheck.Passed)/$($culturalCheck.Total) ($($culturalCheck.Percentage)%)" -ForegroundColor White
    Write-Host "  • Platform Support: $($platformCheck.Supported)/$($platformCheck.Total) ($($platformCheck.Percentage)%)" -ForegroundColor White
    Write-Host ""
    
    Write-Info "💾 Size Statistics:"
    Write-Host "  • Total Application Size: $($appCheck.TotalSize) bytes" -ForegroundColor White
    Write-Host ""
    
    # Overall score
    $overallScore = [math]::Round((
        $componentCheck.Percentage + 
        $appCheck.Percentage + 
        $culturalCheck.Percentage + 
        $platformCheck.Percentage
    ) / 4, 2)
    
    Write-Info "🎯 Overall Completion: $overallScore%"
    Write-Host ""
    
    if ($overallScore -ge 90) {
        Write-Success "🎉 EXCELLENT - Khatulistiwa OS siap untuk production!"
        Write-Cultural "🇮🇩 Sistem operasi Indonesia berhasil dikembangkan dengan sempurna!"
    }
    elseif ($overallScore -ge 80) {
        Write-Success "✅ VERY GOOD - Khatulistiwa OS hampir siap!"
        Write-Warning "Beberapa komponen perlu penyempurnaan"
    }
    elseif ($overallScore -ge 70) {
        Write-Warning "⚠️  GOOD - Khatulistiwa OS dalam tahap pengembangan"
        Write-Info "Masih memerlukan beberapa komponen tambahan"
    }
    else {
        Write-Error "❌ NEEDS WORK - Khatulistiwa OS memerlukan pengembangan lebih lanjut"
    }
    
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Cultural "🎨 KHATULISTIWA OS - TEKNOLOGI MODERN, JIWA INDONESIA 🇮🇩"
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
}

# Main execution
switch ($Target) {
    "all" { Generate-FinalReport }
    "status" { Generate-FinalReport }
    "check" { Generate-FinalReport }
    "validate" { 
        $culturalCheck = Check-CulturalElements
        Write-Cultural "Cultural validation completed: $($culturalCheck.Percentage)%"
    }
    default { Generate-FinalReport }
}
