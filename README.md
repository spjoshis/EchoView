## EchoView

EchoView is a cross-platform Flutter app for real-time camera video streaming between devices on the same Wi-Fi network, with **no internet required**. It uses WebRTC for peer-to-peer streaming and local network discovery, ensuring all data stays within your LAN for privacy and speed.

---

## 🚀 Features

- **Local-Only Streaming:** Real-time, low-latency video streaming over your Wi-Fi network.
- **No Internet Needed:** Works even if your router has no internet connection.
- **Peer-to-Peer (WebRTC):** Direct device-to-device video transmission.
- **Offline Signaling:** Uses local HTTP server and mDNS for device discovery and connection setup.
- **Multiple Clients:** One server (broadcaster) can stream to multiple viewers simultaneously.
- **Simple Roles:**
  - **Server:** Broadcasts camera feed.
  - **Client:** Discovers and views available streams.
- **Privacy First:** No external servers, no cloud, no paid third-party services.
- **Cross-Platform:** Runs on Android and iOS (Flutter).

---

## 📱 How It Works

1. **Choose Mode:** On launch, select **Server** (broadcast) or **Client** (view).
2. **Server Mode:**
	- Select camera (front/back) and quality.
	- Start broadcasting your camera feed.
	- App advertises itself on the local network.
3. **Client Mode:**
	- App automatically discovers available servers on the same Wi-Fi.
	- Select a server to view its live video stream.

All communication and video stay within your local network.

---

## 🛠️ Tech Stack

- **Flutter** (cross-platform UI)
- **WebRTC** (flutter_webrtc plugin)
- **mDNS/Bonjour** (LAN device discovery)
- **Local HTTP Server** (signaling)
- **Provider** (state management)

---

## 📦 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Android Studio or Xcode (for device/simulator)
- Devices connected to the same Wi-Fi network

### Installation

1. **Clone the repo:**
	```sh
	git clone https://github.com/yourusername/EchoView.git
	cd EchoView
	```
2. **Install dependencies:**
	```sh
	flutter pub get
	```
3. **Run on device:**
	```sh
	flutter run -d <device_id>
	```
	(Use `flutter devices` to list available devices)

### iOS Notes
- Requires macOS and Xcode.
- Run `cd ios && pod install` if building for iOS.
- Ensure camera and local network permissions are enabled in `ios/Runner/Info.plist`.

---

## 🧩 Project Structure

```
lib/
  models/         # Data models (camera, peer state, etc.)
  providers/      # State management
  screens/        # UI screens (server, client, viewer)
  services/       # Camera, WebRTC, signaling, discovery
  theme/          # App theming
  widgets/        # Reusable UI components
```

---

## 🔒 Privacy & Security
- No data leaves your local network.
- No external servers or cloud services used.
- Works offline and respects user privacy.

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgements
- [flutter_webrtc](https://pub.dev/packages/flutter_webrtc)
- [camera](https://pub.dev/packages/camera)
- [shelf](https://pub.dev/packages/shelf)
- [uuid](https://pub.dev/packages/uuid)

---

## 💡 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## 📬 Contact

For questions or support, open an issue or contact the maintainer at [gopal.joshi73@hotmail.com](mailto:gopal.joshi73@hotmail.com).
