{ config, pkgs, ... }:
{
  home.sessionVariables = {
    XKB_DEFAULT_OPTIONS = "ctrl:swapcaps";
    DOTNET_ROOT = "${pkgs.dotnet-sdk_9}";
    mesa_glthread = "true";
  };

  imports = [
    ../configuration.nix
    ./shell.nix
    ./mime.nix
    ./programs.nix
    ./services.nix
    ./desktop/sway.nix
    # use vlc
    # ./media/mpv.nix
    ./media/mpd.nix
    ../anon/emacs/doom-standard.nix
  ] ++
  (map (p: ../modules + p) [
    /nix-direnv.nix
    /office/zathura.nix
  ]);

  programs.home-manager.enable = true;

  home.sessionPath = [
    "\${HOME}/.npm-global"
  ];
}
