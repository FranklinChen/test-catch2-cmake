# Modern C++23 with CMake 4+ and Catch2

![CI](https://github.com/FranklinChen/test-catch2-cmake/actions/workflows/ci.yml/badge.svg)

A demonstration project showcasing the latest features of CMake 4+, C++20/23, and modern compiler toolchains across Linux, macOS, and Windows.

## Project Goals

This project serves as a future-proof demonstration of:

- **CMake 4+**: Modern build system features (currently 4.1.2+)
- **C++23**: Latest finalized C++ standard (ISO/IEC 14882:2024)
- **Latest Compilers**: GCC 14 (Ubuntu), GCC 15.2 (macOS), and Clang/LLVM 21.1.5
- **Cross-Platform**: Ubuntu, macOS (with Homebrew compilers), Windows
- **Modern Testing**: Catch2 v3 with automatic test discovery

## Latest Verified Versions (2025)

| Component | Version | Release Date |
|-----------|---------|--------------|
| CMake | 4.1.2 (stable), 4.2.0-rc2 | Sep/Oct 2025 |
| GCC | 14.x (Ubuntu), 15.2 (macOS) | Ubuntu: official repos, macOS: Homebrew |
| Clang/LLVM | 21.1.5 | November 2025 |
| C++23 | ISO/IEC 14882:2024 | Finalized Feb 2023 |
| C++26 | In Development | Expected March 2026 |

## C++ Features Demonstrated

### C++20 Features
- **Concepts**: Type constraints for template parameters (`Numeric` concept)
- **Ranges**: Composable sequence operations with views and pipelines
- **Three-way Comparison**: Spaceship operator (`<=>`) for automatic comparison generation
- **Digit Separators**: Improved numeric literal readability (`1'000'000`)

### C++23 Features
- **Deducing this**: Explicit object parameters for CRTP-like patterns
- **std::expected**: Type-safe error handling without exceptions
- **std::print/println**: Modern formatted output (replaces printf/iostream)
- **Monadic Operations**: Chainable error handling with `and_then`, `or_else`

## Building the Project

### Prerequisites

**Ubuntu:**
```bash
sudo apt update
sudo apt install -y gcc-14 g++-14 cmake
```

**macOS (using Homebrew, NOT Apple Clang):**
```bash
# Install compilers and CMake
brew install gcc@15 llvm@21 cmake
```

**Windows:**
```powershell
# Install CMake from https://cmake.org/download/ or via winget
winget install Kitware.CMake
```

**Note:** Catch2 is automatically downloaded and built by CMake via FetchContent - no manual installation required!

### Build Commands

```bash
# Configure with specific compiler (Unix)
# Ubuntu uses gcc-14, macOS uses gcc-15
cmake -S . -B build \
  -DCMAKE_C_COMPILER=gcc-14 \
  -DCMAKE_CXX_COMPILER=g++-14 \
  -DCMAKE_BUILD_TYPE=Release

# Or with Clang
cmake -S . -B build \
  -DCMAKE_C_COMPILER=clang-21 \
  -DCMAKE_CXX_COMPILER=clang++-21 \
  -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build

# Run all tests
ctest --test-dir build --output-on-failure

# Run specific test categories
./build/tests "[cpp20]"    # C++20 features only
./build/tests "[cpp23]"    # C++23 features only
./build/tests "[concepts]" # Concepts tests only
```

## CI/CD Pipeline

The GitHub Actions workflow tests across multiple configurations:

- **Ubuntu 24.04**: GCC 14, Clang 21
- **macOS Latest**: Homebrew GCC 15, Homebrew LLVM 21 (NOT Apple Clang)
- **Windows Latest**: MSVC latest

All builds use CMake 4.1+ and verify compiler versions to ensure future-proofing.

**Compiler Installation:** The CI uses platform-native package managers (Ubuntu main repos for GCC 14, LLVM APT repository for Clang, Homebrew for macOS) for direct control and reliability, matching the local development setup documented above.

## Why These Choices?

**CMake 4+**: Major version bump with improved features and better modern C++ support.

**C++23**: Latest finalized standard with practical features like `std::expected`, `std::print`, and deducing this.

**Latest Compilers**: GCC 14+ and Clang 21 provide excellent C++23 support and early C++26 features.

**Homebrew on macOS**: Apple Clang lags behind in C++ standard support; Homebrew provides true GCC and latest LLVM/Clang.

**Catch2**: Modern, header-only (or compiled) testing framework with excellent C++20/23 support.

## Code Examples

See `test.cpp` for detailed demonstrations of:
- Concepts with the `Numeric` concept
- Spaceship operator for automatic comparisons
- Deducing this for method chaining
- std::expected for error handling
- Ranges and views for functional-style operations
- std::print for modern formatted output

## Development Notes

- The project uses `catch_discover_tests()` for automatic test discovery
- Compiler warnings are enabled (`-Wall -Wextra -Wpedantic`)
- Build type should be set to `Release` for optimal performance
- Tests are tagged by feature category for selective execution
- **macOS ABI Compatibility**: Catch2 must be built from source with the same compiler. Homebrew's catch2 is built with Apple Clang (libc++), which is ABI-incompatible with GCC's libstdc++

## Maintenance & Version Updates

This repository is designed to stay current with the latest compiler versions through automated tooling.

### Automated Version Checking

A GitHub Actions workflow runs monthly to check for new compiler versions:
- **Workflow**: `.github/workflows/version-check.yml`
- **Schedule**: 1st of every month at 9 AM UTC
- **Action**: Creates/updates a GitHub issue when new versions are detected

You can also trigger the check manually from the GitHub Actions tab.

### Manual Version Updates

To update to the latest compiler versions:

1. **Check for updates:**
   ```bash
   ./scripts/check-latest-versions.sh
   ```

2. **Apply updates:**
   ```bash
   ./scripts/update-versions.sh
   ```

3. **Test and commit:**
   ```bash
   cmake -S . -B build && cmake --build build && ctest --test-dir build
   git add -A && git commit -m "Update to latest compiler versions"
   ```

The update script automatically modifies:
- `CMakeLists.txt` - CMake requirements and version documentation
- `README.md` - Version table and inline references
- `CLAUDE.md` - Version documentation
- `test.cpp` - Test output messages
- `.github/workflows/ci.yml` - CI compiler matrix

See `scripts/README.md` for detailed documentation.

## License

This is a demonstration project. Use freely for learning and reference.
