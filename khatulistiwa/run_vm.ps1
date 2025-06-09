# ============================================================================
# run_vm.ps1 - Virtual Machine Runner untuk Khatulistiwa OS
# Copyright (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group
# ============================================================================
# 
# VM Runner dengan fitur:
# 1. QEMU virtual machine support
# 2. VirtualBox integration
# 3. VMware compatibility
# 4. Cultural VM configuration
# 5. Multi-platform VM support
# 6. Development environment setup

param(
    [string]$VMType = "qemu",
    [string]$Architecture = "x86_64",
    [int]$Memory = 2048,
    [int]$CPUs = 2,
    [string]$ISOPath = "",
    [switch]$EnableKVM = $false,
    [switch]$EnableGraphics = $true,
    [switch]$EnableAudio = $true,
    [switch]$EnableNetwork = $true,
    [switch]$CulturalMode = $true
)

# VM Configuration
$VMConfig = @{
    Name = "Khatulistiwa-OS"
    Version = "2.0.0"
    Memory = $Memory
    CPUs = $CPUs
    Architecture = $Architecture
    DiskSize = "20G"
    NetworkType = "user"
    AudioType = "hda"
    GraphicsType = "std"
}

function Write-VMLog {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Type) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        "Cultural" { "Magenta" }
        default { "Cyan" }
    }
    
    $prefix = switch ($Type) {
        "Success" { "[OK]" }
        "Warning" { "[!!]" }
        "Error" { "[XX]" }
        "Cultural" { "[**]" }
        default { "[--]" }
    }
    
    Write-Host "$timestamp $prefix $Message" -ForegroundColor $color
}

function Show-VMHeader {
    Clear-Host
    Write-Host "
===============================================================================
                        KHATULISTIWA OS VIRTUAL MACHINE                       
                               Runner v2.0.0                                  
                                                                               
              Teknologi Modern dengan Jiwa Indonesia                         
                                                                               
              (c) 2025 Dhafa Nazula Permadi & Team BIGCode By Cv Bintang Gumilang Group                     
===============================================================================
" -ForegroundColor Cyan
    
    Write-VMLog "Starting Khatulistiwa OS Virtual Machine..." "Info"
    Write-VMLog "VM Type: $VMType | Architecture: $Architecture" "Info"
    Write-VMLog "Memory: $($Memory)MB | CPUs: $CPUs" "Info"
    if ($CulturalMode) {
        Write-VMLog "Cultural mode enabled - VM akan diberkahi" "Cultural"
    }
    Write-Host ""
}

function Test-VMPrerequisites {
    Write-VMLog "Checking VM prerequisites..." "Info"
    
    $prerequisites = @()
    
    switch ($VMType.ToLower()) {
        "qemu" {
            $prerequisites += @{
                Name = "QEMU"
                Command = "qemu-system-x86_64 --version"
                Required = $true
            }
        }
        "virtualbox" {
            $prerequisites += @{
                Name = "VirtualBox"
                Command = "VBoxManage --version"
                Required = $true
            }
        }
        "vmware" {
            $prerequisites += @{
                Name = "VMware"
                Command = "vmrun"
                Required = $true
            }
        }
    }
    
    $allGood = $true
    
    foreach ($prereq in $prerequisites) {
        try {
            $null = Invoke-Expression $prereq.Command 2>$null
            Write-VMLog "$($prereq.Name): Available" "Success"
        }
        catch {
            if ($prereq.Required) {
                Write-VMLog "$($prereq.Name): Missing (Required)" "Error"
                $allGood = $false
            } else {
                Write-VMLog "$($prereq.Name): Missing (Optional)" "Warning"
            }
        }
    }
    
    return $allGood
}

function Find-KhatulistiwaISO {
    Write-VMLog "Looking for Khatulistiwa OS ISO..." "Info"
    
    if ($ISOPath -and (Test-Path $ISOPath)) {
        Write-VMLog "Using specified ISO: $ISOPath" "Success"
        return $ISOPath
    }
    
    # Search for ISO files
    $searchPaths = @(
        "khatulistiwa-os-v*.iso",
        "build/khatulistiwa-os-v*.iso",
        "dist/khatulistiwa-os-v*.iso",
        "*.iso"
    )
    
    foreach ($pattern in $searchPaths) {
        $isoFiles = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
        if ($isoFiles) {
            $latestISO = $isoFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            Write-VMLog "Found ISO: $($latestISO.FullName)" "Success"
            return $latestISO.FullName
        }
    }
    
    Write-VMLog "No Khatulistiwa OS ISO found. Please build the system first." "Warning"
    Write-VMLog "Run: powershell -ExecutionPolicy Bypass -File build_production.ps1 -CreateISO" "Info"
    return $null
}

