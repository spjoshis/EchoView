#!/bin/bash

# CamStar - TestFlight Build Script
# This script automates the iOS build process for TestFlight distribution

set -e

echo "🚀 CamStar - TestFlight Build"
echo "=============================="

# Step 1: Clean previous builds
echo "📦 Cleaning previous builds..."
flutter clean

# Step 2: Get Flutter packages
echo "📥 Getting Flutter packages..."
flutter pub get

# Step 3: Install CocoaPods
echo "🔧 Installing CocoaPods dependencies..."
cd ios
pod install
cd ..

# Step 4: Build IPA
echo "🏗️  Building IPA for TestFlight..."
flutter build ipa --release --export-method app-store

# Step 5: Show output location
echo ""
echo "✅ Build complete!"
echo "📍 IPA location: build/ios/ipa/cam_star.ipa"
echo ""
echo "📤 Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Select Runner target → Signing & Capabilities"
echo "3. Select your Apple Developer Team"
echo "4. Build again or upload IPA using:"
echo "   - Xcode: Product → Archive → Distribute App"
echo "   - Transporter: Open .ipa file to upload"
