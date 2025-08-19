#! /usr/bin/env bash
# Usage scripts/enter_docker_environment.sh [image_type]
#
# This script enters the docker environment suitable for project development.
#
# If no argument is given, the script will use the `dev` docker image.
# If image_type argument is given, it will be used to determine the docker
# image type.
# If the first argument is "zsh", the script will use the `zsh` docker image.

# Get absolute path of the script location
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
WEST_DIR=$(realpath "${SCRIPT_DIR}/../../..")

if [ -z "${1}" ]; then
    TYPE="dev"
else
    TYPE="${1}"
fi

docker run -it --rm \
    --privileged \
    --volume "${WEST_DIR}":/home/user/workdir \
    --volume /dev:/dev \
    --workdir /home/user/workdir/project \
    --device-cgroup-rule='c 166:* rmw' \
    ghcr.io/irnas/ncs-zephyr-v3.1.0-"${TYPE}":latest

# Flags:
# --privileged,
# --volume /dev:/dev and
# --device-cgroup-rule
#
# are needed to have access to the USB devices in the container.
# Number 166 corresponds to the major group number of tty devices.
# If this is not the case on your system, you can find the group number by
# running:
# ls -al /dev/tty*
