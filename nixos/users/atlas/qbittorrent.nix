{ config, pkgs, ... }:

{
  import = [ ../modules/virtualization/qbittorrent.nix ];
  # add and enable systemd unit
  systemd = {
    packages = [ pkgs.qbittorrent-nox ];
    services."qbittorrent-nox@atlas" = {
      enable = true;
      serviceConfig = {
        Type = "simple";
        User = "atlas";
        ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
