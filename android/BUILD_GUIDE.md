# CamStar - Android Build Guide

## Prerequisites Checklist
- [ ] Android Studio installed (optional but recommended)
- [ ] Android SDK installed (comes with Android Studio)
- [ ] Flutter SDK installed and configured
- [ ] USB debugging enabled on test device (for physical device testing)

## Quick Start

### Option 1: Using Build Script (Recommended)
```bash
./android/build_debug.sh
```

### Option 2: Manual Build
```bash
# APK build
flutter build apk --debug

# AAB build (App Bundle)
flutter build appbundle --debug
```

## Build Types

### Debug Build (Default)
- **Use case**: Development and testing
- **Signing**: Automatically signed with debug keystore
- **Performance**: Not optimized, includes debugging info
- **Install**: Can install directly on devices
- **Command**: `flutter build apk --debug`

### Release Build (Production)
- **Use case**: Production distribution
- **Signing**: Requires upload keystore (covered in RELEASE_GUIDE.md)
- **Performance**: Optimized and minified
- **Install**: Requires proper signing
- **Command**: `flutter build apk --release`

## Building APK (Android Package)

### Debug APK
```bash
# Build debug APK
flutter build apk --debug

# Output location
# build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (Requires signing - see RELEASE_GUIDE.md)
```bash
# Build release APK
flutter build apk --release

# Output location
# build/app/outputs/flutter-apk/app-release.apk
```

### Split APKs by ABI (Smaller file size)
```bash
# Build separate APKs for different CPU architectures
flutter build apk --split-per-abi

# Outputs (3 files):
# - app-armeabi-v7a-release.apk (32-bit ARM)
# - app-arm64-v8a-release.apk (64-bit ARM)
# - app-x86_64-release.apk (64-bit Intel)
```

## Building AAB (Android App Bundle)

### What is AAB?
- Modern Android app format (required for Play Store since 2021)
- Google Play generates optimized APKs for each device
- Smaller downloads for users

### Debug AAB
```bash
# Build debug AAB
flutter build appbundle --debug

# Output location
# build/app/outputs/bundle/debug/app-debug.aab
```

### Release AAB (Requires signing)
```bash
# Build release AAB
flutter build appbundle --release

# Output location
# build/app/outputs/bundle/release/app-release.aab
```

## Installing on Devices

### Method 1: Flutter Install (Easiest)
```bash
# Connect device via USB (with USB debugging enabled)
flutter install

# Or specify device
flutter install -d <device-id>
```

### Method 2: ADB Install
```bash
# Install APK using ADB
adb install build/app/outputs/flutter-apk/app-debug.apk

# Uninstall first if app exists
adb uninstall com.camstar.camStar
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Method 3: Transfer and Install Manually
1. Copy APK to device (USB, email, cloud storage)
2. On device: Settings → Security → Enable "Install unknown apps"
3. Open APK file on device
4. Tap "Install"

## Running on Emulator

### Start Emulator
```bash
# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator-id>

# Or use Android Studio AVD Manager
```

### Run App
```bash
# Run on connected emulator
flutter run

# Build and install
flutter install
```

## Testing on Physical Device

### Enable Developer Options
1. Settings → About phone
2. Tap "Build number" 7 times
3. Go back → Developer options (now visible)
4. Enable "USB debugging"

### Connect Device
```bash
# Connect device via USB

# Verify connection
adb devices

# Should show:
# List of devices attached
# <device-id>    device
```

### Install and Run
```bash
# Install APK
flutter install

# Or run directly
flutter run
```

## Build Configuration

### Current Setup
- **Package name**: com.camstar.camStar
- **Min SDK**: 21 (Android 5.0 Lollipop)
- **Target SDK**: 34 (Android 14)
- **Version**: 1.0.0+1

