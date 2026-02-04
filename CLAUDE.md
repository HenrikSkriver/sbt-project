# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

This is the **SBT (Spring Boot Toolkit)** source repository - a distributable CLI toolkit for Spring Boot service operations. It bundles just recipes, Python helper scripts, and Claude Code primitives (slash commands and agents) into a single versioned package that gets installed into target Spring Boot projects.

This is **not** a Spring Boot application itself. It's a toolkit that gets installed into other projects via:
```bash
curl -fsSL https://raw.githubusercontent.com/HenrikSkriver/sbt-project/refs/heads/main/install.sh | bash
```

## Repository Structure

- `.sbt/` - The toolkit content that gets distributed to target projects
  - `sbt` - Main just entry point that imports modules via `mod` keyword
  - `modules/*.just` - Self-contained recipe modules (docker, db, test, deploy, deps)
  - `lib/common.just` - Shared variables for root-level recipes only
  - `scripts/*.py` - Python helper scripts
  - `claude/` - Claude Code integration (commands, agents, shared CLAUDE.md)
- `install.sh` - The installer script served via raw GitHub URL

## Architecture: Module Design

Each module in `.sbt/modules/` is **self-contained** with its own variable definitions. This is required because `just` modules (`mod` keyword) create isolated namespaces that don't inherit variables from parent files or imports.

Variables like `registry`, `mvnw`, and `project_name` are defined directly in each module that needs them. Do NOT try to import `common.just` into modules - it will cause parse-time errors.

The `lib/common.just` file is only used by the root `sbt` file for root-level recipes like `version`, `bootstrap`, `ci`, and `health`.

## Testing Changes

Since this is a toolkit that installs into other projects, test changes by:

1. Create a test directory inside the project:
   ```bash
   mkdir .test-install && cd .test-install
   bash ../install.sh
   just  # verify commands list correctly
   ```

2. Clean up after testing:
   ```bash
   rm -rf .test-install
   ```

The `.test-install` directory is already in `.gitignore`.

## Key Conventions

- Just modules use namespace syntax: `just docker::build`, `just test::unit`
- Modules are self-contained - each defines its own variables
- Claude Code files in `.sbt/claude/` get copied to `.claude/` with `sbt-` prefix during installation
- The `<!-- SBT-TOOLKIT-START -->` / `<!-- SBT-TOOLKIT-END -->` markers in CLAUDE.md control what gets replaced on upgrade
- The generated justfile includes an explicit `default` recipe for `just --list`

## Creating Releases

Tag with semantic versioning:
```bash
git tag v0.1.0
git push origin v0.1.0
```

Create a GitHub release from the tag for the installer to resolve `latest`.
