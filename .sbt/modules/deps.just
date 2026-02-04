# ============================================================================
# Dependency management recipes
# ============================================================================

# Check that required tools are installed
check:
  #!/usr/bin/env bash
  set -euo pipefail
  ok=true

  check_tool() {
    if command -v "$1" &> /dev/null; then
      version=$("$1" --version 2>&1 | head -1)
      echo "  ✓ $1 — $version"
    else
      echo "  ✗ $1 — NOT FOUND"
      ok=false
    fi
  }

  echo "Checking required tools:"
  check_tool java
  check_tool mvn
  check_tool docker
  check_tool git
  check_tool curl

  echo ""
  echo "Checking optional tools:"
  check_tool python3 || check_tool py || true
  check_tool just

  echo ""
  if [ "$ok" = true ]; then
    echo "✓ All required tools are available."
  else
    echo "✗ Some required tools are missing. Please install them."
    exit 1
  fi

# Display the Maven dependency tree
tree:
  {{mvnw}} dependency:tree

# Check for dependency updates
updates:
  {{mvnw}} versions:display-dependency-updates

# Check for plugin updates
plugin-updates:
  {{mvnw}} versions:display-plugin-updates

# Analyze dependencies for unused / undeclared
analyze:
  {{mvnw}} dependency:analyze
