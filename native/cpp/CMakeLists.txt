cmake_minimum_required(VERSION 3.20)
project(mylib VERSION 1.0.0 LANGUAGES CXX)

# vcpkg toolchain is injected automatically when CMAKE_TOOLCHAIN_FILE is set.
# See README.md for setup instructions.

add_library(mylib SHARED mylib.cpp)

target_compile_features(mylib PRIVATE cxx_std_17)

# Output directly to native/libs/ so Dart can load it without extra steps.
set_target_properties(mylib PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/../libs"
)
