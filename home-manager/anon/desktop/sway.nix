{ config, pkgs, ... }:

let
  youtube-local_start = pkgs.writeShellScriptBin "youtube-local_start" ''
    #!/usr/bin/env sh
    unset CDPATH
    cd $HOME/src/yt-local
    #nix-shell --run "python server.py"
    python server.py
  '';
in
{
  # if GFX8 VK_EXT_IMAGE_DRM_FORMAT_MODIFIER is supported one day
  # home.sessionVariables = { WLR_RENDERER = "vulkan"; };
  home.packages = [
    pkgs.waybar
    pkgs.wttrbar
    #pkgs.keyd
    youtube-local_start
    ## for youtube_local ##
    (pkgs.python3.withPackages (ps: with ps; [
      flask
      gevent
      brotli
      pysocks
      urllib3
      defusedxml
      cachetools
      stem
    ]))

  ];

  imports =
    (map (p: ../../modules + p) [
      /desktop/sway.nix
    ])
    ++ [
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
          pointer_accel = "0.0";
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
          bg = "${../../../assets/wallpapers/1920x1080-vulcan_sakura.jpg} fill";
        };
      };

      focus.followMouse = false;

      bars = [ { command = "waybar"; } ];

      defaultWorkspace = "workspace number 1";

      assigns = {
        "1" = [
          { class = "Pale moon"; }
          { class = "Chromium-browser"; }
        ];
      };
      assigns = {
        "3" = [ { class = "Hydrus Client"; } ];
      };
      assigns = {
        "4" = [
          { class = "steam"; }
          { app_id = "org.gajim.Gajim"; }
        ];
      };
      assigns = {
        "9" = [ { app_id = "org.keepassxc.KeePassXC"; } ];
      };
      assigns = {
        "10" = [
          { app_id = "org.kde.kdeconnect.app"; }
        ];
      };

      startup = [
        { command = "corectrl"; }
        { command = "keepassxc"; }
        { command = "~/.local/bin/hydrus"; }
        { command = "kdeconnect-app"; }
        { command = "youtube-local_start"; }
        { command = "timidity-server"; }
        #{ command = "keyd-application-mapper -d"; }
      ];

      keybindings =
        let
          modifier = "Mod4";
          mpc = "${pkgs.mpc}/bin/mpc";
        in
        {
          ## emacs ##
          "${modifier}+Shift+z" = "exec emacsclient -c";
          "${modifier}+z" = ''exec emacsclient --eval "(emacs-everywhere)"'';

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
      for_window [app_id="firefox" title="^Picture-in-Picture$"] floating enable, move position 877 450, sticky enable
      for_window [app_id="com.github.wwmm.easyeffects"] floating enable
      for_window [title="manage tags — hydrus client*"] floating enable
      for_window [title="manage tags — hydrus client*"] floating enable
      # for_window [app_id="org.keepassxc.KeePassXC"] move to scratchpad
      # for_window [title="Wine desktop*"] floating enable
      # for_window [title="Rayman III"] floating enable
      for_window [title="Street Fighter III 3rd Strike: Fight for the Future (Japan 990512, NOCD)*"] floating enable

    '';
  };
}
