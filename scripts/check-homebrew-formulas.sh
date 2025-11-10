#!/usr/bin/env bash
# Check if specific compiler versions are available in Homebrew
# This ensures that the versions we want to use are actually installable

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   Homebrew Formula Checker${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${YELLOW}This script is for macOS only.${NC}"
    echo "On Linux, use package managers like apt or build from source."
    exit 0
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}Homebrew is not installed.${NC}"
    echo "Install from: https://brew.sh"
    exit 1
fi

echo "Checking available compiler formulas in Homebrew..."
echo ""

# Function to check if a formula exists
check_formula() {
    local formula=$1
    local name=$2

    if brew info "$formula" &> /dev/null; then
        # Get the version
        VERSION=$(brew info "$formula" | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
        echo -e "  ${GREEN}✓${NC} $name: ${BLUE}$formula${NC} (version $VERSION)"
        return 0
    else
        echo -e "  ${RED}✗${NC} $name: ${BLUE}$formula${NC} (not available)"
        return 1
    fi
}

# Check GCC formulas
echo -e "${YELLOW}GCC Formulas:${NC}"
check_formula "gcc@15" "GCC 15" || true
check_formula "gcc@14" "GCC 14" || true
check_formula "gcc@13" "GCC 13" || true
check_formula "gcc" "GCC (latest)" || true
echo ""

# Check LLVM/Clang formulas
echo -e "${YELLOW}LLVM/Clang Formulas:${NC}"
check_formula "llvm@21" "LLVM 21" || true
check_formula "llvm@18" "LLVM 18" || true
check_formula "llvm@17" "LLVM 17" || true
check_formula "llvm" "LLVM (latest)" || true
echo ""

# Check CMake
echo -e "${YELLOW}Build Tools:${NC}"
check_formula "cmake" "CMake" || true
check_formula "catch2" "Catch2" || true
echo ""

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   Recommendations${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

echo "To install a specific compiler version:"
echo ""
echo "  ${BLUE}# GCC 15${NC}"
echo "  brew install gcc@15"
echo ""
echo "  ${BLUE}# LLVM/Clang 21${NC}"
echo "  brew install llvm@21"
echo ""
echo "After installation, compilers are available at:"
echo "  - GCC: /opt/homebrew/bin/gcc-15 and /opt/homebrew/bin/g++-15"
echo "  - Clang: /opt/homebrew/opt/llvm@21/bin/clang and clang++"
echo ""
echo "Use with CMake:"
echo "  cmake -S . -B build -DCMAKE_CXX_COMPILER=/opt/homebrew/bin/g++-15"
echo "  cmake -S . -B build -DCMAKE_CXX_COMPILER=/opt/homebrew/opt/llvm@21/bin/clang++"
