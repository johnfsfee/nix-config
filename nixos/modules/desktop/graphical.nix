# needed for (graphical) desktop usage
{ config, pkgs, ... }:

{
  security.polkit.enable = true; # needed if using WMs through home-manager
  security.pam.services.swaylock = { }; # fix swaylock not accepting user password
  security.pam.loginLimits = [ { domain = "@users"; item = "rtprio"; type = "-"; value = "1"; } ];

  hardware.graphics = {
    enable = true;
  };

  programs.xwayland.enable = true;

  programs.dconf.enable = true; # gtk theming needs this to work well

  services.flatpak.enable = true;
  fonts.fontDir.enable = true; # fix flatpak fonts

  services.dbus = {
    enable = true;
    #implementation = "broker";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = false; # broken
    wlr.enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "wlr";
  };

  security.rtkit.enable = true; # optional, but recommended

  ## audio settings
  # pipewire
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # for old games
    pulse.enable = true;
    jack.enable = true; # for apps that requires jack
    wireplumber.enable = true;
  };
}
