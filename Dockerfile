# TODO: Change ROS version in build.sh, not here.
ARG BASE_IMAGE=osrf/ros
ARG BASE_TAG=noetic-desktop

FROM ${BASE_IMAGE}:${BASE_TAG}

ARG ROS_NUMBER=1

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

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

# Create the same user as the host itself. (By default Docker creates the container as root, which is not recommended.)
ARG UID=1000
ARG GID=1000
ARG USER=ros
ARG PWDR=/
RUN addgroup --gid ${GID} ${USER} \
 && adduser --gecos "ROS User" --disabled-password --uid ${UID} --gid ${GID} ${USER} \
 && usermod -a -G dialout ${USER} \
 && echo ${USER}" ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/99_aptget \
 && chmod 0440 /etc/sudoers.d/99_aptget && chown root:root /etc/sudoers.d/99_aptget

# Choose to run as user
ENV USER ${USER}
USER ${USER}

# Change HOME environment variable
ENV HOME /home/${USER}

# Set up environment
COPY .config/update_bashrc_ros_1 /sbin/update_bashrc_ros_1
COPY .config/update_bashrc_ros_2 /sbin/update_bashrc_ros_2


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
COPY .config/entrypoint.sh /ros_entrypoint.sh
RUN sudo chmod +x /ros_entrypoint.sh ; sudo chown ${USER} /ros_entrypoint.sh \
 && echo "cd "${PWDR} >> /ros_entrypoint.sh \
 && echo 'exec bash -i -c $@' >> /ros_entrypoint.sh \
 && cat /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]