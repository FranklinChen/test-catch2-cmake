# GitHub Actions Workflows

This directory contains automated workflows for continuous integration and maintenance.

## Workflows

### `ci.yml` - Continuous Integration

**Purpose:** Build and test the project across multiple platforms and compilers.

**Triggers:**
- Push to `main` branch
- Pull requests to `main` branch

**Matrix:**
- **Ubuntu 24.04**: GCC 15, Clang 21
- **macOS Latest**: Homebrew GCC 15, Homebrew LLVM 21
- **Windows Latest**: MSVC

**Actions Used:**
- `actions/checkout@v5` - Check out repository
- `lukka/get-cmake@latest` - Install CMake 4.1+
- `aminya/setup-cpp@v1` - Install compilers (GCC/Clang/LLVM)

**Features:**
- Verifies compiler versions
- Builds with Release configuration
- Runs all tests with CTest
- Demonstrates C++23 features

### `version-check.yml` - Automated Version Monitoring

**Purpose:** Monitor for new compiler and tool versions.

**Triggers:**
- Monthly schedule (1st of month at 9 AM UTC)
- Manual workflow dispatch

**Actions Used:**
- `actions/checkout@v5` - Check out repository
- `actions/github-script@v8` - Create/update GitHub issues
- `actions/upload-artifact@v4` - Upload version check logs

**Features:**
- Checks for latest CMake, GCC, and Clang versions
- Compares with current repository versions
- Creates/updates GitHub issue when updates available
- Uploads version check log as artifact

## Action Versions (Last Updated: November 2025)

| Action | Version | Notes |
|--------|---------|-------|
| actions/checkout | v5 | Latest stable (August 2025) |
| actions/github-script | v8 | Uses Node.js 24 |
| actions/upload-artifact | v4 | Latest stable, v3 deprecated |
| lukka/get-cmake | latest | Always gets latest CMake |
| aminya/setup-cpp | v1 | Cross-platform compiler setup |

## Updating Actions

GitHub Actions should be periodically updated to their latest versions for security and features.

### Automated Updates (Recommended)

Add Dependabot to automatically update actions:

Create `.github/dependabot.yml`:
```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "monthly"
```

### Manual Updates

Check for new versions:
- **actions/checkout**: https://github.com/actions/checkout/releases
- **actions/github-script**: https://github.com/actions/github-script/releases
- **actions/upload-artifact**: https://github.com/actions/upload-artifact/releases
- **aminya/setup-cpp**: https://github.com/aminya/setup-cpp/releases

Update version in workflow files, test, and commit.

## Troubleshooting

### CI Failures

**Compiler not found:**
- Check `aminya/setup-cpp` version compatibility
- Verify compiler version is available on the platform
- Check runner OS version compatibility

**CMake version mismatch:**
- Verify `lukka/get-cmake` is pulling correct version
- Check `cmakeVersion` parameter in workflow

**Test failures:**
- Review test output in Actions logs
- Check if C++23 features are supported by compiler version
- Verify Catch2 compatibility

### Version Check Issues

**"Could not determine latest version":**
- GitHub API rate limiting (60 requests/hour for unauthenticated)
- Network connectivity issues
- Website structure changes

**Issue not created:**
- Check `actions/github-script` permissions
- Verify repository has Issues enabled
- Check workflow logs for errors

## Best Practices

1. **Pin to major versions** (e.g., `@v5`) for stability
2. **Review changelogs** before updating actions
3. **Test in PR** before merging action updates
4. **Use Dependabot** for automated updates
5. **Monitor deprecation notices** from GitHub

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Changelog](https://github.blog/changelog/label/actions/)
- [Actions Marketplace](https://github.com/marketplace?type=actions)
