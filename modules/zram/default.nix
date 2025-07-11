{ config, lib, pkgs, ... }: {
  # Optimized zram configuration for 64GB RAM system
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    
    # For 64GB RAM, use 25% (16GB) for zram swap
    # This provides good emergency swap without wasting too much RAM
    memoryPercent = 25;
    
    # High priority to prefer zram over disk swap
    priority = 100;
  };
  
  # Kernel parameters optimized for high-memory system
  boot.kernel.sysctl = {
    # Lower swappiness since we have plenty of RAM
    "vm.swappiness" = 5;
    
    # Reduce cache pressure with abundant RAM
    "vm.vfs_cache_pressure" = 30;
    
    # Optimize dirty ratios for large RAM
    "vm.dirty_background_ratio" = 2;
    "vm.dirty_ratio" = 10;
    
    # Increase dirty expire and writeback times
    "vm.dirty_expire_centisecs" = 6000;  # 60 seconds
    "vm.dirty_writeback_centisecs" = 1500;  # 15 seconds
    
    # Optimize for desktop workload
    "vm.page-cluster" = 0;  # Disable page clustering for SSDs
    
    # Memory management for large RAM systems
    "vm.min_free_kbytes" = 131072;  # 128MB minimum free
    "vm.watermark_scale_factor" = 125;
    
    # Network optimizations
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.core.netdev_max_backlog" = 5000;
  };
  
  # Install memory monitoring tools
  environment.systemPackages = with pkgs; [
    htop
    btop
    iotop
    atop
    glances
    
    # Memory analysis tools
    valgrind
    heaptrack
  ];
  
  # Systemd service to monitor memory usage
  systemd.services.memory-monitor = {
    description = "Memory Usage Monitor";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScript "memory-check" ''
        echo "Memory Status Report - $(date)"
        echo "=================================="
        free -h
        echo ""
        echo "Zram Status:"
        zramctl
        echo ""
        echo "Top Memory Consumers:"
        ps aux --sort=-%mem | head -10
      ''}";
    };
  };
  
  # Timer to run memory monitoring
  systemd.timers.memory-monitor = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
