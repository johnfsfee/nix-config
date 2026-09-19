{ pkgs, config, ... }:

{
  home.sessionVariables = {
    HISTSIZE = "500";
    HISTFILESIZE = "100000";
    #EDITOR = "nvim";
    #VISUAL = "emacsclient -c";
    # firefox envvars
    MOZ_USE_XINPUT2 = "1";
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DRM_DEVICE = "/dev/dri/renderD128";
    # mesa envvar for experimental decode features (like vulkan)
    RADV_EXPERIMENTAL = "video_decode";
    # disable wine menu builder
    WINEDLLOVERRIDES = "winemenubuilder.exe=d";
    # DAW plugin path
    LV2_PATH = "/home/anon/.nix-profile/lib/lv2";
    VST_PATH = "/home/anon/.nix-profile/lib/vst";
    LXVST_PATH = "/home/anon/.nix-profile/lib/lxvst";
    LADSPA_PATH = "/home/anon/.nix-profile/lib/ladspa";
    DSSI_PATH = "/home/anon/.nix-profile/lib/dssi";
    # lynx envvars
    WWW_HOME = "https://lite.duckduckgo.com/lite";
    LYNX_CFG = "~/.lynx/lynx.cfg";
    LYNX_CFG_PATH = "~/.lynx";
    # emacs's LSP-Mode is faster with PLISTS
    LSP_USE_PLISTS = "true";
    DOOMDIR = "~/nix-config/home-manager/anon/emacs/std-doom/doom";
    # By default java does not enable anti-aliasing for font rendering. By exporting environment variables, this can be fixed:
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
    JAVA_8_HOME = "${pkgs.jdk8}/lib/openjdk";
  };

  programs.starship.enable = true;
  programs.bash = {
    enable = true;

    shellAliases = {
      "sudo" = "sudo ";
      "ed" = "$EDITOR ";
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
