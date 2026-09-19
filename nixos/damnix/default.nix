{ config, pkgs, ... }:

{
  system.stateVersion = "22.05";

  nix.settings.max-jobs = 2;
  nix.settings.cores = 2;
  nix.settings.download-buffer-size = 524288000;

  # musnix.enable = true;

  imports =
    [
      ../configuration.nix
      ./hardware-configuration.nix
      ./kernel
      ./network.nix
      ./audio.nix
      ./programs.nix
      ./users.nix
      ./services.nix
      ./cdemu.nix
    ]
    ++ (map (p: ../modules + p) [
      /printing.nix
      /locale/br-abnt2.nix
      /desktop/graphical.nix
      /desktop/drawing.nix
      /virtualization/docker.nix
    ]);

  time.timeZone = "Brazil/East";
  environment.sessionVariables = {
    TZ = "Brazil/East";
  };
  networking.hostName = "damnix";

  boot = {
    resumeDevice = "/dev/sda2";
    loader.grub = {
      configurationLimit = 8;
      enable = true;
      device = "/dev/sda";
      extraConfig = ''
        nowatchdog
        nmi_watchdog=0
      '';
    };
    tmp.useTmpfs = true;
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  # Enforce fstab options{
  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/nix".options = [ "compress=zstd" "noatime" "nodatacow"  ];
    "/swap".options = [ "noatime" "nodatacow" ];
    "/boot".options = [ "noatime" ];
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (
        subject.isInGroup("users")
          && (
            action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
            action.id == "org.freedesktop.login1.suspend" ||
            action.id == "org.freedesktop.login1.suspend-multiple-sessions" ||
            action.id == "org.freedesktop.login1.hibernate" ||
            action.id == "org.freedesktop.login1.hibernate-multiple-sessions" ||
            action.id == "org.freedesktop.login1.hybridsleep" ||
            action.id == "org.freedesktop.login1.hybridsleep-multiple-sessions" ||
            action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions"
          )
        )
      {
        return polkit.Result.YES;
      }
    });
  '';

  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.enableOnBoot = false;
  virtualisation.libvirtd.onBoot = "ignore";
  virtualisation.libvirtd.onShutdown = "shutdown";

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  environment.systemPackages = with pkgs; [
    nvtopPackages.amd
  ];

  hardware.graphics = {
    enable32Bit = true; # for old games
    # enable vaapi decoding
    # https://github.com/NixOS/nixpkgs/issues/305108#issuecomment-2182192887
    extraPackages = with pkgs; [
      libvdpau-va-gl
      mesa.opencl # enables rusticl support
    ];
  };
  # NOTE: rocm doesn't really work because the cpu needs to support both gen3 pci and pcie atomics for it to work on GFX8 cards
  environment.variables = {
    RUSTICL_ENABLE = "radeonsi";
    ROC_ENABLE_PRE_VEGA = "1";
  };

  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.amdgpu.overdrive.enable = true;
  hardware.amdgpu.overdrive.ppfeaturemask = "0xffffffff";
}
