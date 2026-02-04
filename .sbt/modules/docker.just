# ============================================================================
# Docker recipes for Spring Boot services
# ============================================================================

# Variables (can be overridden in project's justfile)
registry := "ghcr.io/your-org"
project_name := file_name(justfile_directory())
image_tag := `git rev-parse --short HEAD 2>/dev/null || echo "dev"`
spring_profile := "local"
mvnw := if path_exists("mvnw") == "true" { "./mvnw" } else { "mvn" }

# Build the Spring Boot Docker image using buildpacks
build profile="prod":
  #!/usr/bin/env bash
  set -euo pipefail
  echo "Building Docker image: {{registry}}/{{project_name}}:{{image_tag}}"
  {{mvnw}} spring-boot:build-image \
    -DskipTests \
    -Dspring-boot.build-image.imageName="{{registry}}/{{project_name}}:{{image_tag}}" \
    -P{{profile}}
  echo "✓ Image built: {{registry}}/{{project_name}}:{{image_tag}}"

# Push the image to the container registry
push: build
  docker push "{{registry}}/{{project_name}}:{{image_tag}}"
  @echo "✓ Pushed: {{registry}}/{{project_name}}:{{image_tag}}"

# Run the image locally
run port="8080":
  docker run --rm -p {{port}}:{{port}} \
    -e SPRING_PROFILES_ACTIVE={{spring_profile}} \
    "{{registry}}/{{project_name}}:{{image_tag}}"

# Open a shell inside the running container
shell:
  docker run --rm -it --entrypoint /bin/sh \
    "{{registry}}/{{project_name}}:{{image_tag}}"

# Remove dangling images and stopped containers
clean:
  docker system prune -f
  @echo "✓ Docker cleanup complete"

# List images for this project
images:
  @docker images "{{registry}}/{{project_name}}" --format "table {{{{.Repository}}}}\t{{{{.Tag}}}}\t{{{{.Size}}}}\t{{{{.CreatedSince}}}}"
