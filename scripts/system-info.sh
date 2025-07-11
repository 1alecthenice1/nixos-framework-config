#!/bin/bash
# System Information Script

echo "🖥️  Framework NixOS System Information"
echo "====================================="
echo
echo "📋 User Configuration:"
echo "   Username: users"
echo "   Full Name: alec"
echo "   Email: aleckillian44@proton.me"
echo "   Timezone: America/New_York"
echo
echo "🏠 Hardware:"
echo "   Model: $(sudo dmidecode -s system-product-name 2>/dev/null || echo 'Unknown')"
echo "   CPU: $(lscpu | grep 'Model name' | cut -d: -f2 | xargs)"
echo "   Memory: $(free -h | grep '^Mem:' | awk '{print $2}')"
echo "   Storage: $(lsblk -d -o NAME,SIZE | grep nvme | awk '{print $2}')"
echo
echo "💾 Memory Status:"
free -h
echo
echo "🔐 Encryption Status:"
if lsblk | grep -q crypt; then
    echo "   ✅ LUKS encryption active"
    lsblk | grep crypt
else
    echo "   ❌ No encryption detected"
fi
echo
echo "🔧 Services:"
echo "   Desktop: $(loginctl show-session $(loginctl | grep users | awk '{print $1}') -p Type --value 2>/dev/null || echo 'Unknown')"
echo "   Network: $(systemctl is-active NetworkManager)"
echo "   Audio: $(systemctl --user is-active pipewire 2>/dev/null || echo 'inactive')"
echo "   Bluetooth: $(systemctl is-active bluetooth)"
