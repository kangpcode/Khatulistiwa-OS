# ============================================================================
# build_advanced.ps1 - Advanced Build System untuk Khatulistiwa OS
# Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
# ============================================================================
# 
# Advanced build system dengan fitur:
# 1. Multi-platform build support (x86, x86_64, ARM, ARM64, RISC-V)
# 2. Cross-compilation untuk berbagai target
# 3. Cultural validation dan testing
# 4. Automated ISO generation
# 5. Comprehensive error checking dan reporting

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("all", "kernel", "apps", "drivers", "boot", "iso", "test", "clean", "status", "validate")]
    [string]$Target = "all",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("x86", "x86_64", "arm", "arm64", "riscv")]
    [string]$Architecture = "x86_64",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("debug", "release", "cultural")]
    [string]$BuildType = "debug",
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose,
    
    [Parameter(Mandatory=$false)]
    [switch]$CulturalValidation,
    
    [Parameter(Mandatory=$false)]
    [switch]$GenerateISO,
    
    [Parameter(Mandatory=$false)]
    [switch]$RunTests
)

# Build configuration
$BuildConfig = @{
    Version = "1.0.0"
    BuildDate = Get-Date -Format "yyyyMMdd"
    BuildTime = Get-Date -Format "HHmmss"
    Architecture = $Architecture
    BuildType = $BuildType
    RootDir = $PSScriptRoot
    BuildDir = Join-Path $PSScriptRoot "build"
    OutputDir = Join-Path $PSScriptRoot "output"
    ISODir = Join-Path $PSScriptRoot "iso"
    TestDir = Join-Path $PSScriptRoot "tests"
}

# Color output functions
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    
    $colors = @{
        "Red" = [ConsoleColor]::Red
        "Green" = [ConsoleColor]::Green
        "Yellow" = [ConsoleColor]::Yellow
        "Blue" = [ConsoleColor]::Blue
        "Magenta" = [ConsoleColor]::Magenta
        "Cyan" = [ConsoleColor]::Cyan
        "White" = [ConsoleColor]::White
    }
    
    Write-Host $Message -ForegroundColor $colors[$Color]
}

function Write-Success { param([string]$Message) Write-ColorOutput "✅ $Message" "Green" }
function Write-Error { param([string]$Message) Write-ColorOutput "❌ $Message" "Red" }
function Write-Warning { param([string]$Message) Write-ColorOutput "⚠️  $Message" "Yellow" }
function Write-Info { param([string]$Message) Write-ColorOutput "ℹ️  $Message" "Blue" }
function Write-Cultural { param([string]$Message) Write-ColorOutput "🎨 $Message" "Magenta" }

# Header dengan budaya Indonesia
function Show-BuildHeader {
    Write-Host ""
    Write-ColorOutput "=============================================" "Cyan"
    Write-ColorOutput "    KHATULISTIWA OS - ADVANCED BUILD SYSTEM" "Cyan"
    Write-ColorOutput "    Sistem Operasi Indonesia" "Yellow"
    Write-ColorOutput "=============================================" "Cyan"
    Write-Host ""
    Write-Info "Version: $($BuildConfig.Version)"
    Write-Info "Architecture: $($BuildConfig.Architecture)"
    Write-Info "Build Type: $($BuildConfig.BuildType)"
    Write-Info "Build Date: $($BuildConfig.BuildDate)"
    Write-Host ""
}

# Initialize build environment
function Initialize-BuildEnvironment {
    Write-Info "Initializing build environment..."
    
    # Create build directories
    $dirs = @($BuildConfig.BuildDir, $BuildConfig.OutputDir, $BuildConfig.ISODir, $BuildConfig.TestDir)
    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Success "Created directory: $dir"
        }
    }
    
    # Check required tools
    $requiredTools = @("python", "gcc", "make", "nasm")
    foreach ($tool in $requiredTools) {
        try {
            $null = Get-Command $tool -ErrorAction Stop
            Write-Success "Found required tool: $tool"
        }
        catch {
            Write-Warning "Required tool not found: $tool"
        }
    }
    
    # Setup cross-compilation toolchain
    Setup-CrossCompilationToolchain
}

