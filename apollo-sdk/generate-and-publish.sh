#!/bin/bash

################################################################################
# Apollo SDK - Automated Generation and Publishing
################################################################################
# This script automates the entire SDK generation and publishing process:
# 1. Fetches OpenAPI from production
# 2. Filters external-only endpoints
# 3. Validates specs (OpenAPI + AsyncAPI)
# 4. Generates SDKs using Fern (TypeScript + Python)
# 5. Publishes to npm and PyPI
################################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# NPM token must be provided via environment variable for security
# export NPM_TOKEN="your-token-here"  # Do NOT hardcode tokens!

# Configuration
DRY_RUN=false
SKIP_PUBLISH=false
LOCAL_ONLY=false
VERSION=""
VERSION_BUMP=""

# Function to get current published version from npm
get_current_version() {
    local package_name="@aui.io/apollo-sdk"
    local version=$(npm view "$package_name" version 2>/dev/null)
    
    if [ -z "$version" ]; then
        echo "0.0.0"  # Default if package not found
    else
        echo "$version"
    fi
}

# Function to increment version based on bump type
increment_version() {
    local current_version=$1
    local bump_type=$2
    
    # Parse version (MAJOR.MINOR.PATCH)
    local major=$(echo "$current_version" | cut -d. -f1)
    local minor=$(echo "$current_version" | cut -d. -f2)
    local patch=$(echo "$current_version" | cut -d. -f3)
    
    # Validate version parts are numbers
    if ! [[ "$major" =~ ^[0-9]+$ ]] || ! [[ "$minor" =~ ^[0-9]+$ ]] || ! [[ "$patch" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ Invalid version format: $current_version${NC}" >&2
        return 1
    fi
    
    case "$bump_type" in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo -e "${RED}❌ Invalid bump type: $bump_type${NC}" >&2
            return 1
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Helper function to build version argument for fern generate
build_version_arg() {
    if [ -n "$VERSION" ]; then
        echo "--version $VERSION"
    else
        echo ""
    fi
}

# Function to save SDK version info to file
save_sdk_version_info() {
    local version=$1
    local has_pypi=$2
    local output_file="../generatedSDK.json"
    
    # Get current timestamp
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local date_readable=$(date +"%B %d, %Y at %I:%M %p %Z")
    
    # Build JSON content
    if [ "$has_pypi" = true ]; then
        cat > "$output_file" << EOF
{
  "generatedAt": "$timestamp",
  "generatedAtReadable": "$date_readable",
  "version": "$version",
  "packages": {
    "npm": {
      "name": "@aui.io/apollo-sdk",
      "version": "$version",
      "registry": "https://www.npmjs.com/package/@aui.io/apollo-sdk",
      "install": "npm install @aui.io/apollo-sdk@$version"
    },
    "pypi": {
      "name": "aui-apollo-sdk",
      "version": "$version",
      "registry": "https://pypi.org/project/aui-apollo-sdk",
      "install": "pip install aui-apollo-sdk==$version"
    }
  }
}
EOF
    else
        cat > "$output_file" << EOF
{
  "generatedAt": "$timestamp",
  "generatedAtReadable": "$date_readable",
  "version": "$version",
  "packages": {
    "npm": {
      "name": "@aui.io/apollo-sdk",
      "version": "$version",
      "registry": "https://www.npmjs.com/package/@aui.io/apollo-sdk",
      "install": "npm install @aui.io/apollo-sdk@$version"
    }
  }
}
EOF
    fi
    
    echo -e "${GREEN}✅ SDK version info saved to: $output_file${NC}"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            echo -e "${YELLOW}🔍 Running in DRY RUN mode (no publishing)${NC}"
            shift
            ;;
        --skip-publish)
            SKIP_PUBLISH=true
            echo -e "${YELLOW}⏭️  Skipping publish step${NC}"
            shift
            ;;
        --local-only)
            LOCAL_ONLY=true
            echo -e "${YELLOW}💻 Local generation only (no npm/PyPI)${NC}"
            shift
            ;;
        --version)
            VERSION="$2"
            echo -e "${BLUE}📌 Explicit version: ${VERSION}${NC}"
            shift 2
            ;;
        --major)
            VERSION_BUMP="major"
            echo -e "${BLUE}📈 Version bump: MAJOR${NC}"
            shift
            ;;
        --minor)
            VERSION_BUMP="minor"
            echo -e "${BLUE}📈 Version bump: MINOR${NC}"
            shift
            ;;
        --patch)
            VERSION_BUMP="patch"
            echo -e "${BLUE}📈 Version bump: PATCH${NC}"
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run        Run without publishing (validate only)"
            echo "  --skip-publish   Generate SDKs but skip publishing"
            echo "  --local-only     Generate SDKs locally without npm/PyPI"
            echo ""
            echo "Version Management:"
            echo "  --version X.Y.Z  Specify exact version (e.g., --version 1.2.3)"
            echo "  --major          Auto-increment major version (e.g., 0.0.53 → 1.0.0)"
            echo "  --minor          Auto-increment minor version (e.g., 0.0.53 → 0.1.0)"
            echo "  --patch          Auto-increment patch version (e.g., 0.0.53 → 0.0.54)"
            echo "                   (If none specified, Fern will auto-increment patch)"
            echo ""
            echo "  --help           Show this help message"
            echo ""
            echo "Examples:"
            echo "  # Auto-increment patch (default)"
            echo "  NPM_TOKEN=\"token\" ./generate-and-publish.sh"
            echo ""
            echo "  # Explicit version bumps"
            echo "  NPM_TOKEN=\"token\" ./generate-and-publish.sh --patch"
            echo "  NPM_TOKEN=\"token\" ./generate-and-publish.sh --minor"
            echo "  NPM_TOKEN=\"token\" ./generate-and-publish.sh --major"
            echo ""
            echo "  # Specific version"
            echo "  NPM_TOKEN=\"token\" ./generate-and-publish.sh --version 1.0.0"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Validate version arguments (can't specify both --version and bump type)
if [ -n "$VERSION" ] && [ -n "$VERSION_BUMP" ]; then
    echo -e "${RED}❌ Error: Cannot specify both --version and --major/--minor/--patch${NC}"
    echo "Use either:"
    echo "  --version X.Y.Z  (for explicit version)"
    echo "  --major/--minor/--patch  (for auto-increment)"
    exit 1
fi

# Calculate version from bump type if specified
if [ -n "$VERSION_BUMP" ]; then
    echo ""
    echo -e "${BLUE}🔍 Fetching current published version...${NC}"
    CURRENT_VERSION=$(get_current_version)
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to fetch current version${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}   Current version: ${CURRENT_VERSION}${NC}"
    
    # Calculate new version
    NEW_VERSION=$(increment_version "$CURRENT_VERSION" "$VERSION_BUMP")
    
    if [ $? -ne 0 ] || [ -z "$NEW_VERSION" ]; then
        echo -e "${RED}❌ Failed to calculate new version${NC}"
        exit 1
    fi
    
    VERSION="$NEW_VERSION"
    BUMP_UPPER=$(echo "$VERSION_BUMP" | tr '[:lower:]' '[:upper:]')
    echo -e "${GREEN}   New version: ${VERSION} (${BUMP_UPPER} bump)${NC}"
fi

# Function to print step headers
print_step() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to check required environment variables
check_env_vars() {
    local missing_vars=()
    
    if [ "$SKIP_PUBLISH" = false ] && [ "$LOCAL_ONLY" = false ]; then
        # NPM token is required for publishing
        if [ -z "$NPM_TOKEN" ]; then
            missing_vars+=("NPM_TOKEN")
        fi
        
        # GitHub token is required for publishing (to preserve .fernignore fixes)
        if [ -z "$GITHUB_TOKEN" ]; then
            missing_vars+=("GITHUB_TOKEN")
        fi
        
        # PYPI token is optional - warn if not set
        if [ -z "$PYPI_TOKEN" ]; then
            echo -e "${YELLOW}⚠️  PYPI_TOKEN not set - Python package will NOT be published${NC}"
            echo ""
        fi
    fi
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo -e "${RED}❌ Missing required environment variables:${NC}"
        for var in "${missing_vars[@]}"; do
            echo -e "${RED}   - $var${NC}"
        done
        echo ""
        echo "Please set them before running this script:"
        echo "  export NPM_TOKEN='npm_YOUR_TOKEN_HERE'"
        echo ""
        echo "Optional (for Python publishing):"
        echo "  export PYPI_TOKEN='pypi_YOUR_TOKEN_HERE'"
        echo ""
        echo "Or run with --local-only to skip publishing"
        exit 1
    fi
}

# Function to check required tools
check_dependencies() {
    local missing_deps=()
    
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if ! command -v node &> /dev/null; then
        missing_deps+=("node")
    fi
    
    if ! command -v fern &> /dev/null; then
        missing_deps+=("fern (install with: npm install -g fern-api)")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${RED}❌ Missing required dependencies:${NC}"
        for dep in "${missing_deps[@]}"; do
            echo -e "${RED}   - $dep${NC}"
        done
        exit 1
    fi
}

# Change to scripts directory
cd "$(dirname "$0")/scripts"

################################################################################
# STEP 0: Pre-flight checks
################################################################################
print_step "🚀 STEP 0: Pre-flight Checks"

echo "✅ Checking dependencies..."
check_dependencies

echo "✅ Checking environment variables..."
check_env_vars

echo -e "${GREEN}✅ All pre-flight checks passed${NC}"

################################################################################
# STEP 1: Fetch API Specifications
################################################################################
print_step "📥 STEP 1: Fetching API Specifications"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN: Would fetch OpenAPI from production${NC}"
else
    echo "📥 Fetching OpenAPI specification..."
    ./fetch-openapi.sh
fi

################################################################################
# STEP 2: Filter External Endpoints
################################################################################
print_step "🔍 STEP 2: Filtering External Endpoints"

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}🔍 DRY RUN: Would filter external endpoints${NC}"
else
    node filter-external-api.js
    
    # Copy filtered OpenAPI to Fern directory
    echo "📋 Copying filtered OpenAPI to Fern directory..."
    cp ../specs/external-openapi.json ../fern/openapi.json
    echo -e "${GREEN}✅ OpenAPI copied to Fern directory${NC}"
