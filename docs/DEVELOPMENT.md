# Development Guide

## Project Structure

```
.
├── flake.nix                 # Main flake configuration
├── hosts/framework/          # Host-specific configs
│   ├── configuration.nix     # Main system config
│   └── hardware-configuration.nix  # Hardware detection
├── modules/                  # Reusable modules
│   ├── users/               # User management
│   └── security/            # Security settings
└── docs/                    # Documentation
```

## Testing Changes

Always test before deploying:

```bash
# Check syntax
nix flake check

# Build without installing
nix build .#nixosConfigurations.framework.config.system.build.toplevel

# Test in VM
nix build .#nixosConfigurations.framework.config.system.build.vm
./result/bin/run-*-vm
```

## Adding Features

### Step 1: Create a new module
```bash
mkdir modules/new-feature
echo '{ config, lib, pkgs, ... }: { }' > modules/new-feature/default.nix
```

### Step 2: Import in configuration.nix
```nix
imports = [
  # ...existing imports...
  ../../modules/new-feature
];
```

### Step 3: Test and iterate

## Planned Enhancements

- [ ] TPM-based disk encryption
- [ ] Secure Boot with lanzaboote
- [ ] Desktop environment (Hyprland)
- [ ] Advanced partitioning with disko
- [ ] Custom packages and tools
- [ ] Automated installation scripts

## Best Practices

1. **Keep modules focused** - One responsibility per module
2. **Test incrementally** - Don't add everything at once  
3. **Document changes** - Update README and docs
4. **Use semantic commits** - Clear commit messages
5. **Version inputs** - Pin flake inputs for reproducibility
