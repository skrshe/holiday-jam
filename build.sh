#!/bin/bash

if [ -x "$(command -v make)" ]; then
    make
else
    set -ex
	odin build . -out:holiday-jam -file
	./holiday-jam
fi
