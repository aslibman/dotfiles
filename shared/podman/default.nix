{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    openssh
  ];

  services.podman = {
    enable = true;
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
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
}
