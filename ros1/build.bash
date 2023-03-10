#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -r"
   echo -e "\t-r Rebuild the image"
   exit 1 # Exit script after printing help
}


REBUILD=0
while getopts 'r' opt
do
  case $opt in
    r) REBUILD=1 ;;
    ?) helpFunction ;; # Print helpFunction in case parameter is non-existent
    esac
done
shift "$(( OPTIND - 1 ))"


# TODO: Change ROS 2 version if you wish.
BASE_IMAGE=osrf/ros
BASE_TAG=noetic-desktop
# TODO: Change image name if you wish (here and in run.bash).
IMAGE_NAME=ros1_image_name

docker pull $BASE_IMAGE:$BASE_TAG

MYUID="$(id -u $USER)"
MYGID="$(id -g $USER)"


if [ "$REBUILD" -eq 1 ]; then
  docker build \
  --no-cache \
  --build-arg BASE_IMAGE=$BASE_IMAGE \
  --build-arg BASE_TAG=$BASE_TAG \
  --build-arg MYUID=${UID} \
  --build-arg MYGID=${GID} \
  --build-arg USER=${USER} \
  --build-arg "PWDR=$PWD" \
  -t $IMAGE_NAME .
else
  docker build \
  --build-arg BASE_IMAGE=$BASE_IMAGE \
  --build-arg BASE_TAG=$BASE_TAG \
  --build-arg MYUID=${UID} \
  --build-arg MYGID=${GID} \
  --build-arg USER=${USER} \
  --build-arg "PWDR=$PWD" \
  -t $IMAGE_NAME .
fi
