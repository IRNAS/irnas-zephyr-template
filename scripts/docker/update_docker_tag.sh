#!/usr/bin/env bash
# Usage: ./update_docker_tag.sh <IMAGE_TAG>
#
# Description:
#
#   Search through all repository files for the hardcoded Docker image names and
#   update the image tag in the name. The image tag is the string that appears
#   after colon in the docker image name. See the DOCKER_TAG variable below for
#   the image tag that this script searches for.
#
# Arguments:
#
#   IMAGE_TAG               The new image tag which should replace existing
#                           one in the Docker image names.
#                           Must be either valid semantic version number with
#                           the format vMAJOR.MINOR.PATCH or "latest".

NUM_ARGS=1
# Print help text and exit if -h, or --help or insufficient number of arguments
# was given.
if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ $# -lt ${NUM_ARGS} ]; then
    sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' <"$0"
    exit 1
fi

NEW_IMAGE_TAG="$1"
SEMVER_REGEX="v[0-9]+\.[0-9]+\.[0-9]+"
DOCKER_IMAGE="ghcr.io/irnas/ncs-zephyr"

# Validate the argument against the regex and "latest" literal
if [[ ! $NEW_IMAGE_TAG =~ $SEMVER_REGEX && ! $NEW_IMAGE_TAG =~ "latest" ]]; then
    echo "Invalid image tag: $1"
    exit 1
fi

# Get absolute path of the script location
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJ_DIR=$(realpath "${SCRIPT_DIR}/../..")

# shellcheck disable=SC2164
cd "${PROJ_DIR}"

# Find files containing the search pattern, only search in tracked files to be
# faster.
files=$(git ls-files | xargs -I {} grep -rl "$DOCKER_IMAGE" {})

# Process each file
for file in $files; do

    # Perform the in-place substitution
    #
    # 1. (${DOCKER_IMAGE}-[^:]+:) - 1st capture group that matches by the
    #    DOCKER_IMAGE up to the first colon.
    # 2. (${SEMVER_REGEX}|latest) - 2nd capture group that matches either the
    #    semantic version number or literal "latest".
    # 3. (.*) - 3rd capture group, matches everything after the 2nd group.
    #    Needed so that the text after docker image name is not modified.
    #
    # The replacement pattern just surrounds the NEW_VERSION with the
    # first and second capture groups.
    #
    # For example, if "v2.0.0" is passed as the argument, then the:
    #
    #  "image": "ghcr.io/irnas/some_image-v1.0.0-dev:v1.0.0"
    #
    #  is replaced by
    #
    #  "image": "ghcr.io/irnas/some_image-v1.0.0-dev:v2.0.0"
    #
    sed -i -E \
        "s#(${DOCKER_IMAGE}[^:]+:)(${SEMVER_REGEX}|latest)(.*)#\1${NEW_IMAGE_TAG}\3#g" \
        "$file"

done
