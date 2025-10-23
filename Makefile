# Makefile for Jungle

PREFIX ?= $(HOME)/.local
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

# Install the executable to user directory
install: build
	@echo "Installing $(EXECUTABLE_NAME) to $(INSTALL_PATH)..."
	@mkdir -p $(INSTALL_PATH)
	@install -m 755 $(BUILD_PATH)/$(EXECUTABLE_NAME) $(INSTALL_PATH)/$(EXECUTABLE_NAME)
	@echo "✓ $(EXECUTABLE_NAME) installed successfully at $(INSTALL_PATH)/$(EXECUTABLE_NAME)"
	@if ! echo "$$PATH" | grep -q "$(INSTALL_PATH)"; then \
		echo ""; \
		echo "⚠️  Note: $(INSTALL_PATH) is not in your PATH"; \
		echo "   Add this to your shell profile (~/.zshrc or ~/.bashrc):"; \
		echo "   export PATH=\"$(INSTALL_PATH):\$$PATH\""; \
	fi

# Uninstall the executable from user directory
uninstall:
	@echo "Uninstalling $(EXECUTABLE_NAME) from $(INSTALL_PATH)..."
	@rm -f $(INSTALL_PATH)/$(EXECUTABLE_NAME)
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
	@echo "  make install    - Build and install to $(INSTALL_PATH) (default: ~/.local/bin)"
	@echo "  make uninstall  - Remove the executable from $(INSTALL_PATH)"
	@echo "  make clean      - Remove build artifacts"
	@echo "  make test       - Run tests"
	@echo "  make help       - Show this help message"
	@echo ""
	@echo "Custom Installation Path:"
	@echo "  make install PREFIX=/custom/path"
	@echo "  This will install to /custom/path/bin/jungle"
	@echo ""
	@echo "Note: The default installation uses ~/.local/bin"
	@echo "      Make sure this directory is in your PATH"
