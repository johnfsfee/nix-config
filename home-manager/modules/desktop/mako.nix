# defaults for mako notification daemon
{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;

    font = "FiraCode Nerd Font";
    defaultTimeout = 15000;
    extraConfig = ''on-notify=exec canberra-gtk-play -i bell'';
  };
}
