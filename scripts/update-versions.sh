#!/usr/bin/env bash
# Update version references throughout the repository
# This script reads from latest-versions.txt and updates all relevant files

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSIONS_FILE="$SCRIPT_DIR/latest-versions.txt"

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   Version Update Tool${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Check if versions file exists
if [ ! -f "$VERSIONS_FILE" ]; then
    echo -e "${RED}Error: $VERSIONS_FILE not found${NC}"
    echo "Please run ./scripts/check-latest-versions.sh first"
    exit 1
fi

# Source the versions
source "$VERSIONS_FILE"

echo "Reading versions from $VERSIONS_FILE"
echo ""
echo "  CMake:      $CMAKE_VERSION"
echo "  GCC:        $GCC_VERSION"
echo "  Clang/LLVM: $CLANG_VERSION"
echo "  C++ Std:    C++$CPP_STANDARD"
echo ""

# Confirm with user
read -p "Update repository files with these versions? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Update cancelled."
    exit 0
fi

echo ""
echo -e "${YELLOW}Updating files...${NC}"

# Function to update file with sed (macOS and Linux compatible)
update_file() {
    local file=$1
    local pattern=$2
    local replacement=$3

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "$pattern" "$file"
    else
        # Linux
        sed -i "$pattern" "$file"
    fi
}

# Update CMakeLists.txt
echo "  Updating CMakeLists.txt..."
CMAKE_MAJOR=$(echo "$CMAKE_VERSION" | cut -d. -f1)
CMAKE_MINOR=$(echo "$CMAKE_VERSION" | cut -d. -f2)

# Update minimum required version comment
update_file "$REPO_ROOT/CMakeLists.txt" \
    "s/# Requires CMake .* or higher for latest features/# Requires CMake $CMAKE_MAJOR.0 or higher for latest features/g"

# Update cmake_minimum_required line
update_file "$REPO_ROOT/CMakeLists.txt" \
    "s/cmake_minimum_required(VERSION [0-9]\+\.[0-9]\+\.\.\.[0-9]\+\.[0-9]\+)/cmake_minimum_required(VERSION $CMAKE_MAJOR.0...$CMAKE_VERSION)/g"

# Extract GCC major version
GCC_MAJOR=$(echo "$GCC_VERSION" | cut -d. -f1)

# Update compiler version comments in CMakeLists.txt
update_file "$REPO_ROOT/CMakeLists.txt" \
    "s/# GCC: .* (released .*)$/# GCC: $GCC_VERSION (verified $(date +%B\ %Y))/g"

update_file "$REPO_ROOT/CMakeLists.txt" \
    "s/# Clang: .* (released .*)$/# Clang: $CLANG_VERSION (verified $(date +%B\ %Y))/g"

update_file "$REPO_ROOT/CMakeLists.txt" \
    "s/# CMake: .* stable.*$/# CMake: $CMAKE_VERSION (verified $(date +%B\ %Y))/g"

# Update README.md
echo "  Updating README.md..."

# Update version table
update_file "$REPO_ROOT/README.md" \
    "s/| CMake | .* | .* |/| CMake | $CMAKE_VERSION | $(date +%B\ %Y) |/g"

update_file "$REPO_ROOT/README.md" \
    "s/| GCC | .* | .* |/| GCC | $GCC_VERSION | $(date +%B\ %Y) |/g"

update_file "$REPO_ROOT/README.md" \
    "s/| Clang\/LLVM | .* | .* |/| Clang\/LLVM | $CLANG_VERSION | $(date +%B\ %Y) |/g"

# Update inline version mentions
update_file "$REPO_ROOT/README.md" \
    "s/GCC [0-9]\+\.[0-9]\+ and Clang\/LLVM [0-9]\+\.[0-9]\+\.[0-9]\+/GCC $GCC_VERSION and Clang\/LLVM $CLANG_VERSION/g"

update_file "$REPO_ROOT/README.md" \
    "s/gcc-[0-9]\+/gcc-$GCC_MAJOR/g"

update_file "$REPO_ROOT/README.md" \
    "s/g\+\+-[0-9]\+/g++-$GCC_MAJOR/g"

CLANG_MAJOR=$(echo "$CLANG_VERSION" | cut -d. -f1)
update_file "$REPO_ROOT/README.md" \
    "s/clang-[0-9]\+/clang-$CLANG_MAJOR/g"

update_file "$REPO_ROOT/README.md" \
    "s/clang\+\+-[0-9]\+/clang++-$CLANG_MAJOR/g"

update_file "$REPO_ROOT/README.md" \
    "s/llvm@[0-9]\+/llvm@$CLANG_MAJOR/g"

update_file "$REPO_ROOT/README.md" \
    "s/gcc@[0-9]\+/gcc@$GCC_MAJOR/g"

# Update test.cpp output messages
echo "  Updating test.cpp..."
update_file "$REPO_ROOT/test.cpp" \
    "s/Testing C\+\+23 features with GCC .* \/ Clang .*/Testing C++23 features with GCC $GCC_VERSION \/ Clang $CLANG_VERSION/g"

update_file "$REPO_ROOT/test.cpp" \
    "s/CMake version: .*/CMake version: $CMAKE_VERSION+/g"

# Update CLAUDE.md
echo "  Updating CLAUDE.md..."

# Update version table in CLAUDE.md
update_file "$REPO_ROOT/CLAUDE.md" \
    "s/| CMake | .* | .* |/| CMake | $CMAKE_VERSION | Latest major version |/g"

update_file "$REPO_ROOT/CLAUDE.md" \
    "s/| GCC | .* | .* |/| GCC | $GCC_VERSION | Verified $(date +%B\ %Y) |/g"

update_file "$REPO_ROOT/CLAUDE.md" \
    "s/| Clang\/LLVM | .* | .* |/| Clang\/LLVM | $CLANG_VERSION | Verified $(date +%B\ %Y) |/g"

# Update inline version references
update_file "$REPO_ROOT/CLAUDE.md" \
    "s/GCC [0-9]\+\.[0-9]\+/GCC $GCC_VERSION/g"

update_file "$REPO_ROOT/CLAUDE.md" \
    "s/Clang [0-9]\+\.[0-9]\+\.[0-9]\+/Clang $CLANG_VERSION/g"

update_file "$REPO_ROOT/CLAUDE.md" \
    "s/CMake [0-9]\+\.[0-9]\+/CMake $CMAKE_VERSION/g"

# Update CI workflow
echo "  Updating .github/workflows/ci.yml..."

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/# Ubuntu with GCC .* (latest)/# Ubuntu with GCC $GCC_MAJOR (latest)/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/# Ubuntu with Clang .* (latest)/# Ubuntu with Clang $CLANG_MAJOR (latest)/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/# macOS with Homebrew GCC .* (NOT Apple Clang)/# macOS with Homebrew GCC $GCC_MAJOR (NOT Apple Clang)/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/# macOS with Homebrew Clang\/LLVM .* (NOT Apple Clang)/# macOS with Homebrew Clang\/LLVM $CLANG_MAJOR (NOT Apple Clang)/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/gcc-[0-9]\+/gcc-$GCC_MAJOR/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/g\+\+-[0-9]\+/g++-$GCC_MAJOR/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/clang-[0-9]\+/clang-$CLANG_MAJOR/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/clang\+\+-[0-9]\+/clang++-$CLANG_MAJOR/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/llvm@[0-9]\+/llvm@$CLANG_MAJOR/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/gcc@[0-9]\+/gcc@$GCC_MAJOR/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/\"Expected: GCC .* or Clang .*\"/\"Expected: GCC $GCC_VERSION or Clang $CLANG_VERSION\"/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/\"Expected: CMake .*\"/\"Expected: CMake $CMAKE_VERSION+\"/g"

update_file "$REPO_ROOT/.github/workflows/ci.yml" \
    "s/cmakeVersion: \"~[0-9]\+\.[0-9]\+\.[0-9]\+\"/cmakeVersion: \"~$CMAKE_VERSION\"/g"

echo ""
echo -e "${GREEN}✓ All files updated successfully!${NC}"
echo ""
echo -e "${YELLOW}Updated files:${NC}"
echo "  - CMakeLists.txt"
echo "  - README.md"
echo "  - CLAUDE.md"
echo "  - test.cpp"
echo "  - .github/workflows/ci.yml"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review changes: git diff"
echo "  2. Test build: cmake -S . -B build && cmake --build build"
echo "  3. Run tests: ctest --test-dir build"
echo "  4. Commit changes: git add -A && git commit -m 'Update to latest compiler versions'"
