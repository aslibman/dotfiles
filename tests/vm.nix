# Boots a NixOS VM that uses nixosModules.home for a real user, then runs the
# whole bats suite (including `activated` tests) against the switched home and
# checks that re-activating is idempotent. Linux only; needs KVM.
{
  pkgs,
  home-manager,
  homeModule,
}:

pkgs.testers.runNixOSTest {
  name = "home-activation";

  # nixosModules.home sets nixpkgs.overlays
  node.pkgsReadOnly = false;

  nodes.machine = {
    imports = [
      home-manager.nixosModules.home-manager
      homeModule
    ];

    nixpkgs.config.allowUnfree = true;
    virtualisation.memorySize = 4096;

    users.users.tester = {
      isNormalUser = true;
      linger = true;
    };
    home-manager.users.tester = { };
    home-manager.extraSpecialArgs = {
      username = "tester";
      homeDirectory = "/home/tester";
      gitEmail = "tester@example.com";
    };

    environment.systemPackages = import ./tools.nix pkgs;
  };

  testScript =
    { nodes, ... }:
    let
      homeFiles = nodes.machine.home-manager.users.tester.home-files;
    in
    ''
      machine.wait_for_unit("home-manager-tester.service")

      def run_tests():
          machine.succeed(
              "su - tester -c 'HM_HOME_FILES=${homeFiles} "
              "bats --print-output-on-failure ${./.}' >&2"
          )

      with subtest("bats suite against the activated home"):
          run_tests()

      with subtest("re-activation is idempotent and resets edited VS Code settings"):
          settings = "/home/tester/.config/Code/User/settings.json"
          machine.succeed(f"su - tester -c \"jq '.\\\"editor.fontSize\\\" = 99' {settings} > s && mv s {settings}\"")
          machine.succeed("systemctl restart home-manager-tester.service")
          machine.succeed(f"test \"$(jq '.\\\"editor.fontSize\\\"' {settings})\" = 14")
          run_tests()
    '';
}
