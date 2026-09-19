{ pkgs, config, ... }:

{
  imports = (map (p: ../modules + p) [
    /virtualization/podman.nix
  ]);

  virtualisation.waydroid.enable = true;
  programs = {
    adb.enable = true;
    wireshark.enable = true;
  };

  environment.systemPackages = with pkgs; [ alsa-utils lxqt.lxqt-policykit ];
}
