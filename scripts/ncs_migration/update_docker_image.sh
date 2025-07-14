#!/usr/bin/env bash
# Usage: ./update_docker_image_name.sh <options>
#
# Description:
#
#   Search through all repository files for hardcoded Docker image names and
#   update either the Docker image tag, the NCS version, or both.
#
# Notes:
#
#   At least one of the two options must be provided. The script will update all
#   matching references in repository files accordingly.
#
# Options:
#
#   --image-tag <IMAGE_TAG>         The new image tag to replace the existing
#                                   one in Docker image names. Must be either a
#                                   valid semantic version in the format
#                                   vMAJOR.MINOR.PATCH or the string "latest".
#
#   --ncs-revision <NCS_VERSION>    The new NCS version to replace the existing
#                                   one in Docker image names. Must be a valid
#                                   semantic version number in the format
#                                   vMAJOR.MINOR.PATCH.
#
#   -h, --help                      Show this help message and exit.
#

# Starting part of the docker image that the script searches for.
# If the image name changes, this variable must be updated.
DOCKER_IMAGE="ghcr.io/irnas/ncs-zephyr"

NCS_REVISION=""
IMAGE_TAG=""

print_help() {
    sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' <"$0"
}

val_image_tag() {
    # Validate the argument against the regex and "latest" literal
    if [[ ! $IMAGE_TAG =~ $SEMVER_REGEX && ! $IMAGE_TAG =~ "latest" ]]; then
        echo -e "${RED}Invalid image tag: ${IMAGE_TAG}${NC}"
        echo
        print_help
        exit 1
    fi
}

val_ncs_revision() {
    # Validate the argument against the regex
    if [[ ! $NCS_REVISION =~ $SEMVER_REGEX ]]; then
        echo -e "${RED}Invalid NCS revision: ${NCS_REVISION}${NC}"
        echo
        print_help
        exit 1
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
    --ncs-revision)
        NCS_REVISION="$2"
        val_ncs_revision
        shift 2
        ;;
    --image-tag)
        IMAGE_TAG="$2"
        val_image_tag
        shift 2
        ;;
    --help | -h)
        print_help
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        print_help
        exit 1
        ;;
    esac
done

SEMVER_REGEX="v[0-9]+\.[0-9]+\.[0-9]+"

# Color codes
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if at least one variable is set
if [[ -z $NCS_REVISION && -z $IMAGE_TAG ]]; then
    echo -e "${RED}Error: At least one argument must be provided.${NC}"
    echo
    print_help
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
    if [[ -n $IMAGE_TAG ]]; then
        # Replace Docker image tag
        #
        # 1. (${DOCKER_IMAGE}-[^:]+:) - 1st capture group that matches by the
        #    DOCKER_IMAGE up to the first colon.
        # 2. (${SEMVER_REGEX}|latest) - 2nd capture group that matches either
        #    the semantic version number or literal "latest".
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
            "s#(${DOCKER_IMAGE}[^:]+:)(${SEMVER_REGEX}|latest)(.*)#\1${IMAGE_TAG}\3#g" \
            "$file"
    fi

    if [[ -n $NCS_REVISION ]]; then
        # Replace NCS revisions
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
            "s|(${DOCKER_IMAGE}-)${SEMVER_REGEX}(-.*)|\1${NCS_REVISION}\2|g" \
            "$file"
    fi

done
