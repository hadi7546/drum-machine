#!/bin/bash

# Set up the build directory
meson setup builddir

# Compile the project
ninja -C builddir
