{
  description = "Anon's NixOS & Home Manager configurations";

  outputs =
    inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = (
        import ./outputs/nixos-conf.nix {
          inherit inputs system;
        }
      );

      homeConfigurations = (
        import ./outputs/hm-conf.nix {
          inherit inputs system;
        }
      );
    };

  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    #hydrus-rollback.url = "github:Nixos/nixpkgs/94cec473fc2af2fd5fefb866a232145df749c47c";

    nix-alien.url = "github:thiagokokada/nix-alien";

    # musnix.url = "github:musnix/musnix";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # slippi.url = "github:lytedev/slippi-nix";

    emacs-overlay.url = "github:nix-community/emacs-overlay";

    /*
      not in use

      chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

      sops-nix.url = "github:Mic92/sops-nix";
    */
  };
}
