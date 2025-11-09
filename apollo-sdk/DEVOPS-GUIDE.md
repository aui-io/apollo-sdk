# DevOps Guide: Apollo SDK Generation & Publishing

This guide is for the DevOps team to generate and publish the Apollo SDK to npm and PyPI.

## 🎯 Overview

The SDK generation is **fully automated** via a single script that:
1. Fetches the latest OpenAPI spec from production
2. Filters external-facing endpoints
3. Generates TypeScript and Python SDKs
4. Publishes to npm (and optionally PyPI)
5. Tracks version information in `generatedSDK.json`

**Key Feature**: WebSocket authentication fixes are automatically preserved via `.fernignore` and GitHub integration!

## 📋 Prerequisites

### Required
- **npm token**: For publishing to npm registry
- **GitHub access**: Fern uses GitHub (`aui-io/apollo-sdk`) to preserve custom code

### Optional
- **PyPI token**: For Python SDK publishing (can skip if not needed)

## 🚀 Publishing Commands

### Option 1: Auto-increment Patch Version (Recommended)
```bash
NPM_TOKEN="your-npm-token" ./generate-and-publish.sh --patch
```
Example: `1.0.7` → `1.0.8`

### Option 2: Auto-increment Minor Version
```bash
NPM_TOKEN="your-npm-token" ./generate-and-publish.sh --minor
```
Example: `1.0.7` → `1.1.0`

### Option 3: Auto-increment Major Version
```bash
NPM_TOKEN="your-npm-token" ./generate-and-publish.sh --major
```
Example: `1.0.7` → `2.0.0`

### Option 4: Specific Version
```bash
NPM_TOKEN="your-npm-token" ./generate-and-publish.sh --version 2.5.0
```

### Option 5: Publish Both npm and PyPI
```bash
NPM_TOKEN="your-npm-token" PYPI_TOKEN="your-pypi-token" ./generate-and-publish.sh --patch
```

## 🔧 How It Works

### GitHub Integration with `.fernignore`

The SDK generation uses Fern's GitHub integration to preserve custom WebSocket fixes:

1. **Fern generates** SDK and commits to `aui-io/apollo-sdk`
2. **`.fernignore` protects** our custom WebSocket authentication files:
   - `src/api/resources/externalSession/client/Client.ts` (TypeScript)
   - `src/aui/external_session/client.py` (Python)
3. **Custom fixes preserved** - WebSocket query param auth works automatically!
4. **Auto-publish** - npm and PyPI packages are published from GitHub

### What Gets Fixed Automatically

Our `.fernignore` preserves the WebSocket authentication fix that moves the API key from headers to query parameters:

**Before** (Fern's default):
```javascript
_url: 'wss://api.../session',
_headers: { 'x-network-api-key': 'KEY' },  // ❌ Wrong
_queryParameters: {}
```

**After** (Our custom fix):
```javascript
_url: 'wss://api.../session?network_api_key=KEY',  // ✅ Correct!
_headers: {},
_queryParameters: { network_api_key: 'KEY' }
```

This fix is **automatically preserved** across all SDK regenerations!

## 📊 Version Management

The script automatically:
- Fetches the current published version from npm
- Calculates the next version based on your flag (`--patch`, `--minor`, `--major`)
- Uses explicit version if you provide `--version X.Y.Z`

### Version Bump Types

| Flag | Current | New | Use Case |
|------|---------|-----|----------|
| `--patch` | 1.0.7 | 1.0.8 | Bug fixes, minor changes |
| `--minor` | 1.0.7 | 1.1.0 | New features, backward compatible |
| `--major` | 1.0.7 | 2.0.0 | Breaking changes |
| `--version 2.5.0` | any | 2.5.0 | Specific version needed |

## 📄 SDK Version Tracking

After each successful publish, the script creates/updates `generatedSDK.json`:

```json
{
  "generatedAt": "2025-11-08T22:00:00Z",
  "version": "1.0.8",
  "packages": {
    "npm": {
      "name": "@aui.io/apollo-sdk",
      "version": "1.0.8",
      "registry": "https://www.npmjs.com/package/@aui.io/apollo-sdk",
      "install": "npm install @aui.io/apollo-sdk@1.0.8"
    }
  }
}
```

This file is added to `.gitignore` and provides:
- Quick reference for the latest version
- Installation commands for team members
- Timestamp of last publish

## 🔒 Security Notes

1. **NEVER commit tokens** to the repository
2. **Provide tokens at runtime** via environment variables
3. **npm token** is REQUIRED for publishing
4. **PyPI token** is OPTIONAL (skips Python if not provided)

### Setting Up npm Token

1. Log into npmjs.com
2. Go to Access Tokens → Generate New Token
3. Choose "Automation" type
4. Copy the token (starts with `npm_`)
5. Use it in the command: `NPM_TOKEN="npm_..."`

## 🎯 Common Workflows

### Daily/Regular Releases (Patch)
```bash
# Most common: bug fixes and minor updates
NPM_TOKEN="npm_..." ./generate-and-publish.sh --patch
```

### New Feature Release (Minor)
```bash
# New features, backward compatible
NPM_TOKEN="npm_..." ./generate-and-publish.sh --minor
```

### Breaking Changes (Major)
```bash
# API changes that break backward compatibility
NPM_TOKEN="npm_..." ./generate-and-publish.sh --major
```

### Emergency Hotfix (Specific Version)
```bash
# Need to publish a specific version
NPM_TOKEN="npm_..." ./generate-and-publish.sh --version 1.0.9
```

## 📦 Local Testing

To generate SDKs locally without publishing:

```bash
./generate-and-publish.sh --local-only
```

Generated SDKs will be in:
- TypeScript: `apollo-sdk/generated-sdks/typescript/`
- Python: `apollo-sdk/generated-sdks/python/`

## ✅ Verification

After publishing, verify the SDK:

### Check npm
```bash
npm view @aui.io/apollo-sdk version
npm install @aui.io/apollo-sdk@latest
```

### Check PyPI (if published)
```bash
pip show aui-apollo-sdk
```

### Test Installation
```bash
# TypeScript
npm install @aui.io/apollo-sdk@1.0.8

# Python
pip install aui-apollo-sdk==1.0.8
```

## 🐛 Troubleshooting

### Error: "npm error 401 Unauthorized"
- Check that `NPM_TOKEN` is valid and not expired
- Verify token has publish permissions

### Error: "404 Not Found"
- First publish requires the package name to be available
- Verify `@aui.io` organization exists on npm

### Error: "403 Forbidden - private packages"
- Scoped packages (`@aui.io/...`) are private by default
- The script automatically adds `--access public`

### SDK Generated but WebSocket Not Working
- This should NOT happen anymore with `.fernignore`
- Verify `.fernignore` file exists in `fern/` directory
- Check GitHub repo has the custom WebSocket files

## 📞 Support

For issues or questions:
1. Check `generatedSDK.json` for last successful publish
2. Review error messages in terminal output
3. Contact the development team

---

**Last Updated**: November 8, 2025  
**GitHub Repository**: https://github.com/aui-io/apollo-sdk  
**npm Package**: https://www.npmjs.com/package/@aui.io/apollo-sdk
