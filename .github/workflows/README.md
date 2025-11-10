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

**Compiler Installation:**
- **Ubuntu**: Platform-native package managers (ubuntu-toolchain-r PPA for GCC, LLVM APT for Clang)
- **macOS**: Homebrew (`gcc@15`, `llvm@21`)
- **Windows**: Built-in MSVC (no additional installation needed)

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
- **lukka/get-cmake**: https://github.com/lukka/get-cmake/releases

Update version in workflow files, test, and commit.

## Troubleshooting

### CI Failures

**Compiler not found:**
- **Ubuntu**: Verify PPA repository is accessible and compiler package exists
  - Check ubuntu-toolchain-r PPA: `ppa:ubuntu-toolchain-r/test`
  - Check LLVM APT repository: `http://apt.llvm.org/noble/`
- **macOS**: Verify Homebrew formula exists (`brew info gcc@15` or `brew info llvm@21`)
- **Windows**: MSVC should be pre-installed on GitHub-hosted runners

**Package installation failures:**
- **Ubuntu**: Repository key or GPG signature issues (update wget command in workflow)
- **macOS**: Homebrew formula deprecated or renamed (check `brew search gcc` or `brew search llvm`)
- Network connectivity to package repositories

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
