load helpers

nvim_eval() {
    nvim --headless +"lua io.write(tostring($1))" +qa 2>&1
}

@test "neovim starts without errors" {
    run nvim --headless +'colorscheme dracula' +qa
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "vi and vim are neovim" {
    for cmd in vi vim; do
        [[ "$($cmd --version | head -1)" == NVIM* ]] || { echo "$cmd"; return 1; }
    done
}

@test "editor options are applied" {
    [ "$(nvim_eval 'vim.o.number and vim.o.relativenumber')" = "true" ]
    [ "$(nvim_eval 'vim.o.tabstop .. vim.o.shiftwidth .. vim.o.softtabstop')" = "444" ]
    [ "$(nvim_eval 'vim.o.expandtab')" = "true" ]
    [ "$(nvim_eval 'vim.o.scrolloff')" = "6" ]
    [ "$(nvim_eval 'vim.g.colors_name')" = "dracula" ]
}

@test "plugins are loaded" {
    [ "$(nvim_eval 'vim.fn.exists(":AirlineToggle")')" = "2" ]
    [ "$(nvim_eval 'vim.fn.exists(":Commentary")')" = "2" ]
    [ "$(nvim_eval 'vim.notify == require("notify")')" = "true" ]
    [ "$(nvim_eval 'package.loaded["hardtime"] ~= nil')" = "true" ]
}

@test "every bundled treesitter parser loads" {
    parsers="bash c cpp css dockerfile fish go html java javascript json lua make markdown nix python regex rust sql terraform toml tsx typescript vim xml yaml"
    for p in $parsers; do
        result=$(nvim_eval "pcall(vim.treesitter.language.add, '$p')")
        [ "$result" = "true" ] || { echo "parser failed to load: $p ($result)"; return 1; }
    done
}

@test "gcc comments out a line" {
    printf 'print("hi")\n' > "$BATS_TEST_TMPDIR/t.py"
    nvim --headless +'normal gcc' +wq "$BATS_TEST_TMPDIR/t.py"
    [ "$(cat "$BATS_TEST_TMPDIR/t.py")" = '# print("hi")' ]
}

@test "checkhealth reports no errors" {
    nvim --headless +checkhealth +"write! $BATS_TEST_TMPDIR/health.log" +qa 2>/dev/null
    # curl, tar and the tree-sitter CLI are only needed to install parsers outside Nix;
    # infocmp fails when there's no real terminal (CI)
    errors=$(grep -E '^\s*- (❌ )?ERROR' "$BATS_TEST_TMPDIR/health.log" |
        grep -vE 'tree-sitter-cli not found|curl not found|tar not found|"infocmp", "-L"' || true)
    [ -z "$errors" ] || { echo "$errors"; return 1; }
}

@test "startup is fast" {
    nvim --headless --startuptime "$BATS_TEST_TMPDIR/startup.log" +qa
    total_ms=$(tail -1 "$BATS_TEST_TMPDIR/startup.log" | awk '{print int($1)}')
    echo "startup took ${total_ms}ms"
    [ "$total_ms" -lt 300 ]
}
