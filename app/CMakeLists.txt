cmake_minimum_required(VERSION 3.13.1)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

zephyr_compile_definitions(CONFIG_BUILD_TYPE="${EAST_BUILD_TYPE}")

project(project)

target_sources(app PRIVATE src/main.c)
