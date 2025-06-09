# Status Check untuk Khatulistiwa OS
# Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "    KHATULISTIWA OS - STATUS CHECK" -ForegroundColor Cyan
Write-Host "    Sistem Operasi Indonesia" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check core files
Write-Host "Checking Core System Files..." -ForegroundColor Blue
$coreFiles = @{
    "khatcore_runtime.khat" = "system/khatcore_runtime.khat"
    "khatui_runtime.khat" = "system/khatui_runtime.khat"
    "init_check.khat" = "system/init_check.khat"
}

$coreCount = 0
foreach ($file in $coreFiles.GetEnumerator()) {
    if (Test-Path $file.Value) {
        $size = (Get-Item $file.Value).Length
        Write-Host "  [OK] $($file.Key) ($size bytes)" -ForegroundColor Green
        $coreCount++
    } else {
        Write-Host "  [MISSING] $($file.Key)" -ForegroundColor Red
    }
}

# Check applications
Write-Host "Checking System Applications..." -ForegroundColor Blue
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
    $mainPath = Join-Path $appDir "$app.khat"

    if ((Test-Path $appDir) -and (Test-Path $manifestPath) -and (Test-Path $mainPath)) {
        $manifest = Get-Content $manifestPath | ConvertFrom-Json
        $mainSize = (Get-Item $mainPath).Length
        $totalAppSize += $mainSize

        Write-Host "  [OK] $($manifest.cultural_name) ($mainSize bytes)" -ForegroundColor Green
        $appCount++
    } else {
        Write-Host "  [MISSING] $app" -ForegroundColor Red
    }
}

# Check drivers
Write-Host "Checking Drivers..." -ForegroundColor Blue
$driverFiles = @{
    "driver_manager.khat" = "drivers/driver_manager.khat"
    "gamelan_audio.khat" = "drivers/cultural/gamelan_audio.khat"
    "autodetect.c" = "drivers/autodetect.c"
}

$driverCount = 0
foreach ($file in $driverFiles.GetEnumerator()) {
    if (Test-Path $file.Value) {
        $size = (Get-Item $file.Value).Length
        Write-Host "  [OK] $($file.Key) ($size bytes)" -ForegroundColor Green
        $driverCount++
    } else {
        Write-Host "  [MISSING] $($file.Key)" -ForegroundColor Red
    }
}

# Check boot system
Write-Host "Checking Boot System..." -ForegroundColor Blue
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
        Write-Host "  [OK] $($file.Key) ($size bytes)" -ForegroundColor Green
        $bootCount++
    } else {
        Write-Host "  [MISSING] $($file.Key)" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "           SUMMARY REPORT" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

$totalCore = $coreFiles.Count
$totalApps = $expectedApps.Count
$totalDrivers = $driverFiles.Count
$totalBoot = $bootFiles.Count

$corePercent = [math]::Round(($coreCount / $totalCore) * 100, 1)
$appPercent = [math]::Round(($appCount / $totalApps) * 100, 1)
$driverPercent = [math]::Round(($driverCount / $totalDrivers) * 100, 1)
$bootPercent = [math]::Round(($bootCount / $totalBoot) * 100, 1)

Write-Host "Component Status:" -ForegroundColor White
Write-Host "  Core Runtime: $coreCount/$totalCore ($corePercent%)" -ForegroundColor White
Write-Host "  Applications: $appCount/$totalApps ($appPercent%)" -ForegroundColor White
Write-Host "  Drivers: $driverCount/$totalDrivers ($driverPercent%)" -ForegroundColor White
Write-Host "  Boot System: $bootCount/$totalBoot ($bootPercent%)" -ForegroundColor White
Write-Host ""

Write-Host "Size Information:" -ForegroundColor White
Write-Host "  Total Application Size: $totalAppSize bytes" -ForegroundColor White
Write-Host ""

# Overall score
$overallScore = [math]::Round((
    $corePercent + $appPercent + $driverPercent + $bootPercent
) / 4, 1)

Write-Host "Overall Completion: $overallScore%" -ForegroundColor White
Write-Host ""

if ($overallScore -ge 90) {
    Write-Host "EXCELLENT - Khatulistiwa OS siap untuk production!" -ForegroundColor Green
    Write-Host "Sistem operasi Indonesia berhasil dikembangkan!" -ForegroundColor Magenta
} elseif ($overallScore -ge 80) {
    Write-Host "VERY GOOD - Khatulistiwa OS hampir siap!" -ForegroundColor Green
    Write-Host "Beberapa komponen perlu penyempurnaan" -ForegroundColor Yellow
} elseif ($overallScore -ge 70) {
    Write-Host "GOOD - Khatulistiwa OS dalam tahap pengembangan" -ForegroundColor Yellow
    Write-Host "Masih memerlukan beberapa komponen tambahan" -ForegroundColor Blue
} else {
    Write-Host "NEEDS WORK - Khatulistiwa OS memerlukan pengembangan lebih lanjut" -ForegroundColor Red
}

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "KHATULISTIWA OS - TEKNOLOGI MODERN, JIWA INDONESIA" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
