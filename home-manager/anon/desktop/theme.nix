# my preferred gtk and pointer themes
{ config, pkgs, lib, ... }:

let
  buuf-nestort = pkgs.stdenv.mkDerivation {
    pname = "buuf-nestort";
    version = "2025-03-01T17";

    src = pkgs.fetchgit {
      url = "https://git.disroot.org/eudaimon/buuf-nestort";
      rev = "f9af8f2c99205fff5743b6e2076126a195ca7357"; # Use a commit hash for reproducibility
      hash = "sha256-Mw+12u3BPEM6h8wK8YeDYzE6PLWM+4bOfnMjHfdyzUM=";
    };

    installPhase = ''
      mkdir -p $out/share/icons/Buuf-Nestort
      cp -r * $out/share/icons/Buuf-Nestort
      find $out/share/icons/Buuf-Nestort -xtype l -delete
    '';
  };
in
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
    source-han-sans
    source-han-serif
    emacs-all-the-icons-fonts
  ];

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/zenburn.yaml";
  stylix.image = ../../../assets/wallpapers/1920x1080-vulcan_sakura.jpg;
  stylix.targets.firefox.profileNames = [ "default" ];
    stylix.fonts = {
    serif = config.stylix.fonts.monospace;
    sansSerif = config.stylix.fonts.monospace;
    monospace = {
      package = pkgs.nerd-fonts.fira-code;
      name = "FiraCode Nerd Font";
    };
    emoji = config.stylix.fonts.monospace;
  };


  home.pointerCursor = {
    x11.enable = true;
    package = "${../../../assets/cursors/buufAnimated24}";
    name = "cursor-theme";
  };

  gtk = {
    enable = true;
    # gtk4.theme = lib.mkForce null; # home.stateVersion < 26.05

    iconTheme = {
      #package = "${/home/anon/src/buufNestort}";
      package = buuf-nestort;
      name = "Buuf-Nestort";
      #name = "Buuf For Many Desktops";
    };
    cursorTheme = {
      package = "${../../../assets/cursors/buufAnimated24}";
      name = "cursor-theme";
      size = 16;
    };
  };

  /*
  qt = {
    enable = true;
   # platformTheme.name = "gtk";
  };
  */
}
