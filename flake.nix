{
  description = "Home-manager dotfiles";

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
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix4vscode,
      mac-app-util,
      treefmt-nix,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      isDarwin = system: builtins.match ".*-darwin" system != null;

      overlays = [ nix4vscode.overlays.default ];

      treefmtEval = forAllSystems (
        system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} (
          { pkgs, ... }:
          {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.yamlfmt.enable = true;
          }
        )
      );

      mkHomeConfiguration =
        system:
        {
          username,
          homeDirectory,
          gitEmail,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system overlays;
            config.allowUnfree = true;
          };
          modules = [
            ./home.nix
            ./shared
          ]
          ++ nixpkgs.lib.optionals (isDarwin system) [
            mac-app-util.homeManagerModules.default
            ./darwin
          ]
          ++ nixpkgs.lib.optionals (!isDarwin system) [
            ./linux
          ];
          extraSpecialArgs = {
            inherit username homeDirectory gitEmail;
          };
        };
    in
    {
      # For use in NixOS configurations — callers must supply all mkHomeConfiguration args
      # via home-manager.extraSpecialArgs (or home-manager.users.<name>.extraSpecialArgs)
      nixosModules.home =
        { ... }:
        {
          nixpkgs = { inherit overlays; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.sharedModules = [
            ./home.nix
            ./shared
            ./linux
          ];
        };

      # homeConfigurations reads from the environment — only used by the nix run app
      homeConfigurations = forAllSystems (
        system:
        mkHomeConfiguration system {
          username = builtins.getEnv "USER";
          homeDirectory = builtins.getEnv "HOME";
          gitEmail = builtins.getEnv "GIT_EMAIL";
        }
      );

      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "home-manager-switch" ''
                set -euo pipefail
                if [ -z "''${GIT_EMAIL:-}" ]; then
                  EMAIL_FILE="$HOME/.config/git/email"
                  if [ -f "$EMAIL_FILE" ]; then
                    GIT_EMAIL=$(cat "$EMAIL_FILE")
                  else
                    printf "Git email address: "
                    read -r GIT_EMAIL
                    mkdir -p "$HOME/.config/git"
                    printf '%s' "$GIT_EMAIL" > "$EMAIL_FILE"
                  fi
                  export GIT_EMAIL
                fi
                exec ${
                  home-manager.packages.${system}.default
                }/bin/home-manager switch -b backup --flake ${self}#${system} --impure "$@"
              ''
            );
          };
        }
      );

      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              treefmtEval.${system}.config.build.wrapper
              pkgs.codespell
              pkgs.prek
              pkgs.shellcheck
            ];
            shellHook = ''
              prek install
            '';
          };
        }
      );
    };
}
