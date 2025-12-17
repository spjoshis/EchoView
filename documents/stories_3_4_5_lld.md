# Low-Level Design: Stories 3, 4, 5
## Camera Broadcasting, Live Streaming & Local-Only Secure Communication

**Date:** 2025-12-14
**Project:** CamStar - Local Network Camera Streaming
**Stories:**
- Story 3: Implement Camera Broadcasting in Server Mode
- Story 4: Implement Live Video Stream in Client Mode
- Story 5: Ensure Local-Only Secure Communication

---

## 1. Executive Summary

These three stories form the core functionality of CamStar, implementing real-time video streaming over a local network using WebRTC with peer-to-peer architecture. The implementation ensures:
- **Server Mode:** Broadcasts camera feed to multiple clients
- **Client Mode:** Discovers and connects to local servers to view streams
- **Security:** All communication stays within the local network (no external servers)

### Technology Stack
- **WebRTC:** Peer-to-peer video streaming
- **mDNS/Bonjour:** Local service discovery (already implemented)
- **HTTP Server:** Local signaling for WebRTC handshake
- **Provider:** State management (already in use)
- **Camera Plugin:** Access device cameras

---

## 2. Architecture Overview

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     CamStar Application                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐              ┌──────────────────┐         │
│  │   SERVER MODE    │              │   CLIENT MODE    │         │
│  ├──────────────────┤              ├──────────────────┤         │
│  │                  │              │                  │         │
│  │  1. Camera       │              │  1. Discover     │         │
│  │     Selection    │              │     Servers      │         │
│  │                  │              │     (mDNS)       │         │
│  │  2. Start        │              │                  │         │
│  │     Broadcasting │              │  2. Connect to   │         │
│  │                  │              │     Server       │         │
│  │  3. mDNS         │◄────────────►│                  │         │
│  │     Registration │   Discovery  │  3. Receive      │         │
│  │                  │              │     Video Stream │         │
│  │  4. HTTP         │              │                  │         │
│  │     Signaling    │◄────────────►│  4. Display      │         │
│  │     Server       │   WebRTC     │     Video        │         │
│  │                  │   Handshake  │                  │         │
│  │  5. WebRTC       │              │  5. WebRTC       │         │
│  │     Peer (Send)  │◄────────────►│     Peer (Recv)  │         │
│  │                  │   P2P Video  │                  │         │
│  └──────────────────┘              └──────────────────┘         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Local Network   │
                    │   (WiFi/LAN)     │
                    └──────────────────┘
                    (No Internet Needed)
```

### 2.2 WebRTC Flow

```
SERVER                                          CLIENT
  │                                               │
  │  1. Start Camera                              │
  │  2. Register mDNS Service                     │
  │  3. Start HTTP Server (Signaling)             │
  │                                               │
  │ ◄─────────────── mDNS Discovery ──────────────┤
  │                                               │
  │ ◄─────────────── HTTP: Get Offer ─────────────┤
  │                                               │
  │  4. Create RTCPeerConnection                  │
  │  5. Add Camera MediaStream                    │
  │  6. Create SDP Offer                          │
  │                                               │
  │ ──────────────── HTTP: SDP Offer ────────────►│
  │                                               │
  │                                               │  7. Create RTCPeerConnection
  │                                               │  8. Set Remote Description
  │                                               │  9. Create SDP Answer
  │                                               │
  │ ◄────────────── HTTP: SDP Answer ─────────────┤
  │                                               │
  │  10. Set Remote Description                   │
  │                                               │
  │ ◄──────────────── ICE Candidates ────────────►│
  │                                               │
  │  11. P2P Connection Established               │
  │                                               │
  │ ═══════════════ Video Stream ════════════════►│
  │              (Direct P2P)                     │  12. Render Video
  │                                               │
