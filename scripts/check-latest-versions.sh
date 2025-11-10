#!/usr/bin/env bash
# Check for latest versions of CMake, GCC, Clang, and C++ standards
# This script queries official sources and reports the latest available versions

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   Latest Version Checker${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Function to check CMake version
check_cmake_version() {
    echo -e "${YELLOW}Checking CMake...${NC}"

    # Try to get latest from GitHub API
    if command -v curl &> /dev/null; then
        LATEST_CMAKE=$(curl -s https://api.github.com/repos/Kitware/CMake/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

        if [ -n "$LATEST_CMAKE" ]; then
            echo -e "  Latest CMake: ${GREEN}${LATEST_CMAKE}${NC}"
            echo "$LATEST_CMAKE"
            return 0
        fi
    fi

    echo -e "  ${RED}Could not determine latest CMake version${NC}"
    echo "unknown"
}

# Function to check GCC version
check_gcc_version() {
    echo -e "${YELLOW}Checking GCC...${NC}"

    # GCC releases are on their FTP server
    # We'll try to parse the main page for the latest stable release
    if command -v curl &> /dev/null; then
        # Get the latest from the releases page (compatible with macOS grep)
        LATEST_GCC=$(curl -s https://gcc.gnu.org/releases.html | grep -o 'GCC [0-9]\+\.[0-9]\+' | head -1 | sed 's/GCC //')

        if [ -n "$LATEST_GCC" ]; then
            echo -e "  Latest GCC: ${GREEN}${LATEST_GCC}${NC}"
            echo "$LATEST_GCC"
            return 0
        fi
    fi

    echo -e "  ${RED}Could not determine latest GCC version${NC}"
    echo "unknown"
}

# Function to check Clang/LLVM version
check_clang_version() {
    echo -e "${YELLOW}Checking Clang/LLVM...${NC}"

    # Try to get latest from GitHub API (compatible with macOS grep)
    if command -v curl &> /dev/null; then
        LATEST_CLANG=$(curl -s https://api.github.com/repos/llvm/llvm-project/releases | grep '"tag_name":' | grep -o 'llvmorg-[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 | sed 's/llvmorg-//')

        if [ -n "$LATEST_CLANG" ]; then
            echo -e "  Latest Clang/LLVM: ${GREEN}${LATEST_CLANG}${NC}"
            echo "$LATEST_CLANG"
            return 0
        fi
    fi

    echo -e "  ${RED}Could not determine latest Clang version${NC}"
    echo "unknown"
}

# Function to check C++ standard status
check_cpp_standard() {
    echo -e "${YELLOW}Checking C++ Standard...${NC}"

    # C++ standards are predictable: C++26 is being worked on now
    CURRENT_YEAR=$(date +%Y)
    CURRENT_STANDARD="C++23 (ISO/IEC 14882:2024) - Finalized"
    NEXT_STANDARD="C++26 - In Development (expected March 2026)"

    echo -e "  Current: ${GREEN}${CURRENT_STANDARD}${NC}"
    echo -e "  Next:    ${BLUE}${NEXT_STANDARD}${NC}"
}

# Main execution
echo "Checking latest versions from official sources..."
echo ""

# Check CMake (capture only the return value, show output to user)
check_cmake_version > /tmp/cmake_check.tmp
CMAKE_VERSION=$(tail -1 /tmp/cmake_check.tmp)
cat /tmp/cmake_check.tmp
echo ""

# Check GCC
check_gcc_version > /tmp/gcc_check.tmp
GCC_VERSION=$(tail -1 /tmp/gcc_check.tmp)
cat /tmp/gcc_check.tmp
echo ""

# Check Clang
check_clang_version > /tmp/clang_check.tmp
CLANG_VERSION=$(tail -1 /tmp/clang_check.tmp)
cat /tmp/clang_check.tmp
echo ""

check_cpp_standard
echo ""

# Output summary
echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   Summary${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""
echo "CMake:      $CMAKE_VERSION"
echo "GCC:        $GCC_VERSION"
echo "Clang/LLVM: $CLANG_VERSION"
echo "C++ Std:    C++23 (finalized), C++26 (in development)"
echo ""

# Write to a machine-readable file
VERSIONS_FILE="$(dirname "$0")/latest-versions.txt"
cat > "$VERSIONS_FILE" <<EOF
# Latest versions detected on $(date)
CMAKE_VERSION=$CMAKE_VERSION
GCC_VERSION=$GCC_VERSION
CLANG_VERSION=$CLANG_VERSION
CPP_STANDARD=23
CPP_NEXT=26
EOF

echo -e "${GREEN}Version information saved to: ${VERSIONS_FILE}${NC}"
echo ""
echo -e "${YELLOW}To update the repository with these versions, run:${NC}"
echo -e "  ${BLUE}./scripts/update-versions.sh${NC}"
