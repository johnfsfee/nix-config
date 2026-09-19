{ config, pkgs, ... }:

{
  services = {
    gammastep = {
      enable = true;
      latitude = 7.0;
      longitude = -34.0;
      tray = true;
    };

    gpg-agent = {
      enable = true;
      enableBashIntegration = true;
      pinentry.package = pkgs.pinentry-curses;
      defaultCacheTtl = 34560000;
      maxCacheTtl = 34560000;
    };

    easyeffects.enable = true;
    syncthing.enable = true;

    /*
      fluidsynth = {
          enable = true;
          soundService = "pipewire-pulse";
          soundFont = "/home/anon/src/sc55.sf2";
        };
    */
  };

  systemd.user.services.timidity-server = {
    Unit = {
      Description = "timidity server";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.timidity}/bin/timidity -iAD -Os1l -s 44100 -x\'soundfont \"/home/anon/Music/Arachno SoundFont - Version 1.0.sf2\" order=1\' --volume-compensation 20%";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
  systemd.user.services.vice = {
    Unit.Description = "Vice game clip recorder daemon";
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = "${pkgs.vice-clipper}/bin/vice start --no-open-ui";
      PassEnvironment = "WAYLAND_DISPLAY DISPLAY XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS XDG_SESSION_TYPE XDG_CURRENT_DESKTOP";
    };
  };
}
