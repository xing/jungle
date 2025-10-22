# Makefile for Jungle

PREFIX ?= /usr/local
INSTALL_PATH = $(PREFIX)/bin
BUILD_PATH = .build/release
EXECUTABLE_NAME = jungle

.PHONY: all build install uninstall clean test help

# Default target
all: build

# Build the executable in release mode
build:
	@echo "Building $(EXECUTABLE_NAME) in release mode..."
	swift build -c release --disable-sandbox

# Install the executable to the system
install: build
	@echo "Installing $(EXECUTABLE_NAME) to $(INSTALL_PATH)..."
	@if [ -w $(INSTALL_PATH) ]; then \
		mkdir -p $(INSTALL_PATH); \
		install -m 755 $(BUILD_PATH)/$(EXECUTABLE_NAME) $(INSTALL_PATH)/$(EXECUTABLE_NAME); \
	else \
		echo "Note: $(INSTALL_PATH) requires elevated permissions"; \
		sudo mkdir -p $(INSTALL_PATH); \
		sudo install -m 755 $(BUILD_PATH)/$(EXECUTABLE_NAME) $(INSTALL_PATH)/$(EXECUTABLE_NAME); \
	fi
	@echo "✓ $(EXECUTABLE_NAME) installed successfully at $(INSTALL_PATH)/$(EXECUTABLE_NAME)"

# Uninstall the executable from the system
uninstall:
	@echo "Uninstalling $(EXECUTABLE_NAME) from $(INSTALL_PATH)..."
	@if [ -w $(INSTALL_PATH)/$(EXECUTABLE_NAME) ]; then \
		rm -f $(INSTALL_PATH)/$(EXECUTABLE_NAME); \
	else \
		sudo rm -f $(INSTALL_PATH)/$(EXECUTABLE_NAME); \
	fi
	@echo "✓ $(EXECUTABLE_NAME) uninstalled successfully"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf .build
	@echo "✓ Build artifacts cleaned"

# Run tests
test:
	@echo "Running tests..."
	swift test

# Show help
help:
	@echo "Jungle Makefile Commands:"
	@echo ""
	@echo "  make build      - Build the executable in release mode"
	@echo "  make install    - Build and install to $(INSTALL_PATH) (default: /usr/local/bin)"
	@echo "                    Note: May require sudo for system directories"
	@echo "  make uninstall  - Remove the executable from $(INSTALL_PATH)"
	@echo "  make clean      - Remove build artifacts"
	@echo "  make test       - Run tests"
	@echo "  make help       - Show this help message"
	@echo ""
	@echo "Custom Installation Path (no sudo required):"
	@echo "  make install PREFIX=~/.local"
	@echo "  This will install to ~/.local/bin/jungle"
	@echo ""
	@echo "System-wide Installation:"
	@echo "  make install"
	@echo "  This will install to /usr/local/bin/jungle (may prompt for password)"