### Change Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1  # format: major.minor.patch+buildNumber
```

### Change Package Name (Advanced)
Not recommended after initial setup, but if needed:
1. Update `android/app/build.gradle`:
   ```gradle
   applicationId "com.yourcompany.yourapp"
   ```
2. Update `android/app/src/main/AndroidManifest.xml`
3. Update `android/app/src/main/kotlin/` folder structure

## Permissions Configured

CamStar has these Android permissions:

- **INTERNET**: Network communication
- **CAMERA**: Camera access for broadcasting
- **ACCESS_WIFI_STATE**: WiFi network info
- **CHANGE_WIFI_MULTICAST_STATE**: mDNS discovery
- **ACCESS_NETWORK_STATE**: Network connectivity status

## Build Outputs

### File Locations
```
build/
├── app/
│   ├── outputs/
│   │   ├── flutter-apk/
│   │   │   ├── app-debug.apk          # Debug APK
│   │   │   └── app-release.apk        # Release APK
│   │   └── bundle/
│   │       ├── debug/
│   │       │   └── app-debug.aab      # Debug AAB
│   │       └── release/
│   │           └── app-release.aab    # Release AAB
```

### File Sizes (Approximate)
- Debug APK: ~50-70 MB
- Release APK: ~30-45 MB
- AAB: ~30-40 MB

## Troubleshooting

### Error: "Gradle build failed"
```bash
# Clean build
flutter clean
flutter pub get

# Clear Gradle cache
cd android
./gradlew clean
cd ..

# Rebuild
flutter build apk --debug
```

### Error: "SDK location not found"
Create `android/local.properties`:
```properties
sdk.dir=/Users/YOUR_USERNAME/Library/Android/sdk
```

### Error: "ADB not found"
```bash
# Add to ~/.zshrc or ~/.bash_profile
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### Error: "Device not authorized"
1. Disconnect device
2. Run: `adb kill-server`
3. Reconnect device
4. Allow USB debugging prompt on device

### Error: "Install failed due to signature mismatch"
```bash
# Uninstall existing app first
adb uninstall com.camstar.camStar

# Then install
adb install build/app/outputs/flutter-apk/app-debug.apk
```

### Error: NDK not configured
The NDK issue from earlier can be fixed:
```bash
# Remove corrupted NDK
rm -rf ~/Library/Android/sdk/ndk/28.2.13676358

# Rebuild - Gradle will re-download
flutter build apk --debug
```

## Performance Testing

### Check APK Size
```bash
# Analyze APK
flutter build apk --analyze-size

# Or manually
ls -lh build/app/outputs/flutter-apk/app-debug.apk
```

### Profile Build (Performance Testing)
```bash
# Build profile APK
flutter build apk --profile

# Run in profile mode
flutter run --profile
```

## Advanced Options

### Build with specific architecture
```bash
# ARM 64-bit only (most modern devices)
flutter build apk --target-platform android-arm64

# Multiple architectures
flutter build apk --target-platform android-arm,android-arm64,android-x64
```

### Obfuscate code (Release only)
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

### Verbose logging
```bash
flutter build apk --debug --verbose
```

## Distribution Methods

### 1. Direct APK Sharing
- Share `app-debug.apk` via email, cloud, USB
- Users install manually
- Good for: Beta testing, internal distribution

### 2. Firebase App Distribution
- Upload APK to Firebase Console
- Invite testers via email
- Good for: Team testing, QA

### 3. Google Play Internal Testing
- Upload AAB to Play Console
- Requires Play Developer account ($25)
- Good for: Pre-release testing

### 4. Third-party Stores
- Amazon AppStore
- Samsung Galaxy Store
- APKPure, etc.

## Useful Commands

```bash
# Check Flutter setup
flutter doctor -v

# List connected devices
flutter devices

# Clean project
flutter clean

# Update dependencies
flutter pub get

# Build APK (debug)
flutter build apk --debug

# Build AAB (debug)
flutter build appbundle --debug

# Install on device
flutter install

# Run app
flutter run

# Check app size
flutter build apk --analyze-size

# View logcat
adb logcat | grep flutter
```

## Next Steps

### For Testing
1. Build debug APK: `./android/build_debug.sh`
2. Install on device: `flutter install`
3. Test all features

### For Production Distribution
1. See `RELEASE_GUIDE.md` for signing setup
2. Build release AAB
3. Upload to Google Play Console

## Support

- Flutter Android docs: https://docs.flutter.dev/deployment/android
- Android Developer docs: https://developer.android.com/
- Play Console: https://play.google.com/console
