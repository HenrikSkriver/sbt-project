#!/usr/bin/env bash
# ============================================================================
# SBT (Spring Boot Toolkit) — Installer
#
# Installs the SBT toolkit into the current project directory.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/HenrikSkriver/sbt-project/refs/heads/main/install.sh | bash
#
# With a pinned version:
#   SBT_VERSION=v0.1.0 curl -fsSL https://raw.githubusercontent.com/HenrikSkriver/sbt-project/refs/heads/main/install.sh | bash
#
# ============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration — update these for your organization
# ---------------------------------------------------------------------------
SBT_REPO="${SBT_REPO:-HenrikSkriver/sbt-project}"
SBT_BRANCH="${SBT_BRANCH:-main}"
VERSION="${SBT_VERSION:-latest}"
INSTALL_DIR=".sbt"
IMPORT_LINE="import '.sbt/sbt'"

# ---------------------------------------------------------------------------
# Colors (if terminal supports them)
# ---------------------------------------------------------------------------
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  GREEN='' YELLOW='' RED='' BOLD='' NC=''
fi

info()  { echo -e "${BOLD}$1${NC}"; }
ok()    { echo -e "${GREEN}✓ $1${NC}"; }
warn()  { echo -e "${YELLOW}⚠ $1${NC}"; }
fail()  { echo -e "${RED}✗ $1${NC}"; exit 1; }

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------
command -v curl  &>/dev/null || fail "curl is required but not found."
command -v tar   &>/dev/null || fail "tar is required but not found."
command -v just  &>/dev/null || warn "just is not installed. Install it: https://github.com/casey/just#installation"

# ---------------------------------------------------------------------------
# Resolve version
# ---------------------------------------------------------------------------
USE_BRANCH=false
if [ "$VERSION" = "latest" ]; then
  info "Resolving latest version..."
  VERSION=$(curl -fsSL "https://api.github.com/repos/${SBT_REPO}/releases/latest" 2>/dev/null \
    | grep '"tag_name"' | cut -d'"' -f4) || true
  if [ -z "$VERSION" ]; then
    VERSION="$SBT_BRANCH"
    USE_BRANCH=true
    info "  → $VERSION (no releases found, using branch)"
  else
    info "  → $VERSION"
  fi
fi

# ---------------------------------------------------------------------------
# Handle existing installation
# ---------------------------------------------------------------------------
if [ -d "$INSTALL_DIR" ]; then
  current=$(cat "$INSTALL_DIR/.version" 2>/dev/null || echo "unknown")
  warn "sbt $current is already installed in $INSTALL_DIR/"
  read -rp "  Replace with $VERSION? [y/N] " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Aborted."
    exit 0
  fi
  rm -rf "$INSTALL_DIR"
fi

# ---------------------------------------------------------------------------
# Download and extract
# ---------------------------------------------------------------------------
info "Installing sbt $VERSION into $INSTALL_DIR/"

mkdir -p "$INSTALL_DIR"

# Download and extract - use branch URL if USE_BRANCH is set, otherwise try tag first
download_and_extract() {
  local url="$1"
  local tmpdir
  tmpdir=$(mktemp -d)

  if curl -fsSL "$url" | tar xz -C "$tmpdir" --strip-components=1 2>/dev/null; then
    if [ -d "$tmpdir/.sbt" ]; then
      cp -R "$tmpdir/.sbt/"* "$INSTALL_DIR/"
      rm -rf "$tmpdir"
      return 0
    fi
  fi
  rm -rf "$tmpdir"
  return 1
}

downloaded=false

if [ "$USE_BRANCH" = "true" ]; then
  # Directly use branch URL
  if download_and_extract "https://github.com/${SBT_REPO}/archive/refs/heads/${VERSION}.tar.gz"; then
    downloaded=true
  fi
else
  # Try tagged release first
  if download_and_extract "https://github.com/${SBT_REPO}/archive/refs/tags/${VERSION}.tar.gz"; then
    downloaded=true
  elif download_and_extract "https://github.com/${SBT_REPO}/archive/refs/heads/${SBT_BRANCH}.tar.gz"; then
    warn "Tag $VERSION not found. Installed from branch: $SBT_BRANCH"
    downloaded=true
  fi
fi

if [ "$downloaded" = "false" ]; then
  fail "Failed to download sbt from ${SBT_REPO}"
fi

chmod +x "$INSTALL_DIR/sbt"
echo "$VERSION" > "$INSTALL_DIR/.version"

ok "sbt $VERSION installed to $INSTALL_DIR/"

# ---------------------------------------------------------------------------
# Wire up Claude Code primitives
# ---------------------------------------------------------------------------
info ""
info "Setting up Claude Code integration..."

# Create .claude directories if they don't exist
mkdir -p .claude/commands
mkdir -p .claude/agents

