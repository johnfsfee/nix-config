{ config, pkgs, ... }:

{
  # Fix rtkit bug from 2011: https://github.com/heftig/rtkit/issues/13
  # As per https://wiki.archlinux.org/title/PipeWire#Missing_realtime_priority/crackling_under_load_after_suspend
  # Note: existing entry for ExecStart needs to be cleared using ""
  systemd.services.rtkit-daemon.serviceConfig.ExecStart = [
    ""
    "${pkgs.rtkit}/libexec/rtkit-daemon --no-canary"
  ];

  services.pipewire.extraConfig = {
    pipewire = {
      "10-clock-rates" = {
        "context.properties" = {
            "default.clock.rate" = "44100";
           "default.clock.allowed-rates" = [ 32000 44100 48000 ];
        };
      };
      "11-resample-quality" = {
        "stream.properties" = {
          "resample.quality" = 9;
        };
      };
    };
    pipewire-pulse = {
      "15-quantum-min" = {
        "pulse.rules" = [ {
          matches = [ {} ]; # match everything
          actions = {
            update-props = {
              "pulse.min.quantum" = "2048/44100";
              #"pulse.min.req" = "256/48000"; # enforce minimum request
              #"pulse.min.frag" = "256/48000";
            };
          };
        } ];
      };
    };
  };
}
