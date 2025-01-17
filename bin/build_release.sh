#!/usr/bin/env bash

# This script creates an optimized release build.

OUT_DIR="out/release"
mkdir -p "$OUT_DIR"
odin build main_release -out:$OUT_DIR/game_release.bin -no-bounds-check -o:speed
cp -R res $OUT_DIR
echo "Release build created in $OUT_DIR"
