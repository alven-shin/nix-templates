cmake_minimum_required(VERSION 3.15...3.31)

project(MyProject VERSION 0.1.0
                  DESCRIPTION "Very nice project"
                  LANGUAGES CXX)

# c++17 and no compiler extensions
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# for clangd and nix
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE INTERNAL
    "generate compile_commands.json for clangd")
if(CMAKE_EXPORT_COMPILE_COMMANDS)
    set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES
      "${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES}")
endif()

# Check if the build type is Release and enable LTO
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    include(CheckIPOSupported)
    check_ipo_supported(RESULT result)
    message(STATUS "LTO support: ${result}")
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION result CACHE INTERNAL "enable LTO")
endif()

# main executable
add_executable(MyProject
    src/main.cpp
)