```

---

## 3. Component Design

### 3.1 New Dependencies Required

**pubspec.yaml additions:**

```yaml
dependencies:
  # Existing dependencies...
  flutter_webrtc: ^0.11.7        # WebRTC for P2P streaming
  camera: ^0.11.0+2               # Camera access
  shelf: ^1.4.1                   # HTTP server for signaling
  uuid: ^4.5.1                    # Generate unique IDs
```

**Why these dependencies?**
- **flutter_webrtc:** Industry-standard WebRTC implementation for Flutter
- **camera:** Access and control device cameras
- **shelf:** Lightweight HTTP server for WebRTC signaling
- **uuid:** Generate unique peer connection IDs

### 3.2 File Structure

**New files to create:**

```
lib/
├── models/
│   ├── camera_info.dart              # Camera device information
│   ├── peer_connection_state.dart    # WebRTC connection states
│   └── stream_quality.dart           # Video quality presets
│
├── services/
│   ├── camera_service.dart           # Camera initialization & control
│   ├── server_registration_service.dart  # mDNS registration (server)
│   ├── signaling_server_service.dart # HTTP server for WebRTC signaling
│   ├── webrtc_server_service.dart    # WebRTC peer (server side)
│   └── webrtc_client_service.dart    # WebRTC peer (client side)
│
├── providers/
│   ├── camera_provider.dart          # Camera state management
│   ├── broadcast_provider.dart       # Server broadcast state
│   └── stream_viewer_provider.dart   # Client stream state
│
├── screens/
│   ├── server/
│   │   └── server_screen.dart        # [MODIFY] Server UI with camera
│   └── client/
│       ├── client_screen.dart        # [MODIFY] Add navigation to stream
│       └── stream_viewer_screen.dart # [NEW] Video stream viewer
│
└── widgets/
    ├── camera_preview_widget.dart    # Camera preview for server
    ├── video_renderer_widget.dart    # Video display for client
    ├── stream_controls_widget.dart   # Play/pause/stop controls
    └── connection_status_widget.dart # Connection status indicator
```

---

## 4. Data Models

### 4.1 CameraInfo Model

**File:** `lib/models/camera_info.dart`

```dart
class CameraInfo {
  final String id;
  final String name;
  final CameraLensDirection lensDirection;
  final int sensorOrientation;

  CameraInfo({
    required this.id,
    required this.name,
    required this.lensDirection,
    required this.sensorOrientation,
  });

  bool get isFrontCamera => lensDirection == CameraLensDirection.front;
  bool get isBackCamera => lensDirection == CameraLensDirection.back;
}
```

### 4.2 PeerConnectionState Enum

**File:** `lib/models/peer_connection_state.dart`

```dart
enum PeerConnectionState {
  disconnected,
  connecting,
  connected,
  failed,
  closed;

  bool get isConnected => this == PeerConnectionState.connected;
  bool get isActive => this == connecting || this == connected;
}
```

### 4.3 StreamQuality Model

**File:** `lib/models/stream_quality.dart`

```dart
enum StreamQuality {
  low,      // 480p @ 15fps
  medium,   // 720p @ 30fps
  high,     // 1080p @ 30fps
  auto;     // Adaptive

  String get displayName => switch (this) {
    low => 'Low (480p)',
    medium => 'Medium (720p)',
    high => 'High (1080p)',
    auto => 'Auto',
  };

  Map<String, dynamic> get constraints => switch (this) {
    low => {'width': 640, 'height': 480, 'frameRate': 15},
    medium => {'width': 1280, 'height': 720, 'frameRate': 30},
    high => {'width': 1920, 'height': 1080, 'frameRate': 30},
    auto => {'width': 1280, 'height': 720, 'frameRate': 30},
  };
}
```

---

## 5. Service Layer Design

### 5.1 CameraService

**File:** `lib/services/camera_service.dart`

**Responsibilities:**
- Enumerate available cameras
- Initialize camera controller
- Provide camera stream for WebRTC
- Handle camera lifecycle (permissions, errors)

**Key Methods:**
```dart
class CameraService {
  Future<List<CameraInfo>> getAvailableCameras();
  Future<void> initializeCamera(String cameraId);
  Future<MediaStream> getCameraMediaStream();
  Future<void> switchCamera(String cameraId);
  Future<void> dispose();
}
```

**State Management:**
- Current camera ID
- Available cameras list
- Camera initialization state
- Error messages

### 5.2 ServerRegistrationService

**File:** `lib/services/server_registration_service.dart`

**Responsibilities:**
- Register mDNS service with server details
- Advertise HTTP signaling server port
- Handle service start/stop
- Update service attributes (viewer count, etc.)

**Key Methods:**
```dart
class ServerRegistrationService {
  Future<void> registerService({
    required String serverName,
    required int httpPort,
  });

