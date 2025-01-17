#!/usr/bin/env bash

# This creates a build that is similar to a release build, but it is debuggable.
# There is no hot reloading and no separate game library.

OUT_DIR="out/debug"
mkdir -p "$OUT_DIR"
odin build main_release -out:$OUT_DIR/game_debug.bin -debug

cp -R res $OUT_DIR
echo "Debug build created in $OUT_DIR"
