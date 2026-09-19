# preferred wayland terminal
{ config, pkgs, ... }:

{
  programs.foot = {
    enable = true;
    server.enable = false; # FIXME won't see ~/.local/bin in $PATH
    settings = {
      main = {
        # font = "FiraCode Nerd Font:size=11";
        # dpi-aware = "yes";
      };

      mouse = { hide-when-typing = "yes"; };
      colors-dark = {
        alpha = "0.8";
      };
    };
  };
}
