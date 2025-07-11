#!/bin/bash
# VM Test Setup Script
# This script sets up Nix on a VM and tests our Framework configuration

set -euo pipefail

echo "🚀 Setting up Nix testing environment..."
echo "======================================"

# Update system
sudo apt-get update
sudo apt-get install -y curl git

# Install Nix
echo "📦 Installing Nix..."
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# Source Nix
echo "🔄 Sourcing Nix environment..."
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Enable flakes
echo "⚡ Enabling Nix flakes..."
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Clone our configuration
echo "📁 Cloning Framework configuration..."
git clone https://github.com/yourusername/nixos-framework-config.git ~/nixos-test
cd ~/nixos-test

# Test configuration
echo "🧪 Testing Framework configuration..."
nix flake check

echo "🏗️ Building Framework configuration..."
nix build .#nixosConfigurations.framework.config.system.build.toplevel

echo "✅ Framework configuration test complete!"
echo "📊 Build artifacts available in result/"
echo "🎯 Configuration validated successfully!"
