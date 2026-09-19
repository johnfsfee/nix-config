{ config, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "emacsclient -c";
    MOZ_USE_XINPUT2 = "1";
    MOZ_ENABLE_WAYLAND = "1";
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
    WWW_HOME = "https://lite.duckduckgo.com/lite";
    LYNX_CFG = "~/.lynx/lynx.cfg";
    LYNX_CFG_PATH = "~/.lynx";
    HISTSIZE = "500";
    HISTFILESIZE = "100000";
  };

  programs.starship.enable = true;
  programs.bash = {
    enable = true;

    shellAliases = {
      "sudo" = "sudo ";
    };

    bashrcExtra = ''
      nixify() {
        if [ ! -e ./.envrc ]; then
          echo "use nix" > .envrc
          direnv allow
        fi
        if [[ ! -e shell.nix ]] && [[ ! -e default.nix ]]; then
          cat > default.nix <<'EOF'
      with import <nixpkgs> {};
      mkShell {
        nativeBuildInputs = [
          bashInteractive
        ];
      }
      EOF
        fi
      }
      flakify() {
        if [ ! -e flake.nix ]; then
          nix flake new -t github:nix-community/nix-direnv .
        elif [ ! -e .envrc ]; then
          echo "use flake" > .envrc
          direnv allow
        fi

      }
    '';
  };
}
