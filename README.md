# NixOS Framework Laptop Configuration

A complete NixOS configuration optimized for Framework laptops with full disk encryption, TPM integration, and Secure Boot support.

## ⚠️ CRITICAL INSTALLATION WARNING

**TPM and Secure Boot configuration MUST follow the exact sequence below or your system will not boot!**

The PCR 7 register values change between installation states. Enrolling TPM at the wrong time will lock you out of your system.

## 🚀 Installation Guide

### Step 1: Boot NixOS Installer ISO
```bash
# Boot from standard NixOS installer (Secure Boot DISABLED)
# This is correct - do NOT enable Secure Boot yet
```

### Step 2: Install NixOS
```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/nixos-framework-config
cd nixos-framework-config

# Partition disk with LUKS encryption
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko/framework-luks-btrfs.nix

# Install NixOS
sudo nixos-install --flake .#framework
```

### Step 3: Reboot to Installed System
```bash
sudo reboot
# ⚠️ Boot into the INSTALLED system (not the ISO)
# ⚠️ Secure Boot is still DISABLED - this is correct
```

### Step 4: Setup Secure Boot (REQUIRED)
```bash
# Create and enroll Secure Boot keys
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft
sudo nixos-rebuild switch

# Reboot and enable Secure Boot in BIOS
sudo reboot
# Press F2 during boot → Security → Enable Secure Boot → Save & Exit
```

### Step 5: Verify Secure Boot, Then Enroll TPM
```bash
# Verify Secure Boot is active
sudo sbctl status  # Should show "Secure Boot: Enabled"

# ⚠️ ONLY NOW enroll TPM (after Secure Boot is enabled)
sudo ./scripts/tpm-enroll.sh
```

### Step 6: Test Automatic Unlock
```bash
sudo reboot
# System should unlock automatically with TPM
# If not, use your LUKS password and re-enroll
```

## ��️ Critical Security Notes

### **Why This Sequence Matters**
The TPM PCR 7 register contains measurements of the boot process:
- **ISO boot**: Different PCR 7 values (temporary state)
- **Installed system**: Different PCR 7 values (intermediate state)  
- **Secure Boot enabled**: Final PCR 7 values (target state)

**TPM only unlocks if current PCR 7 matches enrollment PCR 7!**

### **Common Mistakes That Break Boot:**
- ❌ Enrolling TPM from the live ISO
- ❌ Enrolling TPM before enabling Secure Boot
- ❌ Skipping the Secure Boot setup step
- ❌ Not rebooting between steps

### **Recovery:**
If system won't boot after TPM enrollment:
1. Use your LUKS password to unlock manually
2. Check Secure Boot status: `sudo sbctl status`
3. Re-enroll TPM: `sudo ./scripts/tpm-enroll.sh`

## 🖥️ What's Included

### **Desktop Environment**
- **Hyprland** - Modern Wayland compositor
- **Waybar** - Status bar with system info
- **Rofi** - Application launcher
- **Firefox, VSCode, Discord** - Essential applications

### **Security Features**
- **LUKS full disk encryption** with TPM unlock
- **Secure Boot** with lanzaboote
- **Firewall** and security hardening
- **Automatic updates** and maintenance

### **Framework Hardware Support**
- **Power management** optimized for Framework
- **Function keys** and hardware controls
- **Firmware updates** with fwupd
- **All ports and expansion cards** supported

### **Memory Optimization (64GB RAM)**
- **Zram** for emergency swap
- **Low swappiness** - prefer RAM over swap
- **Optimized memory management**

## 📋 System Details

- **User:** alma (admin user with sudo access)
- **Shell:** Bash with useful aliases
- **Partition:** Encrypted Btrfs with subvolumes
- **Boot:** UEFI with Secure Boot support
- **TPM:** Hardware-backed disk encryption

## 🔧 Daily Usage Commands

```bash
# System management
rebuild          # Rebuild and switch configuration
update           # Update system and packages
clean            # Clean old generations

# Hardware monitoring  
hardware-info    # System information
battery-info     # Battery status
temp-check       # Temperature monitoring

# Window management (Hyprland)
Super + Q        # Open terminal
Super + R        # Application launcher  
Super + E        # File manager
Super + 1-5      # Switch workspaces
```

## 🧪 Testing Before Installation

```bash
# Test configuration validity
nix flake check

# Build ISO for testing
nix build .#nixosConfigurations.framework-iso.config.system.build.isoImage
```

## ⚠️ Important Notes

- **Always keep your LUKS password** - TPM can fail during updates
- **Test TPM unlock after enrollment** - ensure it works reliably  
- **Backup LUKS headers** before major system changes
- **Secure Boot must be enabled** for TPM enrollment to work
- **Follow the exact sequence** - skipping steps will break boot

## 🆘 Support

If you encounter issues:
1. Check that Secure Boot is enabled: `sudo sbctl status`
2. Verify TPM is working: `sudo systemd-cryptenroll --tpm2-device=list`
3. Re-enroll TPM if needed: `sudo ./scripts/tpm-enroll.sh`
4. Use LUKS password as backup if TPM fails

---

**Remember: The exact installation sequence is critical for TPM + Secure Boot to work correctly!**
