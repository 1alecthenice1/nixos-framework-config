# NixOS Framework Configuration

Basic NixOS configuration for Framework Laptop   sudo## Installation with Encryption

⚠️ **CRITICAL**: Follow this EXACT sequence to avoid PCR 7 conflicts that will prevent booting!

### Step 1: Boot and Install
1. **Boot from NixOS installer ISO**
   ```bash
   # The ISO has Secure Boot disabled - this is correct for installation
   ```

2. **Partition your disk with disko:**
   ```bash
   sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko/framework-luks-btrfs.nix
   ```

3. **Install NixOS:**
   ```bash
   sudo nixos-install --flake .#framework
   ```

### Step 2: Reboot to Installed System
```bash
sudo reboot
# Boot into the newly installed system (NOT the ISO)
```

### Step 3: Setup Secure Boot Infrastructure
```bash
# Run the automated Secure Boot setup script
sudo ./scripts/setup-secureboot.sh
```

This script will:
- Create Secure Boot keys
- Enroll keys (including Microsoft compatibility keys)
- Rebuild the system with Secure Boot support
- Prepare for BIOS activation

### Step 4: Enable Secure Boot in BIOS
```bash
sudo reboot
```
1. **Enter BIOS/UEFI** (usually F2 during startup)
2. **Navigate to Security settings**
3. **Enable Secure Boot**
4. **Save and exit**

### Step 5: Verify and Enroll TPM
```bash
# Verify Secure Boot is active
sudo sbctl status

# Now enroll TPM with correct PCR 7 values
sudo ./scripts/tpm-enroll.sh
```

