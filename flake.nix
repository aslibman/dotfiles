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
        "aarch64-linux"
        "x86_64-linux"
      ];

      inherit (nixpkgs) lib;

      forAllSystems = lib.genAttrs systems;

      isDarwin = lib.hasSuffix "-darwin";

      # Pure evaluation (e.g. `nix flake check`) sees empty env vars, so fall back
      # to placeholders. Real switches go through the app below, which uses --impure.
      getEnvOr =
        name: default:
        let
          value = builtins.getEnv name;
        in
        if value == "" then default else value;

      commonModules = [
        ./home.nix
        ./shared
      ];

      overlays = [ nix4vscode.overlays.default ];

      treefmtEval = forAllSystems (
        system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          projectRootFile = "flake.nix";
          programs.nixfmt.enable = true;
          programs.yamlfmt.enable = true;
        }
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
          modules =
            commonModules
            ++ (
              if isDarwin system then
                [
                  mac-app-util.homeManagerModules.default
                  ./darwin
                ]
              else
                [ ./linux ]
            );
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
          home-manager.sharedModules = commonModules ++ [ ./linux ];
        };

      # homeConfigurations reads from the environment — only used by the nix run app
      homeConfigurations = forAllSystems (
        system:
        mkHomeConfiguration system {
          username = getEnvOr "USER" "user";
          homeDirectory = getEnvOr "HOME" "/homeless-shelter";
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

      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
        home = import ./tests {
          pkgs = nixpkgs.legacyPackages.${system};
          mkHomeConfiguration = mkHomeConfiguration system;
        };
      });

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
