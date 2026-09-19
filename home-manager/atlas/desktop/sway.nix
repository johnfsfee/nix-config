{ config, pkgs, ... }:

{
  # if GFX8 VK_EXT_IMAGE_DRM_FORMAT_MODIFIER is supported one day
  # home.sessionVariables = { WLR_RENDERER = "vulkan"; };
  home.packages = [ pkgs.waybar pkgs.wttrbar ];

  imports = (map (p: ../../modules + p) [
    /desktop/sway.nix
  ]) ++ [
    ./swayidle.nix
    ./theme.nix
  ];

  # sway preferences
  wayland.windowManager.sway = {
    config = {
      input = {
        /*
        "1133:49271:Logitech_USB_Optical_Mouse" = {
          accel_profile = "flat";
          pointer_accel = "0.5";
        };
        "1118:1861:Microsoft_Microsoft___2.4GHz_Transceiver_v8.0" = {
          repeat_delay = "250";
          xkb_numlock = "enabled";
        };
        */
        "type:pointer" = {
          accel_profile = "flat";
          pointer_accel = "0";
        };
        "type:keyboard" = {
          repeat_delay = "250";
          xkb_numlock = "enabled";
          xkb_layout = "us,br";
          xkb_options = "ctrl:swapcaps,numpad:microsoft,grp:rctrl_rshift_toggle";
        };
      };
      output = {
        "*" = {
          subpixel = "rgb";
          adaptive_sync = "on";
          #bg = "${../../../assets/wallpapers/1920x1080-vulcan_sakura.jpg} fill";
        };
      };

      bars = [{ command = "waybar"; }];

      defaultWorkspace = "workspace number 1";

      assigns = { "9" = [{ app_id="ymuse"; }]; };

      startup = [
        { command = "keepassxc"; }
        { command = "ymuse"; }
        #{ command = "gnome-clocks"; } # FIXME gapplication-service
      ];

      keybindings = let
      modifier = "Mod4"; 
      mpc = "${pkgs.mpc-cli}/bin/mpc";
      in {
          # emacs shortcut
        "${modifier}+Ctrl+e" = "exec emacsclient -c";

          # mpd
          "${modifier}+XF86AudioRaiseVolume" = "exec ${mpc} volume +5";
          "${modifier}+XF86AudioLowerVolume" = "exec ${mpc} volume -5";
          "${modifier}+XF86AudioPlay" = "exec ${mpc} toggle";
          "${modifier}+XF86AudioMute" = "exec ${mpc} repeat";
          "${modifier}+Prior" = "exec ${mpc} prev";
          "${modifier}+Next" = "exec ${mpc} next";
      };
    };

    extraConfig = ''
      for_window [app_id="com.github.wwmm.easyeffects"] floating enable
      # for_window [app_id="org.keepassxc.KeePassXC"] move to scratchpad
      for_window [title="Wine desktop*"] floating enable
    '';
  };
}
