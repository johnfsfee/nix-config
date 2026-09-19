{ inputs, system, ... }:

let
  nixosSystem = inputs.nixpkgs.lib.nixosSystem;
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  pkg-config = {
    inherit system;
    config.allowUnfreePredicate = (pkg: true);
  };
in
{
  damnix = nixosSystem rec {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = let
      overlay-config = {
        nixpkgs.overlays = [
          inputs.nix-alien.overlays.default
          (import ../pkgs/default.nix)
        ];
        # Optional, needed for `nix-alien-ld`
        programs.nix-ld.enable = true;
      };
    in [
      # inputs.sops-nix.nixosModules.sops
      # inputs.c
      # inputs.musnix.nixosModules.musnix
      ../nixos/damnix/default.nix
      overlay-config
    ];
  };

  mobilepotato = nixosSystem rec {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      # inputs.sops-nix.nixosModules.sops
      # inputs.musnix.nixosModules.musnix
      # inputs.chaotic.nixosModules.default
      ../nixos/mobilepotato/default.nix

    ];
  };
}
