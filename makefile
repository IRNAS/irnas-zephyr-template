# This is a default makefile for the Zephyr project, that is supposed to be 
# initialized with West and built with East. 
#
# This makefile in combination with the Github actions does the following:
# * Installs python dependencies and toolchain
# * Initializes the project with West and updates it
# * Runs east release
# If the _build_ is running due to the release creation, then the following also 
# happens:
# * Creates 'artefacts' folder,
# * Copies release zip files and extra release notes files into it.
#
# Downloaded West modules, toolchain and nrfutil-toolchain-manager are cached in 
# CI after the first time the entire build is run.
#
# The assumed precondition is that the repo was setup with below commands:
# mkdir -p <project_name>/project
# cd <project_name>/project
# git clone <project_url> .
#
# Every target assumes that is run from the repo's root directory, which is 
# <project_name>/project.

install-dep:
	# Install gcc-multilib for 32-bit support
	sudo apt-get update
	sudo apt-get install gcc-multilib
	pip install -r scripts/requirements.txt
	east sys-setup
	# Below line is needed, as the toolchain manager might be cached in CI, but not configured
	~/.local/share/east/nrfutil-toolchain-manager.exe config --install-dir ~/.local/share/east

install-test-dep:
	sudo apt-get install gcc-multilib lcov
	pip install junit2html

project-setup:
	# Make a West workspace around this project
	west init -l .
	# Use a faster update method
	west update -o=--depth=1 -n
	east update toolchain

pre-build:
	echo "Pre-build"

build:
	# Change east.yml to control what is built.
	east release

# Pre-package target is only run in release process.
pre-package:
	mkdir -p artefacts
	cp release/*.zip artefacts
	cp scripts/pre_changelog.md artefacts
	cp scripts/post_changelog.md artefacts

test:
	east twister -T tests --coverage -p native_posix

test-report-ci:
	junit2html twister-out/twister.xml twister-out/twister-report.html

# Intended to be used by developer
test-report: test-report-ci
	firefox twister-out/twister-report.html

# Twister's coverage report by default includes all Zephyr sources, which is not
# what we want. Below coverage-report-ci target removes all Zephyr sources from
# coverage.info and generates a new coverage report.
REMOVE_DIR = $(shell realpath $(shell pwd)/../zephyr)

# This target is used in CI. It differs from coverage-report target in that it
# removes "project/" from the paths in coverage.info, so that the GitHub action
# that makes the coverage report can create proper links to the source files.
coverage-report-ci:
	rm -fr twister-out/coverage
	lcov -q --remove twister-out/coverage.info "${REMOVE_DIR}/*" -o twister-out/coverage.info  --rc lcov_branch_coverage=1

# Intended to be used by developer
coverage-report: coverage-report-ci
	genhtml -q --output-directory twister-out/coverage --ignore-errors source --branch-coverage --highlight --legend twister-out/coverage.info
	firefox twister-out/coverage/index.html
