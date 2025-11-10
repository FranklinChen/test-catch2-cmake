# Maintenance Guide

This guide explains how to keep the repository updated with the latest compiler versions.

## Quick Start

```bash
# Check for latest versions
./scripts/check-latest-versions.sh

# (macOS only) Verify Homebrew formulas available
./scripts/check-homebrew-formulas.sh

# Apply updates
./scripts/update-versions.sh

# Verify changes
git diff

# Test build
cmake -S . -B build && cmake --build build && ctest --test-dir build

# Commit
git add -A && git commit -m "Update to latest compiler versions"
```

## Automated Monitoring

### GitHub Actions Workflow

The repository includes `.github/workflows/version-check.yml` that:

1. **Runs monthly** on the 1st at 9 AM UTC
2. **Can be triggered manually** from GitHub Actions tab
3. **Creates/updates a GitHub issue** when new versions are detected
4. **Provides step-by-step update instructions** in the issue

### How to Trigger Manual Check

1. Go to your repository on GitHub
2. Click **Actions** tab
3. Select **Version Check** workflow
4. Click **Run workflow** button
5. Wait for completion (~1-2 minutes)
6. Check **Issues** tab for update notifications

## Version Check Script

**Location:** `scripts/check-latest-versions.sh`

**What it does:**
- Queries GitHub API for CMake releases
- Scrapes gcc.gnu.org for GCC versions
- Queries GitHub API for Clang/LLVM releases
- Reports current C++ standard status

**Output:**
- Console report with colored output
- `scripts/latest-versions.txt` - machine-readable version data

**Requirements:**
- `curl` command
- Internet connection
- No authentication needed (uses public APIs)

## Update Script

**Location:** `scripts/update-versions.sh`

**What it does:**
Automatically updates version references in:
- `CMakeLists.txt` - Version requirements and comments
- `README.md` - Version table and all inline references
- `CLAUDE.md` - Documentation version table
- `test.cpp` - Test output messages
- `.github/workflows/ci.yml` - CI compiler matrix

**Safety features:**
- Reads from `latest-versions.txt` (must run check script first)
- Shows version summary before applying changes
- Asks for confirmation (y/N)
- Uses macOS/Linux compatible `sed` commands
- Preserves file structure and only updates version numbers

**Compatibility:**
- Works on macOS (BSD sed)
- Works on Linux (GNU sed)
- Automatically detects OS and uses correct syntax

## Homebrew on macOS

Homebrew provides versioned formulas for compilers that are pinned to specific major versions:

- `gcc@15` - GCC 15.x (stays on 15, receives minor/patch updates)
- `gcc@14` - GCC 14.x
- `llvm@21` - LLVM/Clang 21.x
- `llvm@18` - LLVM/Clang 18.x

**Why versioned formulas matter:**
- Predictable: Major version stays constant
- Up-to-date: Receives security patches and bug fixes
- Parallel installation: Can have multiple versions installed
- Better C++ support: Apple Clang lags behind in C++23/26 features

**Check available formulas:**
```bash
./scripts/check-homebrew-formulas.sh
```

**Install specific version:**
```bash
brew install gcc@15 llvm@21
```

**Use with CMake:**
```bash
# GCC from Homebrew
cmake -S . -B build -DCMAKE_CXX_COMPILER=/opt/homebrew/bin/g++-15

# LLVM from Homebrew
cmake -S . -B build -DCMAKE_CXX_COMPILER=/opt/homebrew/opt/llvm@21/bin/clang++
```

## GitHub Actions Setup

The CI workflow uses `aminya/setup-cpp` action for cross-platform compiler installation:

```yaml
- name: Install GCC 15
  uses: aminya/setup-cpp@v1
  with:
    compiler: gcc
    version: 15
```

**Benefits:**
- Works across Ubuntu, macOS, and Windows
- Handles package manager differences automatically
- Supports specific version pinning
- Manages compiler paths and environment variables
- More reliable than manual installation scripts

**Supported compilers:**
- GCC (Linux, macOS via Homebrew, Windows via MinGW)
- LLVM/Clang (all platforms)
- MSVC (Windows)

## Version Sources

| Component | Source | Update Frequency |
|-----------|--------|------------------|
| CMake | GitHub Kitware/CMake releases | Monthly (patch), Quarterly (minor) |
| GCC | gcc.gnu.org/releases.html | Annual (major), Quarterly (minor) |
| Clang/LLVM | GitHub llvm/llvm-project releases | Bi-annual (major), Monthly (patch) |
| C++ Standard | ISO/IEC schedule | Every 3 years (C++20, C++23, C++26) |
| Homebrew | brew.sh formulae | Continuous (follows upstream) |

## Troubleshooting

### "latest-versions.txt not found"

**Solution:** Run `./scripts/check-latest-versions.sh` first.

### "Could not determine latest version"

**Possible causes:**
- Network connectivity issues
- API rate limiting (GitHub: 60 requests/hour unauthenticated)
- Website structure changed

**Solutions:**
1. Check internet connection
2. Wait 1 hour for GitHub API rate limit reset
3. Check if you can access the URLs manually:
   - https://api.github.com/repos/Kitware/CMake/releases/latest
   - https://gcc.gnu.org/releases.html
   - https://api.github.com/repos/llvm/llvm-project/releases

### Update script makes unexpected changes

**Prevention:**
- Always review with `git diff` before committing
- Test build after updating
- Can revert with `git checkout .` if needed

**If pattern matching fails:**
The update script uses `sed` with specific patterns. If version format changes (e.g., GCC 15 → GCC 16.0), patterns might need adjustment.

## File Patterns Updated

The update script modifies these specific patterns:

### CMakeLists.txt
- `cmake_minimum_required(VERSION x.x...x.x)` → uses latest CMake version
- `# GCC: x.x (released Month Year)` → updates comment
- `# Clang: x.x.x (released Month Year)` → updates comment
- `# CMake: x.x.x` → updates comment

### README.md and CLAUDE.md
- Version tables: `| CMake | x.x.x | ... |`
- Inline references: `GCC x.x`, `Clang x.x.x`, `CMake x.x`
- Package names: `gcc-15`, `g++-15`, `clang-21`, `gcc@15`, `llvm@21`

### test.cpp
- `Testing C++23 features with GCC x.x / Clang x.x.x`
- `CMake version: x.x.x+`

### .github/workflows/ci.yml
- Compiler matrix entries: `gcc-15`, `g++-15`, `clang-21`, etc.
- Expected version messages
- Homebrew package names

## Best Practices

1. **Check monthly** for compiler updates
2. **Test thoroughly** before committing version bumps
3. **Update CI first** to catch compatibility issues
4. **Keep CLAUDE.md in sync** for AI assistants
5. **Monitor CI builds** after version updates

## Future Improvements

Potential enhancements to the automation:

- [ ] Automatic PR creation when new versions detected
- [ ] Verify versions available in package managers (apt, brew, vcpkg)
- [ ] Email notifications for critical updates
- [ ] Support for checking beta/RC versions
- [ ] Validation that new compilers actually support C++23 features
- [ ] Rollback script if update causes build failures

## Contributing

When improving the scripts:

1. Test on both macOS and Linux
2. Ensure backward compatibility
3. Update this guide
4. Test with mock data to avoid API rate limits
5. Add error handling for edge cases

## Support

For issues with the scripts:

1. Check this guide for troubleshooting
2. Review `scripts/README.md` for technical details
3. Open a GitHub issue with:
   - OS and version
   - Script output / error messages
   - Contents of `scripts/latest-versions.txt`
