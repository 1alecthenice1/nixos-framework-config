# Framework NixOS Deployment Instructions

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
