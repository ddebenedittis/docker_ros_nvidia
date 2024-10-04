# Change ROS version in build.sh, not here!
ARG BASE_IMAGE=osrf/ros
ARG BASE_TAG=noetic-desktop

FROM ${BASE_IMAGE}:${BASE_TAG}

ARG ROS_NUMBER=1

# ================================== Nvidia ================================== #

# Use the NVIDIA graphics card.
ENV NVARCH=x86_64

ENV NVIDIA_REQUIRE_CUDA="cuda>=12.1 brand=tesla,driver>=450,driver<451 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471 brand=tesla,driver>=510,driver<511 brand=unknown,driver>=510,driver<511 brand=nvidia,driver>=510,driver<511 brand=nvidiartx,driver>=510,driver<511 brand=geforce,driver>=510,driver<511 brand=geforcertx,driver>=510,driver<511 brand=quadro,driver>=510,driver<511 brand=quadrortx,driver>=510,driver<511 brand=titan,driver>=510,driver<511 brand=titanrtx,driver>=510,driver<511 brand=tesla,driver>=515,driver<516 brand=unknown,driver>=515,driver<516 brand=nvidia,driver>=515,driver<516 brand=nvidiartx,driver>=515,driver<516 brand=geforce,driver>=515,driver<516 brand=geforcertx,driver>=515,driver<516 brand=quadro,driver>=515,driver<516 brand=quadrortx,driver>=515,driver<516 brand=titan,driver>=515,driver<516 brand=titanrtx,driver>=515,driver<516 brand=tesla,driver>=525,driver<526 brand=unknown,driver>=525,driver<526 brand=nvidia,driver>=525,driver<526 brand=nvidiartx,driver>=525,driver<526 brand=geforce,driver>=525,driver<526 brand=geforcertx,driver>=525,driver<526 brand=quadro,driver>=525,driver<526 brand=quadrortx,driver>=525,driver<526 brand=titan,driver>=525,driver<526 brand=titanrtx,driver>=525,driver<526"
ENV NV_CUDA_CUDART_VERSION=12.1.105-1
ENV NV_CUDA_COMPAT_PACKAGE=cuda-compat-12-1

LABEL maintainer="NVIDIA CORPORATION <cudatools@nvidia.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/${NVARCH}/3bf863cc.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/${NVARCH} /" > /etc/apt/sources.list.d/cuda.list && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION=12.1.1

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-12-1=${NV_CUDA_CUDART_VERSION} \
    ${NV_CUDA_COMPAT_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,graphics,utility

# ============================================================================ #

# Prevent bash to ask for user input which may break the building process
ENV DEBIAN_FRONTEND=noninteractive

# Install sudo, and some essential packages.
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt --mount=type=cache,sharing=locked,target=/var/lib/apt \
    apt-get update && apt-get install --no-install-recommends -qqy \
    bash-completion \
    build-essential \
    git \
    sudo \
    wget

# Install packages specific for ROS 1.
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt --mount=type=cache,sharing=locked,target=/var/lib/apt \
    if [ "${ROS_NUMBER}" = "1" ] ; then \
        apt-get update && apt-get install --no-install-recommends -qqy \
        ros-${ROS_DISTRO}-catkin \
        python3-catkin-tools \
        python3-osrf-pycommon ; \
    fi

ARG MYUID=1000
ARG MYGID=1000
ARG USER=ros
ARG PWDR=/

RUN OLD_USER=$(awk -v uid="$MYUID" -F ':' '$3==uid {print $1}' /etc/passwd) \
    && if [ -z "${OLD_USER}" ]; then \
        # There is no existing UID equal to MYUID.
        # Create the same user as the host itself. (By default Docker creates the container as root, which is not recommended.)
        addgroup --gid ${MYGID} ${USER} \
        && adduser --gecos "ROS User" --disabled-password --uid ${MYUID} --gid ${MYGID} ${USER} \
        && usermod -a -G dialout ${USER} \
        && echo ${USER}" ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/99_aptget \
        && chmod 0440 /etc/sudoers.d/99_aptget && chown root:root /etc/sudoers.d/99_aptget ; \
    else \
        usermod -l ${USER} ${OLD_USER} \
        && sudo usermod -d /home/${USER} -m ${USER} \
        && echo ${USER}" ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/99_aptget \
        && chmod 0440 /etc/sudoers.d/99_aptget && chown root:root /etc/sudoers.d/99_aptget ; \
    fi

# Choose to run as user
ENV USER=${USER}
USER ${USER}

# Change HOME environment variable
ENV HOME=/home/${USER}

# Install the required dependencies with rosdep.
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt --mount=type=cache,sharing=locked,target=/var/lib/apt \
    --mount=type=bind,source=./src,target=/home/${USER}/catkin_ws/src,rw \
    cd /home/${USER}/catkin_ws \
 && sudo apt-get update \
 && rosdep update \
 && rosdep install --from-paths src --ignore-src -r -y

# Set up environment
COPY ./docker/.config/update_bashrc_ros_1 /sbin/update_bashrc_ros_1
COPY ./docker/.config/update_bashrc_ros_2 /sbin/update_bashrc_ros_2

RUN if [ "${ROS_NUMBER}" = "1" ] ; then \
        sudo chmod +x /sbin/update_bashrc_ros_1 ; sudo chown ${USER} /sbin/update_bashrc_ros_1 \
        && echo 'echo "source '${PWDR}'/devel/setup.bash" >> ~/.bashrc' >> /sbin/update_bashrc_ros_1 \
        && cat /sbin/update_bashrc_ros_1 \
        && sync ; /bin/bash -c /sbin/update_bashrc_ros_1 ; sudo rm /sbin/update_bashrc_ros_1 ; \
    elif [ "${ROS_NUMBER}" = "2" ] ; then \
        sudo chmod +x /sbin/update_bashrc_ros_2 ; sudo chown ${USER} /sbin/update_bashrc_ros_2 \
        && echo 'echo "source '${PWDR}'/install/setup.bash" >> ~/.bashrc' >> /sbin/update_bashrc_ros_2 \
        && cat /sbin/update_bashrc_ros_2 \
        && sync ; /bin/bash -c /sbin/update_bashrc_ros_2 ; sudo rm /sbin/update_bashrc_ros_2 ; \
    fi

# Change entrypoint to source ~/.bashrc and start in ~
COPY ./docker/.config/entrypoint.sh /ros_entrypoint.sh
RUN sudo chmod +x /ros_entrypoint.sh ; sudo chown ${USER} /ros_entrypoint.sh \
 && echo "cd "${PWDR} >> /ros_entrypoint.sh \
 && echo 'exec bash -i -c $@' >> /ros_entrypoint.sh \
 && cat /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]