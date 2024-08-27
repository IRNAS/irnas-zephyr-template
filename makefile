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
	east install nrfutil-toolchain-manager
	# Below line is needed, as the toolchain manager might be cached in CI, but not configured
	~/.local/share/east/tooling/nrfutil/nrfutil toolchain-manager config --set install-dir=~/.local/share/east

project-setup:
	# Make a West workspace around this project
	east init -l .
	# Use a faster update method
	east update -o=--depth=1 -n
	east install toolchain

# Generate version file for each app
# If multiple apps are present, this target should call the version script
# once for each app
gen-version:
	./scripts/version/version.py --file ./app/VERSION

pre-build: gen-version
	echo "Pre-build"

# Runs on every push to the main branch
quick-build:
	east build -b custom_board app

# Runs on every PR and when doing releases
release:
	# Change east.yml to control what is built.
	east release

# Pre-package target is only run in release process.
pre-package:
	mkdir -p artefacts
	cp release/*.zip artefacts
	cp scripts/pre_changelog.md artefacts
	cp scripts/post_changelog.md artefacts

test:
	east twister -T tests --coverage -p native_sim --coverage-tool lcov

# Used to run twister on remote RPi with attached nRF52840DK
# The {RPI_IP} variable must be set in the environment using Github Secrets
test-remote:
	east twister -T tests -p custom_board --device-testing --device-serial-pty="scripts/rpi-jlink-server/twister_pty.py --host ${RPI_IP} --port 7777" --west-runner=jlink --west-flash="--tool-opt=ip ${RPI_IP}:7778"

test-report-ci:
	junit2html twister-out/twister.xml twister-out/twister-report.html

# Intended to be used by developer, use 'pip install junit2html' to install
# tooling
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

# CodeChecker section
# build and check targets are run on every push to the `main` and in PRs.
# store target is run only on the push to `main`.
# diff target is run only in PRs.
#
# Important: If building more projects, make sure to create separate build
# directories with -d flag, so they can be analyzed separately, see examples
# below.
codechecker-build:
	east build -b custom_board app -d build_app
	east build -b custom_board app -u debug -d build_debug

codechecker-check:
	east codechecker check -d build_app
	east codechecker check -d build_debug

codechecker-store:
	east codechecker store -d build_app
	east codechecker store -d build_debug

# Specify build folders that you want to analyze to the script as positional
# arguments, open it to learn more.
codechecker-diff:
	scripts/codechecker-diff.sh build_app build_debug
