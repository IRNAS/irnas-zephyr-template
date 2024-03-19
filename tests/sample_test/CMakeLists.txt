# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(sample_test)

# Make a helper variable for the app directory
set(APP_DIR ../../app/main/src)

# Add source files with test code
file(GLOB app_sources src/*.c)
target_sources(app PRIVATE ${app_sources})

# Add module under the test

# This can be done in several ways:

# A. Add source files and header include directory via Cmake
#
# For example:
#
# target_include_directories(app PRIVATE ${APP_DIR}/some/path/header_dir)
#
# target_sources(app PRIVATE ${APP_DIR}/some/path/source_file.c)
#
# This is suitable if the module under test is a part of the application source
# directory
#
# B. Use Kconfig symbol to select the module under test inside the prj.conf.
#
# This way is used in this sample_test project. If the Kconfig symbol is not
# visible as a menuconfig option (it might only exist in the application source
# dir), can create a Kconfig file and source it from there, for example:
#
# rsource ../../app/main/src/some_subsys/some_module/Kconfig