  Future<void> updateAttributes(Map<String, String> attributes);
  Future<void> unregisterService();
}
```

**mDNS Service Details:**
- Service Type: `_camstar._tcp`
- Service Name: User's device name
- Port: HTTP signaling server port
- TXT Records:
  - `version`: Protocol version
  - `viewers`: Current viewer count
  - `quality`: Current stream quality

### 5.3 SignalingServerService

**File:** `lib/services/signaling_server_service.dart`

**Responsibilities:**
- HTTP server for WebRTC signaling
- Handle SDP offer/answer exchange
- Handle ICE candidate exchange
- Manage multiple client connections

**HTTP Endpoints:**
```
GET  /offer/:clientId          -> Generate SDP offer
POST /answer/:clientId         -> Receive SDP answer
POST /ice-candidate/:clientId  -> Exchange ICE candidates
GET  /health                   -> Health check
```

**Key Methods:**
```dart
class SignalingServerService {
  Future<void> start(int port);
  Future<void> stop();

  // Callbacks for WebRTC service
  void onOfferRequested(String clientId, Function(RTCSessionDescription) callback);
  void onAnswerReceived(String clientId, RTCSessionDescription answer);
  void onIceCandidateReceived(String clientId, RTCIceCandidate candidate);
}
```

### 5.4 WebRTCServerService

**File:** `lib/services/webrtc_server_service.dart`

**Responsibilities:**
- Create and manage RTCPeerConnection for each client
- Add camera media stream to peer connections
- Handle ICE candidates
- Manage multiple simultaneous clients
- Monitor connection states

**Key Methods:**
```dart
class WebRTCServerService {
  Future<void> initialize(MediaStream cameraStream);

  Future<RTCSessionDescription> createOffer(String clientId);
  Future<void> setRemoteAnswer(String clientId, RTCSessionDescription answer);
  Future<void> addIceCandidate(String clientId, RTCIceCandidate candidate);

  void removeClient(String clientId);
  void dispose();

  // State
  Map<String, RTCPeerConnection> get clients;
  Stream<Map<String, PeerConnectionState>> get clientStatesStream;
}
```

**WebRTC Configuration:**
```dart
final configuration = {
  'iceServers': [], // Empty = local network only
  'iceTransportPolicy': 'all',
  'bundlePolicy': 'max-bundle',
  'rtcpMuxPolicy': 'require',
};
```

### 5.5 WebRTCClientService

**File:** `lib/services/webrtc_client_service.dart`

**Responsibilities:**
- Create RTCPeerConnection to server
- Request SDP offer from server
- Generate and send SDP answer
- Handle ICE candidates
- Provide video stream for rendering

**Key Methods:**
```dart
class WebRTCClientService {
  Future<void> connect({
    required String serverIp,
    required int serverPort,
  });

  Future<void> disconnect();

  // State
  RTCVideoRenderer get videoRenderer;
  Stream<PeerConnectionState> get connectionStateStream;
  Stream<MediaStream?> get remoteStreamStream;
}
```

**Connection Flow:**
1. Create RTCPeerConnection
2. HTTP GET `/offer/:clientId` → Receive SDP offer
3. Set remote description (offer)
4. Create SDP answer
5. HTTP POST `/answer/:clientId` → Send SDP answer
6. Exchange ICE candidates via HTTP POST
7. Wait for connection established
8. Receive remote media stream
9. Attach to video renderer

---

## 6. Provider Layer (State Management)

### 6.1 CameraProvider

**File:** `lib/providers/camera_provider.dart`

**Extends:** `ChangeNotifier`

**State:**
```dart
class CameraProvider extends ChangeNotifier {
  final CameraService _cameraService;

