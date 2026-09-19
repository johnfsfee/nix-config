# my preferred gtk and pointer themes
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
    noto-fonts-cjk # asian
    noto-fonts-color-emoji # google emojis
    source-han-sans-japanese
    source-han-serif-japanese
  ];

  home.pointerCursor = {
    x11.enable = true;
    package = "${../../../assets/cursors/buufAnimated24}";
    name = "cursor-theme";
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.shades-of-gray-theme;
      name = "Shades-of-gray";
    };

    iconTheme = {
      package = "${/home/atlas/src/buufNestort}";
      name = "Buuf For Many Desktops";
    };

    cursorTheme = {
      package = "${../../../assets/cursors/buufAnimated24}";
      name = "cursor-theme";
      size = 16;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      package = pkgs.shades-of-gray-theme;
      name = "Shades-of-gray";
    };
  };
}
