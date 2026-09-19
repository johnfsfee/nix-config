# defaults for mpd
{ config, pkgs, ... }:

{
  services.mpd = {
    enable = true;
    musicDirectory = "~/Music";
    network.listenAddress = "any";
    extraConfig = ''
      audio_output {
            type    "pipewire"
            name    "MPD Pipewire Output"
      }

      audio_output {
        type "httpd"
        name "MPD HTTP Stream"
        encoder "vorbis"
        port "8081"
        bind_to_address "any"
        quality "5.0"
      }
    '';
  };
}
