#!/bin/bash
# Secure Boot Setup Script for Framework NixOS
# Run this AFTER initial installation and reboot, BEFORE TPM enrollment

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root"
    echo "Usage: sudo ./scripts/setup-secureboot.sh"
    exit 1
fi

echo "🔐 Framework NixOS Secure Boot Setup"
echo "===================================="
echo ""
echo "This script will:"
echo "1. Create Secure Boot keys"
echo "2. Enroll keys (including Microsoft compatibility keys)"
echo "3. Rebuild the system with Secure Boot support"
echo "4. Prepare for BIOS Secure Boot activation"
echo ""

# Check if we're in the right environment
if [[ -f /etc/NIXOS_LUSTRATE ]]; then
    echo "❌ This appears to be the installer environment!"
    echo "   Please reboot into the installed system first"
    exit 1
fi

if [[ ! -f /etc/nixos/flake.nix && ! -f /etc/nixos/configuration.nix ]]; then
    echo "❌ This doesn't appear to be a NixOS system"
    exit 1
fi

echo "✅ Running from installed NixOS system"
echo ""

# Check if sbctl is available
if ! command -v sbctl >/dev/null 2>&1; then
    echo "❌ sbctl not found. Ensure the boot module is properly configured."
    exit 1
fi

# Check current Secure Boot status
echo "📊 Current Secure Boot status:"
sbctl status
echo ""

# Check if keys already exist
if [[ -d /usr/share/secureboot/keys ]] && [[ -f /usr/share/secureboot/keys/db/db.key ]]; then
    echo "⚠️  Secure Boot keys already exist"
    read -p "Do you want to recreate them? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing keys..."
        rm -rf /usr/share/secureboot/keys
        rm -rf /var/lib/sbctl
    else
        echo "📋 Using existing keys"
    fi
fi

# Create Secure Boot keys
if [[ ! -d /var/lib/sbctl ]] || [[ ! -f /var/lib/sbctl/db/db.key ]]; then
    echo "🔑 Creating Secure Boot keys..."
    sbctl create-keys
    echo "✅ Secure Boot keys created"
else
    echo "✅ Secure Boot keys already exist"
fi

# Enroll keys
echo ""
echo "📝 Enrolling Secure Boot keys..."
echo "   This includes Microsoft keys for hardware compatibility"

if sbctl enroll-keys --microsoft; then
    echo "✅ Keys enrolled successfully"
else
    echo "⚠️  Key enrollment failed or keys already enrolled"
    echo "   This may be normal if keys are already present"
fi

# Rebuild system
echo ""
echo "🔨 Rebuilding system with Secure Boot support..."
if nixos-rebuild switch; then
    echo "✅ System rebuild successful"
else
    echo "❌ System rebuild failed"
    echo "   Please check the error messages above"
    exit 1
fi

# Check what needs to be signed
echo ""
echo "📋 Checking bootloader signing status..."
sbctl verify

echo ""
echo "🎉 SECURE BOOT SETUP COMPLETE!"
echo "=============================="
echo ""
echo "📋 Next steps:"
echo "1. 🔄 Reboot your system:"
echo "   sudo reboot"
echo ""
echo "2. 🔧 Enable Secure Boot in BIOS:"
echo "   - Boot into BIOS/UEFI (usually F2 during startup)"
echo "   - Navigate to Security settings"
echo "   - Enable Secure Boot"
echo "   - Save and exit"
echo ""
echo "3. ✅ Verify Secure Boot after reboot:"
echo "   sudo sbctl status"
echo ""
echo "4. 🔐 Finally, enroll TPM with correct PCR values:"
echo "   sudo /etc/nixos/scripts/tpm-enroll.sh"
echo ""
echo "⚠️  IMPORTANT:"
echo "   - Do NOT enroll TPM before enabling Secure Boot in BIOS"
echo "   - PCR 7 values must match the final production state"
echo "   - Keep your LUKS password as backup"
echo ""
