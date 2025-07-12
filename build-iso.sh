#!/bin/bash
echo "🚀 Building NixOS Framework ISO..."

# Try cross-compilation first (if on ARM)
if [[ $(uname -m) == "aarch64" ]]; then
    echo "📱 ARM detected - attempting cross-compilation to x86_64"
    nix build .#nixosConfigurations.framework-iso.config.system.build.isoImage \
        --system x86_64-linux --cores 2 --max-jobs 1
else
    echo "💻 x86_64 detected - native build"
    nix build .#nixosConfigurations.framework-iso.config.system.build.isoImage \
        --cores 2 --max-jobs 1
fi

echo "✅ ISO build complete!"
ls -la result/iso/
