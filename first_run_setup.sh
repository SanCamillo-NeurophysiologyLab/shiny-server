#!/bin/bash

set -e

# Step 1: Update group_add in default.env
echo "Updating default.env with docker group ID..."

DOCKER_GID=$(getent group docker | cut -d: -f3)

if [[ -z "$DOCKER_GID" ]]; then
  echo "Error: Could not determine Docker group ID. Make sure the 'docker' group exists."
  exit 1
fi

if [ ! -f default.env ]; then
  echo "default.env not found. Creating it..."
  echo "DOCKER_GID=$DOCKER_GID" > default.env
else
  # If DOCKER_GID is in the file, replace it; else, append it
  if grep -q "^DOCKER_GID=" default.env; then
    sed -i -E "s/^DOCKER_GID=.*/DOCKER_GID=$DOCKER_GID/" default.env
  else
    echo "DOCKER_GID=$DOCKER_GID" >> default.env
  fi
  echo "default.env updated successfully with GID $DOCKER_GID."
fi

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
