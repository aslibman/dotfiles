# Dotfiles

Personal dotfiles managed with [home-manager](https://github.com/nix-community/home-manager) and Nix flakes.

## Quick Start

Install [Nix](https://nixos.org/download/) first, then:

```bash
nix run github:aslibman/dotfiles
```

You'll be prompted for your git email on first run (saved to `~/.config/git/email` for future runs).

To update, just run the install command again.

## Testing

`tests/*.bats` are [bats](https://bats-core.readthedocs.io/) tests for the configuration. They run in
three places:

- **`checks.<system>.home`**: against the built configuration in a scratch `$HOME`, without
  activating anything. `nix flake check` runs this, along with formatting and a check that
  home-manager reports no warnings.
- **CI, after a real `nix run .`** on macOS and Linux: the whole suite, including tests tagged
  `activated` (see `tests/activated.bats`), plus backup, re-switch and no-warnings checks.
- **`checks.<linux>.vm`**: a NixOS VM that uses `nixosModules.home` for a real user, runs the
  suite, then re-activates. Needs a Linux machine or builder with KVM.

```bash
nix flake check                                     # everything for this machine
nix build -L .#checks.aarch64-darwin.home           # just the tests, with output
```

To add a test, add an `@test` to a `.bats` file in `tests/` (`load helpers` for the shared
helpers). Tests that need a real switch go in `activated.bats`. Don't run the suite directly
against your own home: some tests write state there (e.g. `direnv allow`).

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/)

## License

MIT