# Setup cross-compilation toolchain
function Setup-CrossCompilationToolchain {
    Write-Info "Setting up cross-compilation toolchain for $($BuildConfig.Architecture)..."
    
    switch ($BuildConfig.Architecture) {
        "x86" {
            $env:CC = "i686-elf-gcc"
            $env:AS = "i686-elf-as"
            $env:LD = "i686-elf-ld"
        }
        "x86_64" {
            $env:CC = "x86_64-elf-gcc"
            $env:AS = "x86_64-elf-as"
            $env:LD = "x86_64-elf-ld"
        }
        "arm" {
            $env:CC = "arm-none-eabi-gcc"
            $env:AS = "arm-none-eabi-as"
            $env:LD = "arm-none-eabi-ld"
        }
        "arm64" {
            $env:CC = "aarch64-none-elf-gcc"
            $env:AS = "aarch64-none-elf-as"
            $env:LD = "aarch64-none-elf-ld"
        }
        "riscv" {
            $env:CC = "riscv64-unknown-elf-gcc"
            $env:AS = "riscv64-unknown-elf-as"
            $env:LD = "riscv64-unknown-elf-ld"
        }
    }
    
    Write-Success "Cross-compilation toolchain configured for $($BuildConfig.Architecture)"
}

# Build kernel
function Build-Kernel {
    Write-Info "Building Khatulistiwa kernel for $($BuildConfig.Architecture)..."
    
    $kernelDir = Join-Path $BuildConfig.RootDir "kernel"
    $kernelOutput = Join-Path $BuildConfig.OutputDir "khatkernel-$($BuildConfig.Architecture)"
    
    # Compile kernel sources
    $kernelSources = @(
        "core/khatkernel.khat",
        "memory/memory_manager.khat",
        "scheduler/process_scheduler.khat",
        "cultural/cultural_kernel.khat"
    )
    
    foreach ($source in $kernelSources) {
        $sourcePath = Join-Path $kernelDir $source
        if (Test-Path $sourcePath) {
            Write-Info "Compiling kernel source: $source"
            
            # Compile with KhatDev
            $result = & python "sdk/tools/khatdev.py" compile $sourcePath --arch $BuildConfig.Architecture --type $BuildConfig.BuildType
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to compile kernel source: $source"
                return $false
            }
        }
    }
    
    # Link kernel
    Write-Info "Linking kernel..."
    $linkScript = Join-Path $kernelDir "linker-$($BuildConfig.Architecture).ld"
    
    if (Test-Path $linkScript) {
        # Use architecture-specific linker script
        $linkResult = & $env:LD -T $linkScript -o $kernelOutput
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Kernel linking failed"
            return $false
        }
    }
    
    Write-Success "Kernel built successfully: $kernelOutput"
    return $true
}

# Build applications
function Build-Applications {
    Write-Info "Building Khatulistiwa applications..."
    
    $appsDir = Join-Path $BuildConfig.RootDir "apps/system"
    $appsList = Get-ChildItem -Path $appsDir -Directory
    
    $successCount = 0
    $totalCount = $appsList.Count
    
    foreach ($app in $appsList) {
        Write-Info "Building application: $($app.Name)"
        
        $appPath = $app.FullName
        $manifestPath = Join-Path $appPath "manifest.json"
        
        if (Test-Path $manifestPath) {
            # Build with KhatDev
            $result = & python "sdk/tools/khatdev.py" build $appPath --arch $BuildConfig.Architecture --type $BuildConfig.BuildType
            
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Built application: $($app.Name)"
                $successCount++
                
                # Cultural validation if enabled
                if ($CulturalValidation) {
                    Validate-CulturalCompliance $appPath
                }
            }
            else {
                Write-Error "Failed to build application: $($app.Name)"
            }
        }
        else {
            Write-Warning "No manifest found for application: $($app.Name)"
        }
    }
    
    Write-Info "Applications built: $successCount/$totalCount"
    return ($successCount -eq $totalCount)
}

# Build drivers
function Build-Drivers {
    Write-Info "Building Khatulistiwa drivers..."
    
    $driversDir = Join-Path $BuildConfig.RootDir "drivers"
    $driverCategories = @("graphics", "audio", "network", "storage", "input", "cultural")
    
    $successCount = 0
    $totalCount = 0
    
    foreach ($category in $driverCategories) {
        $categoryDir = Join-Path $driversDir $category
        if (Test-Path $categoryDir) {
            $drivers = Get-ChildItem -Path $categoryDir -Filter "*.khat"
            $totalCount += $drivers.Count
            
            foreach ($driver in $drivers) {
                Write-Info "Building driver: $($driver.BaseName)"
                
                # Compile driver
                $result = & python "sdk/tools/khatdev.py" compile $driver.FullName --arch $BuildConfig.Architecture --type driver
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Built driver: $($driver.BaseName)"
                    $successCount++
                }
                else {
                    Write-Error "Failed to build driver: $($driver.BaseName)"
                }
            }
        }
    }
    
    Write-Info "Drivers built: $successCount/$totalCount"
    return ($successCount -eq $totalCount)
}

