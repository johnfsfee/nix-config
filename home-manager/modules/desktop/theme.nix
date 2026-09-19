# template and defaults for themes and fonts
{ config, pkgs, ... }:

{
  # enable custom fonts
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.fira-code # term and glyphs
    font-awesome_4 # more glyphs, v5 doesnt work well with waybar and v6 messes my other fonts
    font-awesome_5 # need this for some extra glyphs
    powerline-fonts # unicode characters and glyphs
    noto-fonts # google multilanguage font
    noto-fonts-cjk-sans # asian
    noto-fonts-color-emoji # google emojis

  ];

  home.pointerCursor = {
    x11.enable = true;
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
  };

  gtk = {
    enable = true;
    gtk4.theme = null; # home.stateVersion < 26.05

    theme = {
      package = pkgs.dracula-theme;
      name = "Dracula";
    };

    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };

    cursorTheme = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = 16;
    };

    gtk3 = {
      extraConfig = {
        gtk-enable-event-sounds = true;
        gtk-enable-input-feedback-sounds = true;
        gtk-sound-theme-name = "freedesktop";
      };
    };

    gtk2 = {
      extraConfig = {
        gtk-enable-event-sounds = true;
        gtk-enable-input-feedback-sounds = true;
        gtk-sound-theme-name = "freedesktop";
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      package = pkgs.adwaita-qt;
      name = "adwaita-dark";
    };
  };
}
