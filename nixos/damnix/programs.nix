{ pkgs, config, ... }:

{
  imports = (map (p: ../modules + p) [
    /virtualization/virt-manager.nix
    #/virtualization/docker.nix
  ]);

  #virtualisation.waydroid.enable = true;
  virtualisation.podman = {
    enable = true;
  };

  programs = {
    fuse.userAllowOther = true; # for bindfs on /tmp/ tmpfs
    wireshark.enable = true;
    kdeconnect.enable = true;
    gpu-screen-recorder.enable = true;

    /*
    corectrl = {
      enable = true;
      gpuOverclock.enable = true;
      gpuOverclock.ppfeaturemask = "0xffffffff";
    };
    */

    gamescope = {
      enable = true;
      #capSysNice = true;
    };

    gamemode.enable = true;

    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraLibraries = pkgs: [ pkgs.gperftools pkgs.libxcb ];
        extraPkgs =
          pkgs: with pkgs; [
            libXcursor
            libXi
            libXinerama
            libXScrnSaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
          ];
      };
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
  };

  environment.systemPackages = with pkgs; [
  alsa-utils lxqt.lxqt-policykit lact
  freerdp
  nix-alien
  ];
  systemd.packages = with pkgs; [ lact android-tools ];
  systemd.services.lactd.wantedBy = ["multi-user.target"];

}