# Build bootloader
function Build-Bootloader {
    Write-Info "Building Khatulistiwa bootloader for $($BuildConfig.Architecture)..."
    
    $bootDir = Join-Path $BuildConfig.RootDir "boot"
    $bootOutput = Join-Path $BuildConfig.OutputDir "khatboot-$($BuildConfig.Architecture)"
    
    switch ($BuildConfig.Architecture) {
        "x86" {
            # Build legacy BIOS bootloader
            $bootSource = Join-Path $bootDir "bootloader/khatboot.asm"
            if (Test-Path $bootSource) {
                $result = & nasm -f bin $bootSource -o "$bootOutput.bin"
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Built legacy bootloader"
                    return $true
                }
            }
        }
        "x86_64" {
            # Build UEFI bootloader
            $uefiSource = Join-Path $bootDir "uefi/uefi_khatboot.c"
            if (Test-Path $uefiSource) {
                $result = & $env:CC -ffreestanding -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -I uefi-headers -c $uefiSource -o "$bootOutput.o"
                if ($LASTEXITCODE -eq 0) {
                    $result = & $env:LD -shared -Bsymbolic -L uefi-lib -T uefi.lds "$bootOutput.o" -o "$bootOutput.efi" -lgnuefi -lefi
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success "Built UEFI bootloader"
                        return $true
                    }
                }
            }
        }
        "arm64" {
            # Build ARM64 bootloader
            $armSource = Join-Path $bootDir "arm/arm64_boot.S"
            if (Test-Path $armSource) {
                $result = & $env:AS $armSource -o "$bootOutput.o"
                if ($LASTEXITCODE -eq 0) {
                    $result = & $env:LD "$bootOutput.o" -o "$bootOutput.elf"
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success "Built ARM64 bootloader"
                        return $true
                    }
                }
            }
        }
        "riscv" {
            # Build RISC-V bootloader
            $riscvSource = Join-Path $bootDir "riscv/riscv_boot.S"
            if (Test-Path $riscvSource) {
                $result = & $env:AS $riscvSource -o "$bootOutput.o"
                if ($LASTEXITCODE -eq 0) {
                    $result = & $env:LD "$bootOutput.o" -o "$bootOutput.elf"
                    if ($LASTEXITCODE -eq 0) {
                        Write-Success "Built RISC-V bootloader"
                        return $true
                    }
                }
            }
        }
    }
    
    Write-Error "Failed to build bootloader for $($BuildConfig.Architecture)"
    return $false
}

# Validate cultural compliance
function Validate-CulturalCompliance {
    param([string]$AppPath)
    
    Write-Cultural "Validating cultural compliance for: $AppPath"
    
    $manifestPath = Join-Path $AppPath "manifest.json"
    if (Test-Path $manifestPath) {
        $manifest = Get-Content $manifestPath | ConvertFrom-Json
        
        # Check cultural elements
        $culturalChecks = @{
            "has_cultural_name" = $null -ne $manifest.cultural_name
            "has_batik_theme" = $null -ne $manifest.cultural.batik_theme
            "has_indonesian_terminology" = $manifest.name -match "Khat"
            "has_cultural_description" = $manifest.description -match "(budaya|Indonesia|tradisional)"
        }
        
        $passedChecks = 0
        $totalChecks = $culturalChecks.Count
        
        foreach ($check in $culturalChecks.GetEnumerator()) {
            if ($check.Value) {
                Write-Success "✓ $($check.Key)"
                $passedChecks++
            }
            else {
                Write-Warning "✗ $($check.Key)"
            }
        }
        
        $complianceScore = [math]::Round(($passedChecks / $totalChecks) * 100, 2)
        
        if ($complianceScore -ge 80) {
            Write-Cultural "Cultural compliance: $complianceScore% - EXCELLENT"
        }
        elseif ($complianceScore -ge 60) {
            Write-Warning "Cultural compliance: $complianceScore% - GOOD"
        }
        else {
            Write-Error "Cultural compliance: $complianceScore% - NEEDS IMPROVEMENT"
        }
    }
}

