# settings i consider important for any hosts
{ config, pkgs, inputs, ... }:

{
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    /*
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 32d";
    };
    */
  };

  # channels and registry on flakes
  environment.etc."nix/inputs/nixpkgs".source = inputs.nixpkgs.outPath;
  nix.nixPath = [ "nixpkgs=/etc/nix/inputs/nixpkgs" ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  programs = {
    nix-ld.enable = true;
    appimage = {
      enable = true;
      # binfmt = true; # doesn't work with type3 appimages
      package = pkgs.appimage-run.override { extraPkgs = pkgs: [
        pkgs.python312
      ]; };
    };
    fzf = {
      fuzzyCompletion = true;
      keybindings = true;
    };
    iotop.enable = true; # setcap
  };
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    nixVersions.stable
    nettools
    age
    bat
    man-db
    file
    neovim
    mg
    htop
    lm_sensors
    wget
    fzf
    ripgrep
    fd
    tmux
    traceroute
    dig
    iproute2
    pciutils
    nix-index
  ];

  environment.sessionVariables = {
    # "FZF_DEFAULT_OPTS" = "--preview 'bat --color=always {}'";
    "FZF_DEFAULT_COMMAND" = "fd --type f";
  };

  # list packages installed on host
  environment.shellAliases = { nix-query = "nix-store -q --references /run/current-system/sw | rg -v man | sed 's/^[^-]*-//g' | sed 's/-[0-9].*//g' | rg -v '^nix' | sort -u"; };

}
