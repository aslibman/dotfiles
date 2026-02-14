{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { self, nixpkgs, home-manager, nix4vscode, mac-app-util, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      isDarwin = system: builtins.match ".*-darwin" system != null;

      mkHomeConfiguration = system: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [ nix4vscode.overlays.default ];
        };
        modules = [ ./home.nix ]
          ++ nixpkgs.lib.optionals (isDarwin system) [
            mac-app-util.homeManagerModules.default
            ./iterm2
          ];
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
              exec ${home-manager.packages.${system}.default}/bin/home-manager switch -b backup --flake ${self}#${system} "$@"
            '');
          };
        }
      );
    };
}