  List<CameraInfo> _availableCameras = [];
  CameraInfo? _selectedCamera;
  bool _isInitializing = false;
  String? _errorMessage;

  // Getters
  List<CameraInfo> get availableCameras;
  CameraInfo? get selectedCamera;
  bool get isInitializing;
  String? get errorMessage;
  bool get hasError;

  // Methods
  Future<void> loadCameras();
  Future<void> selectCamera(String cameraId);
  Future<MediaStream> getCameraStream();
}
```

### 6.2 BroadcastProvider

**File:** `lib/providers/broadcast_provider.dart`

**Extends:** `ChangeNotifier`

**State:**
```dart
class BroadcastProvider extends ChangeNotifier {
  final ServerRegistrationService _registrationService;
  final SignalingServerService _signalingService;
  final WebRTCServerService _webrtcService;

  bool _isBroadcasting = false;
  int _viewerCount = 0;
  Map<String, PeerConnectionState> _clientStates = {};
  String? _errorMessage;

  // Getters
  bool get isBroadcasting;
  int get viewerCount;
  Map<String, PeerConnectionState> get clientStates;
  String? get errorMessage;

  // Methods
  Future<void> startBroadcast({
    required String serverName,
    required MediaStream cameraStream,
  });

  Future<void> stopBroadcast();
}
```

**Broadcast Flow:**
1. Start HTTP signaling server (random available port)
2. Initialize WebRTC service with camera stream
3. Register mDNS service with server details
4. Listen for client connections
5. Update viewer count as clients connect/disconnect

### 6.3 StreamViewerProvider

**File:** `lib/providers/stream_viewer_provider.dart`

**Extends:** `ChangeNotifier`

**State:**
```dart
class StreamViewerProvider extends ChangeNotifier {
  final WebRTCClientService _webrtcService;

  PeerConnectionState _connectionState = PeerConnectionState.disconnected;
  ServerDevice? _connectedServer;
  RTCVideoRenderer? _videoRenderer;
  String? _errorMessage;

  // Getters
  PeerConnectionState get connectionState;
  ServerDevice? get connectedServer;
  RTCVideoRenderer? get videoRenderer;
  String? get errorMessage;
  bool get isConnected;

  // Methods
  Future<void> connectToServer(ServerDevice server);
  Future<void> disconnect();

  @override
  Future<void> dispose();
}
```

---

## 7. UI Components

### 7.1 ServerScreen (Modified)

**File:** `lib/screens/server/server_screen.dart`

**Layout:**
```
┌─────────────────────────────────────┐
│  ← Server Mode                      │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐  │
│  │                               │  │
│  │    Camera Preview             │  │
│  │    (Full screen preview)      │  │
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
│  Camera: [Dropdown: Front/Back]    │
│                                     │
│  Quality: [Dropdown: Auto/Low/Med]  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │   🎥 Start Broadcasting       │  │
│  └───────────────────────────────┘  │
│                                     │
│  Status: Ready / Broadcasting       │
│  Viewers: 0                         │
│                                     │
└─────────────────────────────────────┘
```

**State Management:**
- Uses `MultiProvider` with:
  - `CameraProvider`
  - `BroadcastProvider`

**User Flow:**
1. Screen loads → Auto-load cameras
2. User selects camera from dropdown
3. Preview shows selected camera
4. User selects quality
5. User taps "Start Broadcasting"
6. Camera initializes
7. Broadcast starts
8. mDNS service registered
9. Status shows "Broadcasting"
10. Viewer count updates in real-time

### 7.2 ClientScreen (Modified)

**File:** `lib/screens/client/client_screen.dart`

**Changes:**
- Add tap handler to `ServerListItem`
- Navigate to `StreamViewerScreen` on tap
- Pass `ServerDevice` to viewer screen

**Updated Flow:**
```dart
ServerListItem(
  server: server,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => StreamViewerProvider(WebRTCClientService()),
          child: StreamViewerScreen(server: server),
        ),
      ),
    );
  },
)
```

### 7.3 StreamViewerScreen (New)

**File:** `lib/screens/client/stream_viewer_screen.dart`

**Layout:**
```
┌─────────────────────────────────────┐
│  ← [Server Name]                    │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐  │
│  │                               │  │
│  │    Video Renderer             │  │
│  │    (Remote stream)            │  │
│  │                               │  │
│  │    [Connection indicator]     │  │
│  └───────────────────────────────┘  │
│                                     │
│  Status: Connecting / Connected     │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  🔌 Disconnect             │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

