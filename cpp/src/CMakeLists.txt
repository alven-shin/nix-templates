# Note that headers are optional, and do not affect add_library, but they will not
# show up in IDEs unless they are listed in add_library.

# Optionally glob, but only for CMake 3.12 or later:
file(GLOB HEADER_LIST CONFIGURE_DEPENDS "${MyProject_SOURCE_DIR}/include/my_library/*.hpp")

# Make an automatic library - will be static or dynamic based on user setting
add_library(my_library
    lib.cpp
    ${HEADER_LIST}
)

# All users of this library will need at least C++11
target_compile_features(my_library PUBLIC cxx_std_17)

# We need this directory, and users of our library will need it too
target_include_directories(my_library PUBLIC ../include)

# IDEs should put the headers in a nice place
source_group(
  TREE "${PROJECT_SOURCE_DIR}/include"
  PREFIX "Header Files"
  FILES ${HEADER_LIST})
