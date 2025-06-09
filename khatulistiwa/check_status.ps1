# ============================================================================
# check_status.ps1 - Status Check untuk Khatulistiwa OS
# Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
# ============================================================================

# Color functions
function Write-Success { param([string]$Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Error { param([string]$Message) Write-Host "❌ $Message" -ForegroundColor Red }
function Write-Warning { param([string]$Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Info { param([string]$Message) Write-Host "ℹ️  $Message" -ForegroundColor Blue }

# Header
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "    KHATULISTIWA OS - STATUS CHECK" -ForegroundColor Cyan
Write-Host "    Sistem Operasi Indonesia" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check core files
Write-Info "Checking Core System Files..."
$coreFiles = @{
    "khatcore_runtime.khat" = "system/khatcore_runtime.khat"
    "khatui_runtime.khat" = "system/khatui_runtime.khat"
    "init_check.khat" = "system/init_check.khat"
}

$coreCount = 0
foreach ($file in $coreFiles.GetEnumerator()) {
    if (Test-Path $file.Value) {
        $size = (Get-Item $file.Value).Length
        Write-Success "  $($file.Key) ($size bytes)"
        $coreCount++
    } else {
        Write-Error "  $($file.Key) - MISSING"
    }
}

# Check kernel files
Write-Info "Checking Kernel Files..."
$kernelFiles = @{
    "khatkernel.khat" = "kernel/core/khatkernel.khat"
    "cultural_kernel.khat" = "kernel/cultural/cultural_kernel.khat"
}

$kernelCount = 0
foreach ($file in $kernelFiles.GetEnumerator()) {
    if (Test-Path $file.Value) {
        $size = (Get-Item $file.Value).Length
        Write-Success "  $($file.Key) ($size bytes)"
        $kernelCount++
    } else {
        Write-Error "  $($file.Key) - MISSING"
    }
}

# Check applications
Write-Info "Checking System Applications..."
$appsDir = "apps/system"
$expectedApps = @(
    "khatlauncher", "khatsettings", "khatfiles", "khatstore", "khatmonitor",
    "khatsecurity", "khatnotif", "khatcalendar", "khatnotes", "khatnetwork",
    "devicemanager", "builder_gui", "diskmanager", "appmanager", "drivermanager",
    "khatmultitask", "khatcalc", "resetmanager", "devsandbox", "versionupdate"
)

$appCount = 0
$totalAppSize = 0

foreach ($app in $expectedApps) {
    $appDir = Join-Path $appsDir $app
    $manifestPath = Join-Path $appDir "manifest.json"
    $mainPath = Join-Path $appDir "main.khat"
    
    if ((Test-Path $appDir) -and (Test-Path $manifestPath) -and (Test-Path $mainPath)) {
        $manifest = Get-Content $manifestPath | ConvertFrom-Json
        $mainSize = (Get-Item $mainPath).Length
        $totalAppSize += $mainSize
        
        Write-Success "  $($manifest.cultural_name) ($mainSize bytes)"
        $appCount++
    } else {
        Write-Error "  $app - MISSING"
    }
}

# Check drivers
Write-Info "Checking Drivers..."
$driverFiles = @{
    "driver_manager.khat" = "drivers/driver_manager.khat"
    "gamelan_audio.khat" = "drivers/cultural/gamelan_audio.khat"
    "autodetect.c" = "drivers/autodetect.c"
}

$driverCount = 0
foreach ($file in $driverFiles.GetEnumerator()) {
    if (Test-Path $file.Value) {
        $size = (Get-Item $file.Value).Length
        Write-Success "  $($file.Key) ($size bytes)"
        $driverCount++
    } else {
        Write-Error "  $($file.Key) - MISSING"
    }
}

# Check boot system
Write-Info "Checking Boot System..."
$bootFiles = @{
    "universal_boot.c" = "boot/multiplatform/universal_boot.c"
    "uefi_khatboot.c" = "boot/uefi/uefi_khatboot.c"
    "arm64_boot.S" = "boot/arm/arm64_boot.S"
    "riscv_boot.S" = "boot/riscv/riscv_boot.S"
    "grub.cfg" = "boot/grub/grub.cfg"
}

$bootCount = 0
foreach ($file in $bootFiles.GetEnumerator()) {
    if (Test-Path $file.Value) {
        $size = (Get-Item $file.Value).Length
        Write-Success "  $($file.Key) ($size bytes)"
        $bootCount++
    } else {
        Write-Error "  $($file.Key) - MISSING"
    }
}

# Check SDK
Write-Info "Checking SDK Tools..."
$sdkFiles = @{
    "khatsdk.py" = "sdk/khatsdk.py"
    "khapp_builder.py" = "sdk/khapp_builder.py"
}

$sdkCount = 0
foreach ($file in $sdkFiles.GetEnumerator()) {
    if (Test-Path $file.Value) {
        $size = (Get-Item $file.Value).Length
        Write-Success "  $($file.Key) ($size bytes)"
        $sdkCount++
    } else {
        Write-Error "  $($file.Key) - MISSING"
    }
}

# Check documentation
Write-Info "Checking Documentation..."
$docFiles = @{
    "README.md" = "docs/README.md"
    "user-guide.md" = "docs/user/user-guide.md"
    "developer-guide.md" = "docs/developer/developer-guide.md"
}

$docCount = 0
foreach ($file in $docFiles.GetEnumerator()) {
    if (Test-Path $file.Value) {
        $size = (Get-Item $file.Value).Length
        Write-Success "  $($file.Key) ($size bytes)"
        $docCount++
    } else {
        Write-Error "  $($file.Key) - MISSING"
    }
}

# Summary
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "           SUMMARY REPORT" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$totalCore = $coreFiles.Count
$totalKernel = $kernelFiles.Count
$totalApps = $expectedApps.Count
$totalDrivers = $driverFiles.Count
$totalBoot = $bootFiles.Count
$totalSDK = $sdkFiles.Count
$totalDocs = $docFiles.Count

$corePercent = [math]::Round(($coreCount / $totalCore) * 100, 1)
$kernelPercent = [math]::Round(($kernelCount / $totalKernel) * 100, 1)
$appPercent = [math]::Round(($appCount / $totalApps) * 100, 1)
$driverPercent = [math]::Round(($driverCount / $totalDrivers) * 100, 1)
$bootPercent = [math]::Round(($bootCount / $totalBoot) * 100, 1)
$sdkPercent = [math]::Round(($sdkCount / $totalSDK) * 100, 1)
$docPercent = [math]::Round(($docCount / $totalDocs) * 100, 1)

Write-Host "📊 Component Status:" -ForegroundColor White
Write-Host "  • Core Runtime: $coreCount/$totalCore ($corePercent%)" -ForegroundColor White
Write-Host "  • Kernel: $kernelCount/$totalKernel ($kernelPercent%)" -ForegroundColor White
Write-Host "  • Applications: $appCount/$totalApps ($appPercent%)" -ForegroundColor White
Write-Host "  • Drivers: $driverCount/$totalDrivers ($driverPercent%)" -ForegroundColor White
Write-Host "  • Boot System: $bootCount/$totalBoot ($bootPercent%)" -ForegroundColor White
Write-Host "  • SDK Tools: $sdkCount/$totalSDK ($sdkPercent%)" -ForegroundColor White
Write-Host "  • Documentation: $docCount/$totalDocs ($docPercent%)" -ForegroundColor White
Write-Host ""

Write-Host "💾 Size Information:" -ForegroundColor White
Write-Host "  • Total Application Size: $totalAppSize bytes" -ForegroundColor White
Write-Host ""

# Overall score
$overallScore = [math]::Round((
    $corePercent + $kernelPercent + $appPercent + 
    $driverPercent + $bootPercent + $sdkPercent + $docPercent
) / 7, 1)

Write-Host "🎯 Overall Completion: $overallScore%" -ForegroundColor White
Write-Host ""

if ($overallScore -ge 90) {
    Write-Success "🎉 EXCELLENT - Khatulistiwa OS siap untuk production!"
    Write-Host "🇮🇩 Sistem operasi Indonesia berhasil dikembangkan!" -ForegroundColor Magenta
} elseif ($overallScore -ge 80) {
    Write-Success "✅ VERY GOOD - Khatulistiwa OS hampir siap!"
    Write-Warning "Beberapa komponen perlu penyempurnaan"
} elseif ($overallScore -ge 70) {
    Write-Warning "⚠️  GOOD - Khatulistiwa OS dalam tahap pengembangan"
    Write-Info "Masih memerlukan beberapa komponen tambahan"
} else {
    Write-Error "❌ NEEDS WORK - Khatulistiwa OS memerlukan pengembangan lebih lanjut"
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "🎨 KHATULISTIWA OS - TEKNOLOGI MODERN, JIWA INDONESIA 🇮🇩" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
