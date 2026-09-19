{ pkgs, ...}:
{
  imports = [ ./wg-conf.nix ];

  services.gnome.gnome-keyring.enable = true;

  security.pam.services.anon.enableGnomeKeyring = true;

  security.sudo.extraRules = [
    {
      users = [ "anon" ]; commands = [ { command = "${pkgs.iproute2}/bin/tc qdisc *"; options = [ "NOPASSWD" ]; } ];
    }
  ];


  users.users.anon = {
    isNormalUser = true;
    extraGroups = [ "wheel" "cdrom" "dialout" "tty" "uucp" "plugdev" "libvirtd" "docker" "podman" "adbusers" "video" "pipewire" "audio" "wireshark" "transmission" "input" "corectrl" "keyd" ];
    uid = 1000;
    # https://wiki.nixos.org/wiki/Distrobox#%22potentially_insufficient_UIDs_and_GUIDs%22_error
    subGidRanges = [
      {
        count = 65536;
        startGid = 1001; #can't include user's id
      }
    ];
    subUidRanges = [
      {
        count = 65536;
        startUid = 1001; # can't include user's id
      }
    ];
  };
}
