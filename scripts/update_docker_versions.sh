#!/usr/bin/env bash
# Usage: ./update_docker_versions.sh <new-version>
#
# Description:
#
#   Search through all repository files for the hardcoded Docker image name and
#   update the version number following it with the given version number.
#   The version number is the Zephyr or NCS version number, not the Docker image
#   tag. See the DOCKER_IMAGE variable in the script for the image name to
#   search for.
#
# Arguments:
#
#   new-version             The new version number to update the Docker image,
#                           must be a valid semantic version number with the
#                           format vMAJOR.MINOR.PATCH

NUM_ARGS=1
# Print help text and exit if -h, or --help or insufficient number of arguments
# was given.
if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ $# -lt ${NUM_ARGS} ]; then
    sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' <"$0"
    exit 1
fi

NEW_VERSION="$1"
SEMVER_REGEX="v[0-9]+\.[0-9]+\.[0-9]+"
DOCKER_IMAGE="ghcr.io/irnas/ncs-zephyr"

# Validate the argument against the regex
if [[ ! $NEW_VERSION =~ $SEMVER_REGEX ]]; then
    echo "Invalid semantic version: $1"
    exit 1
fi

# Get absolute path of the script location
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PROJ_DIR=$(realpath "${SCRIPT_DIR}/..")

# shellcheck disable=SC2164
cd "${PROJ_DIR}"

# Find files containing the search pattern, only search in tracked files to be
# faster.
files=$(git ls-files | xargs -I {} grep -rl "$DOCKER_IMAGE" {})

# Process each file
for file in $files; do

    # Perform the in-place substitution
    #
    # 1. (${DOCKER_IMAGE}-[^:]+:) - First capture group that matches by the
    #   DOCKER_IMAGE up to the first colon.
    # 2. ${SEMVER_REGEX} - Match the semantic version number.
    # 3. (\b) - Second capture group, needed so that the text after the semantic
    #   version number is not modified.
    #
    # The replacement pattern just surrounds the NEW_VERSION with the
    # first and second capture groups.
    #
    # Example:
    #
    #  "image": "ghcr.io/irnas/ncs-zephyr-1.0.0-dev:1.0.0"
    #
    #  is replaced by
    #
    #  "image": "ghcr.io/irnas/ncs-zephyr-2.0.0-dev:1.0.0"
    sed -i -E \
        "s|(${DOCKER_IMAGE}-)${SEMVER_REGEX}(-\b)|\1${NEW_VERSION}\2|g" \
        "$file"

    echo "Updated $file with $NEW_VERSION"
done
