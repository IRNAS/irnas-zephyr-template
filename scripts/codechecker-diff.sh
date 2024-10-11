#! /usr/bin/env bash
# Usage scripts/codechecker-diff.sh <build_dir1> <build_dir2> ...
#
# This script is used to compare the analysis results of given build directories
# against the analysis results stored on the codechecker server.
#
# Precondition:
# - The codechecker server is running and EAST_CODECHECKER_SERVER_URL
#   environment variable contains its url. This is expected by the
#   `east codechecker servdiff` command.
# - The codechecker client is installed and logged in to the codechecker server.
# - Given build directories were analyzed with east codechecker check command
#
# Script will then compare the analysis results of each build directory against
# the analysis results on the server and store the diff in codechecker-diffs
# directory. If any reports are detected, the script will exit with error code
# 1, otherwise 0.

error_detected=0

mkdir -p codechecker-diffs

for build_dir in "$@"; do

    name=$(jq -r ".name" "${build_dir}"/codecheckerfile.json)
    board=$(jq -r ".board" "${build_dir}"/codecheckerfile.json)
    build_type=$(jq -r ".build_type" "${build_dir}"/codecheckerfile.json)

    # Replace / with _ in the board name
    # shellcheck disable=SC2001
    board=$(echo "${board}" | sed 's|/|_|g')

    # If build_type is null, we don't want to add it to the name
    if [[ $build_type == null ]]; then
        build_type=""
    else
        build_type="-"$build_type
    fi

    filename="codechecker-diff-${name}-${board}${build_type}.txt"

    if ! east codechecker servdiff --build-dir "${build_dir}" --new >codechecker-diffs/"${filename}"; then
        echo -e "Failed to get the construct valid ${filename}, reason:\n"
        cat codechecker-diffs/"${filename}"
        exit 1
    fi

    # A little bit of parsing to get the number of detected errors
    number_detected_errors=$(sed -nr 's/Number of analyzer reports.*\| ([0-9]+).*/\1/p' codechecker-diffs/"${filename}")

    if [[ $number_detected_errors -gt 0 ]]; then
        echo "New errors were detected in ${name}"
        echo "::error ::New errors were detected by the CodeChecker in ${name}-${board}${build_type} build. Click Summary, scroll down to the bottom and download the codechecker-diff file to see the detected errors."
        error_detected=1
    fi

done

exit $error_detected
