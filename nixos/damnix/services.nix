{ pkgs, config, ... }:

{
  disabledModules = [
    "services/desktops/profile-sync-daemon.nix"
    "services/hardware/keyd.nix"
  ];

  imports = [
    ../../modules/improved-psd.nix
    ../../modules/fixed-keyd.nix
  ];

  fonts.packages = [ pkgs.nerd-fonts.fira-code ];

  services = {
    udev.packages = [ pkgs.vice-clipper ];

    kmscon = {
      enable = false;
      useXkbConfig = true;
      config.font-name = "FiraCode Nerd Font";
      config.hwAccel = true;
    };

    logind.settings.Login = {
      HandlePowerKey = "hibernate";
      # IdleAction=hybrid-sleep
      # IdleActionSec=30min

      # https://github.com/graysky2/profile-sync-daemon/issues/349
      RuntimeDirectorySize = "20%";
    };

    # too resource intensive
    #jitterentropy-rngd.enable = true; # test if more entropy helps

    gvfs.enable = true;
    devmon.enable = true; # automount daemon
    udisks2.enable = true; # let file explorer mount drives

    dbus.implementation = "broker";

    irqbalance.enable = true;

    # broken, and removed from nixpkgs
    #preload.enable = false;

    ananicy.enable = false; # do not use it with bore/scx_lavd
    ananicy.package = pkgs.ananicy-cpp;

    psd.enable = true;
    psd.overlayfsUsers = [ "anon" ];

    transmission = {
      enable = false;
      package = pkgs.transmission_4;
      settings = {
        peer-limit-global = 16;
        peer-limit-per-torrent = 2;
        speed-limit-down = 1500;
        speed-limit-down-enabled = true;
        speed-limit-up = 900;
        speed-limit-up-enabled = true;
      };
    };

    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

      input-remapper = {
        enable = true;
        enableUdevRules = true;
      };

    /*
      keyd = {
        enable = true;
      };
    */
  };

  # users.groups.keyd = { };

  systemd = {
    sleep.settings.Sleep = {
      HibernateDelaySec = "60min";
    };

    /*
      services.keyd.serviceConfig.CapabilityBoundingSet = [
        "CAP_SETGID"
      ];
    */

    user.services = {
      polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
  };
}
