# Docker ROS NVIDIA

## Overview

Dockerfiles to build images that have ROS (1 or 2) with NVIDIA support and with GUI support (e.g. Gazebo and RViz).

The `build.bash` and the `run.bash` files are used to automatically build and run the image.


## Preliminaries

Install [Docker Community Edition](https://docs.docker.com/engine/install/ubuntu/) (ex Docker Engine) with post-installation steps for Linux.

Install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#setting-up-nvidia-container-toolkit) (nvidia-docker2).


## Usage
The docker base image and the ROS version can be changed by modifying the `BASE_IMAGE`, `BASE_TAG`, and `ROS_NUMBER` bash variables in `build.bash`. To change the image name, modify `IMAGE_NAME` both in `build.bash` and `run.bash`.

Build the docker image (use the `-r` option to update the underlying images):
```shell
./docker/build.bash [-r]
```

Run the container:
```shell
./docker/run.bash
```

The workspace directory should be the folder containing `run.bash` and `build.bash`. It is mounted in the Docker container on startup.

Build the workspace inside the Docker container with colcon or catkin to avoid permission problems. The workspace's `setup.bash` is automatically sourced when the container is opened; thus it will fail the first time the container is run.

Take a look at https://docs.docker.com/develop/develop-images/dockerfile_best-practices/ before modifying the Dockerfile according to your needs.

To use VSCode with Docker, you can use the Dev Containers extension to attach VSCode to a running container. For having autocomplete, linting, etc. take a look at https://github.com/athackst/vscode_ros2_workspace and in particular to `c_cpp_properties.json` and `settings.json` in `.vscode`.


## Author

Davide De Benedittis


## Acknowledgments

[Baptiste Busch](https://medium.com/@baptiste.busch/creating-a-ros-or-ros2-workspace-in-docker-part-1-912529c87708)