function Invoke-CulturalVMBlessing {
    if (-not $CulturalMode) {
        return
    }
    
    Write-VMLog "Performing cultural VM blessing..." "Cultural"
    Write-Host ""
    
    Write-Host "Bismillahirrahmanirrahim..." -ForegroundColor Blue
    Start-Sleep -Seconds 1
    
    Write-Host "Semoga virtual machine ini berjalan dengan lancar..." -ForegroundColor Magenta
    Start-Sleep -Seconds 1
    
    Write-Host "Dengan berkah Pancasila dan Garuda..." -ForegroundColor Magenta
    Start-Sleep -Seconds 1
    
    Write-Host "Untuk kemajuan teknologi Indonesia..." -ForegroundColor Magenta
    Start-Sleep -Seconds 1
    
    Write-Host ""
    Write-VMLog "VM blessing completed" "Cultural"
}

function Start-QEMUMachine {
    param([string]$ISOPath)
    
    Write-VMLog "Starting QEMU virtual machine..." "Info"
    
    # Build QEMU command
    $qemuCmd = @(
        "qemu-system-$Architecture"
        "-name", "`"$($VMConfig.Name)`""
        "-m", $VMConfig.Memory
        "-smp", $VMConfig.CPUs
    )
    
    # Add ISO
    if ($ISOPath) {
        $qemuCmd += @("-cdrom", "`"$ISOPath`"")
    }
    
    # Add hard disk
    $diskPath = "khatulistiwa-disk.qcow2"
    if (-not (Test-Path $diskPath)) {
        Write-VMLog "Creating virtual disk: $diskPath" "Info"
        & qemu-img create -f qcow2 $diskPath $VMConfig.DiskSize
    }
    $qemuCmd += @("-hda", "`"$diskPath`"")
    
    # Graphics
    if ($EnableGraphics) {
        $qemuCmd += @("-vga", $VMConfig.GraphicsType)
    } else {
        $qemuCmd += @("-nographic")
    }
    
    # Audio
    if ($EnableAudio) {
        $qemuCmd += @("-audiodev", "dsound,id=audio0", "-device", "AC97,audiodev=audio0")
    }
    
    # Network
    if ($EnableNetwork) {
        $qemuCmd += @("-netdev", "user,id=net0", "-device", "e1000,netdev=net0")
    }
    
    # KVM acceleration (Linux only)
    if ($EnableKVM -and $IsLinux) {
        $qemuCmd += @("-enable-kvm")
    }
    
    # Boot order
    $qemuCmd += @("-boot", "d")
    
    # Cultural enhancements
    if ($CulturalMode) {
        $qemuCmd += @("-name", "`"Khatulistiwa OS - Teknologi Berbudaya`"")
    }
    
    Write-VMLog "QEMU Command: $($qemuCmd -join ' ')" "Info"
    Write-VMLog "Starting VM with cultural blessing..." "Cultural"
    
    # Start QEMU
    try {
        & $qemuCmd[0] $qemuCmd[1..($qemuCmd.Length-1)]
    }
    catch {
        Write-VMLog "Failed to start QEMU: $($_.Exception.Message)" "Error"
        return $false
    }
    
    return $true
}

