# Framework NixOS Deployment Inst## Step 6: Reboot FIRST, Then Enable Secure Boot, Then Configure TPM
⚠️ **CRITICAL**: Follow this exact sequence for proper PCR 7 values!

### 6.1: Reboot into installed system
```bash
sudo reboot
```

### 6.2: Enable Secure Boot (from installed system)
```bash
# Create Secure Boot keys
sudo sbctl create-keys

# Enroll keys (including Microsoft keys for compatibility)
sudo sbctl enroll-keys --microsoft

# Rebuild system with Secure Boot support
sudo nixos-rebuild switch

# Reboot
sudo reboot
```

### 6.3: Enable Secure Boot in BIOS
1. **Boot into BIOS/UEFI** (usually F2 or Del during boot)
2. **Navigate to Security settings**
3. **Enable Secure Boot**
4. **Save and exit** 
5. **Boot normally** - system should start with Secure Boot enabled

### 6.4: Verify Secure Boot and Enroll TPM
```bash
# Verify Secure Boot is working
sudo sbctl status

# Now enroll TPM with correct PCR 7 values
sudo /etc/nixos/scripts/tmp-enroll.sh
```

**Why this sequence matters:**
- **Step 1**: Ensures we're in the installed system (not ISO)
- **Step 2**: Sets up Secure Boot infrastructure 
- **Step 3**: Activates Secure Boot in firmware
- **Step 4**: Creates final PCR 7 values that TPM will validate against
- **Skipping steps**: Will result in PCR 7 mismatch and boot failuresons

## Prerequisites
- Framework Laptop 13 AMD 7040 series
- NixOS installation media
- Network connectivity

## Step 1: Boot NixOS Installer
Boot your Framework laptop with NixOS installation media.

## Step 2: Clone Configuration
```bash
git clone <your-repo-url> /mnt/nixos-config
cd /mnt/nixos-config
```

## Step 3: Partition Disk with Disko
```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disk-config.nix
```

## Step 4: Install NixOS
```bash
sudo nixos-install --flake .#framework
```

## Step 5: Set Root Password
```bash
sudo nixos-enter
passwd root
exit
```

## Step 6: Reboot and Configure TPM
After first boot:
```bash
sudo ./scripts/tpm-enroll.sh
```

## Step 7: Update System
```bash
rebuild  # Alias for nixos-rebuild switch
```

Your Framework laptop is now configured with:
- ✅ Hyprland desktop environment
- ✅ TPM2 hardware encryption
- ✅ Complete hardware support
- ✅ 64GB RAM optimization
- ✅ Development tools
