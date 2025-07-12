{ config, lib, pkgs, ... }: {
  # Android development environment
  environment.systemPackages = with pkgs; [
    # Android Studio and tools
    android-studio
    android-tools        # adb, fastboot, aapt, etc.
    
    # Android utilities
    scrcpy              # Screen mirroring and control
    
    # Mobile development frameworks
    flutter
    dart
    
    # React Native tools
    nodejs
    yarn
    
    # Gradle (Android build system)
    gradle
  ];
  
  # Enable ADB system-wide
  programs.adb.enable = true;
  
  # Android development environment variables
  environment.variables = {
    ANDROID_HOME = "$HOME/Android/Sdk";
    ANDROID_SDK_ROOT = "$HOME/Android/Sdk";
  };
}