{ config, pkgs, ... }:

{
  powerManagement.enable = true;
  services.thermald.enable = true;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;

      START_CHARGE_THRESH_BAT0 = 40;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  system.stateVersion = "24.05";
  environment.systemPackages = with pkgs; [
    nvtopPackages.intel
  ];

  nix.settings.max-jobs = 2;
  nix.settings.cores = 2;

  hardware.graphics = {
    enable32Bit = true; # for old games
    # enable vaapi decoding
    extraPackages = with pkgs; [ libvdpau-va-gl vaapiIntel ];
  };

  boot.initrd.kernelModules = [ "i915" ];
  services.xserver.videoDrivers = [ "modesetting" ];

  # musnix.enable = true;

  imports = [
    ../configuration.nix
    ./hardware-configuration.nix
    ./kernel
    ./network.nix
    ./programs.nix
    ./users.nix
    ./services.nix
  ] ++ (map (p: ../modules + p) [
    /printing.nix
    /locale/br-abnt2.nix
    /desktop/graphical.nix
    /desktop/drawing.nix
  ]);

  time.timeZone = "Brazil/East";
  environment.sessionVariables = { TZ = "Brazil/East"; };
  networking.hostName = "mobilepotato";

  boot = {
    loader.grub = {
      enable = true;
      device = "/dev/sda";
      extraConfig = ''
        nowatchdog
        nmi_watchdog=0
      '';
    };
  };

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 16*1024;
  } ];
}
