cmake_minimum_required(VERSION 3.13.1)

# create compile_commands.json for clang
set(CMAKE_EXPORT_COMPILE_COMMANDS on)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

project(project)

# We always want colored gcc output
zephyr_compile_options(-fdiagnostics-color=always)

target_sources(app PRIVATE src/main.c)
