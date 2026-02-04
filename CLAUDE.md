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
  - `sbt` - Main just entry point that imports all modules
  - `modules/*.just` - Namespaced just recipe modules (docker, db, test, deploy, deps)
  - `lib/common.just` - Shared variables and defaults
  - `scripts/*.py` - Python helper scripts
  - `claude/` - Claude Code integration (commands, agents, shared CLAUDE.md)
- `install.sh` - The installer script served via raw GitHub URL

## Testing Changes

Since this is a toolkit that installs into other projects, test changes by:

1. Run `just` from the repository root to verify just syntax is valid
2. Test the install script in a fresh directory:
   ```bash
   mkdir /tmp/test-project && cd /tmp/test-project
   SBT_REPO=HenrikSkriver/sbt-project bash /path/to/install.sh
   just  # verify commands are available
   ```

## Key Conventions

- Just modules use namespace syntax: `just docker::build`, `just test::unit`
- Claude Code files in `.sbt/claude/` get copied to `.claude/` with `sbt-` prefix during installation
- Variables in `lib/common.just` can be overridden by consuming projects
- The `<!-- SBT-TOOLKIT-START -->` / `<!-- SBT-TOOLKIT-END -->` markers in CLAUDE.md control what gets replaced on upgrade

## Creating Releases

Tag with semantic versioning:
```bash
git tag v0.1.0
git push origin v0.1.0
```

Create a GitHub release from the tag for the installer to resolve `latest`.
