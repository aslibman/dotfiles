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
      import shlex

      def as_tester(command):
          return machine.succeed("su - tester -c " + shlex.quote(command))

      def run_suite():
          as_tester("TERM=xterm-256color HM_HOME_FILES=${homeFiles} bats --print-output-on-failure ${./.} >&2")

      machine.wait_for_unit("home-manager-tester.service")

      with subtest("bats suite against the activated home"):
          run_suite()

      with subtest("re-activation is idempotent and resets edited VS Code settings"):
          settings = "/home/tester/.config/Code/User/settings.json"
          as_tester(f"jq '.[\"editor.fontSize\"] = 99' {settings} > s && mv s {settings}")
          machine.succeed("systemctl restart home-manager-tester.service")
          font_size = as_tester(f"jq '.[\"editor.fontSize\"]' {settings}").strip()
          assert font_size == "14", f"editor.fontSize is {font_size} after re-activation"
          run_suite()
    '';
}
