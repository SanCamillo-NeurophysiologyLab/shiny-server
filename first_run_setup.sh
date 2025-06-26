#!/bin/bash

set -e

# Step 1: Update group_add in docker-compose.yml
echo "Updating docker-compose.yml with docker group ID..."

DOCKER_GID=$(getent group docker | cut -d: -f3)

if [[ -z "$DOCKER_GID" ]]; then
  echo "Error: Could not determine Docker group ID. Make sure the 'docker' group exists."
  exit 1
fi

# Replace the line that starts with '  - "' and has a number with the correct GID
sed -i -E "s/(group_add:[[:space:]]*\n[[:space:]]*- )[\"']?[0-9]+[\"']?/\1\"$DOCKER_GID\"/" docker-compose.yml

echo "docker-compose.yml updated successfully with GID $DOCKER_GID."

# Step 2: Build all app images
echo "Building all app Docker images..."

for app_dir in apps/*; do
  if [[ -d "$app_dir" && -f "$app_dir/build_docker_image.sh" ]]; then
    echo "Building image for $(basename "$app_dir")..."
    (
      cd "$app_dir"
      chmod +x build_docker_image.sh
      ./build_docker_image.sh
    )
    echo "Built $(basename "$app_dir") successfully."
  fi
done

echo "All app images built successfully."
