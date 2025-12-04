#!/bin/bash
# Mind Palace installer
# Creates ~/.mind-palace and sets up the CLI

set -e

# Resolve script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target directory
MIND_PALACE_DIR="${MIND_PALACE_DIR:-$HOME/.mind-palace}"

echo "Mind Palace Installer"
echo "====================="
echo ""

# Run compatibility check
echo "Checking compatibility..."
source "$SCRIPT_DIR/lib/check-compat.sh"
if ! check_compatibility; then
  echo ""
  echo "Please resolve the errors above and try again."
  exit 1
fi
echo "Compatibility check passed."
echo ""

# Create directory structure
echo "Creating $MIND_PALACE_DIR..."
mkdir -p "$MIND_PALACE_DIR"/{user,self,projects,sessions}

# Create CLI symlink
echo "Creating CLI symlink..."
ln -sf "$SCRIPT_DIR/bin/mp" "$MIND_PALACE_DIR/mp"

# Verify
if [[ ! -x "$MIND_PALACE_DIR/mp" ]]; then
  echo "Warning: CLI may not be executable"
fi

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  $MIND_PALACE_DIR/mp help"
echo ""
echo "Quick start:"
echo "  $MIND_PALACE_DIR/mp add user preferences"
echo "  $MIND_PALACE_DIR/mp search 'query'"
echo ""
echo "Optional: Add to your PATH:"
echo "  export PATH=\"\$PATH:$MIND_PALACE_DIR\""
