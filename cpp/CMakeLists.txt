cmake_minimum_required(VERSION 3.15...3.31)

project(MyProject VERSION 0.1.0
                  DESCRIPTION "Very nice project"
                  LANGUAGES CXX)

# Only do these if this is the main project, and not if it is included through add_subdirectory
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    # Let's ensure -std=c++xx instead of -std=g++xx
    set(CMAKE_CXX_EXTENSIONS FALSE)

    # Let's nicely support folders in IDEs
    set_property(GLOBAL PROPERTY USE_FOLDERS TRUE)

    # for clangd and nix
    set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE CACHE INTERNAL "export compile_commands.json for clangd")
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
endif()

add_subdirectory(src)  # library
add_subdirectory(apps) # executables
