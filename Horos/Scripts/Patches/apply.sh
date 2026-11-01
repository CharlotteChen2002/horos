#!/bin/sh
#
# Applies Horos/Scripts/Patches/<target>/*.patch to the <target> submodule checkout.
# Idempotent: patches that are already applied are skipped.
#
# These patches fix third-party code that newer Clang/SDK versions reject; the submodules
# stay pinned to their upstream tags, and the fixes live here instead of in forks.
#
# Usage: apply.sh <target>   (run from anywhere; <target> is the submodule directory name)

set -e

target="$1"
[ -n "$target" ] || { echo >&2 "error: usage: $0 <target>"; exit 1; }

patches_dir="$(cd "$(dirname "$0")" && pwd)/$target"
source_dir="$(cd "$(dirname "$0")/../../.." && pwd)/$target"

[ -d "$patches_dir" ] || exit 0

for patch in "$patches_dir"/*.patch; do
    [ -f "$patch" ] || continue
    name="$(basename "$patch")"
    if git -C "$source_dir" apply --reverse --check "$patch" >/dev/null 2>&1; then
        echo "$target: $name already applied"
    elif git -C "$source_dir" apply --check "$patch" >/dev/null 2>&1; then
        git -C "$source_dir" apply "$patch"
        echo "$target: applied $name"
    else
        echo >&2 "error: $target: $name does not apply to $source_dir; was the submodule updated?"
        exit 1
    fi
done
