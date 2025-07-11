# Framework NixOS Deployment Inst## Step 6: Reboot FIRST, Then Configure TPM
⚠️ **CRITICAL**: Reboot into the installed system before TPM enrollment!

```bash
sudo reboot
```

After the system boots from the installed NixOS (not the installer):
```bash
sudo /etc/nixos/scripts/tpm-enroll.sh
```

**Why this matters:**
- TPM PCR values must match the final boot environment
- ISO/installer has different PCR 7 values than installed system
- Enrolling from wrong environment will prevent bootons

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
