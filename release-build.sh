#!/bin/bash

# Apple Notes Plugin Release Build Script
# Builds and packages the Apple Notes Enhancer for distribution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Project configuration
PROJECT_NAME="AppleNotesEnhancer"
SCHEME_NAME="AppleNotesEnhancer"
BUILD_CONFIG="Release"
VERSION="1.0.0"
BUNDLE_ID="com.notesenhancer.app"

# Directories
BUILD_DIR="./build"
RELEASE_DIR="./build/release"
ARCHIVE_PATH="./build/${PROJECT_NAME}.xcarchive"
PACKAGE_DIR="./build/package"

# Functions
print_status() { echo -e "${BLUE}📋 $1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }

echo "🚀 Building Apple Notes Plugin v${VERSION} for Distribution"
echo "=================================================="

# Clean previous builds
print_status "Cleaning previous builds..."
rm -rf "${BUILD_DIR}"
mkdir -p "${RELEASE_DIR}"
mkdir -p "${PACKAGE_DIR}"

# Build the archive
print_status "Building archive..."
xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${BUILD_CONFIG}" \
    -archivePath "${ARCHIVE_PATH}" \
    -destination "generic/platform=macOS" \
    -allowProvisioningUpdates \
    DEVELOPMENT_TEAM="" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGN_STYLE=Manual

if [ $? -ne 0 ]; then
    print_error "Archive build failed!"
    exit 1
fi
print_success "Archive created successfully"

# Export the app
print_status "Exporting application..."

# Create export options plist
cat > "${BUILD_DIR}/export-options.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>signingStyle</key>
    <string>manual</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string></string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${RELEASE_DIR}" \
    -exportOptionsPlist "${BUILD_DIR}/export-options.plist"

if [ $? -ne 0 ]; then
    print_warning "Export with signing failed, trying without signing..."
    
    # Try without signing for development distribution
    cat > "${BUILD_DIR}/export-options-unsigned.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>signingStyle</key>
    <string>manual</string>
</dict>
</plist>
EOF
    
    xcodebuild -exportArchive \
        -archivePath "${ARCHIVE_PATH}" \
        -exportPath "${RELEASE_DIR}" \
        -exportOptionsPlist "${BUILD_DIR}/export-options-unsigned.plist"
fi

# Find the exported app
APP_PATH=$(find "${RELEASE_DIR}" -name "${PROJECT_NAME}.app" -type d | head -n1)

if [ -z "$APP_PATH" ]; then
    print_error "Could not find exported app!"
    exit 1
fi

print_success "App exported to: $APP_PATH"

# Create package structure
print_status "Creating distribution package..."
PACKAGE_NAME="Apple-Notes-Enhancer-${VERSION}"
PACKAGE_PATH="${PACKAGE_DIR}/${PACKAGE_NAME}"
mkdir -p "${PACKAGE_PATH}"

# Copy app to package
cp -R "$APP_PATH" "${PACKAGE_PATH}/"

# Create installation instructions
cat > "${PACKAGE_PATH}/INSTALL.md" << 'EOF'
# Installation Instructions for Apple Notes Enhancer

## Quick Install
1. Drag `Apple Notes Enhancer.app` to your `/Applications` folder
2. Open the app (it will appear in your menu bar)
3. Grant required permissions when prompted

## Required Permissions

### Accessibility Access
1. Open System Preferences → Security & Privacy → Privacy → Accessibility
2. Click the lock to make changes
3. Add `Apple Notes Enhancer` to the list
4. Ensure it's checked

### Input Monitoring
1. Open System Preferences → Security & Privacy → Privacy → Input Monitoring  
2. Click the lock to make changes
3. Add `Apple Notes Enhancer` to the list
4. Ensure it's checked

## Usage
1. Open Apple Notes
2. Look for the Notes Enhancer icon in your menu bar
3. Start typing in Notes:
   - `# ` for headings
   - `- ` for bullet lists
   - `> ` for quotes
   - Press `⌘P` for command palette

## Uninstall
Simply delete the app from Applications and remove it from the Privacy preferences.
EOF

# Create permissions helper script
cat > "${PACKAGE_PATH}/setup-permissions.sh" << 'EOF'
#!/bin/bash
echo "🔐 Setting up Apple Notes Enhancer permissions..."

# Open System Preferences to Accessibility
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

echo "✅ Please add Apple Notes Enhancer to Accessibility permissions"
echo "📋 Then run the app from Applications folder"
EOF

chmod +x "${PACKAGE_PATH}/setup-permissions.sh"

# Create uninstall script
cat > "${PACKAGE_PATH}/uninstall.sh" << 'EOF'
#!/bin/bash
echo "🗑️ Uninstalling Apple Notes Enhancer..."

# Kill the app if running
pkill -f "Apple Notes Enhancer" 2>/dev/null || true

# Remove from Applications
if [ -d "/Applications/Apple Notes Enhancer.app" ]; then
    rm -rf "/Applications/Apple Notes Enhancer.app"
    echo "✅ Removed from Applications"
fi

# Remove user preferences
defaults delete com.notesenhancer.app 2>/dev/null || true

echo "✅ Apple Notes Enhancer uninstalled successfully"
echo "📋 Please manually remove from System Preferences → Privacy if desired"
EOF

chmod +x "${PACKAGE_PATH}/uninstall.sh"

# Copy documentation
cp README.md "${PACKAGE_PATH}/" 2>/dev/null || echo "# Apple Notes Enhancer\n\nSee INSTALL.md for setup instructions." > "${PACKAGE_PATH}/README.md"
cp LICENSE "${PACKAGE_PATH}/" 2>/dev/null || echo "MIT License" > "${PACKAGE_PATH}/LICENSE"

# Create changelog
cat > "${PACKAGE_PATH}/CHANGELOG.md" << EOF
# Changelog

## v${VERSION} - $(date +%Y-%m-%d)

### Features
- ✅ Markdown shortcuts (# for headings, - for lists, > for quotes)
- ✅ Slash commands (/heading, /checklist, /quote, etc.)
- ✅ Command palette (⌘P in Notes)
- ✅ Formatting overlay toolbar
- ✅ Background operation with menu bar control
- ✅ Privacy-focused local processing

### Initial Release
- Complete Apple Notes enhancement suite
- macOS Monterey+ support
- Accessibility-based integration
EOF

# Create ZIP archive
print_status "Creating ZIP archive..."
cd "${PACKAGE_DIR}"
zip -r "${PACKAGE_NAME}.zip" "${PACKAGE_NAME}/"
cd - > /dev/null

# Create DMG if create-dmg is available
if command -v create-dmg &> /dev/null; then
    print_status "Creating DMG installer..."
    
    create-dmg \
        --volname "Apple Notes Enhancer" \
        --volicon "${APP_PATH}/Contents/Resources/AppIcon.icns" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "Apple Notes Enhancer.app" 175 120 \
        --hide-extension "Apple Notes Enhancer.app" \
        --app-drop-link 425 120 \
        --hdiutil-quiet \
        "${PACKAGE_DIR}/${PACKAGE_NAME}.dmg" \
        "${PACKAGE_PATH}/" 2>/dev/null || {
        
        print_warning "DMG creation failed, continuing with ZIP only"
    }
else
    print_warning "create-dmg not found, skipping DMG creation"
    print_status "Install with: brew install create-dmg"
fi

# Show results
echo ""
print_success "🎉 Apple Notes Plugin build completed!"
echo "=================================================="
echo "📦 Distribution packages created:"

if [ -f "${PACKAGE_DIR}/${PACKAGE_NAME}.zip" ]; then
    echo "   📦 ZIP: $(basename "${PACKAGE_DIR}/${PACKAGE_NAME}.zip")"
    echo "      Size: $(du -h "${PACKAGE_DIR}/${PACKAGE_NAME}.zip" | cut -f1)"
fi

if [ -f "${PACKAGE_DIR}/${PACKAGE_NAME}.dmg" ]; then
    echo "   💿 DMG: $(basename "${PACKAGE_DIR}/${PACKAGE_NAME}.dmg")"  
    echo "      Size: $(du -h "${PACKAGE_DIR}/${PACKAGE_NAME}.dmg" | cut -f1)"
fi

echo ""
echo "📋 Next steps:"
echo "   1. Test the app locally: open '${APP_PATH}'"
echo "   2. Upload to GitHub Releases"
echo "   3. Update download links in README"
echo ""
echo "🔐 For users:"
echo "   1. Download and extract the ZIP"
echo "   2. Run ./setup-permissions.sh" 
echo "   3. Drag app to Applications"
echo "   4. Grant Accessibility & Input Monitoring permissions"
echo ""
print_success "Ready for distribution! 🚀"
EOF