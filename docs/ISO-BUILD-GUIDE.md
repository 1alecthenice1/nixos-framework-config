# ISO Building Guide

This guide explains how to build a bootable NixOS ISO for Framework laptop deployment using both local builds and GitHub Actions.

## 🏗️ Building with GitHub Actions (Recommended)

### Automatic Builds

The repository includes a GitHub Actions workflow that automatically builds ISOs:

- **On every push** to main/master branch
- **On every tag** (creates a release)
- **Manual trigger** via GitHub Actions tab

### Setting up GitHub Actions

1. **Push your configuration to GitHub:**
   ```bash
   git add .
   git commit -m "Add ISO build configuration"
   git push origin main
   ```

2. **Optional: Setup Cachix for faster builds**
   - Create account at [cachix.org](https://cachix.org)
   - Add `CACHIX_AUTH_TOKEN` to repository secrets
   - This speeds up subsequent builds significantly

3. **Trigger a build:**
   - Push any commit to trigger automatic build
   - Or go to Actions tab → "Build NixOS Framework ISO" → "Run workflow"

### Downloading Built ISOs

**From Actions:**
1. Go to Actions tab in your GitHub repository
2. Click on latest successful build
3. Download "framework-nixos-iso" artifact
4. Extract the ZIP to get your ISO file

**From Releases (tagged builds):**
1. Create a tag: `git tag v1.0.0 && git push origin v1.0.0`
2. ISO will be automatically attached to the GitHub release
3. Download directly from Releases page

## 🖥️ Building Locally

### Prerequisites

- Nix with flakes enabled
- Sufficient disk space (~10GB for build cache)
- Good internet connection (first build downloads lots of packages)

### Build Command

```bash
# Quick build
./scripts/build-iso.sh

# Manual build
nix build .#nixosConfigurations.framework-iso.config.system.build.isoImage
```

### Expected Build Time

- **First build:** 30-60 minutes (downloads everything)
- **Subsequent builds:** 5-15 minutes (uses cache)
- **GitHub Actions:** 20-40 minutes (fresh environment)

## 📦 ISO Contents

The built ISO includes:

### Hardware Support
- ✅ Framework 13 AMD 7040 optimizations
- ✅ Latest kernel with Framework drivers
- ✅ TPM 2.0 support
- ✅ WiFi and Bluetooth drivers
- ✅ Display and audio drivers

### Installation Tools
- ✅ Disk partitioning tools (disko)
- ✅ Encryption setup (LUKS + TPM)
- ✅ Secure Boot tools (sbctl)
- ✅ Your NixOS configuration in `/nixos-config`
- ✅ Automated installation helper script

### Desktop Environment
- ✅ XFCE desktop for easier installation
- ✅ Firefox for documentation access
- ✅ File manager and terminal
- ✅ Network manager for WiFi setup

### Users
- ✅ `installer` user (password: `installer`)
- ✅ `root` user (password: `nixos`)
- ✅ SSH enabled for remote installation

## 🚀 Using the ISO

### 1. Flash to USB Drive

**Linux/macOS:**
```bash
sudo dd if=framework-nixos-*.iso of=/dev/sdX bs=4M status=progress
```

**Windows:**
- Use [Balena Etcher](https://www.balena.io/etcher/)
- Or [Rufus](https://rufus.ie/)

### 2. Boot on Framework

1. Insert USB drive
2. Boot Framework laptop
3. Press F12 for boot menu
4. Select USB drive
5. Choose "NixOS Live" from GRUB menu

### 3. Install NixOS

The ISO includes an installation helper script on the desktop:
- **GUI:** Double-click "Install Framework NixOS" desktop icon
- **Terminal:** Run `/etc/installer-script.sh`

**⚠️ CRITICAL TPM Warning:**
- DO NOT enroll TPM from the live ISO
- TPM enrollment must be done from the installed system after reboot
- PCR 7 values differ between ISO and installed system
- Ignoring this will prevent your system from booting

## 🔧 Customizing the ISO

### Adding Packages

Edit `hosts/iso/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  # Your additional packages here
  git vim firefox
  # ... existing packages ...
];
```

### Changing Desktop Environment

Replace XFCE with your preferred DE in `hosts/iso/configuration.nix`:

```nix
services.xserver = {
  enable = true;
  displayManager.gdm.enable = true;      # Change this
  desktopManager.gnome.enable = true;    # And this
};
```

### Including Custom Files

Add files to the ISO:

```nix
isoImage.contents = [
  {
    source = ./my-custom-files;
    target = "/custom-files";
  }
];
```

## 📊 Build Optimization

### Speeding Up Builds

1. **Use Cachix:**
   ```bash
   nix-env -iA cachix -f https://cachix.org/api/v1/install
   cachix use nixos-framework
   ```

2. **Local binary cache:**
   ```bash
   nix.settings.substituters = [
     "https://cache.nixos.org/"
     "https://nixos-framework.cachix.org"
   ];
   ```

3. **Build with more cores:**
   ```bash
   nix build --max-jobs 8 .#nixosConfigurations.framework-iso.config.system.build.isoImage
   ```

### Reducing ISO Size

Remove unnecessary packages from `hosts/iso/configuration.nix`:

```nix
# Comment out packages you don't need
environment.systemPackages = with pkgs; [
  # firefox  # Remove if you don't need browser
  # neovim   # Remove if vim is sufficient
];
```

## 🐛 Troubleshooting

### Build Failures

**Out of disk space:**
```bash
nix-collect-garbage -d
nix store gc
```

**Network timeouts:**
```bash
nix build --max-jobs 1 --cores 1 .#nixosConfigurations.framework-iso.config.system.build.isoImage
```

**Module errors:**
```bash
# Check flake syntax
nix flake check

# Build specific component
nix build .#nixosConfigurations.framework-iso.config.system.build.toplevel
```

### GitHub Actions Issues

**Authentication errors:**
- Check repository permissions
- Ensure Actions are enabled

**Build timeouts:**
- Reduce ISO size
- Use Cachix
- Split into multiple builds

**Artifact upload failures:**
- Check artifact size (GitHub has limits)
- Compress if necessary

## 📝 Best Practices

### Version Control
- Tag releases for stable ISOs
- Include ISO hash in commit messages
- Document changes in release notes

### Testing
- Test ISOs in VM before physical deployment
- Validate on actual Framework hardware
- Check both UEFI and Legacy boot modes

### Security
- Regenerate ISO for sensitive deployments
- Don't include secrets in ISO
- Use fresh credentials for each deployment

## 🎯 Quick Start Commands

```bash
# Build ISO locally
./scripts/build-iso.sh

# Build and test in VM
nix build .#nixosConfigurations.framework-iso.config.system.build.isoImage
qemu-system-x86_64 -enable-kvm -m 4G -cdrom result/iso/*.iso

# Push to trigger GitHub Actions build
git add . && git commit -m "Update ISO" && git push

# Create release with ISO
git tag v1.0.0 && git push origin v1.0.0
```
