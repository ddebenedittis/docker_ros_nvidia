#!/bin/bash
set -e

# Navigate to the root directory of the project.
cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

# ================================= Config =================================== #

# Edit these defaults to match your build configuration.
# They will be written to .env and used by docker-compose.yml.
BASE_IMAGE=osrf/ros
BASE_TAG=foxy-desktop
ROS_NUMBER=2
IMAGE_NAME=ros_image_name

# ============================= Generate .env ================================ #

cat > .env <<EOF
# Build configuration
BASE_IMAGE=${BASE_IMAGE}
BASE_TAG=${BASE_TAG}
ROS_NUMBER=${ROS_NUMBER}
IMAGE_NAME=${IMAGE_NAME}

# Host-specific values (auto-detected)
HOST_UID=$(id -u)
HOST_GID=$(id -g)
AUDIO_GID=$(getent group audio | cut -d: -f3)
XAUTH=/tmp/.docker.xauth
EOF

echo "Generated .env with:"
cat .env

# ============================== X11 Auth ==================================== #

XAUTH=/tmp/.docker.xauth
if [ ! -f "$XAUTH" ]; then
    touch "$XAUTH"
    xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge -
fi
xhost +

echo "X11 auth configured."

# =========================== Create Directories ============================= #

mkdir -p ../build ../log ../src

if [ "$ROS_NUMBER" = "1" ]; then
    mkdir -p ../devel
elif [ "$ROS_NUMBER" = "2" ]; then
    mkdir -p ../install
fi

mkdir -p ~/.vscode ~/.vscode-server ~/.config/Code

echo "Directories created."
echo ""
echo "Setup complete. You can now run (from project root):"
echo "  docker compose -f docker/docker-compose.yml build"
echo "  docker compose -f docker/docker-compose.yml run --rm ros"
