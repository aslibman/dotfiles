setup() {
    cd "$BATS_TEST_TMPDIR" || return
    mkdir -p project/sub
    echo hello > project/alpha.txt
    echo world > project/sub/beta.txt
}

@test "ff searches the current directory when given no folder" {
    cd project
    FZF_DEFAULT_OPTS="--filter=alpha" run ff
    [ "$status" -eq 0 ]
    [ "$output" = "alpha.txt" ]
}

@test "ff searches the given folder" {
    FZF_DEFAULT_OPTS="--filter=beta" run ff project/sub
    [ "$status" -eq 0 ]
    [ "$output" = "beta.txt" ]
}

@test "fkill kills the selected process" {
    sleep 29.7351 &
    pid=$!
    FZF_DEFAULT_OPTS="--exact --filter='sleep 29.7351$'" run fkill
    [ "$status" -eq 0 ]
    wait "$pid" || code=$?
    [ "$code" -eq 137 ] # 128 + SIGKILL
}

@test "fkill passes a custom signal" {
    sleep 29.7352 &
    pid=$!
    FZF_DEFAULT_OPTS="--exact --filter='sleep 29.7352$'" run fkill -TERM
    [ "$status" -eq 0 ]
    wait "$pid" || code=$?
    [ "$code" -eq 143 ] # 128 + SIGTERM
}
