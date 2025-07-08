#! /usr/bin/env bash
# Usage: ./create_signing_keys.sh key_file secret_key_var
#
# Description:
#
#   Create private key files from env vars.
#
# Arguments:
#
#   key_file The full path of the key file to create, e.g. app/signing_key_rsa2048.pem
#   secret_key_var The name of the ENV variable or Github secret that contains the private keys,
#                  e.g. IMAGE_SIGN_KEY.

NUM_ARGS=2
# Print help text and exit if -h, or --help or insufficient number of arguments
# was given.
if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ $# -lt ${NUM_ARGS} ]; then
    sed -ne '/^#/!q;s/.\{1,2\}//;1d;p' <"$0"
    exit 1
fi

FILE_PATH="$1"
KEY_VAR="$2"

# Check that the key content is not empty
# If it is, we are probably running in a local environment.
# In CI, the key should be set as a GitHub secret and the variable should not be empty.
# If it is empty, the file will not be created, and the build will fail.
if [ -z "${!KEY_VAR}" ]; then
    echo "${KEY_VAR} is not set, doing nothing."
    exit 0
fi

# Create the key file
echo "${!KEY_VAR}" >"${FILE_PATH}"

echo "Created key file ${FILE_PATH} from environment variable ${KEY_VAR}"
