#!/bin/bash
# TPM LUKS Enrollment Helper
# Run this after installation to enable TPM unlock

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "❌ This script must be run as root"
    echo "Usage: sudo ./scripts/tpm-enroll.sh"
    exit 1
fi

echo "🔐 TPM LUKS Enrollment"
echo "====================="
echo ""
echo "⚠️  CRITICAL: This script must be run from the INSTALLED system"
echo "   - Do NOT run from live ISO or installer"
echo "   - Secure Boot MUST be enabled before running this script"
echo "   - PCR values must match the final boot environment"
echo "   - System must be fully booted and operational"
echo ""

# Check if running from installed system
if [[ -f /etc/NIXOS_LUSTRATE ]]; then
    echo "❌ Detected installer environment!"
    echo "   Please reboot into the installed system first"
    exit 1
fi

# Verify we're in a proper NixOS installation
if [[ ! -f /etc/nixos/configuration.nix && ! -f /etc/nixos/flake.nix ]]; then
    echo "❌ This doesn't appear to be a proper NixOS installation"
    echo "   Please run from the installed NixOS system"
    exit 1
fi

echo "✅ Running from installed system"

# Check Secure Boot status
if command -v sbctl >/dev/null 2>&1; then
    SECBOOT_STATUS=$(sbctl status 2>/dev/null | grep "Secure Boot" | awk '{print $3}' || echo "unknown")
    if [[ "$SECBOOT_STATUS" != "Enabled" ]]; then
        echo "❌ Secure Boot is not enabled!"
        echo ""
        echo "🔧 To enable Secure Boot:"
        echo "1. Create and enroll keys:"
        echo "   sudo sbctl create-keys"
        echo "   sudo sbctl enroll-keys --microsoft"
        echo "2. Rebuild system:"
        echo "   sudo nixos-rebuild switch"
        echo "3. Reboot and enable Secure Boot in BIOS/UEFI"
        echo "4. Run this script again after Secure Boot is enabled"
        echo ""
        echo "⚠️  TPM enrollment with Secure Boot disabled will create incorrect PCR 7 values!"
        echo "   The system may not boot properly after enabling Secure Boot later."
        echo ""
        read -p "Do you want to continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted. Please enable Secure Boot first."
            exit 1
        fi
        echo "⚠️  WARNING: Proceeding with Secure Boot disabled - PCR 7 values may be incorrect!"
    else
        echo "✅ Secure Boot is enabled - PCR 7 values will be correct"
    fi
else
    echo "⚠️  WARNING: sbctl not found - cannot verify Secure Boot status"
    echo "   Ensure Secure Boot is enabled in BIOS before proceeding"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Find LUKS device
LUKS_DEVICE=$(findmnt -n -o SOURCE / | xargs lsblk -no pkname | head -1)
LUKS_DEVICE="/dev/${LUKS_DEVICE}"

echo "📱 Found LUKS device: $LUKS_DEVICE"

# Check if TPM is available
if [[ ! -c /dev/tpm0 ]]; then
    echo "❌ TPM device not found"
    exit 1
fi

echo "✅ TPM device found"

# Enroll TPM
echo "🔑 Enrolling TPM (you'll need to enter your LUKS password)..."
systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+7 "$LUKS_DEVICE"

echo "✅ TPM enrollment complete!"
echo "💡 Your system can now unlock with TPM on next boot"
echo "⚠️  Keep your password as backup - TPM can fail!"

# Show enrollment status
echo ""
echo "📊 Current enrollment status:"
systemd-cryptenroll "$LUKS_DEVICE"
