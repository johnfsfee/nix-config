{ pkgs, config, ... }:

{
  imports = [ ../../modules/improved-psd.nix ];
  disabledModules = [ "services/desktops/profile-sync-daemon.nix" ];

  services = {
    gvfs.enable = true;

    dbus.implementation = "broker";
    irqbalance.enable = true;
    ananicy.enable = false; # do not use with bore or scx_lavd
    ananicy.package = pkgs.ananicy-cpp;
    psd.enable = true;
    psd.overlayfsUsers = [ "atlas" ];

    i2pd = {
      enable = true;
      proto.httpProxy.enable = true;
    };

    sshd.enable = true;

    zerotierone = {
      enable = true;
    };
  };
}
