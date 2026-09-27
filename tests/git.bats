load helpers

setup() {
    cd "$BATS_TEST_TMPDIR" || return
}

# Turn `git help --config` entries like `pager.<cmd>` into anchored regexes.
known_git_keys_regex() {
    git help --config | grep -E '^[a-zA-Z]' | sed -e 's/\./\\./g' -e 's/<[^>]*>/[^.]+/g' -e 's/\*/.*/g' |
        sed 's/.*/^&$/' | tr '\n' '|' | sed 's/|$//'
}

# delta.* is delta's own section; filter.lfs.* is written by git-lfs.
@test "every git config key we set is a real git key" {
    regex=$(known_git_keys_regex)
    unknown=$(git config --global --list --name-only | grep -vE '^(delta|filter\.lfs)\.' | grep -viE "$regex" || true)
    [ -z "$unknown" ] || { echo "unknown git keys: $unknown"; return 1; }
}

@test "identity and credential helper" {
    [ "$(git config user.name)" = "Alex Libman" ]
    [ "$(git config user.email)" = "${GIT_EMAIL:-tester@example.com}" ]
    if is_darwin; then
        [ "$(git config credential.helper)" = "osxkeychain" ]
    else
        [ "$(git config credential.helper)" = "libsecret" ]
    fi
}

@test "git lfs filter is installed" {
    [[ "$(git config filter.lfs.clean)" == *"git-lfs clean"* ]]
    [[ "$(git config filter.lfs.process)" == *"git-lfs filter-process"* ]]
}

@test "pagers: delta for diffs, bat for log, no log decorations" {
    [ "$(git config core.pager)" = "delta" ]
    [ "$(git config interactive.diffFilter)" = "delta --color-only" ]
    [ "$(git config pager.log)" = "bat -n --style=changes" ]
    [ "$(git config log.decorate)" = "no" ]
    [ "$(git config diff.algorithm)" = "histogram" ]
    [ "$(git config diff.colorMoved)" = "default" ]
}

@test "delta renders a diff with line numbers" {
    git init -q repo && cd repo
    printf 'one\ntwo\n' > file && git add file && git commit -qm init
    printf 'one\nthree\n' > file
    run bash -c 'git --no-pager diff | delta'
    [ "$status" -eq 0 ]
    [[ "$output" == *"three"* ]]
    [[ "$output" == *"│"* ]]
}

@test "merge conflicts use zdiff3 markers" {
    git init -q -b main repo && cd repo
    printf 'base\n' > file && git add file && git commit -qm base
    git switch -qc other && printf 'theirs\n' > file && git commit -qam theirs
    git switch -q main && printf 'ours\n' > file && git commit -qam ours
    run git merge other
    [ "$status" -ne 0 ]
    grep -q '^||||||| ' file
    grep -q '^base$' file
}

@test "new repositories default to main" {
    git init -q repo
    [ "$(git -C repo symbolic-ref --short HEAD)" = "main" ]
}
