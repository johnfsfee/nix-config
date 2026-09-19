{ config, pkgs, ... }:
{
  home.sessionVariables = {
    XKB_DEFAULT_OPTIONS = "ctrl:swapcaps";
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet";
    mesa_glthread = "true";
  };

  home.packages = [ pkgs.dotnet-sdk_10 ];

  imports =
    [
      ../configuration.nix
      ./shell.nix
      ./mime.nix
      ./programs.nix
      ./services.nix
      ./firefox.nix
      ./desktop/sway.nix
      ./media/mpv.nix
      ./media/mpd.nix
      ./media/games.nix
      #./emacs/doom-standard.nix
      ./emacs/custom.nix
    ]
    ++ (map (p: ../modules + p) [
      /nix-direnv.nix
    ]);

  programs.home-manager.enable = true;

  xdg.userDirs.setSessionVariables = false;

  home.sessionPath = [
    "\${HOME}/.npm-global"
  ];
  i18n.inputMethod = {
    enable = false;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];
  };
}
