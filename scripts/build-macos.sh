#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building Drum Machine for macOS${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

# Clean previous build if it exists
if [ -d "builddir" ]; then
    echo -e "${YELLOW}Removing previous build directory...${NC}"
    rm -rf builddir
fi

# Create build directory
echo -e "${YELLOW}Setting up build directory...${NC}"
meson setup builddir --prefix=/usr/local

# Build the project
echo -e "${YELLOW}Building the project...${NC}"
ninja -C builddir

# Install the project
echo -e "${YELLOW}Installing the project...${NC}"
ninja -C builddir install

# Create a macOS app bundle
echo -e "${YELLOW}Creating macOS application bundle...${NC}"
mkdir -p dist

# Create app bundle structure
APP_NAME="Drum Machine.app"
APP_DIR="dist/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy the executable
cp builddir/src/drum-machine "$MACOS_DIR/"

# Copy resources
cp -r data "$RESOURCES_DIR/"
cp -r po "$RESOURCES_DIR/"

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>drum-machine</string>
    <key>CFBundleIdentifier</key>
    <string>io.github.revisto.drum-machine</string>
    <key>CFBundleName</key>
    <string>Drum Machine</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.5.0</string>
    <key>CFBundleVersion</key>
    <string>1.5.0</string>
    <key>CFBundleIconFile</key>
    <string>drum-machine.icns</string>
</dict>
</plist>
EOF

# Create a simple icon from the SVG (if rsvg-convert is available)
if command -v rsvg-convert >/dev/null 2>&1; then
    echo -e "${YELLOW}Converting SVG icon to PNG...${NC}"
    rsvg-convert -h 512 data/icons/io.github.revisto.drum-machine.Source.svg -o "$RESOURCES_DIR/drum-machine.png"
else
    echo -e "${YELLOW}Note: Install rsvg-convert to generate proper icons${NC}"
    echo -e "${YELLOW}You may want to create a proper .icns file from the SVG icon${NC}"
fi

echo -e "${GREEN}macOS build completed successfully!${NC}"
echo -e "${GREEN}Application bundle created at: $APP_DIR${NC}"
