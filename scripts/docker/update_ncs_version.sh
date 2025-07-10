#!/usr/bin/env bash
# Usage: ./update_ncs_version.sh <NCS_VERSION>
#
# Description:
#
#   Search through all repository files for the hardcoded Docker image names and
#   update the NCS version in the name. See the DOCKER_IMAGE variable below for
#   the image name that this script searches for.
#
# Arguments:
#
#   NCS_VERSION             The new NCS version which should replace existing
#                           one in the Docker image names.
#                           Must be a valid semantic version number with the
#                           format vMAJOR.MINOR.PATCH

NUM_ARGS=1
# Print help text and exit if -h, or --help or insufficient number of arguments
# was given.
if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ $# -lt ${NUM_ARGS} ]; then
    sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' <"$0"
    exit 1
fi

NEW_NCS_VERSION="$1"
SEMVER_REGEX="v[0-9]+\.[0-9]+\.[0-9]+"
DOCKER_IMAGE="ghcr.io/irnas/ncs-zephyr"

# Validate the argument against the regex
if [[ ! $NEW_NCS_VERSION =~ $SEMVER_REGEX ]]; then
    echo "Invalid semantic version: $1"
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
    # 1. (${DOCKER_IMAGE}-) - 1st capture group that matches by the
    #   DOCKER_IMAGE up to the first hyphen.
    # 2. ${SEMVER_REGEX} - Match the semantic version number.
    # 3. (.*) - 2nd capture group, matches everything after the 2nd group.
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
    #  "image": "ghcr.io/irnas/some_image-v2.0.0-dev:v1.0.0"
    sed -i -E \
        "s|(${DOCKER_IMAGE}-)${SEMVER_REGEX}(-.*)|\1${NEW_NCS_VERSION}\2|g" \
        "$file"
done
