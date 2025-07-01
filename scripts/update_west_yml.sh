#!/usr/bin/env bash
# Usage: ./update_west_yml.sh <new-revision>
#
# Description:
#
#   Update a west.yaml for use in a NCS Project to a new NCS revision.
#   This script will:
#   - Fetch the west.yml file from the NCS repository for the specified revision from github.
#   - Fetch the west.yml file for the corresponding Zephyr revision from github.
#   - Update the local west.yml file with the new NCS and Zephyr revisions and update
#     the name-allowlists of both.
#
#   Requires yq to be installed. It can be installed with:
#   snap install yq
#
# Arguments:
#
#   new-revision            The new NCS revision with the format vMAJOR.MINOR.PATCH.
#

NUM_ARGS=1
# Print help text and exit if -h, or --help or insufficient number of arguments
# was given.
if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ $# -lt ${NUM_ARGS} ]; then
    sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' <"$0"
    exit 1
fi

# Check that yq is installed
if ! command -v yq &>/dev/null; then
    echo "yq is not installed. Please install yq to run this script."
    echo "You can install it with: snap install yq"
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
WEST_YML_PATH="${SCRIPT_DIR}/../west.yml"

NEW_NCS_REVISION="${1}"

# Check that the west.yml file exists
if [ ! -f "${WEST_YML_PATH}" ]; then
    echo "The specified west.yml file does not exist: ${WEST_YML_PATH}"
    exit 1
fi

# Validate the argument against the regex
SEMVER_REGEX="v[0-9]+\.[0-9]+\.[0-9]+"
if [[ ! ${NEW_NCS_REVISION} =~ ${SEMVER_REGEX} ]]; then
    echo "Invalid revision argument: ${NEW_NCS_REVISION}"
    echo "The revision must be in the format vMAJOR.MINOR.PATCH, e.g. v1.2.3"
    exit 1
fi

# Read the existing west.yml file and get the NCS NEW_NCS_REVISION
current_revision=$(yq '.manifest.projects[] | select(.name == "nrf").revision' "${WEST_YML_PATH}")

echo "Current NCS revision in west.yml: $current_revision"
echo "Updating to: ${NEW_NCS_REVISION}"

# if the current revision is the same as the new revision, exit
if [ "${current_revision}" = "${NEW_NCS_REVISION}" ]; then
    echo "The current NCS revision is already set to ${NEW_NCS_REVISION}. No changes made."
    exit 0
fi

# Fetch the west.yml from remote NCS repository
# if fault, exit
if ! wget -q --output-document _new_ncs_west.yml "https://raw.githubusercontent.com/nrfconnect/sdk-nrf/refs/tags/${NEW_NCS_REVISION}/west.yml"; then
    echo "Failed to fetch the west.yml file from the NCS repository for revision ${NEW_NCS_REVISION}."
    echo "Check if the revision is correct and if the repository is accessible: https://raw.githubusercontent.com/nrfconnect/sdk-nrf/refs/tags/${NEW_NCS_REVISION}/west.yml"
    exit 1
fi

# Get the corresponding Zephyr revision from the new NCS west.yml
NEW_ZEPHYR_REVISION=$(yq '.manifest.projects[] | select(.name == "zephyr").revision' _new_ncs_west.yml)

# Also download the new Zephyr west.yml file
if ! wget -q --output-document _new_zephyr_west.yml "https://raw.githubusercontent.com/nrfconnect/sdk-zephyr/refs/tags/${NEW_ZEPHYR_REVISION}/west.yml"; then
    echo "Failed to fetch the west.yml file from the Zephyr repository for revision ${NEW_ZEPHYR_REVISION}."
    echo "Check if the revision is correct and if the repository is accessible: https://raw.githubusercontent.com/nrfconnect/sdk-zephyr/refs/tags/${NEW_ZEPHYR_REVISION}/west.yml"
    exit 1
fi

# We now have the new NCS west.yml and the new Zephyr west.yml files.
# For each manifest.projects[].name in the new NCS west.yml, add it to the
# nrf projects name-allowlist in the local west.yml file.
# Repeat similarly for zephyr remote project names, adding them to the
# zephyr projects name-allowlist in the local west.yml file.

# Get what we want from the new NCS west.yml
yq '.manifest.projects[].name | select(. != "zephyr")' ./_new_ncs_west.yml >_a.txt
# Sort alphabetically and remove duplicates
sort -o _a.txt -u _a.txt
# Now add "  - " in front of each line (This gives us a valid "yaml list")
sed -i 's/^/  - /' _a.txt
# Place the content of _a.txt into the west.yml file
yq -i '.manifest.projects[] |= select(.name == "nrf").import.name-allowlist = load("_a.txt")' "${WEST_YML_PATH}"

# repeat the same process for the Zephyr west.yml
yq '.manifest.projects[].name' ./_new_zephyr_west.yml >_b.txt
sort -o _b.txt -u _b.txt
sed -i 's/^/  - /' _b.txt
yq -i '.manifest.projects[] |= select(.name == "zephyr").import.name-allowlist = load("_b.txt")' "${WEST_YML_PATH}"

# Update the nrf and zephyr revisions in the west.yml file
yq -i '.manifest.projects[] |= select(.name == "nrf").revision = "'"${NEW_NCS_REVISION}"'"' "${WEST_YML_PATH}"
yq -i '.manifest.projects[] |= select(.name == "zephyr").revision = "'"${NEW_ZEPHYR_REVISION}"'"' "${WEST_YML_PATH}"

# Cleanup temporary files
rm _new_ncs_west.yml _new_zephyr_west.yml _a.txt _b.txt

echo ""
echo ""
echo "west.yml has been updated to NCS revision ${NEW_NCS_REVISION}."
echo "Check the file and comment-out all modules in the name-allowlists that are not needed in this project."
echo "After that, run 'east update' to fetch the new modules."

exit 0
