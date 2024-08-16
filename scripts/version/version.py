#!/usr/bin/env python3

import argparse
import subprocess
import sys
from typing import NamedTuple


class ParsedTag(NamedTuple):
    """A named tuple to hold the parsed tag information."""

    major: int
    minor: int
    patch: int
    extra: str  # Can be None
    tweak: int


def is_only_hash(tag):
    """Checks if the tag is only a hash.

    Args:
        tag (str): The tag to check.

    Returns:
        bool: True if the tag is only a hash, False otherwise.
    """
    return len(tag.split("-")) == 1


def parse_integer_version(part, tag, annotation):
    """Try to parse an integer version part, such as major, minor, or patch.

    1. If no tag (only hash), then generate v0.0.0-99
    2. If tag exists, the the format is: "v<MAJOR>.<MINOR>.<PATCH>[-<RC>]-<TWEAK>". Example: v1.2.3-rc1-0 (The hash is removed in the get_tag function)
        There are only 2 valid options (with or without rc).
        Anything else must be rejected (script must exit with an error).

    Args:
        part (str): The part if the tag to parse.
        tag (str): The full tag.
        annotation (str): The "name" of what is being parsed. Like "major", "minor", or "patch".

    Returns:
        int: The parsed integer version part.
    """
    try:
        return int(part)
    except Exception:
        raise ValueError(
            f"Invalid tag format: {tag}. {annotation} version must be an integer."
        )


def parse_tag(tag):
    """Parse the git tag.

    Args:
        tag (str): The tag to parse.

    Returns:
        ParsedTag: The parsed tag information.
    """
    # If only hash, generate default version
    if is_only_hash(tag):
        return ParsedTag(0, 0, 0, "", 99)

    # Check if starts with "v"
    if not tag.startswith("v"):
        raise ValueError(f"Invalid tag format: {tag}. Tag must start with 'v'.")

    # Split at "." and "-". Check how many parts we have.
    parts = tag.replace("v", "").replace("-", ".").split(".")

    # Start from the front and parse all parts
    idx = 0

    # Major, minor and patch are required
    major = parse_integer_version(parts[idx], tag, "Major")
    idx += 1
    minor = parse_integer_version(parts[idx], tag, "Minor")
    idx += 1
    patch = parse_integer_version(parts[idx], tag, "Patch")
    idx += 1

    # Determine if we have a EXTRA part or not
    # If 5 parts, we have an extra part
    # If 4 parts, we don't have an extra part
    has_extra = len(parts) == 5

    if has_extra:
        extra = parts[idx]
        idx += 1
    else:
        extra = None

    # Tweak is required
    tweak = parse_integer_version(parts[idx], tag, "Tweak")
    idx += 1

    return ParsedTag(major, minor, patch, extra, tweak)


def get_tag():
    """Get the tag using git describe. The hash is removed.

    Returns:
        str: The tag from git describe.
    """
    git_describe = (
        subprocess.check_output(["git", "describe", "--tags", "--always", "--long"])
        .decode("utf-8")
        .strip()
    )

    # Remove the hash (last part after "-")
    git_describe = git_describe.rsplit("-", 1)[0]

    return git_describe


def main():
    """Create a Zephyr compatible VERSION file."""
    parser = argparse.ArgumentParser(
        prog="version",
        description="Generate a Zephyr compatible VERSION file from a provided tag or from git describe. If the tag is not valid (or does not exists), the version will be set to 0.0.0-0.",
    )
    parser.add_argument(
        "-f",
        "--file",
        metavar="FILE",
        type=str,
        required=True,
        help="The file path to write the version information to.",
    )
    parser.add_argument(
        "-t",
        "--tag",
        metavar="TAG",
        type=str,
        required=False,
        help='The tag to use for version information in the format "v<MAJOR>.<MINOR>.<PATCH>[-<EXTRA>]-<TWEAK>", eg. v1.2.3-4 or v1.2.3-rc1-4. If not provided, git describe will be used.',
    )

    args = parser.parse_args()
    filename = args.file
    tag = args.tag

    if tag is None:
        tag = get_tag()

    try:
        pt = parse_tag(tag)
    except Exception as e:
        print(e)
        sys.exit(1)

    with open(filename, "w") as f:
        f.write(
            f"VERSION_MAJOR = {pt.major}\n"
            f"VERSION_MINOR = {pt.minor}\n"
            f"PATCHLEVEL = {pt.patch}\n"
            f"VERSION_TWEAK = {pt.tweak}\n"
        )
        if pt.extra:
            f.write(f"EXTRAVERSION = {pt.extra}\n")


if __name__ == "__main__":
    main()
