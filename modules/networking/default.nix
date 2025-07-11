{ config, lib, pkgs, ... }: {
  # NetworkManager for GUI network management
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;  # Better for Framework WiFi
    ethernet.macAddress = "random";
    wifi.macAddress = "random";
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      22    # SSH
      80    # HTTP
      443   # HTTPS
      8080  # Development server
    ];
    allowedUDPPorts = [ 
      53    # DNS
      67    # DHCP
      68    # DHCP
    ];
  };

  # DNS configuration
  networking.nameservers = [ 
    "1.1.1.1" 
    "8.8.8.8" 
    "9.9.9.9" 
  ];

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Networking tools
  environment.systemPackages = with pkgs; [
    # Network management
    networkmanager
    networkmanagerapplet
    
    # Network analysis
    wireshark
    nmap
    iperf3
    speedtest-cli
    
    # VPN tools
    openvpn
    wireguard-tools
    
    # Network utilities
    wget curl
    dig
    whois
    traceroute
    nettools
    inetutils
    
    # Bluetooth management
    bluez
    bluez-tools
    blueman
    
    # Monitoring
    bandwhich
    nethogs
    iftop
  ];

  # Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
  
  services.blueman.enable = true;

  # Avahi for network discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Printing support
  services.printing = {
    enable = true;
    drivers = with pkgs; [ 
      gutenprint 
      hplip 
      canon-cups-ufr2 
    ];
  };
  
  services.avahi.publish = {
    enable = true;
    userServices = true;
  };
}
