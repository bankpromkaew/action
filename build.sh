#!/bin/bash

# Apple Notes Enhancer Build Script
# This script builds the macOS application from the command line

set -e  # Exit on any error

echo "🚀 Building Apple Notes Enhancer..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="AppleNotesEnhancer"
SCHEME_NAME="AppleNotesEnhancer"
BUILD_CONFIG="Debug"
DERIVED_DATA_PATH="./build"

# Function to print colored output
print_status() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode command line tools not found. Please install Xcode."
    exit 1
fi

print_success "Xcode found: $(xcodebuild -version | head -n1)"

# Check if project exists
if [ ! -f "${PROJECT_NAME}.xcodeproj/project.pbxproj" ]; then
    print_error "Project file not found: ${PROJECT_NAME}.xcodeproj"
    exit 1
fi

print_success "Project file found"

# Clean previous builds
print_status "Cleaning previous builds..."
rm -rf "${DERIVED_DATA_PATH}"
xcodebuild clean \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${BUILD_CONFIG}" \
    -quiet

print_success "Clean completed"

# Build the project
print_status "Building ${PROJECT_NAME}..."
xcodebuild build \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${BUILD_CONFIG}" \
    -derivedDataPath "${DERIVED_DATA_PATH}" \
    -allowProvisioningUpdates

if [ $? -eq 0 ]; then
    print_success "Build completed successfully!"
    
    # Find the built app
    APP_PATH=$(find "${DERIVED_DATA_PATH}" -name "${PROJECT_NAME}.app" -type d | head -n1)
    
    if [ -n "$APP_PATH" ]; then
        print_success "App built at: $APP_PATH"
        
        # Check app signature
        print_status "Checking app signature..."
        codesign -dv "$APP_PATH" 2>&1 | head -n5
        
        # Show app info
        print_status "App information:"
        echo "  Size: $(du -sh "$APP_PATH" | cut -f1)"
        echo "  Bundle ID: $(defaults read "$APP_PATH/Contents/Info.plist" CFBundleIdentifier 2>/dev/null || echo "Unknown")"
        echo "  Version: $(defaults read "$APP_PATH/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "Unknown")"
        
        # Option to run the app
        echo ""
        read -p "🚀 Do you want to run the app now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Launching ${PROJECT_NAME}..."
            open "$APP_PATH"
            print_success "App launched! Check your menu bar for the Notes Enhancer icon."
            print_warning "Remember to grant Accessibility and Input Monitoring permissions in System Preferences."
        fi
        
    else
        print_warning "Could not locate built app"
    fi
    
else
    print_error "Build failed! Check the output above for errors."
    exit 1
fi

echo ""
print_success "Build script completed!"
echo -e "${BLUE}📖 Next steps:${NC}"
echo "  1. Grant Accessibility permission in System Preferences"
echo "  2. Grant Input Monitoring permission in System Preferences"  
echo "  3. Open Apple Notes and try typing: # Hello World"
echo "  4. Press ⌘P in Notes to open command palette"
echo ""
echo -e "${YELLOW}💡 Tip: The app runs in the background. Look for the icon in your menu bar.${NC}"