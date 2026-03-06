# CLAUDE.md

## Project Overview

Docker ROS NVIDIA provides Dockerfiles and scripts to build Docker images with ROS 1 or ROS 2, NVIDIA GPU support (CUDA 12.1), and GUI forwarding (X11) for tools like Gazebo and RViz.

## Repository Structure

- `docker/Dockerfile` — Single Dockerfile supporting both ROS 1 and ROS 2 (controlled by `ROS_NUMBER` build arg)
- `docker/build.bash` — Build script; configuration variables at the top (`BASE_IMAGE`, `BASE_TAG`, `ROS_NUMBER`, `IMAGE_NAME`)
- `docker/run.bash` — Run script with GPU, X11, audio, and volume mount setup
- `docker/.config/entrypoint.sh` — Container entrypoint (sources bashrc, workspace setup)
- `docker/.config/update_bashrc_ros_1` — ROS 1 shell initialization
- `docker/.config/update_bashrc_ros_2` — ROS 2 shell initialization
- `.devcontainer/devcontainer.json` — VS Code Dev Container config (defaults to ROS 2 Humble)

## Build and Run

```bash
# Build the Docker image (edit variables at top of build.bash first)
./docker/build.bash

# Rebuild without cache
./docker/build.bash -r

# Run the container
./docker/run.bash
```

## Architecture Notes

- The Dockerfile creates a non-root user matching the host UID/GID to avoid permission issues on mounted volumes.
- ROS version selection requires consistent `BASE_TAG` and `ROS_NUMBER` (e.g., `noetic-desktop` with `ROS_NUMBER=1`, `humble-desktop` with `ROS_NUMBER=2`).
- `IMAGE_NAME` must match between `build.bash` and `run.bash`.
- NVIDIA CUDA 12.1 is added on top of OSRF ROS base images by installing NVIDIA apt repos directly in the Dockerfile.
- ROS 1 uses catkin/catkin-tools with `devel/` workspace output; ROS 2 uses colcon with `install/` output.
- The build script creates `build/`, `log/`, `src/`, and the appropriate output directory (`devel/` or `install/`) before building.
- Docker BuildKit cache mounts are used for apt caches to speed up rebuilds.

## Prerequisites

- Docker Community Edition
- NVIDIA Container Toolkit (nvidia-docker2)
- X11 server and PulseAudio (for GUI and audio)
