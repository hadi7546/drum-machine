#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building Drum Machine for Windows${NC}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Change to project directory
cd "$PROJECT_DIR"

# Check if cross-file exists
if [ ! -f "scripts/windows-cross-file.txt" ]; then
    echo -e "${RED}Error: Windows cross-file not found at scripts/windows-cross-file.txt${NC}"
    exit 1
fi

# Clean previous build if it exists
if [ -d "builddir" ]; then
    echo -e "${YELLOW}Removing previous build directory...${NC}"
    rm -rf builddir
fi

# Create build directory for Windows cross-compilation
echo -e "${YELLOW}Setting up build directory for Windows cross-compilation...${NC}"
meson setup builddir --cross-file=scripts/windows-cross-file.txt

# Build the project
echo -e "${YELLOW}Building the project...${NC}"
ninja -C builddir

# Create Windows installer
echo -e "${YELLOW}Creating Windows installer...${NC}"
mkdir -p dist

# Copy the executable
cp builddir/src/drum-machine dist/

# Copy necessary data files
cp -r data dist/

# Create a simple batch file to run the application
cat > "dist/drum-machine.bat" << EOF
@echo off
drum-machine.exe %*
EOF

# Create a simple installer script
cat > "dist/install.bat" << EOF
@echo off
echo Installing Drum Machine...
echo.

REM Create installation directory
if not exist "%ProgramFiles%\Drum Machine" mkdir "%ProgramFiles%\Drum Machine"

REM Copy files
xcopy /E /I /Y data "%ProgramFiles%\Drum Machine\data"
copy /Y drum-machine.exe "%ProgramFiles%\Drum Machine\"

REM Create desktop shortcut (requires admin privileges)
echo Creating desktop shortcut...
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%USERPROFILE%\Desktop\Drum Machine.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%ProgramFiles%\Drum Machine\drum-machine.exe" >> CreateShortcut.vbs
echo oLink.WorkingDirectory = "%ProgramFiles%\Drum Machine\" >> CreateShortcut.vbs
echo oLink.Description = "Drum Machine" >> CreateShortcut.vbs
echo oLink.IconLocation = "%ProgramFiles%\Drum Machine\drum-machine.exe, 0" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript CreateShortcut.vbs
del CreateShortcut.vbs

echo.
echo Installation completed!
echo You can find Drum Machine in your Start Menu or on the Desktop.
echo.
pause
EOF

echo -e "${GREEN}Windows build completed successfully!${NC}"
echo -e "${GREEN}Windows executable created at: dist/drum-machine${NC}"
echo -e "${GREEN}Installer script created at: dist/install.bat${NC}"
