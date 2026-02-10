{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      mkHomeConfiguration = system: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./home.nix ];
      };
    in {
      homeConfigurations = forAllSystems mkHomeConfiguration;

      apps = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = {
            type = "app";
            program = toString (pkgs.writeShellScript "home-manager-switch" ''
              exec ${home-manager.packages.${system}.default}/bin/home-manager switch --flake ${self}#${system} "$@"
            '');
          };
        }
      );
    };
}
