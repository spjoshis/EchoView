# CamStar - TestFlight Distribution Guide

## Prerequisites Checklist
- [x] Active Apple Developer account ($99/year)
- [ ] Xcode installed (latest version)
- [ ] CocoaPods installed (`sudo gem install cocoapods`)
- [ ] macOS computer

## Quick Start (Automated)

### Option 1: Using Build Script (Recommended)
```bash
./ios/build_testflight.sh
```

### Option 2: Manual Build
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release --export-method app-store
```

## Code Signing Setup (Required Before First Build)

### Step 1: Open Xcode Workspace
```bash
open ios/Runner.xcworkspace
```

**Important:** Always open `.xcworkspace`, NOT `.xcodeproj`

### Step 2: Configure Signing
1. Select **Runner** project in navigator (left sidebar)
2. Select **Runner** target (under Targets)
3. Go to **Signing & Capabilities** tab
4. Check **Automatically manage signing**
5. Select your **Team** from dropdown (your Apple Developer account)
6. Verify **Bundle Identifier**: `com.camstar.camStar`
7. Ensure **Signing Certificate** shows "Apple Distribution"

### Step 3: Verify Build Settings
1. Select **Runner** target
2. Go to **Build Settings** tab
3. Search for "Deployment Target"
4. Verify **iOS Deployment Target** = 13.0
5. Search for "Bitcode"
6. Verify **Enable Bitcode** = No

## Building for TestFlight

### Method 1: Flutter CLI (Fastest)
```bash
# Build IPA
flutter build ipa --release --export-method app-store

# Output location
# build/ios/ipa/cam_star.ipa
```

### Method 2: Xcode Archive (Full Control)
1. Open: `open ios/Runner.xcworkspace`
2. Select: Product → Destination → Any iOS Device (arm64)
3. Build: Product → Archive
4. Wait for archive to complete (5-10 minutes)
5. Organizer window opens automatically
6. Click **Distribute App**
7. Select **App Store Connect**
8. Click **Next** through options
9. Xcode uploads to TestFlight

## Uploading to TestFlight

### Method 1: Xcode (Integrated)
- After archiving, use **Distribute App** → **App Store Connect**
- Xcode handles upload automatically

### Method 2: Transporter App (Alternative)
1. Download **Transporter** from Mac App Store
2. Open Transporter
3. Sign in with Apple ID
4. Click **+** or drag IPA file
5. Click **Deliver**

### Method 3: Command Line (Advanced)
```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/cam_star.ipa \
  --username "your@apple.id" \
  --password "@keychain:AC_PASSWORD"
```

## App Store Connect Setup

### Create App Record (First Time Only)
1. Go to: https://appstoreconnect.apple.com
2. Navigate to: **My Apps** → **+** (Add New App)
3. Fill in details:
   - **Platform**: iOS
   - **Name**: CamStar
   - **Primary Language**: English
   - **Bundle ID**: com.camstar.camStar
   - **SKU**: camstar-ios (or any unique identifier)
4. Click **Create**

### Configure TestFlight
1. Open your app in App Store Connect
2. Go to **TestFlight** tab
3. Under **Internal Testing**, add testers:
   - Click **+** next to testers
   - Add email addresses (max 100 internal testers)
4. Under **External Testing** (optional):
   - Create test group
   - Add up to 10,000 external testers
   - Requires App Store review (1-2 days)

## Version Management

### Current Version
- Version: **1.0.0**
- Build: **1**

### Increment Build Number (Each Upload)
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+2  # Increment build number
```

### Increment Version Number (New Release)
```yaml
version: 1.1.0+1  # New version, reset build number
```

**Rule:** Each TestFlight upload must have a unique build number

## Troubleshooting

### Error: "No profiles for 'com.camstar.camStar'"
**Fix:** Open Xcode → Signing & Capabilities → Select Team

### Error: "Missing compliance"
**Fix:** In App Store Connect → TestFlight → Select Build → Provide Export Compliance (usually "No" for local-only apps)

### Error: "Unsupported minimum iOS version"
**Fix:** Ensure deployment target is 13.0+ in both Xcode and Podfile

### Error: CocoaPods compatibility
```bash
cd ios
pod repo update
pod deintegrate
pod install
cd ..
```

### Error: Archive not showing in Organizer
- Verify scheme is set to "Runner"
- Ensure "Generic iOS Device" is selected
- Check for build errors in Issue Navigator

## Testing the Build

### Before Uploading
1. Test on simulator: `flutter run -d "iPhone 15 Pro"`
2. Test on physical device: `flutter run`
3. Verify camera permissions work
4. Verify server/client modes work on local network
5. Test broadcast and streaming functionality

### After TestFlight Upload
1. Wait 5-10 minutes for processing
2. Check email for "Ready to Test" notification
3. Install TestFlight app on iOS device
4. Accept invitation
5. Install CamStar from TestFlight
6. Test all features

## Permissions Configured

The app already has these iOS permissions configured:

- **Camera**: "CamStar needs camera access to broadcast your camera feed to other devices"
- **Local Network**: "CamStar needs local network access to discover and connect to camera servers on your Wi-Fi network"
- **Bonjour Services**: _camstar._tcp (for mDNS discovery)

## Build Specifications

- **Minimum iOS**: 13.0
- **Swift Version**: 5.0
- **Bitcode**: Disabled (modern requirement)
- **Architecture**: arm64 (64-bit only)

## Distribution Certificate

Xcode will automatically create/download:
- **Development Certificate**: For local testing
- **Distribution Certificate**: For TestFlight/App Store

Certificate is stored in your Keychain and managed by Xcode.

## Next Steps After TestFlight

1. Gather beta tester feedback
2. Fix bugs and improve features
3. Increment version number
4. Submit for App Store review
5. Release to public

## Useful Commands

```bash
# Check Flutter doctor
flutter doctor -v

# List iOS devices
flutter devices

# Clean build
flutter clean

# Update dependencies
flutter pub get
cd ios && pod install && cd ..

# Build without Xcode
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# View build logs
flutter build ipa --release --verbose
```

## Support

- Flutter docs: https://docs.flutter.dev/deployment/ios
- TestFlight docs: https://developer.apple.com/testflight/
- App Store Connect: https://appstoreconnect.apple.com
