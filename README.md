# Dotfiles

Personal dotfiles managed with [home-manager](https://github.com/nix-community/home-manager) and Nix flakes.

## Quick Start

Install [Nix](https://nixos.org/download/) first, then:

```bash
nix run github:aslibman/dotfiles --impure
```

You'll be prompted for your git email on first run (saved to `~/.config/git/email` for future runs).

To update, just run the install command again.

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/)

## License

MIT
