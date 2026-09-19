{ config, pkgs, lib, ... }:

{
  imports = [ ./mods.nix ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelPackages = pkgs.linuxPackages_cachyos;
  #chaotic.scx.enable = true; # rustland by default
  #chaotic.scx.scheduler = "scx_lavd"; # rustland by default
  # boot.kernelPatches = [  ];
}
