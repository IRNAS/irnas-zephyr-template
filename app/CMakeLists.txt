cmake_minimum_required(VERSION 3.20.0)

# Use conf as location of configuration files, to declutter the app folder
set(APPLICATION_CONFIG_DIR "${CMAKE_CURRENT_LIST_DIR}/conf")

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})

project(project)

target_sources(app PRIVATE src/main.c)
