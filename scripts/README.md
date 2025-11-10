# Maintenance Scripts

This directory contains automation scripts to keep the repository up-to-date with the latest compiler versions.

## Scripts

### `check-latest-versions.sh`

Queries official sources to detect the latest versions of:
- CMake (from GitHub releases)
- GCC (from gcc.gnu.org)
- Clang/LLVM (from GitHub releases)
- C++ standards (hardcoded based on ISO schedule)

**Usage:**
```bash
./scripts/check-latest-versions.sh
```

**Output:**
- Console output with latest versions
- Creates `scripts/latest-versions.txt` with machine-readable version data

**Requirements:**
- `curl` (for API queries)
- Internet connection

### `check-homebrew-formulas.sh`

**macOS only**: Verifies which compiler versions are available as Homebrew formulas.

**Usage:**
```bash
./scripts/check-homebrew-formulas.sh
```

**Checks:**
- GCC formulas (gcc@15, gcc@14, gcc@13, gcc)
- LLVM/Clang formulas (llvm@21, llvm@18, llvm@17, llvm)
- Build tools (cmake, catch2)

**Output:**
- Reports available formulas with versions
- Provides installation commands
- Shows compiler paths after installation

**Why this matters:**
Homebrew on macOS provides versioned compiler formulas (e.g., `gcc@15`, `llvm@21`) that stay pinned to specific major versions. This script helps verify that the versions you want to use are actually available for installation.

### `update-versions.sh`

Updates all version references throughout the repository based on `latest-versions.txt`.

**Updates the following files:**
- `CMakeLists.txt` - CMake requirements and version comments
- `README.md` - Version table and inline references
- `CLAUDE.md` - Version table and documentation
- `test.cpp` - Test output messages
- `.github/workflows/ci.yml` - Compiler versions in CI matrix

**Usage:**
```bash
./scripts/update-versions.sh
```

**Interactive:**
The script will show you the versions and ask for confirmation before making changes.

**Safety:**
- Always review changes with `git diff` before committing
- Test the build after updating versions
- The script preserves existing patterns and only updates version numbers

## Workflow

### Manual Update Process

1. **Check for updates:**
   ```bash
   ./scripts/check-latest-versions.sh
   ```

2. **Review versions:**
   ```bash
   cat scripts/latest-versions.txt
   ```

3. **Apply updates:**
   ```bash
   ./scripts/update-versions.sh
   ```

4. **Review changes:**
   ```bash
   git diff
   ```

5. **Test build:**
   ```bash
   cmake -S . -B build
   cmake --build build
   ctest --test-dir build
   ```

6. **Commit:**
   ```bash
   git add -A
   git commit -m "Update to latest compiler versions"
   git push
   ```

### Automated Updates

The repository includes a GitHub Actions workflow (`.github/workflows/version-check.yml`) that:
- Runs monthly on the 1st at 9 AM UTC
- Can be triggered manually from GitHub Actions UI
- Checks for new versions
- Creates/updates a GitHub issue if updates are available
- Provides step-by-step instructions in the issue

## Version Sources

| Component | Source | Method |
|-----------|--------|--------|
| CMake | https://github.com/Kitware/CMake/releases | GitHub API |
| GCC | https://gcc.gnu.org/releases.html | Web scraping |
| Clang/LLVM | https://github.com/llvm/llvm-project/releases | GitHub API |
| C++ Standards | ISO/IEC schedule | Hardcoded (C++23 finalized, C++26 expected 2026) |

## Troubleshooting

### "Could not determine latest version"

**Causes:**
- No internet connection
- API rate limiting (GitHub API has limits for unauthenticated requests)
- Website structure changed

**Solutions:**
- Check your internet connection
- Wait an hour and try again (rate limit reset)
- Update the script if website structure changed

### "sed: command c expects \ followed by text"

**Cause:**
Different `sed` implementations between macOS and Linux

**Solution:**
The scripts detect the OS and use the appropriate syntax automatically. If you still see this error, check your OS detection logic.

## Future Enhancements

Potential improvements:
- [ ] Add support for MSVC version detection on Windows
- [ ] Support for other compilers (Intel, AMD, etc.)
- [ ] Automatic PR creation with version updates
- [ ] Verification that new versions are available in package managers
- [ ] Support for checking specific package manager versions (apt, brew, vcpkg)
- [ ] Email notifications for version updates
- [ ] Integration with dependabot-style automated PRs

## Contributing

When modifying the scripts:
1. Test on both macOS and Linux
2. Ensure backward compatibility
3. Update this README with new features
4. Add error handling for edge cases