**State Management:**
- Uses `StreamViewerProvider`
- Auto-connects on screen load
- Auto-disconnects on screen pop

**Connection States:**
```dart
switch (connectionState) {
  case PeerConnectionState.disconnected:
    // Show "Tap to connect" button
  case PeerConnectionState.connecting:
    // Show loading spinner
  case PeerConnectionState.connected:
    // Show video stream
  case PeerConnectionState.failed:
    // Show error with retry button
  case PeerConnectionState.closed:
    // Navigate back
}
```

### 7.4 Widgets

#### CameraPreviewWidget

**File:** `lib/widgets/camera_preview_widget.dart`

```dart
class CameraPreviewWidget extends StatelessWidget {
  final CameraController? controller;
  final bool showOverlay;

  // Displays camera preview with aspect ratio
  // Shows loading indicator during initialization
  // Shows error message if camera fails
}
```

#### VideoRendererWidget

**File:** `lib/widgets/video_renderer_widget.dart`

```dart
class VideoRendererWidget extends StatefulWidget {
  final RTCVideoRenderer renderer;
  final bool mirror;

  // Displays remote video stream
  // Handles aspect ratio and orientation
  // Shows placeholder when no stream
}
```

#### ConnectionStatusWidget

**File:** `lib/widgets/connection_status_widget.dart`

```dart
class ConnectionStatusWidget extends StatelessWidget {
  final PeerConnectionState state;

  // Displays connection status with icon and color
  // Connecting: Yellow with spinner
  // Connected: Green with checkmark
  // Failed: Red with error icon
}
```

---

## 8. Local-Only Security (Story 5)

### 8.1 Security Requirements

**No External Servers:**
- ✅ No STUN servers in ICE configuration
- ✅ No TURN servers in ICE configuration
- ✅ All signaling via local HTTP (not WebSocket to external server)
- ✅ mDNS discovery (local network only)

**Network Isolation:**
- ✅ Bind HTTP server to local IP only (not 0.0.0.0)
- ✅ Verify server IP is in private range (10.x, 172.16-31.x, 192.168.x)
- ✅ No external API calls

**Permissions:**
- ✅ Camera permission (already in manifests)
- ✅ Local network permission (already configured)
- ✅ No internet permission abuse

### 8.2 WebRTC Configuration (Local Only)

```dart
final rtcConfiguration = {
  'iceServers': [], // EMPTY = local network candidates only
  'iceTransportPolicy': 'all',
  'iceCandidatePoolSize': 0,
};
```

**ICE Candidate Filtering:**
```dart
peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
  // Filter to only accept local network candidates
  if (candidate.candidate?.contains('typ host') ?? false) {
    // Host candidate = local network
    sendIceCandidate(candidate);
  } else if (candidate.candidate?.contains('typ srflx') ?? false) {
    // Server reflexive = external IP (REJECT)
    return;
  } else if (candidate.candidate?.contains('typ relay') ?? false) {
    // Relay = TURN server (REJECT)
    return;
  }
};
```