### Step 6: Test TPM Unlock
```bash
sudo reboot
# System should unlock automatically with TPM
# If not, use your LUKS password and check the logs
```--flake .#framework
   ```
4. **Reboot and setup Secure Boot:**
   ```bash
   sudo reboot
   # After reboot:
   sudo ./scripts/setup-secureboot.sh
   # Enable Secure Boot in BIOS, then:
   sudo ./scripts/tpm-enroll.sh
   ```

## Security Notes & Warnings

### ⚠️ CRITICAL SEQUENCE REQUIREMENTS
- **NEVER enroll TPM from the live ISO** - PCR 7 values will be wrong
- **NEVER enroll TPM before enabling Secure Boot** - PCR 7 values will change
- **ALWAYS follow the exact 6-step sequence above** - skipping steps breaks boot
- **Enable Secure Boot in BIOS BEFORE TPM enrollment** - final PCR 7 values needed

### 🔐 Security Best Practices
- **Always keep your LUKS password** - TPM can fail during updates or hardware changes
- **Test TPM unlock after enrollment** - verify it works before relying on it
- **Backup LUKS headers before major changes** - allows recovery if TPM fails
- **Understand the 3-stage boot process** - ISO → Installed → Secure Boot enabled

### �️ Troubleshooting
- **System won't boot after TPM enrollment**: Use LUKS password, re-enroll TPM
- **TPM enrollment fails**: Check Secure Boot status with `sudo sbctl status`  
- **Secure Boot shows disabled**: Re-run setup-secureboot.sh and enable in BIOS
- **Boot takes long time**: Normal during first boot with new keys

### 📚 Why This Sequence Matters
The **PCR 7 register** contains measurements of the boot process. Different boot states create different PCR 7 values:

1. **ISO boot**: PCR 7 = ISO certificates (temporary)
2. **Installed system without Secure Boot**: PCR 7 = lanzaboote without Secure Boot 
3. **Installed system with Secure Boot**: PCR 7 = lanzaboote + Secure Boot (final)

TPM will **only unlock** if current PCR 7 matches enrollment PCR 7. Enrolling in wrong state = **system won't boot**.series.

## Status: Production Ready! 🚀

This is a minimal, working NixOS configuration that includes:

- 🏠 Basic Framework hardware support
- 👤 User configuration for alma
- 🔒 Basic security settings
- 📦 Essential packages

## Configuration Details

- **Username:** alma
- **Full Name:** alec  
- **Email:** aleckillian44@proton.me
- **GitHub:** 1alecthenice1
- **Timezone:** America/New_York

## Next Steps

1. **Test the configuration:**
   ```bash
   nix flake check
   nix build .#nixosConfigurations.framework.config.system.build.toplevel
   ```

2. **Test in a VM:**
   ```bash
   nix build .#nixosConfigurations.framework.config.system.build.vm
   ./result/bin/run-*-vm
   ```

3. **Add more features incrementally:**
   - TPM encryption
   - Secure Boot
   - Desktop environment
   - Advanced partitioning

## Installation

This is a basic configuration. For actual installation, you'll need to:
1. Boot from NixOS installer
2. Partition your disk manually
3. Generate hardware-configuration.nix
4. Install with this flake

## Development

This repository is set up for incremental development. You can safely:
- Add new modules in `modules/`
- Extend the flake with additional inputs
- Test changes in VMs before installation

## Contributing

Feel free to submit issues and enhancement requests!

## 🔐 Encryption Features Added

This configuration now includes:

- 🔒 **LUKS disk encryption** with btrfs subvolumes
- 🛡️ **TPM 2.0 support** for hardware-backed encryption
- 🔐 **Secure Boot** support with lanzaboote
- 📦 **Declarative partitioning** with disko
- ⚡ **Optimized boot** configuration

## Installation with Encryption

1. **Boot from NixOS installer**
2. **Partition with disko:**
   ```bash
   sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko/framework-luks-btrfs.nix
   ```
3. **Install NixOS:**
   ```bash
   sudo nixos-install --flake .#framework
   ```
4. **After reboot, enroll TPM:**
   ```bash
   sudo ./scripts/tpm-enroll.sh
   ```

## Security Notes

- ⚠️ **Always keep your LUKS password** - TPM can fail
- 🔄 **Test TPM unlock** before relying on it
- 💾 **Backup LUKS headers** before major changes
- 🛡️ **Secure Boot** requires additional BIOS setup


## 🖥️ Desktop Environment Features

This configuration now includes a complete desktop environment:

### **Desktop Environment**
- 🌊 **Hyprland** - Modern Wayland compositor
- 🎨 **Waybar** - Beautiful status bar
- 🔔 **Dunst** - Notification daemon
- 🚀 **Rofi** - Application launcher
- 🔒 **Swaylock** - Screen locker

### **Applications**
- 🌐 **Firefox & Chromium** - Web browsers
- 💬 **Discord, Telegram** - Communication
- 🎵 **Spotify, VLC** - Media players
- 📝 **VSCode, LibreOffice** - Productivity
- 🗂️ **Nautilus** - File manager

### **Networking & Hardware**
- 📡 **NetworkManager** - GUI network management
- 🔵 **Bluetooth** - Full BT support with Blueman
- 🖨️ **Printing** - CUPS with common drivers
- 📹 **Webcam** - Camera support
- 🔊 **PipeWire** - Low-latency audio

### **Hardware Optimization**
- ⚡ **Framework-specific** optimizations
- 🎮 **AMD GPU** acceleration
- 🐳 **Docker & VMs** - Development ready
- 🔧 **Framework tools** - EC control, firmware updates

### **Memory Management (64GB Optimized)**
- 💾 **25% zram swap** (16GB) - Emergency swap
- 🚀 **Low swappiness** (5) - Prefer RAM
- ⚡ **Optimized dirty ratios** - Better performance
- 📊 **Memory monitoring** - Hourly reports

## Quick Start Commands

```bash
# System management
rebuild          # Rebuild system
update           # Update system  
clean            # Clean old generations

# Hardware info
hardware-info    # System hardware details
battery-info     # Battery status
temp-check       # Temperature sensors

# Screenshots
Super + Print    # Area screenshot to clipboard

# Window management
Super + Q        # Terminal
Super + R        # App launcher
Super + E        # File manager
Super + 1-5      # Switch workspaces
```

## Performance Notes

- **Memory**: Optimized for 64GB RAM with minimal swapping
- **Graphics**: Hardware acceleration enabled for AMD GPU
- **Audio**: Low-latency PipeWire configuration
- **Power**: Framework-specific power management
- **Storage**: Btrfs with compression and optimized mount options

