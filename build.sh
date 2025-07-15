#!/bin/bash

# Apple Notes Enhancer Build Script
# Simple and robust build process

set -e  # Exit on any error

echo "🚀 Building Apple Notes Enhancer (Robust Version)..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="AppleNotesEnhancer"
BUILD_CONFIG="Debug"

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

# Function to check and install Xcode tools
check_xcode() {
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode command line tools not found!"
        echo "Please install with: xcode-select --install"
        exit 1
    fi
    
    # Accept license if needed
    if ! xcodebuild -license check &> /dev/null; then
        print_warning "Xcode license needs to be accepted"
        sudo xcodebuild -license accept 2>/dev/null || true
    fi
    
    print_success "Xcode tools ready"
}

# Function to handle Gatekeeper
handle_gatekeeper() {
    print_status "Temporarily disabling Gatekeeper for build..."
    sudo spctl --master-disable 2>/dev/null || {
        print_warning "Could not disable Gatekeeper (you may need to do this manually)"
        echo "Go to: System Preferences > Security & Privacy > General"
        echo "Set 'Allow apps downloaded from: Anywhere'"
        read -p "Press Enter when ready to continue..."
    }
}

# Function to re-enable Gatekeeper
restore_gatekeeper() {
    print_status "Re-enabling Gatekeeper..."
    sudo spctl --master-enable 2>/dev/null || true
}

# Function to build the project
build_project() {
    print_status "Building ${PROJECT_NAME}..."
    
    # Clean first
    rm -rf build/ 2>/dev/null || true
    
    # Build with simplified settings
    xcodebuild clean build \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${PROJECT_NAME}" \
        -configuration "${BUILD_CONFIG}" \
        -derivedDataPath "./build" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        -quiet
        
    if [ $? -eq 0 ]; then
        print_success "Build completed!"
        return 0
    else
        print_error "Build failed!"
        return 1
    fi
}

# Function to find and set up the built app
setup_app() {
    APP_PATH=$(find "./build" -name "${PROJECT_NAME}.app" -type d 2>/dev/null | head -n1)
    
    if [ -z "$APP_PATH" ]; then
        print_error "Could not find built app!"
        return 1
    fi
    
    print_success "App built at: $APP_PATH"
    
    # Make it executable (in case of permission issues)
    chmod +x "$APP_PATH/Contents/MacOS/${PROJECT_NAME}" 2>/dev/null || true
    
    # Try to remove quarantine attribute
    xattr -dr com.apple.quarantine "$APP_PATH" 2>/dev/null || true
    
    print_success "App is ready to run!"
    return 0
}

# Function to show permissions setup
show_permission_setup() {
    echo ""
    print_status "IMPORTANT: Permission Setup Required"
    echo ""
    echo -e "${YELLOW}To use Apple Notes Enhancer, you MUST grant these permissions:${NC}"
    echo ""
    echo "1. 🔐 ACCESSIBILITY PERMISSION:"
    echo "   • Open System Preferences"
    echo "   • Go to Security & Privacy → Privacy → Accessibility"
    echo "   • Click the lock and enter your password"
    echo "   • Check the box next to 'Apple Notes Enhancer'"
    echo ""
    echo "2. ⌨️ INPUT MONITORING PERMISSION:"
    echo "   • Go to Security & Privacy → Privacy → Input Monitoring"
    echo "   • Click the lock and enter your password"
    echo "   • Check the box next to 'Apple Notes Enhancer'"
    echo ""
    echo -e "${GREEN}The app will automatically detect when permissions are granted!${NC}"
    echo ""
}

# Function to launch the app
launch_app() {
    if [ -n "$APP_PATH" ]; then
        echo ""
        read -p "🚀 Launch Apple Notes Enhancer now? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Launching app..."
            open "$APP_PATH"
            
            echo ""
            print_success "🎉 Apple Notes Enhancer is starting!"
            echo ""
            echo -e "${BLUE}Look for the Notes icon in your menu bar${NC}"
            echo -e "${BLUE}The app will guide you through permission setup${NC}"
            echo ""
            echo -e "${YELLOW}Quick Test:${NC}"
            echo "1. Open Apple Notes"
            echo "2. Type: # Hello World (then space)"
            echo "3. Watch it become a title!"
            echo "4. Press ⌘P for command palette"
        fi
    fi
}

# Main execution
main() {
    echo "Starting build process..."
    echo ""
    
    # Check prerequisites
    check_xcode
    
    # Check if project exists
    if [ ! -f "${PROJECT_NAME}.xcodeproj/project.pbxproj" ]; then
        print_error "Project file not found!"
        echo "Make sure you're in the AppleNotesEnhancer directory"
        exit 1
    fi
    
    # Handle security
    handle_gatekeeper
    
    # Build the project
    if build_project; then
        if setup_app; then
            show_permission_setup
            launch_app
        fi
    else
        print_error "Build failed. Common solutions:"
        echo "1. Make sure Xcode is installed: xcode-select --install"
        echo "2. Accept Xcode license: sudo xcodebuild -license accept"
        echo "3. Try opening the project in Xcode and building there"
        restore_gatekeeper
        exit 1
    fi
    
    # Restore security settings
    restore_gatekeeper
    
    echo ""
    print_success "✨ Setup complete!"
    echo ""
    echo -e "${BLUE}Enjoy your enhanced Apple Notes experience! 🚀${NC}"
}

# Run main function
main