function Start-VirtualBoxMachine {
    param([string]$ISOPath)
    
    Write-VMLog "Starting VirtualBox virtual machine..." "Info"
    
    $vmName = $VMConfig.Name
    
    # Check if VM exists
    try {
        $existingVM = & VBoxManage showvminfo $vmName 2>$null
        if ($existingVM) {
            Write-VMLog "VM '$vmName' already exists. Starting existing VM..." "Info"
            & VBoxManage startvm $vmName --type gui
            return $true
        }
    }
    catch {
        # VM doesn't exist, create new one
    }
    
    Write-VMLog "Creating new VirtualBox VM: $vmName" "Info"
    
    try {
        # Create VM
        & VBoxManage createvm --name $vmName --ostype "Linux_64" --register
        
        # Configure VM
        & VBoxManage modifyvm $vmName --memory $VMConfig.Memory
        & VBoxManage modifyvm $vmName --cpus $VMConfig.CPUs
        & VBoxManage modifyvm $vmName --vram 128
        & VBoxManage modifyvm $vmName --graphicscontroller vmsvga
        
        if ($EnableAudio) {
            & VBoxManage modifyvm $vmName --audio dsound --audiocontroller ac97
        }
        
        if ($EnableNetwork) {
            & VBoxManage modifyvm $vmName --nic1 nat
        }
        
        # Create and attach hard disk
        $diskPath = "khatulistiwa-disk.vdi"
        & VBoxManage createhd --filename $diskPath --size 20480
        & VBoxManage storagectl $vmName --name "SATA Controller" --add sata --controller IntelAhci
        & VBoxManage storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $diskPath
        
        # Attach ISO
        if ($ISOPath) {
            & VBoxManage storagectl $vmName --name "IDE Controller" --add ide
            & VBoxManage storageattach $vmName --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $ISOPath
        }
        
        # Start VM
        Write-VMLog "Starting VirtualBox VM with cultural blessing..." "Cultural"
        & VBoxManage startvm $vmName --type gui
        
        return $true
    }
    catch {
        Write-VMLog "Failed to create/start VirtualBox VM: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Start-VMwareMachine {
    param([string]$ISOPath)
    
    Write-VMLog "VMware support is experimental" "Warning"
    Write-VMLog "Please use QEMU or VirtualBox for best experience" "Info"
    return $false
}

function Show-VMInstructions {
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host "                        KHATULISTIWA OS VM STARTED                           " -ForegroundColor Green
    Write-Host "===============================================================================" -ForegroundColor Green
    Write-Host ""
    
    Write-VMLog "Virtual machine telah dimulai dengan berkah!" "Success"
    Write-Host ""
    
    Write-Host "Instruksi penggunaan:" -ForegroundColor Yellow
    Write-Host "  1. Tunggu VM boot sampai muncul GRUB bootloader" -ForegroundColor White
    Write-Host "  2. Pilih 'Khatulistiwa OS (Default)' untuk boot normal" -ForegroundColor White
    Write-Host "  3. Atau pilih opsi lain sesuai kebutuhan" -ForegroundColor White
    Write-Host "  4. Nikmati pengalaman Khatulistiwa OS!" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Opsi boot yang tersedia:" -ForegroundColor Yellow
    Write-Host "  - Khatulistiwa OS (Default): Boot normal dengan semua fitur" -ForegroundColor White
    Write-Host "  - Safe Mode: Boot aman untuk troubleshooting" -ForegroundColor White
    Write-Host "  - Cultural Demo: Demo semua fitur budaya" -ForegroundColor White
    Write-Host "  - Recovery Mode: Mode pemulihan sistem" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Fitur yang dapat dicoba:" -ForegroundColor Yellow
    Write-Host "  - Khat Launcher: Peluncur aplikasi dengan tema budaya" -ForegroundColor White
    Write-Host "  - Khat Files: File manager dengan organisasi Rumah Adat" -ForegroundColor White
    Write-Host "  - Khat Calendar: Kalender multi-sistem (Gregorian, Hijri, Jawa)" -ForegroundColor White
    Write-Host "  - Khat Notes: Catatan dengan gaya naskah tradisional" -ForegroundColor White
    Write-Host "  - Gamelan Audio: Sistem audio dengan suara gamelan" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Selamat menjelajahi Khatulistiwa OS!" -ForegroundColor Green
    Write-Host "Indonesia Bisa! Merdeka! Bhinneka Tunggal Ika!" -ForegroundColor Red
    Write-Host ""
}

# Main VM execution
function Start-KhatulistiwaVM {
    try {
        Show-VMHeader
        
        # Check prerequisites
        if (-not (Test-VMPrerequisites)) {
            Write-VMLog "Prerequisites not met. Please install required VM software." "Error"
            return $false
        }
        
        # Find ISO
        $isoPath = Find-KhatulistiwaISO
        if (-not $isoPath) {
            Write-VMLog "No ISO found. Please build Khatulistiwa OS first." "Error"
            return $false
        }
        
        # Perform cultural blessing
        Invoke-CulturalVMBlessing
        
        # Start appropriate VM
        $success = $false
        switch ($VMType.ToLower()) {
            "qemu" {
                $success = Start-QEMUMachine -ISOPath $isoPath
            }
            "virtualbox" {
                $success = Start-VirtualBoxMachine -ISOPath $isoPath
            }
            "vmware" {
                $success = Start-VMwareMachine -ISOPath $isoPath
            }
            default {
                Write-VMLog "Unsupported VM type: $VMType" "Error"
                Write-VMLog "Supported types: qemu, virtualbox, vmware" "Info"
                return $false
            }
        }
        
        if ($success) {
            Show-VMInstructions
        }
        
        return $success
        
    } catch {
        Write-VMLog "Fatal error: $($_.Exception.Message)" "Error"
        return $false
    }
}

# Execute VM runner
Write-VMLog "Memulai Khatulistiwa OS Virtual Machine..." "Info"
$result = Start-KhatulistiwaVM

if ($result) {
    Write-VMLog "VM started successfully!" "Success"
    exit 0
} else {
    Write-VMLog "Failed to start VM" "Error"
    exit 1
}
