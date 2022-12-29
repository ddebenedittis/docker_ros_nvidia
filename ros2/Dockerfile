# TODO: Change ROS 2 version if you with (here and in build.sh).
ARG BASE_IMAGE=osrf/ros
ARG BASE_TAG=humble-desktop

FROM ${BASE_IMAGE}:${BASE_TAG}

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# Prevents bash to ask for user input which may break the building process
ENV DEBIAN_FRONTEND=noninteractive

# Install sudo, some packages for Pinocchio, pip, and some ROS packages
RUN apt-get update && apt-get install -qqy \
    wget \
    git \
    bash-completion \
    build-essential \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create the same user as the host itself. (By default Docker creates the container as root, which is not recommended.)
ARG UID=1000
ARG GID=1000
ARG USER=ros
ARG PWDR=/
RUN addgroup --gid ${GID} ${USER}
RUN adduser --gecos "ROS User" --disabled-password --uid ${UID} --gid ${GID} ${USER}
RUN usermod -a -G dialout ${USER}
RUN echo ${USER}" ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/99_aptget
RUN chmod 0440 /etc/sudoers.d/99_aptget && chown root:root /etc/sudoers.d/99_aptget

# Choose to run as user
ENV USER ${USER}
USER ${USER}

# Change HOME environment variable
ENV HOME /home/${USER}

# Set up environment
COPY config/update_bashrc /sbin/update_bashrc
RUN sudo chmod +x /sbin/update_bashrc ; sudo chown ${USER} /sbin/update_bashrc
RUN echo 'echo "source '${PWDR}'/install/setup.bash" >> ~/.bashrc' >> /sbin/update_bashrc
RUN cat /sbin/update_bashrc
RUN sync ; /bin/bash -c /sbin/update_bashrc ; sudo rm /sbin/update_bashrc

# Change entrypoint to source ~/.bashrc and start in ~
COPY config/entrypoint.sh /ros_entrypoint.sh
RUN sudo chmod +x /ros_entrypoint.sh ; sudo chown ${USER} /ros_entrypoint.sh ;
RUN echo "cd "${PWDR} >> /ros_entrypoint.sh
RUN echo 'exec bash -i -c $@' >> /ros_entrypoint.sh

RUN cat /ros_entrypoint.sh

# Clean image
RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]