# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a demonstration project showcasing modern CMake 4+, C++20/23 features with Catch2 testing framework across all major platforms (Linux, macOS, Windows). The project serves as a future-proof reference for the latest C++ language features and compiler toolchains.

## Verified Versions (November 2025)

| Component | Version | Notes |
|-----------|---------|-------|
| CMake | 4.1.2 (stable), 4.2.0-rc2 | Latest major version |
| GCC | 15.2 | Released April 2025 |
| Clang/LLVM | 21.1.5 | Released November 2025 |
| C++23 | ISO/IEC 14882:2024 | Finalized standard |
| C++26 | In Development | Expected March 2026 |
| Catch2 | v3+ | Modern testing framework |

## Build System (CMakeLists.txt)

- **CMake Version**: Requires 4.0 minimum (CMakeLists.txt:3)
- **C++ Standard**: C++23 set via `target_compile_features(tests PRIVATE cxx_std_23)` (CMakeLists.txt:32)
- **Testing Framework**: Catch2 v3 with automatic test discovery via `catch_discover_tests()` (CMakeLists.txt:46-50)
- **Compiler Flags**: Platform-specific warnings enabled (CMakeLists.txt:35-39)

## Building and Testing

### Standard Workflow

```bash
# Configure with specific compiler
cmake -S . -B build \
  -DCMAKE_C_COMPILER=gcc-15 \
  -DCMAKE_CXX_COMPILER=g++-15 \
  -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build

# Run all tests
ctest --test-dir build --output-on-failure

# Run tests by feature category
./build/tests "[cpp20]"       # C++20 features only
./build/tests "[cpp23]"       # C++23 features only
./build/tests "[concepts]"    # Concepts tests
./build/tests "[expected]"    # std::expected tests
./build/tests "[ranges]"      # Ranges tests
```

### Platform-Specific Setup

**Ubuntu:**
```bash
sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
sudo apt update
sudo apt install -y gcc-15 g++-15 clang-21 catch2 cmake
```

**macOS (Homebrew compilers, NOT Apple Clang):**
```bash
brew install gcc@15 llvm@21 catch2 cmake

# Use Homebrew GCC
cmake -S . -B build -DCMAKE_CXX_COMPILER=g++-15

# Or Homebrew LLVM
cmake -S . -B build -DCMAKE_CXX_COMPILER=/opt/homebrew/opt/llvm/bin/clang++
```

**Windows:**
```powershell
vcpkg install catch2
cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake
```

## Architecture

Single-file demonstration with comprehensive feature coverage:

- `test.cpp`: C++20/23 feature demonstrations with test cases
  - Concepts (lines 22-28)
  - Spaceship operator (lines 35-42)
  - Deducing this (lines 49-63)
  - std::expected (lines 75-80)
  - Ranges (lines 87-93)
  - std::print (used in tests)

- `CMakeLists.txt`: Modern CMake 4+ build configuration with documented version requirements

- `.github/workflows/ci.yml`: Multi-compiler, multi-platform CI matrix testing GCC 15, Clang 21, and MSVC

## C++ Features Demonstrated

**C++20:**
- Concepts for type constraints (`Numeric` concept)
- Ranges with views and pipelines
- Three-way comparison (spaceship operator `<=>`)
- Digit separators in numeric literals

**C++23:**
- Deducing this (explicit object parameters)
- std::expected for type-safe error handling
- std::print/println for formatted output
- Monadic operations (and_then, or_else)

## CI/CD Configuration

The GitHub Actions workflow (.github/workflows/ci.yml) runs a comprehensive test matrix:

**Ubuntu 24.04:**
- GCC 15.2
- Clang 21.1.5

**macOS Latest:**
- Homebrew GCC 15 (NOT Apple Clang)
- Homebrew LLVM 21 (NOT Apple Clang)

**Windows Latest:**
- MSVC (latest)

All builds:
- Use CMake 4.1+
- Verify compiler versions
- Run with Release configuration
- Execute tagged test subsets

## Key Implementation Notes

1. **Compiler Selection on macOS**: The project explicitly uses Homebrew-installed GCC/Clang, not Apple Clang, because Apple Clang has incomplete C++23 support. CI workflow specifies full paths like `/opt/homebrew/opt/llvm/bin/clang++`.

2. **Feature Availability**: Some C++23 features (like std::print, std::expected) may have varying support. The tests are designed to verify feature availability.

3. **CMake 4 Features**: The CMakeLists.txt uses modern CMake patterns including generator expressions for compiler-specific flags and explicit project metadata.

4. **Test Discovery**: Tests are automatically discovered via Catch2's `catch_discover_tests()` and tagged by feature for selective execution.

## Maintenance & Version Updates

The repository includes automation for keeping compiler versions current:

### Automated Checks

- **GitHub Action**: `.github/workflows/version-check.yml` runs monthly
- **Schedule**: 1st of month at 9 AM UTC (or manual trigger)
- **Result**: Creates/updates GitHub issue when new versions detected

### Manual Updates

Use the maintenance scripts in `scripts/`:

```bash
# Check for latest versions
./scripts/check-latest-versions.sh

# Apply updates to all files
./scripts/update-versions.sh
```

The update script modifies:
- CMakeLists.txt (version requirements and comments)
- README.md (version table and references)
- CLAUDE.md (this file)
- test.cpp (test output messages)
- .github/workflows/ci.yml (compiler matrix)

See `scripts/README.md` for detailed documentation.

### Version Sources

- **CMake**: GitHub API (Kitware/CMake releases)
- **GCC**: gcc.gnu.org releases page
- **Clang/LLVM**: GitHub API (llvm/llvm-project releases)
- **C++ Standards**: ISO/IEC schedule (hardcoded)

## Future Enhancements

When C++26 is finalized (expected March 2026), consider adding:
- Reflection examples
- Contracts (if available)
- Pattern matching enhancements
- Additional concurrency features (std::execution)

Then run `./scripts/check-latest-versions.sh` to detect and update to C++26.