fi

################################################################################
# STEP 3: Validate Specs
################################################################################
print_step "✅ STEP 3: Validating API Specifications"

echo "📄 Validating external-openapi.json..."
if jq empty ../specs/external-openapi.json 2>/dev/null; then
    ENDPOINTS=$(jq '.paths | length' ../specs/external-openapi.json)
    SCHEMAS=$(jq '.components.schemas | length' ../specs/external-openapi.json)
    echo -e "${GREEN}✅ OpenAPI spec is valid${NC}"
    echo "   - Endpoints: $ENDPOINTS"
    echo "   - Schemas: $SCHEMAS"
else
    echo -e "${RED}❌ OpenAPI spec is invalid${NC}"
    exit 1
fi

echo ""
echo "📄 Checking asyncapi.yaml..."
if [ -f "../specs/asyncapi.yaml" ]; then
    echo -e "${GREEN}✅ AsyncAPI spec exists${NC}"
else
    echo -e "${YELLOW}⚠️  AsyncAPI spec not found (optional)${NC}"
fi

################################################################################
# STEP 4: Generate SDKs with Fern
################################################################################
print_step "🎨 STEP 4: Generating SDKs with Fern"

cd ../fern

echo "🔍 Validating Fern configuration..."
if fern check; then
    echo -e "${GREEN}✅ Fern configuration is valid${NC}"
