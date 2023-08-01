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
	pip install -r scripts/requirements.txt
	east sys-setup
	# Below line is needed, as the toolchain manager might be cached in CI, but not configured
	~/.local/share/east/nrfutil-toolchain-manager.exe config --install-dir ~/.local/share/east

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
