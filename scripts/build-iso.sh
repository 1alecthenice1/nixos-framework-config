 the#!/bin/bash
# Build Framework NixOS ISO locally
# This script builds the same ISO that GitHub Actions will create

set -euo pipefail

echo "🏗️ Building Framework NixOS ISO"
echo "==============================="
echo ""

# Check if we're in the right directory
if [[ ! -f "flake.nix" ]]; then
    echo "❌ Run this from your nixos repository root (where flake.nix exists)"
    exit 1
fi

# Build the ISO
echo "📦 Building ISO (this may take a while)..."
nix build .#nixosConfigurations.framework-iso.config.system.build.isoImage --print-build-logs

# Find the built ISO
ISO_PATH=$(find result/iso -name "*.iso" | head -1)
if [[ -z "$ISO_PATH" ]]; then
    echo "❌ ISO not found in result/iso/"
    exit 1
fi

ISO_NAME=$(basename "$ISO_PATH")
ISO_SIZE=$(du -h "$ISO_PATH" | cut -f1)

echo ""
echo "✅ ISO BUILD COMPLETE!"
echo "======================"
echo ""
echo "📁 ISO Path: $ISO_PATH"
echo "📦 ISO Name: $ISO_NAME"
echo "💾 ISO Size: $ISO_SIZE"
echo ""
echo "🚀 Next steps:"
echo "1. Flash to USB drive:"
echo "   sudo dd if=$ISO_PATH of=/dev/sdX bs=4M status=progress"
echo "   (Replace /dev/sdX with your USB drive)"
echo ""
echo "2. Or use a GUI tool like Balena Etcher"
echo ""
echo "3. Boot from USB on your Framework laptop"
echo ""
echo "💡 The ISO includes:"
echo "   - Framework hardware support"
echo "   - TPM and encryption tools"
echo "   - Desktop environment for easy installation"
echo "   - Your NixOS configuration in /nixos-config"
echo "   - Installation helper script"
echo ""