# Generate ISO image
function Generate-ISOImage {
    Write-Info "Generating Khatulistiwa OS ISO image..."
    
    $isoStructure = @{
        "boot" = @{
            "khatboot.bin" = Join-Path $BuildConfig.OutputDir "khatboot-$($BuildConfig.Architecture).bin"
            "khatkernel" = Join-Path $BuildConfig.OutputDir "khatkernel-$($BuildConfig.Architecture)"
            "khat-initrd.img" = Join-Path $BuildConfig.OutputDir "khat-initrd.img"
        }
        "system" = @{
            "apps" = Join-Path $BuildConfig.RootDir "apps/system"
            "drivers" = Join-Path $BuildConfig.OutputDir "drivers"
        }
        "cultural" = @{
            "batik" = Join-Path $BuildConfig.RootDir "cultural/batik"
            "gamelan" = Join-Path $BuildConfig.RootDir "cultural/gamelan"
            "wayang" = Join-Path $BuildConfig.RootDir "cultural/wayang"
        }
    }
    
    # Create ISO directory structure
    foreach ($category in $isoStructure.GetEnumerator()) {
        $categoryDir = Join-Path $BuildConfig.ISODir $category.Key
        New-Item -ItemType Directory -Path $categoryDir -Force | Out-Null
        
        foreach ($item in $category.Value.GetEnumerator()) {
            $sourcePath = $item.Value
            $destPath = Join-Path $categoryDir $item.Key
            
            if (Test-Path $sourcePath) {
                if (Test-Path $sourcePath -PathType Container) {
                    Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
                }
                else {
                    Copy-Item -Path $sourcePath -Destination $destPath -Force
                }
                Write-Success "Added to ISO: $($item.Key)"
            }
            else {
                Write-Warning "Missing for ISO: $($item.Key)"
            }
        }
    }
    
    # Generate ISO using available tools
    $isoFile = Join-Path $BuildConfig.OutputDir "khatulistiwa-os-$($BuildConfig.Architecture)-$($BuildConfig.BuildDate).iso"
    
    try {
        # Try using mkisofs or genisoimage
        $mkisofs = Get-Command mkisofs -ErrorAction SilentlyContinue
        if ($mkisofs) {
            $result = & mkisofs -o $isoFile -b boot/khatboot.bin -c boot/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table $BuildConfig.ISODir
        }
        else {
            $genisoimage = Get-Command genisoimage -ErrorAction SilentlyContinue
            if ($genisoimage) {
                $result = & genisoimage -o $isoFile -b boot/khatboot.bin -c boot/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table $BuildConfig.ISODir
            }
            else {
                Write-Warning "No ISO creation tool found (mkisofs/genisoimage)"
                return $false
            }
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "ISO image created: $isoFile"
            return $true
        }
        else {
            Write-Error "ISO creation failed"
            return $false
        }
    }
    catch {
        Write-Error "ISO creation error: $($_.Exception.Message)"
        return $false
    }
}

# Run tests
function Run-Tests {
    Write-Info "Running Khatulistiwa OS tests..."
    
    $testResults = @{
        "unit_tests" = 0
        "cultural_tests" = 0
        "integration_tests" = 0
        "performance_tests" = 0
    }
    
    # Unit tests
    Write-Info "Running unit tests..."
    $unitTestResult = & python "sdk/tools/khatdev.py" test --type unit
    if ($LASTEXITCODE -eq 0) {
        $testResults.unit_tests = 1
        Write-Success "Unit tests passed"
    }
    else {
        Write-Error "Unit tests failed"
    }
    
    # Cultural tests
    if ($CulturalValidation) {
        Write-Cultural "Running cultural compliance tests..."
        $culturalTestResult = & python "sdk/tools/khatdev.py" test --type cultural
        if ($LASTEXITCODE -eq 0) {
            $testResults.cultural_tests = 1
            Write-Success "Cultural tests passed"
        }
        else {
            Write-Error "Cultural tests failed"
        }
    }
    
    # Integration tests
    Write-Info "Running integration tests..."
    $integrationTestResult = & python "sdk/tools/khatdev.py" test --type integration
    if ($LASTEXITCODE -eq 0) {
        $testResults.integration_tests = 1
        Write-Success "Integration tests passed"
    }
    else {
        Write-Error "Integration tests failed"
    }
    
    # Performance tests
    Write-Info "Running performance tests..."
    $performanceTestResult = & python "sdk/tools/khatdev.py" test --type performance
    if ($LASTEXITCODE -eq 0) {
        $testResults.performance_tests = 1
        Write-Success "Performance tests passed"
    }
    else {
        Write-Error "Performance tests failed"
    }
    
    # Test summary
    $passedTests = ($testResults.Values | Measure-Object -Sum).Sum
    $totalTests = $testResults.Count
    
    Write-Info "Test Results: $passedTests/$totalTests passed"
    
    return ($passedTests -eq $totalTests)
}

