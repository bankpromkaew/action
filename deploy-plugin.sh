#!/bin/bash

# Quick Deploy Script for Apple Notes Plugin
# Builds and deploys the Apple Notes Enhancer as a plugin

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Apple Notes Plugin Quick Deploy${NC}"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "AppleNotesEnhancer.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Run this script from the project root directory"
    exit 1
fi

# Make scripts executable
echo -e "${BLUE}📋 Setting up build scripts...${NC}"
chmod +x build.sh
chmod +x release-build.sh

# Test build first
echo -e "${BLUE}🔨 Testing build...${NC}"
./build.sh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build test successful!${NC}"
else
    echo "❌ Build failed. Please check the errors above."
    exit 1
fi

# Create release build
echo -e "${BLUE}📦 Creating release build...${NC}"
./release-build.sh

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Release build completed!${NC}"
else
    echo "❌ Release build failed. Please check the errors above."
    exit 1
fi

# Check for built packages
PACKAGE_DIR="./build/package"
if [ -d "$PACKAGE_DIR" ]; then
    echo -e "${GREEN}📦 Distribution packages:${NC}"
    find "$PACKAGE_DIR" -name "*.zip" -o -name "*.dmg" | while read file; do
        echo "   📄 $(basename "$file") ($(du -h "$file" | cut -f1))"
    done
fi

echo ""
echo -e "${GREEN}🎉 Apple Notes Plugin deployment ready!${NC}"
echo ""
echo -e "${YELLOW}📋 Next steps:${NC}"
echo "1. Test the built app locally"
echo "2. Create a GitHub release:"
echo "   - Go to: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]//' | sed 's/.git$//')/releases/new"
echo "   - Upload the ZIP and DMG files from build/package/"
echo "   - Use the release notes template from the build output"
echo ""
echo "3. Alternative: Use GitHub Actions:"
echo "   - Push a version tag: git tag v1.0.0 && git push origin v1.0.0"
echo "   - Or trigger manual release in GitHub Actions tab"
echo ""
echo -e "${BLUE}🔧 For users to install:${NC}"
echo "1. Download the ZIP from your GitHub release"
echo "2. Extract and drag 'Apple Notes Enhancer.app' to Applications"
echo "3. Run the app and grant permissions when prompted"
echo "4. Enjoy enhanced Apple Notes! ✨"