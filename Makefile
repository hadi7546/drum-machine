.PHONY: all clean deps flatpak-deps linux windows windows32 macos help

# Default target
all: linux

# Clean build artifacts
clean:
	rm -rf builddir dist

# Generate Flatpak dependencies
deps:
	flatpak_pip_generator --build-isolation --requirements-file=requirements.txt -o python-dependencies --runtime=org.gnome.Sdk/x86_64/master

# Build for Linux (native)
linux:
	@echo "Building for Linux..."
	meson setup builddir
	ninja -C builddir
	@echo "Linux build completed successfully"

# Build Flatpak
flatpak:
	@echo "Building Flatpak..."
	flatpak-builder --user --install --force-clean builddir flatpak/io.github.revisto.drum-machine.json

# Build for Windows (x64)
windows:
	@echo "Building for Windows (x64)..."
	@if [ ! -f "scripts/windows-cross-file.txt" ]; then \
		echo "Error: Windows cross-file not found"; \
		exit 1; \
	fi
	meson setup builddir --cross-file=scripts/windows-cross-file.txt
	ninja -C builddir
	./scripts/build-windows.sh

# Build for Windows (x86)
windows32:
	@echo "Building for Windows (x86)..."
	@if [ ! -f "scripts/windows32-cross-file.txt" ]; then \
		echo "Error: Windows 32-bit cross-file not found"; \
		exit 1; \
	fi
	meson setup builddir --cross-file=scripts/windows32-cross-file.txt
	ninja -C builddir
	./scripts/build-windows.sh

# Build for macOS
macos:
	@echo "Building for macOS..."
	./scripts/build-macos.sh

# Install dependencies for development
install-deps:
	@echo "Installing development dependencies..."
	pip install -r requirements.txt
	pip install meson ninja
	@echo "Installing system dependencies..."
	@if command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update && sudo apt-get install -y build-essential; \
	elif command -v pacman >/dev/null 2>&1; then \
		sudo pacman -S base-devel; \
	elif command -v dnf >/dev/null 2>&1; then \
		sudo dnf install -y @development-tools; \
	elif command -v brew >/dev/null 2>&1; then \
		brew install meson ninja; \
	fi

# Show help
help:
	@echo "Available targets:"
	@echo "  all          - Build for Linux (native) [default]"
	@echo "  clean        - Clean build artifacts"
	@echo "  deps         - Generate Flatpak dependencies"
	@echo "  linux        - Build for Linux (native)"
	@echo "  flatpak      - Build Flatpak package"
	@echo "  windows      - Build for Windows (x64)"
	@echo "  windows32    - Build for Windows (x86)"
	@echo "  macos        - Build for macOS"
	@echo "  install-deps - Install development dependencies"
	@echo "  help         - Show this help message" 