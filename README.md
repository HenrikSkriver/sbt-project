# SBT — Spring Boot Toolkit

A shared, versioned CLI toolkit for Spring Boot service operations.
Built with [just](https://github.com/casey/just) and designed to be used both
by developers from the terminal and by [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
agents.

## What Is This?

SBT is a collection of **just recipes**, **Python helper scripts**, and
**Claude Code primitives** (slash commands and agents) bundled together into a
single installable package. It standardizes how your team builds, tests,
deploys, and manages Spring Boot services.

It serves **two audiences** from the same package:

1. **Developers** — run `just docker::build`, `just test::unit`, `just db::migrate`
   from the terminal. Consistent commands across every service in your fleet.

2. **Claude Code agents** — shared slash commands (`/sbt-implement-endpoint`,
   `/sbt-review-pr`) and agents (`sbt-test-writer-agent`, `sbt-maven-agent`)
   that follow the same conventions and use the same just recipes to verify
   their work. This means the AI agent runs `just test::unit` the same way you
   do.

The toolkit is **versioned and distributable**. Install a specific version into
any Spring Boot project. Pin one service to `v1.0.0` and another to `v2.0.0`.
Upgrade when you're ready.

## Prerequisites

- [just](https://github.com/casey/just#installation) — the only hard requirement
  ```bash
  # macOS
  brew install just

  # Linux
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

  # Windows (scoop)
  scoop install just
  ```
- **Python 3** — optional, only needed for recipes that call Python scripts
- **Claude Code** — optional, only needed for the AI agent features

## Installation

### Install into a project using curl

Navigate to your Spring Boot project root and run:

```bash
curl -fsSL https://raw.githubusercontent.com/HenrikSkriver/sbt-project/refs/heads/main/install.sh | bash
```

To install a specific version:

```bash
SBT_VERSION=v0.1.0 curl -fsSL https://raw.githubusercontent.com/HenrikSkriver/sbt-project/refs/heads/main/install.sh | bash
```

The install script will:

1. Download the SBT toolkit into `.sbt/`
2. Create a `justfile` in the project root with a default recipe (or tell you what to add if one exists)
3. Copy Claude Code commands and agents into `.claude/` (prefixed with `sbt-`)
4. Append shared instructions to `CLAUDE.md`

### What gets installed

```
your-spring-service/
├── justfile                          # Thin wrapper — imports SBT + default recipe
├── CLAUDE.md                         # Updated with SBT conventions
│
├── .sbt/                             # The toolkit (installed by curl)
│   ├── sbt                           # Just script entry point
│   ├── .version                      # Installed version tag
│   ├── modules/                      # Self-contained recipe modules
│   │   ├── docker.just               # Container lifecycle
│   │   ├── db.just                   # Database migrations
│   │   ├── test.just                 # Test execution
│   │   ├── deploy.just               # Deployment workflows
│   │   └── deps.just                 # Dependency management
│   ├── scripts/
│   │   ├── analyze_deps.py           # Dependency analysis helper
│   │   └── seed_data.py              # Test data seeder
│   ├── lib/
│   │   └── common.just               # Shared variables for root recipes
│   └── claude/
│       ├── CLAUDE.md                  # Shared project instructions
│       ├── commands/                  # Slash command sources
│       │   ├── implement-endpoint.md
│       │   ├── review-pr.md
│       │   └── fix-test.md
│       └── agents/                    # Agent definition sources
│           ├── test-writer-agent.md
│           └── maven-agent.md
│
└── .claude/                           # Claude Code config (your project's)
    ├── .sbt-managed                   # Tracks which files SBT installed
    ├── commands/
    │   ├── sbt-implement-endpoint.md  # ← copied from .sbt/claude/commands/
    │   ├── sbt-review-pr.md
    │   └── sbt-fix-test.md
    └── agents/
        ├── sbt-test-writer-agent.md   # ← copied from .sbt/claude/agents/
        └── sbt-maven-agent.md
```

The `sbt-` prefix on files in `.claude/` makes it easy to identify which
commands and agents were installed by SBT vs. created specifically for your
project. The `.sbt-managed` manifest tracks all installed files.

## Usage

### Developer CLI

After installation, all commands are available through `just`:

```bash
# List everything
just

# Check that required tools are present
just deps::check

# Bootstrap the project (check deps + run migrations)
just bootstrap

# Run unit tests
just test::unit

# Run integration tests
just test::integration

# Run the full CI pipeline locally (test + build image)
just ci

# Build the Docker image
just docker::build

# Run database migrations
just db::migrate

# Create a new migration
just db::new-migration add-users-table

# Deploy to staging
just deploy::to staging

# Check service health
just health 8080

# Show installed SBT version
just version
```

### Claude Code Agents

When working with Claude Code in a project that has SBT installed, the shared
agents and commands are automatically available.

**Slash commands** — type these in the Claude Code prompt:

```
/sbt-implement-endpoint
/sbt-review-pr
/sbt-fix-test
```

**Agents** — reference these when asking Claude Code to perform specialized tasks:

- `sbt-test-writer-agent` — Writes comprehensive unit and integration tests
  following project conventions. Runs `just test::unit` and
  `just test::integration` to verify its work.

- `sbt-maven-agent` — Handles dependency management, POM changes, version
  upgrades. Uses `just deps::tree`, `just deps::analyze`, etc. to understand
  the current state before making changes.

**The key insight**: both developers and agents use the same `just` recipes.
When the test-writer-agent runs `just test::unit`, it executes the exact same
command a developer would. One toolkit, two audiences.

## The Thin Wrapper Justfile

The `justfile` created at your project root serves as a thin wrapper.
It imports everything from SBT and includes a default recipe that lists all
available commands:

```just
# ============================================================================
# Project justfile
# ============================================================================
import '.sbt/sbt'

# List all available commands
default:
  @just --list

# ---------------------------------------------------------------------------
# Project-specific recipes
# ---------------------------------------------------------------------------

# Start local dependencies and run the service
dev:
  docker compose -f docker-compose.dev.yml up -d
  just db::migrate
  ./mvnw spring-boot:run -Dspring-profiles.active=local

# Seed this service's test data
seed:
  python3 scripts/seed_payments.py --env local

# Full local setup from scratch
local-setup: deps::check db::migrate seed
  @echo "✓ Local environment ready"
```

Running `just` will list both the SBT toolkit recipes and your project-specific
ones together. The developer sees a unified interface.

## Customization

### Add project-specific recipes

Add your own recipes to the project's `justfile` after the import. These can
call SBT recipes as dependencies:

```just
import '.sbt/sbt'

default:
  @just --list

# Your custom recipes
local-setup: deps::check db::migrate
  @echo "✓ Local environment ready"
```

### Add project-specific Claude commands

Create files in `.claude/commands/` (without the `sbt-` prefix) for commands
specific to your project. They won't be overwritten when SBT is upgraded.

### Add project-specific CLAUDE.md instructions

Add your instructions **above** the `<!-- SBT-TOOLKIT-START -->` marker in
`CLAUDE.md`. The SBT section is managed by the installer and will be replaced
on upgrade. Your custom content above the marker is preserved.

## Upgrading

Run the install script again with the desired version:

```bash
SBT_VERSION=v0.2.0 curl -fsSL https://raw.githubusercontent.com/HenrikSkriver/sbt-project/refs/heads/main/install.sh | bash
```

The installer will:
- Ask for confirmation before replacing the existing installation
- Re-copy Claude commands and agents (the `sbt-` prefixed files)
- Update the SBT section in `CLAUDE.md`
- Leave your project-specific justfile recipes untouched

## Version Pinning

Each project can pin to a different SBT version. The installed version is
recorded in `.sbt/.version`:

```bash
cat .sbt/.version
# v0.1.0
```

This means Service A can stay on `v1.0.0` while Service B upgrades to `v2.0.0`.
There is no global state and no version conflicts between projects.

## Architecture Notes

### Module Design

Each module in `.sbt/modules/` is self-contained with its own variable
definitions. This is required because `just` modules (`mod` keyword) are
isolated namespaces that don't inherit variables from parent files.

Variables like `registry`, `mvnw`, and `project_name` are defined directly
in each module that needs them. This ensures reliable parsing regardless of
how the modules are loaded.

### Python Scripts

Just recipes can call Python for tasks that benefit from a real programming
language. SBT includes example scripts in `.sbt/scripts/`. You can add your
own and call them from recipes:

```just
# In a just recipe
analyze:
  python3 .sbt/scripts/analyze_deps.py
```

Python scripts in the bundle are useful for dependency analysis, data seeding,
report generation, health checks, and anything involving HTTP calls or JSON
parsing that would be awkward in bash.

## Cross-Platform Support

| Platform     | Status | Notes                                        |
|-------------|--------|----------------------------------------------|
| macOS       | ✓      | Fully supported                              |
| Linux       | ✓      | Fully supported (shebang uses `-S` flag)     |
| Windows WSL | ✓      | Works identically to Linux                   |
| Windows     | Partial| `just` works natively; install script needs WSL or Git Bash |

## Repository Structure (for SBT maintainers)

If you are maintaining the SBT repository itself:

```
sbt-project/                   # The SBT repo
├── .sbt/                      # The toolkit content that gets installed
│   ├── sbt                    # Entry point
│   ├── .version
│   ├── modules/               # Self-contained recipe modules
│   ├── scripts/
│   ├── lib/
│   └── claude/
├── install.sh                 # The install script (served via raw URL)
├── CLAUDE.md                  # Instructions for working on this repo
└── README.md                  # This file
```

Tag releases with semantic versioning:

```bash
git tag v0.1.0
git push origin v0.1.0
```

Create a GitHub release from the tag so the install script can resolve
`latest` automatically.

## Philosophy

> **The script is the source of truth.** Both developers and AI agents
> execute the same recipes. The justfile is the launch pad.

Inspired by the pattern described in
[disler/install-and-maintain](https://github.com/disler/install-and-maintain):
deterministic scripts handle execution, agents provide oversight. The toolkit
is a living document that executes.
