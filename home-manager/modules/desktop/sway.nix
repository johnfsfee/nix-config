{
  config,
  pkgs,
  lib,
  ...
}:

let
  # bash script to let dbus know about important env variables and
  # propagate them to relevent services run at the end of sway config
  # see
  # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
  # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts
  # some user services to make sure they have the correct environment variables
  dbus-sway-environment = pkgs.writeTextFile {
    name = "dbus-sway-environment";
    destination = "/bin/dbus-sway-environment";
    executable = true;

    # adding DBUS_SESSION_BUS_ADDRESS to dbus activation environment isn't useful but it's useful to set it for systemd.
    # the --systemd flag will add the envvars for systemd user services as well as for traditional D-Bus session services.
    text = ''
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_DATA_DIRS PATH
      # systemctl --user stop pipewire xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
      # systemctl --user start pipewire xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
      # systemctl --user restart xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
    '';
  };

  /*
  # start custom systemd services
  services-start = pkgs.writeShellScriptBin "services-start" ''
    systemctl --user restart gammastep
  '';
  */
in
{
  /*
  systemd.user.services.gammastep = {
    Unit = {
      Description = "Night time color filter";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.gammastep}/bin/gammastep -m wayland -l 7:-34 -t 6500:3000";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
  */

  services = {
    swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";
        layer = "overlay";
        control-center-layer = "top";
        layer-shell = true;
        cssPriority = "application";
        control-center-margin-top = 0;
        control-center-margin-bottom = 0;
        control-center-margin-right = 0;
        control-center-margin-left = 0;
        notification-2fa-action = true;
        notification-inline-replies = false;
        notification-icon-size = 64;
        notification-body-image-height = 100;
        notification-body-image-width = 200;
      };
    };
  };

  # you can use the theme.nix module as a template for your own theme
  imports = [
    ./foot.nix
    #./mako.nix
  ];

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    XDG_SOUND_THEME = "freedesktop";
    GTK_MODULES = "canberra-gtk-module";
  };

  home.packages = with pkgs; [
    dbus-sway-environment
    #services-start
    wayland
    libsForQt5.qtwayland
    jq
    libcanberra-gtk3 # sound theme integration
    sound-theme-freedesktop
    wl-screenrec # screenrecorder
    slurp # region select
    grim # screen shot
    shotman # screenshot tool
    wl-clipboard # wl-copy and wl-paste from stdin/stdout
    wl-clip-persist # persist clipboard data after closing programs
    # cliphist # clipboard manager, supports images
    xclip # for some clipboard usecases in xwayland clients
    pcmanfm # file manager
    file-roller # archive manager
    swayimg # image viewer (supports gif etc)
  ];

  # tells wob where the sock is
  home.sessionVariables = {
    WOBSOCK = "\${XDG_RUNTIME_DIR}/wob.sock";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        image-viewer = [ "swayimg.desktop" ];
      in
      {
        "inode/directory" = "pcmanfm.desktop";
        "image/jpeg" = image-viewer;
        "image/jpg" = image-viewer;
        "image/jxl" = image-viewer;
        "image/gif" = image-viewer;
        "image/bmp" = image-viewer;
        "image/png" = image-viewer;
        "image/tiff" = image-viewer;
        "image/webp" = image-viewer;
        "image/avif" = image-viewer;
      };
  };

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = rec {

      fonts = {
        names = [ "FiraCode Nerd Font" ];
        size = lib.mkForce 11.0;
      };

      # much better
      focus.newWindow = "urgent";

      gaps.smartBorders = "on";
      gaps.smartGaps = true;

      /*
      colors.focused = rec {
        border = "#83abd4AA";
        indicator = border;
        background = "#DDDDDD";
        childBorder = border;
        text = "#121212";
      };
      */

      startup = [
        { command = "dbus-sway-environment"; }
        { command = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"; }
        #{ command = "services-start"; }
        # { command = "wl-paste --watch cliphist store"; }
        { command = "wl-clip-persist --clipboard regular"; }
        { command = "${pkgs.autotiling-rs}/bin/autotiling-rs"; }
        { command = "rm -f $WOBSOCK && mkfifo $WOBSOCK && tail -f $WOBSOCK | ${pkgs.wob}/bin/wob"; }
        { command = "foot --server"; }
        # { command = "pcmanfm -d"; } # annoying popup
      ];

      /*
        bars = [
          {
            mode = "dock";
            hiddenState = "hide";
            position = "bottom";
            workspaceButtons = true;
            workspaceNumbers = true;
            statusCommand = "${pkgs.i3status}/bin/i3status";
            fonts = {
              names = [ "monospace" ];
              size = 8.0;
            };
            trayOutput = "*";
            colors = {
              background = "#000000";
              statusline = "#ffffff";
              separator = "#666666";
              focusedWorkspace = {
                border = "#4c7899";
                background = "#285577";
                text = "#ffffff";
              };
              activeWorkspace = {
                border = "#333333";
                background = "#5f676a";
                text = "#ffffff";
              };
              inactiveWorkspace = {
                border = "#333333";
                background = "#222222";
                text = "#888888";
              };
              urgentWorkspace = {
                border = "#2f343a";
                background = "#900000";
                text = "#ffffff";
              };
              bindingMode = {
                border = "#2f343a";
                background = "#900000";
                text = "#ffffff";
              };
            };
          }
        ];
      */

      modifier = "Mod4";
      floating.modifier = "Mod4";
      # Use as default launcher menu
      menu = "${pkgs.dmenu}/bin/dmenu_path | ${pkgs.wmenu}/bin/wmenu -b | xargs swaymsg exec --";
      # Use as default terminal
      terminal = "footclient";
      # navkeys
      left = "h";
      down = "j";
      up = "k";
      right = "l";

      keybindings =
        let
          grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
        in
        {
          ## basics
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+Ctrl+m" = "exec ${terminal}";
          "${modifier}+d" = "exec ${menu}";
          # clipboard manager
          # "${modifier}+v" = "exec cliphist list | ${pkgs.wmenu}/bin/wmenu -bl15 | cliphist decode | wl-copy";
          # "${modifier}+b" = "exec cliphist list | ${pkgs.wmenu}/bin/wmenu -bl15 | cliphist delete";
          # screen lock
          "${modifier}+Escape" = "exec ${pkgs.swaylock}/bin/swaylock -fF -c 000000";

          ## audio
          "XF86AudioRaiseVolume" =
            ''exec wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+ && wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > $WOBSOCK'';
          "XF86AudioLowerVolume" =
            ''exec wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%- && wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > $WOBSOCK'';
          "XF86AudioMute" =
            ''exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && (wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo 0 > $WOBSOCK) || wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > $WOBSOCK'';
          "XF86AudioPlay" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";

          ## utils
          # calculator
          "XF86Calculator" = "exec ${pkgs.speedcrunch}/bin/speedcrunch";

          # screenshot
          "Print" = "exec shotman --capture output"; # screen
          "${modifier}+g" = "exec shotman --capture region"; # select region

          # notification
          "${modifier}+t" = "exec swaync-client -t";
          "${modifier}+Shift+t" = "exec swaync-client -C";

          ## sway
          "${modifier}+Shift+c" = "reload";

          "${modifier}+Shift+q" = "kill";
          "${modifier}+Shift+Escape" =
            "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'";

          "${modifier}+f" = "fullscreen";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+Shift+s" = "layout default";

          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";
          "${modifier}+${left}" = "focus left";
          "${modifier}+${down}" = "focus down";
          "${modifier}+${up}" = "focus up";
          "${modifier}+${right}" = "focus right";

          "${modifier}+Shift+Left" = "move left 50px";
          "${modifier}+Shift+Down" = "move down 50px";
          "${modifier}+Shift+Up" = "move up 50px";
          "${modifier}+Shift+Right" = "move right 50px";
          "${modifier}+Shift+${left}" = "move left 50px";
          "${modifier}+Shift+${down}" = "move down 50px";
          "${modifier}+Shift+${up}" = "move up 50px";
          "${modifier}+Shift+${right}" = "move right 50px";

          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";
          "${modifier}+0" = "workspace number 10";

          "${modifier}+Shift+1" = "move container to workspace number 1";
          "${modifier}+Shift+2" = "move container to workspace number 2";
          "${modifier}+Shift+3" = "move container to workspace number 3";
          "${modifier}+Shift+4" = "move container to workspace number 4";
          "${modifier}+Shift+5" = "move container to workspace number 5";
          "${modifier}+Shift+6" = "move container to workspace number 6";
          "${modifier}+Shift+7" = "move container to workspace number 7";
          "${modifier}+Shift+8" = "move container to workspace number 8";
          "${modifier}+Shift+9" = "move container to workspace number 9";
          "${modifier}+Shift+0" = "move container to workspace number 10";

          "${modifier}+n" = "focus output left";
          "${modifier}+m" = "focus output right";

          "${modifier}+Shift+n" = "move output left";
          "${modifier}+Shift+m" = "move output right";

          "${modifier}+Tab" = "move workspace to output right";
          "${modifier}+Shift+Tab" = "move workspace to output left";

          # "${modifier}+t" = "input type:touchpad events disabled";
          # "${modifier}+Shift+t" = "input type:touchpad events enabled";

          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+space" = "focus mode_toggle";

          "${modifier}+a" = "focus parent";
          "${modifier}+c" = "focus child";

          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";

          "${modifier}+r" = ''mode "resize" '';
        };

      modes.resize = {
        "Left" = "resize shrink width 50px";
        "Up" = "resize grow height 50px";
        "Down" = "resize shrink height 50px";
        "Right" = "resize grow width 50px";
        "${left}" = "resize shrink width 50px";
        "${up}" = "resize grow height 50px";
        "${down}" = "resize shrink height 50px";
        "${right}" = "resize grow width 50px";
        "Shift+Left" = "resize shrink width 10px";
        "Shift+Up" = "resize grow height 10px";
        "Shift+Down" = "resize shrink height 10px";
        "Shift+Right" = "resize grow width 10px";
        "Shift+${left}" = "resize shrink width 10px";
        "Shift+${up}" = "resize grow height 10px";
        "Shift+${down}" = "resize shrink height 10px";
        "Shift+${right}" = "resize grow width 10px";

        "Return" = ''mode "default" '';
        "Escape" = ''mode "default" '';
        "Ctrl+m" = ''mode "default" '';
        "Ctrl+bracketleft" = ''mode "default" '';
      };
    };
  };
}
