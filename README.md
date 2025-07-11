# NixOS Framework Configuration

Basic NixOS configuration for Framework Laptop   sudo nixos-install --flake .#framework
   ```
4. **Reboot and setup Secure Boot:**
   ```bash
   sudo reboot
   # After reboot:
   sudo ./scripts/setup-secureboot.sh
   # Enable Secure Boot in BIOS, then:
   sudo ./scripts/tpm-enroll.sh
   ```

## Security Notes

- ⚠️ **Always keep your LUKS password** - TPM can fail
- 🔄 **Enable Secure Boot BEFORE TPM enrollment** - critical for PCR 7 values
- 💾 **Backup LUKS headers** before major changes
- 🛡️ **Follow the exact sequence** - installation → Secure Boot → TPM enrollmentseries.

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


## 👤 User Configuration

**System configured for:**
- **Username:** users
- **Full Name:** alec
- **Email:** aleckillian44@proton.me
- **Timezone:** America/New_York

## 🚀 Ready for Installation!

Your Framework NixOS configuration is now complete and ready for deployment.

### Quick Installation Commands:

```bash
# 1. Boot from NixOS installer
# 2. Clone this repository
git clone https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME
cd YOUR_REPO_NAME

# 3. Partition and install
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko/framework-luks-btrfs.nix
sudo nixos-install --flake .#framework

# 4. Reboot and enroll TPM (optional)
sudo ./scripts/tpm-enroll.sh

# 5. Check system status
./scripts/system-info.sh
```

## 🎉 What You'll Get

- **Secure:** TPM + LUKS + Secure Boot
- **Fast:** Optimized for 64GB RAM with zram
- **Complete:** Full desktop environment with all applications
- **Framework-optimized:** All hardware features supported
- **User-friendly:** Hyprland with intuitive keybindings

Welcome to your new Framework NixOS system! 🎊
