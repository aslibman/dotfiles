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

`tests/*.bats` are [bats](https://bats-core.readthedocs.io/) tests that run against the built
home configuration (with a scratch `$HOME`), so nothing is activated on your machine.

```bash
nix flake check                                     # all checks, as CI runs them
nix build -L .#checks.aarch64-darwin.home           # just the tests, with output
```

To add a test, add an `@test` to a `.bats` file in `tests/`. Your packages are on `PATH` and
`$HOME` contains the generated dotfiles.

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/)

## License

MIT
