#!/bin/bash
# This scripts send a HTTP POST request to the specified URL and checks if the response code is 200.
# The URL endpoint is a server running on the Raspberry Pi that is connected to the J-Link debugger.
# The script is called from the `twister-rpi.yaml` workflow file.

# Check if the required arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <timeout_seconds> <interval_seconds> <request_url>"
    exit 1
fi

timeout="$1"
interval="$2"
request_url="$3"
start_time=$(date +%s) # Converts the date into unix timestamp

echo "$start_time"

while true; do
    # Send a POST request to the request_url and capture the HTTP response code
    response_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$request_url")

    # Check if the response code is 200
    if [ "$response_code" -eq 200 ]; then
        echo "Request to $request_url succeeded with status code 200."
        exit 0
    fi

    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    # Check if the timeout is reached
    if [ "$elapsed_time" -ge "$timeout" ]; then
        echo "Timeout reached. Request to $request_url failed with status code $response_code."
        exit 1
    fi

    echo "Request to $request_url failed with status code $response_code. Retrying in $interval seconds..."
    sleep "$interval"
done
