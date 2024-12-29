#!/bin/bash
set -ex

odin build *.odin -file -out:holiday-jam
./holiday-jam

