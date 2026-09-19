{ config, pkgs, lib, ... }:

{
  imports = [ ./mods.nix ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  # boot.kernelPatches = [  ];
  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;
    scheduler = "scx_lavd";
    extraArgs = [ "--performance" ];
  };
}