# Show build status
function Show-BuildStatus {
    Write-Info "Khatulistiwa OS Build Status"
    Write-Host ""
    
    # Check kernel
    $kernelPath = Join-Path $BuildConfig.OutputDir "khatkernel-$($BuildConfig.Architecture)"
    if (Test-Path $kernelPath) {
        Write-Success "Kernel: Built"
    }
    else {
        Write-Error "Kernel: Not built"
    }
    
    # Check applications
    $appsDir = Join-Path $BuildConfig.RootDir "apps/system"
    $appsList = Get-ChildItem -Path $appsDir -Directory
    $builtApps = 0
    
    foreach ($app in $appsList) {
        $appOutput = Join-Path $BuildConfig.OutputDir "apps/$($app.Name).khapp"
        if (Test-Path $appOutput) {
            $builtApps++
        }
    }
    
    Write-Info "Applications: $builtApps/$($appsList.Count) built"
    
    # Check bootloader
    $bootPath = Join-Path $BuildConfig.OutputDir "khatboot-$($BuildConfig.Architecture)*"
    if (Get-ChildItem -Path $bootPath -ErrorAction SilentlyContinue) {
        Write-Success "Bootloader: Built"
    }
    else {
        Write-Error "Bootloader: Not built"
    }
    
    # Check ISO
    $isoPath = Join-Path $BuildConfig.OutputDir "khatulistiwa-os-*.iso"
    if (Get-ChildItem -Path $isoPath -ErrorAction SilentlyContinue) {
        Write-Success "ISO: Generated"
    }
    else {
        Write-Warning "ISO: Not generated"
    }
}

# Clean build artifacts
function Clean-BuildArtifacts {
    Write-Info "Cleaning build artifacts..."
    
    $cleanDirs = @($BuildConfig.BuildDir, $BuildConfig.OutputDir, $BuildConfig.ISODir)
    
    foreach ($dir in $cleanDirs) {
        if (Test-Path $dir) {
            Remove-Item -Path $dir -Recurse -Force
            Write-Success "Cleaned: $dir"
        }
    }
    
    Write-Success "Build artifacts cleaned"
}

# Main build function
function Start-Build {
    Show-BuildHeader
    Initialize-BuildEnvironment
    
    $buildSuccess = $true
    
    switch ($Target) {
        "all" {
            $buildSuccess = (Build-Kernel) -and (Build-Applications) -and (Build-Drivers) -and (Build-Bootloader)
            if ($GenerateISO -and $buildSuccess) {
                $buildSuccess = Generate-ISOImage
            }
            if ($RunTests -and $buildSuccess) {
                $buildSuccess = Run-Tests
            }
        }
        "kernel" { $buildSuccess = Build-Kernel }
        "apps" { $buildSuccess = Build-Applications }
        "drivers" { $buildSuccess = Build-Drivers }
        "boot" { $buildSuccess = Build-Bootloader }
        "iso" { $buildSuccess = Generate-ISOImage }
        "test" { $buildSuccess = Run-Tests }
        "clean" { Clean-BuildArtifacts; return }
        "status" { Show-BuildStatus; return }
        "validate" { 
            $CulturalValidation = $true
            $buildSuccess = Build-Applications
        }
    }
    
    # Build summary
    Write-Host ""
    Write-ColorOutput "=============================================" "Cyan"
    if ($buildSuccess) {
        Write-Success "BUILD SUCCESSFUL - Khatulistiwa OS siap!"
        Write-Cultural "Sistem operasi Indonesia berhasil dibangun!"
    }
    else {
        Write-Error "BUILD FAILED - Ada masalah dalam proses build"
        Write-Warning "Periksa log error di atas untuk detail"
    }
    Write-ColorOutput "=============================================" "Cyan"
    Write-Host ""
}

# Execute build
Start-Build
