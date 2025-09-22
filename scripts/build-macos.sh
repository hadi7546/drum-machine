#!/bin/bash

# Go to the project root
cd ..

# Set up the build directory
meson setup builddir

# Compile the project
ninja -C builddir
