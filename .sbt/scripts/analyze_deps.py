#!/usr/bin/env python3
"""
analyze_deps.py — Analyze Maven dependency tree for potential issues.

This is an example script showing how Python can be used alongside
just recipes for more complex analysis tasks.

Usage (called from just recipes):
    python3 scripts/analyze_deps.py [--security-only]
"""

import subprocess
import sys
import json
from pathlib import Path


def get_dependency_tree():
    """Run mvn dependency:tree and capture the output."""
    mvnw = "./mvnw" if Path("mvnw").exists() else "mvn"
    result = subprocess.run(
        [mvnw, "dependency:tree", "-DoutputType=text"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"Error running Maven: {result.stderr}", file=sys.stderr)
        sys.exit(1)
    return result.stdout


def analyze(tree_output: str, security_only: bool = False):
    """Analyze the dependency tree and report findings."""
    lines = tree_output.strip().split("\n")
    dependencies = []
    for line in lines:
        # Simple parsing of dependency:tree text output
        stripped = line.strip().lstrip("+-\\| ")
        if ":" in stripped and not stripped.startswith("["):
            parts = stripped.split(":")
            if len(parts) >= 4:
                dependencies.append(
                    {
                        "group": parts[0],
                        "artifact": parts[1],
                        "type": parts[2],
                        "version": parts[3],
                        "scope": parts[4] if len(parts) > 4 else "compile",
                    }
                )

    print(f"\nFound {len(dependencies)} dependencies\n")

    if not security_only:
        # Group by scope
        scopes = {}
        for dep in dependencies:
            scope = dep["scope"]
            scopes.setdefault(scope, []).append(dep)

        for scope, deps in sorted(scopes.items()):
            print(f"  {scope}: {len(deps)} dependencies")

    # Placeholder for security check
    print("\n  Note: For real security scanning, integrate with")
    print("  OWASP dependency-check or Snyk.")


if __name__ == "__main__":
    security_only = "--security-only" in sys.argv
    tree = get_dependency_tree()
    analyze(tree, security_only)
