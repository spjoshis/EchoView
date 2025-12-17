#!/bin/bash

# CamStar - Android Debug Build Script
# This script builds debug APK and AAB files for testing

set -e

echo "🤖 CamStar - Android Debug Build"
echo "=================================="

# Step 1: Clean previous builds
echo "📦 Cleaning previous builds..."
flutter clean

# Step 2: Get Flutter packages
echo "📥 Getting Flutter packages..."
flutter pub get

# Step 3: Build APK (for direct installation)
echo "🏗️  Building debug APK..."
flutter build apk --debug

echo ""
echo "✅ APK build complete!"
echo "📍 APK location: build/app/outputs/flutter-apk/app-debug.apk"
echo ""

# Step 4: Build AAB (optional - for Play Store)
echo "🏗️  Building debug AAB (App Bundle)..."
flutter build appbundle --debug

echo ""
echo "✅ AAB build complete!"
echo "📍 AAB location: build/app/outputs/bundle/debug/app-debug.aab"
echo ""
echo "📤 Next steps:"
echo "════════════════════════════════════════════════════════"
echo ""
echo "To install APK on device:"
echo "  1. Enable USB debugging on Android device"
echo "  2. Connect device via USB"
echo "  3. Run: flutter install"
echo "     OR: adb install build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "To test on emulator:"
echo "  1. Start Android emulator"
echo "  2. Run: flutter run"
echo ""
echo "File sizes:"
ls -lh build/app/outputs/flutter-apk/app-debug.apk 2>/dev/null | awk '{print "  APK: " $5}'
ls -lh build/app/outputs/bundle/debug/app-debug.aab 2>/dev/null | awk '{print "  AAB: " $5}'
echo ""