else
    echo -e "${RED}❌ Fern configuration is invalid${NC}"
    exit 1
fi

if [ "$LOCAL_ONLY" = true ]; then
    VERSION_ARG=$(build_version_arg)
    echo ""
    echo "💻 Generating SDKs locally..."
    fern generate --group local --log-level info $VERSION_ARG
    echo ""
    echo -e "${GREEN}✅ SDKs generated locally in generated-sdks/${NC}"
    
    # Patch WebSocket authentication (move API key from headers to query params)
    echo ""
    cd ../scripts
    node patch-websocket-auth.js
    cd ../fern
    
    echo ""
    echo "📦 Local SDK paths:"
    echo "   - TypeScript: apollo-sdk/generated-sdks/typescript/"
    echo "   - Python: apollo-sdk/generated-sdks/python/"
    
    # Save version info for local generation
    if [ -n "$VERSION" ]; then
        LOCAL_VERSION="$VERSION"
    else
        LOCAL_VERSION="local-$(date +%Y%m%d-%H%M%S)"
    fi
    echo ""
    save_sdk_version_info "$LOCAL_VERSION" true
    
    exit 0
fi

################################################################################
# STEP 5: Publish to npm and PyPI
################################################################################
if [ "$SKIP_PUBLISH" = false ]; then
    print_step "📦 STEP 5: Publishing SDKs"
    
    # Display version information
    if [ -n "$VERSION" ]; then
        echo -e "${BLUE}📌 Publishing version: ${VERSION}${NC}"
    else
        echo -e "${BLUE}📊 Fern will auto-increment version${NC}"
    fi
    echo ""
    
    if [ "$DRY_RUN" = true ]; then
        if [ -z "$PYPI_TOKEN" ]; then
            echo -e "${YELLOW}🔍 DRY RUN: Would publish SDK to npm only${NC}"
        else
            echo -e "${YELLOW}🔍 DRY RUN: Would publish SDKs to npm and PyPI${NC}"
        fi
    else
        # Determine which group to use based on available tokens
        VERSION_ARG=$(build_version_arg)
        
        if [ -z "$PYPI_TOKEN" ]; then
            echo "🚀 Publishing to npm only (via GitHub)..."
            echo -e "${YELLOW}⚠️  Skipping PyPI (PYPI_TOKEN not set)${NC}"
            echo ""
            fern generate --group npm --log-level info $VERSION_ARG
            
            echo ""
            echo -e "${GREEN}✅ SDK published successfully!${NC}"
            echo ""
            echo "📦 Published package:"
            echo "   - npm: @aui.io/apollo-sdk"
            
            # Get the published version (either explicit or fetch from npm)
            if [ -z "$VERSION" ]; then
                PUBLISHED_VERSION=$(get_current_version)
            else
                PUBLISHED_VERSION="$VERSION"
            fi
            
            # Save SDK version info
            echo ""
            save_sdk_version_info "$PUBLISHED_VERSION" false
        else
            echo "🚀 Publishing to npm and PyPI (via GitHub)..."
            fern generate --group production --log-level info $VERSION_ARG
            
            echo ""
            echo -e "${GREEN}✅ SDKs published successfully!${NC}"
            echo ""
            echo "📦 Published packages:"
            echo "   - npm: @aui.io/apollo-sdk"
            echo "   - PyPI: aui-apollo-sdk"
            
            # Get the published version (either explicit or fetch from npm)
            if [ -z "$VERSION" ]; then
                PUBLISHED_VERSION=$(get_current_version)
            else
                PUBLISHED_VERSION="$VERSION"
            fi
            
            # Save SDK version info
            echo ""
            save_sdk_version_info "$PUBLISHED_VERSION" true
        fi
    fi
fi

################################################################################
# COMPLETION
################################################################################
print_step "✨ SDK Generation Complete!"

echo "📊 Summary:"
echo "   ✅ Fetched OpenAPI from production"
echo "   ✅ Filtered external endpoints"
echo "   ✅ Validated specifications"
echo "   ✅ Generated TypeScript SDK"
echo "   ✅ Generated Python SDK"

if [ "$SKIP_PUBLISH" = false ] && [ "$DRY_RUN" = false ]; then
    echo "   ✅ Published to npm"
    echo "   ✅ Published to PyPI"
fi

echo ""
echo -e "${GREEN}🎉 All done!${NC}"
echo ""

if [ "$LOCAL_ONLY" = false ] && [ "$SKIP_PUBLISH" = false ] && [ "$DRY_RUN" = false ]; then
    echo "📚 Installation commands:"
    if [ -z "$PYPI_TOKEN" ]; then
        echo "   npm install @aui.io/apollo-sdk"
    else
        echo "   npm install @aui.io/apollo-sdk"
        echo "   pip install aui-apollo-sdk"
    fi
fi

echo ""

