{ inputs, system, ... }:

with inputs;

let
  pkgConfig = { inherit system; config.allowUnfreePredicate = (pkg: true); };
  pkgs = nixpkgs.legacyPackages.${system};

  commonConfig = {
    nixpkgs.overlays = [
    (import ../pkgs/default.nix)
    nur.overlays.default
    emacs-overlay.overlays.default
    ];
    nixpkgs.config.allowUnfreePredicate = (pkg: true); # workaround for https://github.com/nix-community/home-manager/issues/2942
    nixpkgs.config.permittedInsecurePackages = [ "python-2.7.18.6" ];
    nix.registry.nixpkgs.flake = nixpkgs;
    xdg.configFile."nix/inputs/nixpkgs".source = nixpkgs.outPath;
  };

in
{
  anon = home-manager.lib.homeManagerConfiguration rec {
    inherit pkgs;
    modules = [
      commonConfig
      ../home-manager/anon/default.nix
      {
        home = {
          stateVersion = "22.05";
          username = "anon";
          homeDirectory = "/home/anon";
          #packages = [ inputs.hydrus-rollback.legacyPackages.${system}.hydrus ];
        };
      }
      stylix.homeModules.stylix
      #slippi.homeManagerModules.default
      {
        # use your path
        #slippi-launcher.isoPath = "/home/anon/Games/Roms/gc/Super Smash Bros. Melee (USA) (En,Ja) (v1.02)/Super Smash Bros. Melee (USA) (En,Ja) (v1.02).iso";
      }
    ];
    extraSpecialArgs = {
      inherit inputs;
    };
  };

  atlas = home-manager.lib.homeManagerConfiguration rec {
    inherit pkgs;
    modules = [
      commonConfig
      ../home-manager/atlas/default.nix
      {
        home = {
          stateVersion = "22.05";
          username = "atlas";
          homeDirectory = "/home/atlas";
        };
      }
    ];
    extraSpecialArgs = {
      inherit inputs;
    };
  };
}
