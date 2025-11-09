# Apollo SDK - Automated Generation & Publishing

> **Automated SDK pipeline for AUI API** - Generates TypeScript & Python SDKs from OpenAPI/AsyncAPI specifications and publishes to npm/PyPI.

## 🎯 Overview

This repository contains an **automated SDK generation and publishing pipeline** that:

- ✅ Fetches OpenAPI specs from production
- ✅ Filters to external-only endpoints (`/api/v1/external/*`)
- ✅ Fixes authentication header mismatches automatically
- ✅ Generates TypeScript & Python SDKs using [Fern](https://buildwithfern.com)
- ✅ Publishes to npm (`@aui.io/apollo-sdk`) via GitHub Actions
- ✅ Preserves custom WebSocket authentication fixes across regenerations
- ✅ Manages semantic versioning automatically

---

## 🚀 Quick Start (DevOps)

### Prerequisites

1. **NPM Token**: Get from https://www.npmjs.com/settings/YOUR_ACCOUNT/tokens
2. **GitHub Token**: Get from https://github.com/settings/tokens/new (with `repo` scope, authorized for `aui-io` org)
3. **PyPI Token** (optional): For Python publishing

### Basic Usage

```bash
# Navigate to project
cd /path/to/apollo-sdk

# Set tokens
export NPM_TOKEN="npm_xxxxx"
export GITHUB_TOKEN="ghp_xxxxx"
export PYPI_TOKEN="pypi-xxxxx"  # Optional

# Publish with automatic patch version bump (0.0.X)
./generate-and-publish.sh --patch

# Or specify version bump type
./generate-and-publish.sh --minor   # 0.X.0
./generate-and-publish.sh --major   # X.0.0

# Or set explicit version
./generate-and-publish.sh --version 2.0.0
```

**That's it!** The script handles everything automatically.

---

## 📋 What Happens When You Run It

```
1. Pre-flight Checks
   ├─ Validates tokens are set
   ├─ Checks dependencies (node, jq, fern)
   └─ ✅ Ready to proceed

2. Fetch API Specs
   ├─ Downloads OpenAPI from production
   ├─ Filters to external endpoints only
   ├─ Fixes: x-api-key → x-network-api-key
   └─ ✅ specs/external-openapi.json created

3. Version Management
   ├─ Fetches current version from npm
   ├─ Calculates next version (patch/minor/major)
   └─ ✅ Version determined: 1.0.16

4. Generate & Push to GitHub
   ├─ Fern validates specs
   ├─ Generates TypeScript SDK
   ├─ Pushes to aui-io/apollo-sdk
   ├─ Protects custom WebSocket fix (.fernignore)
   └─ ✅ Tagged: v1.0.16

5. GitHub Actions Build & Publish
   ├─ Compiles TypeScript → dist/
   ├─ Publishes to npm with --access public
   └─ ✅ @aui.io/apollo-sdk@1.0.16 live!

6. Version Tracking
   └─ ✅ Saved to generatedSDK.json
```

---

## 🔧 How It Works

### The Problem We Solved

**REST API Issue:**
- OpenAPI spec had wrong header name (`x-api-key`)
- Actual API required `x-network-api-key`

**WebSocket Issue:**
- Fern generated code sent API key as **header**
- WebSocket API required API key as **query parameter**
- URL needed `/ia-controller` prefix

### The Solution

1. **REST API Fix** (`scripts/filter-external-api.js`)
   - Automatically detects and corrects header names during filtering
   - No manual intervention needed

2. **WebSocket Fix** (GitHub repo: `aui-io/apollo-sdk`)
   - Custom `Client.ts` file with correct authentication
   - API key sent as query parameter: `?network_api_key=YOUR_KEY`
   - Protected by `.fernignore` from being overwritten

3. **Automated Publishing**
   - Fern pushes to GitHub → triggers GitHub Actions → publishes to npm
   - Version tracking in `generatedSDK.json`

### Architecture

```
Local Repo (apollo-sdk/)
├─ generate-and-publish.sh  ← Main script
├─ fern/
│  ├─ generators.yml         ← Fern configuration
│  ├─ openapi.json           ← Generated spec
│  ├─ asyncapi.yaml          ← WebSocket spec
│  └─ .fernignore            ← Protects custom files
├─ scripts/
│  ├─ fetch-openapi.sh
│  └─ filter-external-api.js
└─ generatedSDK.json         ← Version tracking

GitHub Repo (aui-io/apollo-sdk)
├─ src/
│  └─ api/resources/externalSession/client/
│     └─ Client.ts           ← Custom WebSocket fix (protected)
├─ .fernignore               ← Prevents overwriting Client.ts
└─ .github/workflows/
   └─ ci.yml                 ← Builds & publishes to npm
```

---

## 🔐 Configuration Files

### `fern/generators.yml`

Defines how SDKs are generated and published:

```yaml
groups:
  npm:  # TypeScript → npm
    generators:
      - name: fernapi/fern-typescript-sdk
        github:
          repository: aui-io/apollo-sdk  # Push here
        output:
          location: npm
          package-name: "@aui.io/apollo-sdk"
          token: ${NPM_TOKEN}

  pypi:  # Python → PyPI (optional)
    generators:
      - name: fernapi/fern-python-sdk
        github:
          repository: aui-io/apollo-sdk-python  # If needed
        output:
          location: pypi
          package-name: "aui-apollo-sdk"
          token: ${PYPI_TOKEN}
```

### `fern/.fernignore`

Protects custom files from being overwritten:

```
# TypeScript WebSocket Client (custom query param auth fix)
src/api/resources/externalSession/client/Client.ts

# Python WebSocket Client (if publishing Python to GitHub)
src/aui/external_session/client.py
```

---

## 📦 Published SDKs

### TypeScript/JavaScript

```bash
npm install @aui.io/apollo-sdk
```

```typescript
import { AuiApiClient } from '@aui.io/apollo-sdk';

const client = new AuiApiClient({
    apiKey: 'API_KEY_01K92N5BD5M7239VRK7YTK4Y6N',
});

// REST API
const messages = await client.externalApis.getTaskMessages(taskId);

// WebSocket
const socket = await client.externalSession.connect();
socket.on('open', () => {
    socket.sendUserMessage({
        task_id: "task_id",
        text: "Your message"
    });
});
socket.on('message', (msg) => console.log(msg));
```

### Python

```bash
pip install aui-apollo-sdk  # When published
```

```python
from aui import AuiApiClient

client = AuiApiClient(api_key="YOUR_API_KEY")

# REST API
messages = client.external_apis.get_task_messages(task_id=task_id)

# WebSocket
with client.external_session.connect() as socket:
    socket.send_user_message({
        "task_id": "task_id",
        "text": "Your message"
    })
    for message in socket.iter_messages():
        print(message)
```

---

## 🎯 Version Management

The script automatically manages versions using semantic versioning:

```bash
# Current version: 1.0.15

# Patch (bug fixes): 1.0.15 → 1.0.16
./generate-and-publish.sh --patch

# Minor (new features): 1.0.15 → 1.1.0
./generate-and-publish.sh --minor

# Major (breaking changes): 1.0.15 → 2.0.0
./generate-and-publish.sh --major

# Explicit version
./generate-and-publish.sh --version 2.5.0
```

### Version Tracking

After each publish, version info is saved to `generatedSDK.json`:

```json
{
  "generatedAt": "2025-11-09T08:31:50Z",
  "version": "1.0.15",
  "packages": {
    "npm": {
      "name": "@aui.io/apollo-sdk",
      "version": "1.0.15",
      "install": "npm install @aui.io/apollo-sdk@1.0.15"
    }
  }
}
```

---

## 🔍 Testing

### TypeScript Tests

```bash
cd tests/typescript
npm install
node test-tasks.js        # Test REST API
node test-websocket.js    # Test WebSocket
```

### Python Tests

```bash
cd tests/python
pip install -r requirements.txt
python test_tasks.py      # Test REST API (when published)
```

---

## 🐛 Troubleshooting

### "npm error 404"
- **Issue**: Package not found on npm
- **Solution**: First publish might take a few minutes. Wait and retry.

### "GitHub 403 Forbidden"
- **Issue**: GitHub token not authorized for organization
- **Solution**: 
  1. Go to https://github.com/settings/tokens
  2. Find your token → "Configure SSO"
  3. Authorize for `aui-io` organization

### "Fern validation failed"
- **Issue**: OpenAPI or AsyncAPI spec has errors
- **Solution**: Check logs for specific validation errors. Usually caused by malformed spec from production.

### "WebSocket connection failed"
- **Issue**: Authentication or URL problem
- **Solution**: 
  - Check API key is valid
  - Verify URL includes `/ia-controller` prefix
  - Ensure query parameter auth is applied

---

## 📚 Additional Documentation

- **[DEVOPS-GUIDE.md](./DEVOPS-GUIDE.md)** - Detailed DevOps setup and token management
- **[PYTHON-WEBSOCKET-FIX.md](./PYTHON-WEBSOCKET-FIX.md)** - Python WebSocket authentication fix details
- **[tests/](./tests/)** - Example test files and usage

---

## 🔄 Regeneration Flow

When you run the generation script:

1. **Local Changes** → `generate-and-publish.sh` runs
2. **Fern Generates** → Creates SDK code
3. **GitHub Push** → Code pushed to `aui-io/apollo-sdk`
4. **`.fernignore` Protects** → Custom `Client.ts` NOT overwritten ✅
5. **GitHub Actions** → Builds and publishes to npm
6. **npm Registry** → New version available

**Key Point**: The WebSocket fix persists across all regenerations thanks to `.fernignore`!

---

## 📝 Key Files

| File | Purpose |
|------|---------|
| `generate-and-publish.sh` | Main automation script |
| `fern/generators.yml` | Fern SDK generation config |
| `fern/.fernignore` | Protects custom WebSocket fixes |
| `fern/asyncapi.yaml` | WebSocket API specification |
| `scripts/filter-external-api.js` | Filters & fixes OpenAPI spec |
| `generatedSDK.json` | Version tracking (auto-generated) |
| `DEVOPS-GUIDE.md` | Detailed DevOps documentation |

---

## 🎊 Summary

This automated pipeline:

- ✅ **Saves time**: One command to fetch, generate, and publish
- ✅ **Maintains quality**: Automatic header fixes and validation
- ✅ **Preserves customizations**: `.fernignore` protects WebSocket fixes
- ✅ **Tracks versions**: Automatic semantic versioning with tracking
- ✅ **DevOps friendly**: Simple token management, clear error messages

**For DevOps**: Just set tokens and run `./generate-and-publish.sh --patch`. Everything else is automatic!

---

## 🤝 Support

For issues or questions:
1. Check **[DEVOPS-GUIDE.md](./DEVOPS-GUIDE.md)** for detailed instructions
2. Review **Troubleshooting** section above
3. Contact the SDK maintainer team

---

**Last Updated**: November 9, 2025  
**Current SDK Version**: 1.0.15  
**Repository**: https://github.com/aui-io/apollo-sdk
