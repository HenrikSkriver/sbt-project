# ============================================================================
# Test recipes — unit, integration, coverage
# ============================================================================

import '../lib/common.just'

# Run unit tests only
unit:
  {{mvnw}} test -Dtest="!*IntegrationTest,!*IT"
  @echo "✓ Unit tests passed"

# Run integration tests only
integration:
  {{mvnw}} verify -DskipUnitTests -Dspring.profiles.active=test
  @echo "✓ Integration tests passed"

# Run all tests
all:
  {{mvnw}} verify
  @echo "✓ All tests passed"

# Run tests with coverage report
coverage:
  #!/usr/bin/env bash
  set -euo pipefail
  {{mvnw}} verify -Djacoco.skip=false
  echo ""
  echo "✓ Coverage report generated"
  report="target/site/jacoco/index.html"
  if [ -f "$report" ]; then
    echo "  Report: $report"
    # Open in browser on macOS
    if command -v open &> /dev/null; then
      open "$report"
    fi
  fi

# Run a specific test class
single class:
  {{mvnw}} test -Dtest="{{class}}"

# Run tests matching a pattern
matching pattern:
  {{mvnw}} test -Dtest="{{pattern}}"