### 8.3 HTTP Server Security

**Shelf Server Configuration:**
```dart
final server = await shelf_io.serve(
  handler,
  InternetAddress.anyIPv4, // Listen on all local interfaces
  port,
);

// Add CORS headers for local network access
final handler = const Pipeline()
    .addMiddleware(corsHeaders())
    .addMiddleware(logRequests())
    .addHandler(_router);
```

**CORS Middleware (Local Only):**
```dart
Middleware corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      final response = await handler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*', // OK for local network
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      });
    };
  };
}
```

### 8.4 IP Address Validation

```dart
bool isPrivateIP(String ip) {
  final parts = ip.split('.').map(int.parse).toList();

  // 10.0.0.0/8
  if (parts[0] == 10) return true;

  // 172.16.0.0/12
  if (parts[0] == 172 && parts[1] >= 16 && parts[1] <= 31) return true;

  // 192.168.0.0/16
  if (parts[0] == 192 && parts[1] == 168) return true;

  // 127.0.0.0/8 (localhost)
  if (parts[0] == 127) return true;

  return false;
}
```

---

## 9. Error Handling

### 9.1 Camera Errors

**Scenarios:**
- Camera permission denied
- Camera not available
- Camera in use by another app
- Camera initialization timeout

**Handling:**
```dart
try {
  await _cameraService.initializeCamera(cameraId);
} on CameraException catch (e) {
  switch (e.code) {
    case 'cameraPermission':
      _errorMessage = 'Camera permission denied. Please enable in settings.';
      break;
    case 'cameraNotFound':
      _errorMessage = 'Camera not found. Please check your device.';
      break;
    default:
      _errorMessage = 'Camera error: ${e.description}';
  }
  notifyListeners();
}
```

### 9.2 WebRTC Connection Errors

**Scenarios:**
- Peer connection fails
- Network disconnected during stream
- Signaling server unreachable
- ICE gathering timeout

**Handling:**
```dart
peerConnection.onConnectionState = (RTCPeerConnectionState state) {
  switch (state) {
    case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
      _handleConnectionFailed();
      break;
    case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
      _handleConnectionDisconnected();
      break;
    case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
      _handleConnectionClosed();
      break;
    default:
      break;
  }
};
```

### 9.3 Network Errors

**Scenarios:**
- WiFi disconnected
- Server unreachable
- HTTP signaling timeout

**User Feedback:**
- Show snackbar with error message
- Provide retry button
- Auto-reconnect attempt (with exponential backoff)

---

## 10. Performance Considerations

### 10.1 Video Quality Adaptation

**Strategy:**
- Start with "Auto" quality (720p @ 30fps)
- Monitor network statistics
- Reduce quality if packet loss > 5%
- Increase quality if bandwidth available

### 10.2 Multiple Client Handling

**Server Side:**
- Support up to 5 simultaneous clients
- Each client has separate RTCPeerConnection
- Shared camera MediaStream (single capture)
- Monitor memory usage

**Resource Management:**
```dart
static const maxClients = 5;

Future<RTCSessionDescription> createOffer(String clientId) async {
  if (_clients.length >= maxClients) {
    throw Exception('Maximum clients reached');
  }
  // ... create peer connection
}
```

### 10.3 Memory Management

**Camera Stream:**
- Dispose camera controller when not broadcasting
- Release MediaStream tracks on stop
- Clear video renderer on disconnect

**Peer Connections:**
- Close and remove disconnected peers
- Cleanup timer for stale connections (30 seconds)

---

## 11. Testing Strategy

### 11.1 Unit Tests

**Services:**
- `camera_service_test.dart`: Mock camera access
- `server_registration_service_test.dart`: Mock mDNS
- `signaling_server_service_test.dart`: Test HTTP endpoints
- `webrtc_server_service_test.dart`: Mock peer connections
- `webrtc_client_service_test.dart`: Mock client connection

