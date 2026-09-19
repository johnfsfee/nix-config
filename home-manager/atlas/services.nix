{ config, pkgs, ... }:

{
  services = {
    easyeffects.enable = true;
    syncthing.enable = true;

    gpg-agent = {
      enable = true;
      enableBashIntegration = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
  };

}
