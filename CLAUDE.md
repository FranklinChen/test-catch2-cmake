# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a demonstration project showcasing modern CMake 4+, C++20/23 features with Catch2 testing framework across all major platforms (Linux, macOS, Windows). The project serves as a future-proof reference for the latest C++ language features and compiler toolchains.

## Verified Versions (November 2025)

| Component | Version | Notes |
|-----------|---------|-------|
| CMake | 4.1.2 (stable), 4.2.0-rc2 | Latest major version |
| GCC | 15.x | Latest available per platform |
| Clang/LLVM | 21.x | Latest stable |
| C++23 | ISO/IEC 14882:2024 | Finalized standard |
| C++26 | In Development | Expected March 2026 |
| Catch2 | v3+ | Modern testing framework |

## Build System (CMakeLists.txt)

- **CMake Version**: Requires 4.0 minimum (CMakeLists.txt:3)
- **C++ Standard**: C++23 set via `target_compile_features(tests PRIVATE cxx_std_23)` (CMakeLists.txt:40)
- **Testing Framework**: Catch2 v3.7.1 fetched automatically via CMake FetchContent (CMakeLists.txt:22-31)
- **Compiler Flags**: Platform-specific warnings enabled (CMakeLists.txt:43-47)
- **Automatic Dependencies**: No manual Catch2 installation needed - CMake downloads and builds it

## Building and Testing

### Standard Workflow

```bash
# Configure with specific compiler (use gcc-15 on all platforms)
cmake -S . -B build \
  -DCMAKE_C_COMPILER=gcc-15 \
  -DCMAKE_CXX_COMPILER=g++-15 \
  -DCMAKE_BUILD_TYPE=Release

# For Clang on Ubuntu (with libc++)
# export CXXFLAGS="-stdlib=libc++" LDFLAGS="-stdlib=libc++ -lc++abi"
# cmake -S . -B build \
#   -DCMAKE_C_COMPILER=clang-21 \
#   -DCMAKE_CXX_COMPILER=clang++-21 \
#   -DCMAKE_BUILD_TYPE=Release

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
# Add repositories
sudo add-apt-repository ppa:ubuntu-toolchain-r/ppa -y
wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
sudo add-apt-repository "deb http://apt.llvm.org/noble/ llvm-toolchain-noble-21 main" -y
sudo apt update

# Install GCC 15 (latest available on Ubuntu)
sudo apt install -y gcc-15 g++-15

# Install Clang 21 with libc++ (required for C++23 compatibility)
sudo apt install -y clang-21 libc++-21-dev libc++abi-21-dev

# Install CMake
sudo apt install -y cmake
```

**macOS (Homebrew compilers, NOT Apple Clang):**
```bash
# Install compilers and CMake
brew install gcc@15 llvm@21 cmake

# Build with Homebrew GCC
cmake -S . -B build -DCMAKE_CXX_COMPILER=g++-15

# Or build with Homebrew LLVM
cmake -S . -B build -DCMAKE_CXX_COMPILER=/opt/homebrew/opt/llvm/bin/clang++
```

**Windows:**
```powershell
# Install CMake (or use installer from cmake.org)
winget install Kitware.CMake

# Configure (MSVC detected automatically)
cmake -S . -B build
```

**Note:** Catch2 is automatically downloaded and built by CMake via FetchContent - no manual installation required on any platform!

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

- `.github/workflows/ci.yml`: Multi-compiler, multi-platform CI matrix testing GCC 14/15, Clang 21, and MSVC

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
- GCC 15.x
- Clang 21.x (with libc++)

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

1. **Platform-Specific Compiler Versions**:
   - Ubuntu uses GCC 15 (latest available in ubuntu-toolchain-r/ppa PPA)
   - macOS uses GCC 15 (available via Homebrew)
   - Both platforms support C++23 features fully

2. **Clang libc++ Requirement on Linux**: Clang 21 on Ubuntu must use libc++ instead of libstdc++ to avoid C++23 compatibility issues with ranges and std::forward_like. The CI workflow sets `CXXFLAGS="-stdlib=libc++"` and `LDFLAGS="-stdlib=libc++ -lc++abi"` automatically for Clang builds on Linux.

3. **Compiler Selection on macOS**: The project explicitly uses Homebrew-installed GCC/Clang, not Apple Clang, because Apple Clang has incomplete C++23 support. CI workflow specifies full paths like `/opt/homebrew/opt/llvm/bin/clang++`.

4. **Automatic Dependency Management**: Catch2 v3.7.1 is automatically fetched and built via CMake's FetchContent module. This eliminates platform-specific installation steps and ensures ABI compatibility by building Catch2 with the same compiler used for the tests. No manual installation required on any platform.

5. **Feature Availability**: Some C++23 features (like std::print, std::expected) may have varying support. The tests are designed to verify feature availability.

6. **CMake 4 Features**: The CMakeLists.txt uses modern CMake patterns including FetchContent for dependencies, generator expressions for compiler-specific flags, and explicit project metadata.

7. **Test Discovery**: Tests are automatically discovered via Catch2's `catch_discover_tests()` and tagged by feature for selective execution.

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