# Track which files we install so they can be identified as sbt-managed
SBT_MANIFEST=".claude/.sbt-managed"
> "$SBT_MANIFEST"

# Copy commands (prefixed with sbt- for clear identification)
if [ -d "$INSTALL_DIR/claude/commands" ]; then
  for cmd in "$INSTALL_DIR"/claude/commands/*.md; do
    [ -f "$cmd" ] || continue
    basename=$(basename "$cmd")
    target=".claude/commands/sbt-${basename}"
    cp "$cmd" "$target"
    echo "commands/sbt-${basename}" >> "$SBT_MANIFEST"
    ok "  Command: /sbt-${basename%.md}"
  done
fi

# Copy agents (prefixed with sbt- for clear identification)
if [ -d "$INSTALL_DIR/claude/agents" ]; then
  for agent in "$INSTALL_DIR"/claude/agents/*.md; do
    [ -f "$agent" ] || continue
    basename=$(basename "$agent")
    target=".claude/agents/sbt-${basename}"
    cp "$agent" "$target"
    echo "agents/sbt-${basename}" >> "$SBT_MANIFEST"
    ok "  Agent:   sbt-${basename%.md}"
  done
fi

# Append shared CLAUDE.md instructions
if [ -f "$INSTALL_DIR/claude/CLAUDE.md" ]; then
  SBT_MARKER="<!-- SBT-TOOLKIT-START -->"
  SBT_END_MARKER="<!-- SBT-TOOLKIT-END -->"

  if [ -f "CLAUDE.md" ] && grep -q "$SBT_MARKER" "CLAUDE.md"; then
    # Replace existing SBT section
    # Use a temp file for portability (macOS sed differs from GNU sed)
    tmpfile=$(mktemp)
    awk "
      /$SBT_MARKER/{skip=1; next}
      /$SBT_END_MARKER/{skip=0; next}
      !skip{print}
    " CLAUDE.md > "$tmpfile"
    mv "$tmpfile" CLAUDE.md
  fi

  # Append SBT section
  {
    echo ""
    echo "$SBT_MARKER"
    cat "$INSTALL_DIR/claude/CLAUDE.md"
    echo "$SBT_END_MARKER"
  } >> CLAUDE.md
  ok "  CLAUDE.md updated with SBT instructions"
fi

# ---------------------------------------------------------------------------
# Create or update the root justfile
# ---------------------------------------------------------------------------
info ""
info "Setting up justfile..."

if [ ! -f "justfile" ] && [ ! -f "Justfile" ]; then
  printf '%s\n' \
    "# ============================================================================" \
    "# Project justfile" \
    "# ============================================================================" \
    "# The SBT toolkit is imported below, providing shared recipes for" \
    "# building, testing, deploying, and managing this Spring Boot service." \
    "# Add your project-specific recipes after the import." \
    "" \
    "import '.sbt/sbt'" \
    "" \
    "# List all available commands" \
    "default:" \
    "  @just --list" \
    "" \
    "# ---------------------------------------------------------------------------" \
    "# Project-specific recipes" \
    "# ---------------------------------------------------------------------------" \
    "" \
    "# Example: local development setup" \
    "# local-setup:" \
    "#   docker compose -f docker-compose.dev.yml up -d" \
    "#   just db::migrate" \
    '#   @echo "Ready for development"' \
    "" \
    "# Example: start the service locally" \
    "# dev: local-setup" \
    "#   ./mvnw spring-boot:run -Dspring-profiles.active=local" \
    > justfile
  ok "Created justfile with sbt import"
else
  # Find existing justfile (could be justfile or Justfile)
  existing_justfile="justfile"
  [ -f "Justfile" ] && existing_justfile="Justfile"

  if grep -qF "$IMPORT_LINE" "$existing_justfile"; then
    ok "$existing_justfile already imports sbt"
  else
    warn "Add this line to your $existing_justfile (ideally near the top):"
    echo ""
    echo "    $IMPORT_LINE"
    echo ""
  fi
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
info " sbt $VERSION — installed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo " Usage:"
echo "   just                    List all available commands"
echo "   just version            Show sbt version"
echo "   just bootstrap          Bootstrap the project"
echo "   just docker::build      Build Docker image"
echo "   just test::unit         Run unit tests"
echo "   just db::migrate        Run database migrations"
echo ""
echo " Claude Code:"
echo "   /sbt-implement-endpoint   Implement a REST endpoint"
echo "   /sbt-review-pr            Review a pull request"
echo "   /sbt-fix-test             Diagnose and fix a failing test"
echo ""
echo " Files installed:"
echo "   .sbt/                   Toolkit recipes, scripts, and config"
echo "   .claude/commands/sbt-*  Shared Claude Code slash commands"
echo "   .claude/agents/sbt-*    Shared Claude Code agents"
echo "   CLAUDE.md               Updated with SBT instructions"
echo ""
