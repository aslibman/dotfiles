{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    openssh
  ];

  services.podman = {
    enable = true;
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    # Override nix-darwin's volumes manually because the default does
    # not currently actually use the podman CLI's default volumes.
    # https://sourcegraph.com/r/github.com/nix-community/home-manager@2b9504d5a0169d4940a312abe2df2c5658db8de9/-/blob/modules/services/podman/darwin.nix?L86
    useDefaultMachine = false;
    machines.dev-machine = {
      volumes = [
        "/Users:/Users"
        "/var/folders:/var/folders"
      ];
    };
  };

  # `podman machine init` requires ssh-keygen on the PATH
  home.activation.podmanSshPath = lib.hm.dag.entryBefore [ "podmanMachines" ] ''
    export PATH="${pkgs.openssh}/bin:$PATH"
  '';

  home.activation.validatePodman = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    run echo "🔍 Validating Podman configuration..."

    if ! run ${pkgs.writeShellScript "test-podman-wrapper" ''
      export PATH="${config.home.profileDirectory}/bin:$PATH"
      ${./test-podman.sh}
    ''}; then
      echo "❌ Podman validation failed!"
      echo "Fix the errors above before the configuration can be activated."
      exit 1
    fi
  '';
}
