# Docker ROS NVIDIA

## Overview

Dockerfiles to build images that have ROS (1 or 2) with NVIDIA support and with GUI support (e.g. Gazebo and RViz).

The `build.bash` and the `run.bash` files are used to automatically build and run the image.


## Preliminaries

Install [Docker Community Edition](https://docs.docker.com/engine/install/ubuntu/) (ex Docker Engine) with post-installation steps for Linux.

Install [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) (nvidia-docker2).


## Usage

Build the docker image (-r option to update the underlying images):
```shell
./build.bash [-r]
```
The docker base image and the ROS version can be changed by modifying the `BASE_IMAGE` and `BASE_TAG` bash variables. To change the image name, modify `IMAGE_NAME` in `build.bash` in `run.bash`.

Run the container:
```shell
./run.bash
```

The workspace directory should be the folder containing `run.bash` and `build.bash`. It is mounted in the Docker container on startup.

Build the workspace inside the Docker container with colcon or catkin to avoid permission problems. The workspace's `setup.bash` is automatically sourced when the container is opened; thus it will fail the first time the container is run.

Take a look at https://docs.docker.com/develop/develop-images/dockerfile_best-practices/ before modifying the Dockerfile according to your needs.


## Author

Davide De Benedittis


## Acknowledgments

[Baptiste Busch](https://medium.com/@baptiste.busch/creating-a-ros-or-ros2-workspace-in-docker-part-1-912529c87708)
