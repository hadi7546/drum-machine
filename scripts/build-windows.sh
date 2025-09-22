#!/bin/bash

# Go to the project root
cd ..

# Set up the build directory for Windows cross-compilation
meson setup builddir --cross-file=scripts/windows-cross-file.txt

# Compile the project
ninja -C builddir
