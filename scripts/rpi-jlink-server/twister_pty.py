#!/usr/bin/env python3
# A script used by twister to run the pseudoterminal
# The script opens a telnet connection to the specified IP and PORT and prints the output to the terminal

import argparse
import telnetlib

parser = argparse.ArgumentParser(description="Read telnet output")
parser.add_argument("--host", help="Host to connect to")
parser.add_argument("--port", help="Port to connect to")
args = parser.parse_args()

HOST = args.host
PORT = args.port


def read_telnet_output():
    """Read the telnet output and print it to the terminal."""
    try:
        with telnetlib.Telnet(HOST, PORT) as tn:
            while True:
                line = tn.read_until(b"PROJECT EXECUTION SUCCESSFUL")
                print(line.decode("utf-8"))
                if b"PROJECT EXECUTION SUCCESSFUL" in line:
                    print("Tests finished running. Exiting!")
                    return 0

    except Exception as e:
        print(f"An exception occurred when reading telnet output: {e}")


# Run the event loop and call the function to start reading the telnet output
if __name__ == "__main__":
    if not HOST or not PORT:
        print("Please specify a host and port")
        exit()
    read_telnet_output()
