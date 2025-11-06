# DevOps Publishing Guide - Apollo SDK

## 🔐 Security-First Publishing

This guide is for DevOps teams to publish the Apollo SDK with **manually provided tokens** for security.

## 📋 Prerequisites

- Access to npm account with publish rights to `@aui.io` organization
- (Optional) Access to PyPI account for Python SDK publishing
- Tokens should be generated fresh and rotated regularly

## 🚀 Publishing the SDK

### Option 1: TypeScript Only (Most Common) ⭐

Publish only to npm (no Python SDK):

```bash
cd /Users/aui/AUI/apollo-sdk/apollo-sdk
NPM_TOKEN="npm_YOUR_TOKEN_HERE" ./generate-and-publish.sh
```

**Result:** ✅ TypeScript SDK published to npm, Python skipped

---

### Option 2: TypeScript + Python (Both)

Publish to both npm and PyPI:

```bash
cd /Users/aui/AUI/apollo-sdk/apollo-sdk
NPM_TOKEN="npm_YOUR_TOKEN_HERE" PYPI_TOKEN="pypi_YOUR_TOKEN_HERE" ./generate-and-publish.sh
```

**Result:** ✅ TypeScript SDK published to npm, ✅ Python SDK published to PyPI

---

### Option 3: Using Environment Variables (Multi-command sessions)

If running multiple commands or want tokens available for the session:

```bash
# Set tokens
export NPM_TOKEN="npm_YOUR_TOKEN_HERE"
export PYPI_TOKEN="pypi_YOUR_TOKEN_HERE"  # Optional

# Navigate to project
cd /Users/aui/AUI/apollo-sdk/apollo-sdk

# Run publish (tokens already set)
./generate-and-publish.sh

# Tokens remain set for the session
# Run again if needed
./generate-and-publish.sh
```

## 🤔 Token Behavior Summary

| NPM_TOKEN | PYPI_TOKEN | What Gets Published |
|-----------|-----------|---------------------|
| ✅ Provided | ❌ Not provided | ✅ TypeScript only (npm) |
| ✅ Provided | ✅ Provided | ✅ TypeScript (npm) + Python (PyPI) |
| ❌ Not provided | ❌ Not provided | ❌ Error - NPM_TOKEN required |
| ❌ Not provided | ✅ Provided | ❌ Error - NPM_TOKEN required |

**Key Points:**
- NPM_TOKEN is **always required** (TypeScript is the primary SDK)
- PYPI_TOKEN is **optional** (Python SDK only published if token provided)
- Script is smart - it won't fail if PYPI_TOKEN is missing, it just skips Python

## 📦 What Gets Published

### TypeScript SDK (npm)
- **Package Name:** `@aui.io/apollo-sdk`
- **Registry:** https://www.npmjs.com/package/@aui.io/apollo-sdk
- **Install Command:** `npm install @aui.io/apollo-sdk`

### Python SDK (PyPI) - Optional
- **Package Name:** `aui-apollo-sdk`
- **Registry:** https://pypi.org/project/aui-apollo-sdk/
- **Install Command:** `pip install aui-apollo-sdk`

## 🔄 Publishing Workflow

The script automatically:
1. ✅ Fetches latest OpenAPI spec from production
2. ✅ Filters to external-only endpoints
3. ✅ Validates specifications (OpenAPI + AsyncAPI)
4. ✅ Generates SDK using Fern
5. ✅ Publishes to npm (and PyPI if token provided)

## ⚙️ Script Options

### Generate Locally Only (No Publishing)
```bash
./generate-and-publish.sh --local-only
```
SDKs will be generated to:
- TypeScript: `apollo-sdk/generated-sdks/typescript/`
- Python: `apollo-sdk/generated-sdks/python/`

### Dry Run (Validate Without Publishing)
```bash
NPM_TOKEN="npm_YOUR_TOKEN_HERE" ./generate-and-publish.sh --dry-run
```

### Skip Publishing Step
```bash
./generate-and-publish.sh --skip-publish
```

## 🔑 Token Management

### Getting NPM Token

1. Login to https://www.npmjs.com/
2. Go to **Access Tokens** in your profile
3. Click **Generate New Token**
4. Choose **Automation** type
5. Copy the token (starts with `npm_`)

**Important:** The token must have:
- ✅ Publish access
- ✅ Rights to the `@aui.io` organization

### Getting PyPI Token (Optional)

1. Login to https://pypi.org/
2. Go to **Account Settings** → **API tokens**
3. Click **Add API token**
4. Set scope to "Entire account" or specific project
5. Copy the token (starts with `pypi-`)

## 🔒 Security Best Practices

1. **Never commit tokens** to git or hardcode them in scripts
2. **Use short-lived tokens** when possible
3. **Rotate tokens regularly** (every 30-90 days)
4. **Revoke tokens immediately** if compromised
5. **Use CI/CD secrets** if running in automated pipelines
6. **Limit token scope** to only what's needed (publish only)

## 📊 Expected Output

### Successful Publish
```
✅ SDK published successfully!

📦 Published package:
   - npm: @aui.io/apollo-sdk

📚 Installation commands:
   npm install @aui.io/apollo-sdk
```

### Errors to Watch For

#### 401 Unauthorized
- **Cause:** Invalid or expired token
- **Fix:** Generate a new token

#### 403 Forbidden
- **Cause:** Token doesn't have publish rights
- **Fix:** Use a token with publish permissions

#### 404 Not Found (organization)
- **Cause:** Wrong organization scope
- **Fix:** Ensure you're publishing to `@aui.io` (not `@aui`)

## 🐛 Troubleshooting

### Clear npm cache if seeing permission errors:
```bash
npm cache clean --force
```

### Verify token has correct permissions:
```bash
npm token list
```

### Check published versions:
```bash
npm view @aui.io/apollo-sdk versions
```

## 📞 Support

If you encounter issues:
1. Check the error message in the script output
2. Verify your token permissions
3. Ensure you're using the correct organization scope (`@aui.io`)
4. Contact the development team if issues persist

## 🔄 Version Management

The SDK version is auto-incremented by Fern with each publish. To check the current version:

```bash
npm view @aui.io/apollo-sdk version
```

---

**Last Updated:** November 2025  
**Script Location:** `/apollo-sdk/generate-and-publish.sh`  
**Organization:** @aui.io

