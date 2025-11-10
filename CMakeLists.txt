# Modern CMake 4+ demonstration project
# Requires CMake 4.0 or higher for latest features
cmake_minimum_required(VERSION 4.0...4.2)

# Project declaration with version and description (CMake 3.0+ feature)
project(TestCatch2CMake
    VERSION 1.0.0
    DESCRIPTION "Modern C++23 demonstration with Catch2 and CMake 4+"
    LANGUAGES CXX
)

# Document latest verified compiler versions (as of November 2025)
# GCC: 14.x (Ubuntu), 15.x (macOS) - latest available per platform
# Clang: 21.x (uses libc++ on Linux for C++23 compatibility)
# CMake: 4.1.2 stable, 4.2.0-rc2 available
# C++23: Finalized (ISO/IEC 14882:2024)
# C++26: In development, expected finalization March 2026

# Enable testing
enable_testing()

# Fetch Catch2 from GitHub using FetchContent (CMake 3.11+ feature)
# This ensures consistent versions across all platforms and compilers
include(FetchContent)
FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG v3.7.1
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(Catch2)

# Create test executable
add_executable(tests test.cpp)

# Link against Catch2 with main
target_link_libraries(tests PRIVATE Catch2::Catch2WithMain)

# Set C++ standard to C++23 (latest finalized standard)
target_compile_features(tests PRIVATE cxx_std_23)

# Enable compiler-specific warnings and optimizations
target_compile_options(tests PRIVATE
    $<$<CXX_COMPILER_ID:GNU>:-Wall -Wextra -Wpedantic -fconcepts-diagnostics-depth=3>
    $<$<CXX_COMPILER_ID:Clang>:-Wall -Wextra -Wpedantic>
    $<$<CXX_COMPILER_ID:MSVC>:/W4 /permissive->
)

# Include CTest module for test infrastructure
include(CTest)

# Include Catch2 test discovery
include(Catch)
catch_discover_tests(tests
    EXTRA_ARGS --benchmark-samples=10
    PROPERTIES
        LABELS "unit"
)
