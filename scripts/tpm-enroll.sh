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
