{ pkgs, config, ... }:

{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -fF -c 000000";
      }
      {
        timeout = 360;
        command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
      }
      {
        timeout = 900;
        command = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
      }
    ];
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -fF -c 000000";
    };
  };
}
