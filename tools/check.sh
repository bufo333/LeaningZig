#!/bin/sh
# Verify every exercise solution in the course compiles and passes.
#
#   tools/check.sh            check everything
#   tools/check.sh 04 16      check only chapters 04 and 16
#
# Each solution file starts with a header comment containing a line
#   //! Run with:  zig test ex1_foo.zig        (or zig run …, with any flags)
# and the checker executes exactly that command in the solution's directory.
# Solution *directories* (multi-file / build.zig exercises) are checked with
# `zig build test` if build.zig declares a test step, otherwise `zig build`.
# `zig run` programs get their stdin from a sibling  <name>.stdin  file if present.

set -u
cd "$(dirname "$0")/.." || exit 1
pass=0; fail=0; failed=""
filter="$*"

want() {
    # $1 = chapter dir name like 04-integers
    [ -z "$filter" ] && return 0
    for f in $filter; do case "$1" in "$f"*) return 0;; esac; done
    return 1
}

run_one() {
    dir=$1; entry=$2; cmd=$3; input=$4
    if [ -n "$input" ]; then
        out=$(cd "$dir" && sh -c "$cmd" < "$input" 2>&1)
    else
        out=$(cd "$dir" && sh -c "$cmd" < /dev/null 2>&1)
    fi
    if [ $? -eq 0 ]; then
        pass=$((pass + 1)); printf '  ok   %s\n' "$entry"
    else
        fail=$((fail + 1)); failed="$failed\n  $entry"
        printf '  FAIL %s\n%s\n' "$entry" "$(printf '%s\n' "$out" | sed 's/^/       | /' | head -40)"
    fi
}

for chapter in exercises/*/; do
    chapter=${chapter%/}
    name=$(basename "$chapter")
    want "$name" || continue
    sol="$chapter/solutions"
    [ -d "$sol" ] || { printf 'skip %s (no solutions/)\n' "$name"; continue; }
    printf '%s\n' "$name"
    for f in "$sol"/*.zig; do
        [ -e "$f" ] || continue
        base=$(basename "$f")
        cmd=$(grep -m1 'Run with:' "$f" | sed 's/.*Run with:[[:space:]]*//')
        [ -z "$cmd" ] && cmd="zig test $base"
        stdin_file=""
        [ -e "${f%.zig}.stdin" ] && stdin_file="$(cd "$(dirname "$f")" && pwd)/$(basename "${f%.zig}.stdin")"
        run_one "$sol" "$name/$base" "$cmd" "$stdin_file"
    done
    for d in "$sol"/*/; do
        [ -d "$d" ] || continue
        d=${d%/}
        base=$(basename "$d")
        if [ -e "$d/build.zig" ]; then
            if grep -q 'b.step("test"' "$d/build.zig"; then cmd="zig build test"; else cmd="zig build"; fi
        elif [ -e "$d/main.zig" ]; then
            cmd="zig run main.zig"
        else
            printf '  skip %s (no build.zig or main.zig)\n' "$name/$base"; continue
        fi
        run_one "$d" "$name/$base/" "$cmd" ""
    done
done
printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || { printf 'failed:%b\n' "$failed"; exit 1; }