**Providers:**
- `camera_provider_test.dart`: State transitions
- `broadcast_provider_test.dart`: Start/stop flow
- `stream_viewer_provider_test.dart`: Connection states

### 11.2 Widget Tests

**Screens:**
- `server_screen_test.dart`: UI state, button actions
- `stream_viewer_screen_test.dart`: Connection flow, video display

**Widgets:**
- `camera_preview_widget_test.dart`: Preview states
- `video_renderer_widget_test.dart`: Renderer display
- `connection_status_widget_test.dart`: Status indicators

### 11.3 Integration Tests

**Scenarios:**
1. Start server → Client discovers → Client connects → Video streams
2. Multiple clients connect simultaneously
3. Client disconnects gracefully
4. Server stops while clients connected
5. Network disconnection handling

---

## 12. Implementation Plan

### Phase 1: Foundation (Story 3 - Part 1)
1. Add dependencies to `pubspec.yaml`
2. Create data models (CameraInfo, PeerConnectionState, StreamQuality)
3. Implement CameraService
4. Implement CameraProvider
5. Update ServerScreen with camera selection and preview

### Phase 2: Server Broadcasting (Story 3 - Part 2)
6. Implement ServerRegistrationService
7. Implement SignalingServerService (HTTP server)
8. Implement WebRTCServerService
9. Implement BroadcastProvider
10. Update ServerScreen with broadcast controls

### Phase 3: Client Streaming (Story 4)
11. Implement WebRTCClientService
12. Implement StreamViewerProvider
13. Create StreamViewerScreen
14. Update ClientScreen navigation
15. Create video renderer widget

### Phase 4: Security & Polish (Story 5)
16. Verify no external servers in WebRTC config
17. Add IP address validation (private network only)
18. Filter ICE candidates (local only)
19. Add connection security checks
20. Add connection status indicators

### Phase 5: Testing
21. Write unit tests for all services
22. Write unit tests for all providers
23. Write widget tests for screens
24. Write widget tests for widgets
25. Manual integration testing
26. Fix bugs and polish

---

## 13. Code Snippets (Key Implementations)

### 13.1 WebRTC Server Offer Creation

```dart
Future<RTCSessionDescription> createOffer(String clientId) async {
  // Create peer connection
  final peerConnection = await createPeerConnection({
    'iceServers': [], // Local only
  });

  // Add camera stream
  _cameraStream.getTracks().forEach((track) {
    peerConnection.addTrack(track, _cameraStream);
  });

  // Set up ICE candidate handler
  peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
    _pendingIceCandidates[clientId]?.add(candidate);
  };

  // Create offer
  final offer = await peerConnection.createOffer({
    'offerToReceiveVideo': false,
    'offerToReceiveAudio': false,
  });

  await peerConnection.setLocalDescription(offer);

  // Store peer connection
  _clients[clientId] = peerConnection;

  return offer;
}
```

### 13.2 WebRTC Client Connection

```dart
Future<void> connect({
  required String serverIp,
  required int serverPort,
}) async {
  final baseUrl = 'http://$serverIp:$serverPort';
  final clientId = const Uuid().v4();

  // Create peer connection
  _peerConnection = await createPeerConnection({
    'iceServers': [],
  });

  // Handle remote stream
  _peerConnection!.onTrack = (RTCTrackEvent event) {
    if (event.streams.isNotEmpty) {
      _remoteStream = event.streams[0];
      _remoteStreamController.add(_remoteStream);
    }
  };

  // Request offer from server
  final offerResponse = await http.get(
    Uri.parse('$baseUrl/offer/$clientId'),
  );

  final offerJson = jsonDecode(offerResponse.body);
  final offer = RTCSessionDescription(
    offerJson['sdp'],
    offerJson['type'],
  );

  // Set remote description
  await _peerConnection!.setRemoteDescription(offer);

  // Create answer
  final answer = await _peerConnection!.createAnswer();
  await _peerConnection!.setLocalDescription(answer);

  // Send answer to server
  await http.post(
    Uri.parse('$baseUrl/answer/$clientId'),
    body: jsonEncode({
      'sdp': answer.sdp,
      'type': answer.type,
    }),
  );
}
```

