# enable virt-manager. Don't forget to add
# your user to libvirtd
{ config, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [ virtiofsd ];    
  };

  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
  virt-manager
  ];
}
