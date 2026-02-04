# ============================================================================
# Database recipes — migrations, seeding, utilities
# ============================================================================

# Variables
mvnw := if path_exists("mvnw") == "true" { "./mvnw" } else { "mvn" }
python := if os() == "windows" { "py -3" } else { "python3" }

# Run Flyway migrations via Spring Boot
migrate:
  {{mvnw}} flyway:migrate -Dflyway.configFiles=src/main/resources/db/flyway.conf
  @echo "✓ Migrations applied"

# Show current migration status
status:
  {{mvnw}} flyway:info -Dflyway.configFiles=src/main/resources/db/flyway.conf

# Reset the database (clean + migrate)
reset:
  #!/usr/bin/env bash
  set -euo pipefail
  echo "⚠ This will destroy all data. Proceeding in 3 seconds..."
  sleep 3
  {{mvnw}} flyway:clean flyway:migrate \
    -Dflyway.configFiles=src/main/resources/db/flyway.conf \
    -Dflyway.cleanDisabled=false
  echo "✓ Database reset complete"

# Generate a new migration file with a timestamp
new-migration name:
  #!/usr/bin/env bash
  set -euo pipefail
  timestamp=$(date +%Y%m%d%H%M%S)
  dir="src/main/resources/db/migration"
  mkdir -p "$dir"
  file="$dir/V${timestamp}__{{name}}.sql"
  echo "-- Migration: {{name}}" > "$file"
  echo "-- Created: $(date -Iseconds)" >> "$file"
  echo "" >> "$file"
  echo "Created: $file"

# Seed test data (uses a Python helper script if available)
seed:
  #!/usr/bin/env bash
  set -euo pipefail
  script_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../scripts"
  if [ -f "$script_dir/seed_data.py" ]; then
    {{python}} "$script_dir/seed_data.py"
  else
    echo "No seed script found. Skipping."
  fi
