#!/bin/bash

# User data script for EC2 spot instance
# This script runs when the instance starts up

set -e

S3_BUCKET="${s3_bucket}"
LOG_FILE="/var/log/nixos-build.log"

# Function to log with timestamps
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

log "Starting NixOS Framework ISO build setup..."

# Update system
log "Updating system packages..."
yum update -y

# Install required packages
log "Installing required packages..."
yum install -y git curl wget unzip

# Install Nix
log "Installing Nix package manager..."
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# Source Nix environment
log "Setting up Nix environment..."
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Configure Nix
log "Configuring Nix settings..."
mkdir -p /etc/nix
cat > /etc/nix/nix.conf << EOF
experimental-features = nix-command flakes
allowed-unfree = true
max-jobs = auto
cores = 0
EOF

# Restart nix daemon
log "Restarting Nix daemon..."
systemctl restart nix-daemon

# Wait for nix daemon
sleep 10

# Test Nix installation
log "Testing Nix installation..."
nix --version || (log "ERROR: Nix installation failed" && exit 1)

# Create build script
log "Creating build script..."
cat > /home/ec2-user/build-nixos-iso.sh << 'EOF'
#!/bin/bash

set -e

LOG_FILE="/var/log/nixos-build.log"
S3_BUCKET="${s3_bucket}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

log "Starting NixOS Framework ISO build..."

# Source Nix environment
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Clone the repository
log "Cloning nixos-framework-config repository..."
cd /home/ec2-user
rm -rf nixos-framework-config
git clone https://github.com/1alecthenice1/nixos-framework-config.git
cd nixos-framework-config

# Show disk space before build
log "Disk space before build:"
df -h | tee -a $LOG_FILE

# Build the ISO
log "Building Framework NixOS ISO..."
start_time=$(date +%s)
nix build .#nixosConfigurations.framework-iso.config.system.build.isoImage --print-build-logs 2>&1 | tee -a $LOG_FILE

if [ $? -eq 0 ]; then
    end_time=$(date +%s)
    build_time=$((end_time - start_time))
    log "Build completed successfully in $build_time seconds!"
    
    # Find the ISO file
    ISO_FILE=$(find result -name "*.iso" | head -1)
    if [ -n "$ISO_FILE" ]; then
        ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
        ISO_NAME=$(basename "$ISO_FILE")
        
        log "ISO built: $ISO_FILE (Size: $ISO_SIZE)"
        
        # Upload to S3
        log "Uploading ISO to S3 bucket: $S3_BUCKET"
        aws s3 cp "$ISO_FILE" "s3://$S3_BUCKET/$ISO_NAME" || log "WARNING: S3 upload failed"
        
        # Show final disk usage
        log "Final disk space:"
        df -h | tee -a $LOG_FILE
        
        log "Build complete! ISO available at: s3://$S3_BUCKET/$ISO_NAME"
    else
        log "ERROR: No ISO file found in result directory"
        ls -la result/ | tee -a $LOG_FILE
        exit 1
    fi
else
    log "ERROR: Build failed!"
    exit 1
fi
EOF

# Make build script executable
chmod +x /home/ec2-user/build-nixos-iso.sh
chown ec2-user:ec2-user /home/ec2-user/build-nixos-iso.sh

# Install AWS CLI v2
log "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -q awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Create systemd service to run build on startup
log "Creating build service..."
cat > /etc/systemd/system/nixos-build.service << EOF
[Unit]
Description=NixOS Framework ISO Build
After=nix-daemon.service
Requires=nix-daemon.service

[Service]
Type=oneshot
User=ec2-user
WorkingDirectory=/home/ec2-user
ExecStart=/home/ec2-user/build-nixos-iso.sh
StandardOutput=append:/var/log/nixos-build.log
StandardError=append:/var/log/nixos-build.log

[Install]
WantedBy=multi-user.target
EOF

# Enable but don't start the service (can be started manually)
systemctl enable nixos-build.service

log "Setup complete! To start the build:"
log "  sudo systemctl start nixos-build.service"
log "  Or run manually: sudo -u ec2-user /home/ec2-user/build-nixos-iso.sh"
log "  Monitor with: tail -f /var/log/nixos-build.log"
