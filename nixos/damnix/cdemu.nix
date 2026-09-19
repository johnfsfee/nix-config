{ pkgs, config, lib, ... }:

{
boot.extraModulePackages = [ pkgs.linuxPackages_zen.vhba ];
boot.kernelModules = [ "vhba" ];

environment.systemPackages = [
  pkgs.cdemu-daemon
  pkgs.cdemu-client
  pkgs.gcdemu
];

services.dbus.packages = [ pkgs.cdemu-daemon ];

# Allow user access to /dev/vhba_ctl
services.udev.extraRules = ''
  KERNEL=="vhba_ctl", MODE="0660", GROUP="cdrom"
'';

#users.users.<username>.extraGroups = [ "cdrom" ];

# Required for GNOME/dbus-broker: systemd --user unit
systemd.user.services.cdemu-daemon = {
  description = "CDEmu Daemon";
  serviceConfig = {
    ExecStart = "${pkgs.cdemu-daemon}/bin/cdemu-daemon";
    Restart = "on-failure";
  };
};
}
