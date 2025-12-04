#!/bin/bash
# Compatibility check for Mind Palace
# Run during install and can be called manually

set -e

check_compatibility() {
  local errors=0
  local warnings=0

  # Check OS
  case "$OSTYPE" in
    darwin*|linux*)
      ;;
    msys*|cygwin*|win32*)
      echo "Error: Native Windows is not supported."
      echo "Please use WSL (Windows Subsystem for Linux)."
      echo "See: https://docs.microsoft.com/en-us/windows/wsl/install"
      return 1
      ;;
    *)
      echo "Warning: Unrecognized OS ($OSTYPE). Proceeding anyway."
      ((warnings++)) || true
      ;;
  esac

  # Check jq (required for JSON parsing in hooks)
  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required but not installed."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "  Install with: brew install jq"
    else
      echo "  Install with: apt install jq (or your package manager)"
    fi
    ((errors++)) || true
  fi

  # On macOS, check for gsed (GNU sed) for consistent behavior
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v gsed >/dev/null 2>&1; then
      echo "Error: gsed (GNU sed) is required on macOS."
      echo "  Install with: brew install gnu-sed"
      ((errors++)) || true
    fi
  fi

  # Check bash version (need 4+ for associative arrays)
  local bash_major="${BASH_VERSION%%.*}"
  if [[ "$bash_major" -lt 4 ]]; then
    echo "Warning: Bash $BASH_VERSION detected. Version 4+ recommended."
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "  Install with: brew install bash"
    fi
    ((warnings++)) || true
  fi

  # Summary
  if [[ $errors -gt 0 ]]; then
    echo ""
    echo "Compatibility check failed with $errors error(s)."
    return 1
  fi

  if [[ $warnings -gt 0 ]]; then
    echo ""
    echo "Compatibility check passed with $warnings warning(s)."
  fi

  return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  check_compatibility
fi
