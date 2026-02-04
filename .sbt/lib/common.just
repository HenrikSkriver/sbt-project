# ============================================================================
# Common variables and conventions shared across all sbt modules.
# This file is imported (not a module) so everything here is in root scope.
# ============================================================================

# SBT metadata
sbt_version := "0.1.0"
sbt_dir     := justfile_directory()

# Project detection (inferred from the consuming project's root justfile)
project_name := file_name(justfile_directory())

# Java / Spring Boot defaults (override in your project's justfile)
java_version  := "21"
spring_profile := "local"

# Docker defaults
registry  := "ghcr.io/your-org"  # Override in your project's justfile
image_tag := `git rev-parse --short HEAD 2>/dev/null || echo "dev"`

# Maven wrapper detection
mvnw := if path_exists("mvnw") == "true" { "./mvnw" } else { "mvn" }

# Python - cross-platform
python := if os() == "windows" { "py -3" } else { "python3" }
