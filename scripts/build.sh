#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

# Default build type
BUILD_TYPE="native"
CROSS_FILE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --windows|--win)
      BUILD_TYPE="windows"
      CROSS_FILE="scripts/windows-cross-file.txt"
      shift
      ;;
    --windows32|--win32)
      BUILD_TYPE="windows32"
      CROSS_FILE="scripts/windows32-cross-file.txt"
      shift
      ;;
    --macos|--mac)
      BUILD_TYPE="macos"
      shift
      ;;
    --flatpak|--linux)
      BUILD_TYPE="flatpak"
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --windows, --win     Build for Windows (x64)"
      echo "  --windows32, --win32 Build for Windows (x86)"
      echo "  --macos, --mac       Build for macOS"
      echo "  --flatpak, --linux   Build for Linux (Flatpak)"
      echo "  --help, -h           Show this help message"
      echo ""
      echo "If no option is specified, builds for the current platform."
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information."
      exit 1
      ;;
  esac
done

echo -e "${GREEN}Building Drum Machine${NC}"
echo -e "${YELLOW}Build type: $BUILD_TYPE${NC}"

# Clean previous build if it exists
if [ -d "builddir" ]; then
    echo -e "${YELLOW}Removing previous build directory...${NC}"
    rm -rf builddir
fi

# Setup build directory based on type
case $BUILD_TYPE in
  "windows"|"windows32")
    if [ ! -f "$CROSS_FILE" ]; then
      echo -e "${RED}Error: Cross-compilation file not found: $CROSS_FILE${NC}"
      exit 1
    fi
    echo -e "${YELLOW}Setting up cross-compilation build...${NC}"
    meson setup builddir --cross-file="$CROSS_FILE"
    ;;
  "macos")
    echo -e "${YELLOW}Setting up native build...${NC}"
    meson setup builddir
    ;;
  "flatpak")
    echo -e "${YELLOW}Setting up Flatpak build...${NC}"
    meson setup builddir
    ;;
  *)
    echo -e "${YELLOW}Setting up native build...${NC}"
    meson setup builddir
    ;;
esac

# Build the project
echo -e "${YELLOW}Building the project...${NC}"
ninja -C builddir

# Platform-specific packaging
case $BUILD_TYPE in
  "windows"|"windows32")
    echo -e "${YELLOW}Packaging for Windows...${NC}"
    ./scripts/build-windows.sh
    ;;
  "macos")
    echo -e "${YELLOW}Packaging for macOS...${NC}"
    ./scripts/build-macos.sh
    ;;
  "flatpak")
    echo -e "${YELLOW}Building Flatpak package...${NC}"
    ninja -C builddir install
    ;;
  *)
    echo -e "${YELLOW}Installing for current platform...${NC}"
    ninja -C builddir install
    ;;
esac

echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}Check the dist/ directory for platform-specific packages.${NC}"
