# Docker ROS NVIDIA

## Overview

Dockerfiles to build images that have ROS (1 or 2) with NVIDIA support and with GUI support (e.g. Gazebo and RViz).

The `build.bash` and the `run.bash` files are used to automatically build and run the image.

This repository is intended to be used as a base for other projects that require ROS, NVIDIA, and GUI support in Docker.
You can clone it, remove the .git file to start a new repository, and modify the `build.bash`, `run.bash`, and `Dockerfile` files to suit your needs.

If you find this useful, you can cite [this repository](https://github.com/ddebenedittis/docker_ros_nvidia) and/or [me](https://github.com/ddebenedittis) in your work.


## Preliminaries

Install [Docker Community Edition](https://docs.docker.com/engine/install/ubuntu/) (ex Docker Engine).
You can follow the installation method through `apt`.
Note that it makes you verify the installation by running `sudo docker run hello-world`.
It is better to avoid running this command with `sudo` and instead follow the post installation steps first and then run the command without `sudo`.

Follow with the [post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/) for Linux.
This will allow you to run Docker without `sudo`.

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

To use VS Code with Docker, you can use the Dev Containers extension to attach VS Code to a running container. For having autocomplete, linting, etc. take a look at https://github.com/athackst/vscode_ros2_workspace and in particular to `c_cpp_properties.json` and `settings.json` in `.vscode`.


## Troubleshooting

- **No GPU available in Docker**: running `nvidia-smi` in the Docker container returns `Failed to initialize NVML: Unknown Error`.\
  Solution:
  - Run `sudo nano /etc/nvidia-container-runtime/config.toml`, set `no-cgroups = false`, and save (Ctrl + X and then Y).
  - Restart Docker with `sudo systemctl restart docker`.


## Author

[Davide De Benedittis](https://github.com/ddebenedittis)


## Acknowledgments

- [Baptiste Busch](https://medium.com/@baptiste.busch/creating-a-ros-or-ros2-workspace-in-docker-part-1-912529c87708): creation of a ROS workspace in Docker
- [Official NVIDIA CUDA Docker Images](https://hub.docker.com/r/nvidia/cuda): NVIDIA Drivers in Docker. Uses the `12.x.x-base-ubuntuxx.xx` version. Change it to your liking.
