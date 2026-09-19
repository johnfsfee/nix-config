{
  imports = [ ./wg-conf.nix ];
  security.pam.services.atlas.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  users.users.atlas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" "docker" "adbusers" "video" "audio" "wireshark" "transmission" "input" "corectrl" ];
  };
}