### 13.3 HTTP Signaling Server

```dart
Future<void> start(int port) async {
  final router = shelf_router.Router();

  // Health check
  router.get('/health', (Request request) {
    return Response.ok('OK');
  });

  // Get offer
  router.get('/offer/<clientId>', (Request request, String clientId) async {
    try {
      final offer = await _onOfferRequested?.call(clientId);
      return Response.ok(
        jsonEncode({
          'sdp': offer?.sdp,
          'type': offer?.type,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(body: e.toString());
    }
  });

  // Receive answer
  router.post('/answer/<clientId>', (Request request, String clientId) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body);
      final answer = RTCSessionDescription(json['sdp'], json['type']);

      await _onAnswerReceived?.call(clientId, answer);

      return Response.ok('OK');
    } catch (e) {
      return Response.badRequest(body: e.toString());
    }
  });

  // Start server
  _server = await shelf_io.serve(
    router,
    InternetAddress.anyIPv4,
    port,
  );
}
```

---

## 14. Dependencies Summary

**New packages required:**
```yaml
dependencies:
  flutter_webrtc: ^0.11.7   # WebRTC peer connections
  camera: ^0.11.0+2          # Camera access
  shelf: ^1.4.1              # HTTP server for signaling
  uuid: ^4.5.1               # Generate unique IDs
```

**Already in project:**
- `provider: ^6.1.1` - State management ✅
- `multicast_dns: ^0.3.2+7` - Service discovery ✅
- `network_info_plus: ^6.0.1` - Local IP ✅
- `permission_handler: ^11.3.1` - Permissions ✅

---

## 15. Acceptance Criteria

### Story 3: Camera Broadcasting in Server Mode
- [ ] Server screen shows available cameras
- [ ] User can select front/back camera
- [ ] Camera preview displays correctly
- [ ] User can select video quality (Low/Medium/High/Auto)
- [ ] "Start Broadcasting" button initiates broadcast
- [ ] mDNS service registers with server details
- [ ] HTTP signaling server starts on random port
- [ ] Viewer count displays and updates in real-time
- [ ] "Stop Broadcasting" stops all services gracefully
- [ ] Error handling for camera/network issues

### Story 4: Live Video Stream in Client Mode
- [ ] Tapping server in discovery list navigates to stream viewer
- [ ] Stream viewer auto-connects on screen load
- [ ] Connection status indicator shows state (connecting/connected/failed)
- [ ] Video stream displays in full screen
- [ ] Video aspect ratio maintained
- [ ] Disconnect button stops stream and returns to discovery
- [ ] Error handling with retry option
- [ ] Graceful handling of server disconnect

### Story 5: Local-Only Secure Communication
- [ ] No STUN/TURN servers in WebRTC configuration
- [ ] All signaling via local HTTP (no external WebSocket)
- [ ] ICE candidates filtered to local network only
- [ ] Server IP validated to be private network range
- [ ] No external API calls or data transmission
- [ ] App functions without internet connection (WiFi only)
- [ ] Security audit passes (no external dependencies)

---

## 16. Future Enhancements (Out of Scope)

- Audio streaming
- Recording functionality
- Picture-in-picture mode
- Landscape/portrait orientation handling
- Multiple camera support (picture-in-picture)
- Stream analytics (bitrate, packet loss, etc.)
- Chat functionality
- Screen sharing
- AR effects/filters

---

## Conclusion

This LLD provides a comprehensive blueprint for implementing Stories 3, 4, and 5. The architecture ensures:
- **Modularity:** Clear separation between services, providers, and UI
- **Testability:** Each component can be tested independently
- **Security:** All communication stays within local network
- **Scalability:** Support for multiple simultaneous clients
- **Maintainability:** Well-documented code following Flutter best practices

The implementation will follow a phased approach, building incrementally with testing at each stage.
