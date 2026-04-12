{ pkgs, ... }:

let
  gitEmail = builtins.getEnv "GIT_EMAIL";
in
{
  programs.git = {
    # Helpful reference:
    # https://jvns.ca/blog/2024/02/16/popular-git-config-options/#pull-ff-only-or-pull-rebase-true

    enable = true;

    lfs.enable = true;

    settings = {
      user = {
        name = "Alex Libman";
        email = gitEmail;
      };

      credential.helper = if pkgs.stdenv.isDarwin then "osxkeychain" else "libsecret";
      init.defaultBranch = "main";

      core.pager = "delta";

      interactive.diffFilter = "delta --color-only";

      delta = {
        navigate = true;
        line-numbers = true;
        hyperlinks = true;
        colorMoved = "default";
        syntax-theme = "Dracula";
      };

      pager.log = "bat -n --style=changes";

      # histogram handles reordering better than the default myers algorithm
      # https://luppeng.wordpress.com/2020/10/10/when-to-use-each-of-the-git-diff-algorithms/
      diff = {
        algorithm = "histogram";
        color = "no";
      };

      # zdiff3 includes context about previous code when resolving merge conflicts
      # https://ductile.systems/zdiff3/
      merge.conflictstyle = "zdiff3";

      # Decorations disabled due to clash with bat
      # https://github.com/sharkdp/bat/discussions/2329
      log.decorate = "no";
    };
  };
}
