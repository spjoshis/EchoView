# Story 2: Discover Server Devices on Local Network - Low-Level Design (LLD)

## 1. Overview
Implement automatic discovery of server devices on the local network using mDNS (Multicast DNS) / Bonjour / Zeroconf. Client devices should be able to find all available CamStar servers broadcasting on the same Wi-Fi network.

## 2. Architecture Components

### 2.1 Data Models
- **ServerDevice** (class):
  - `String id`: Unique identifier (could be IP + port)
  - `String name`: Device/server name
  - `String ipAddress`: IPv4/IPv6 address
  - `int port`: Service port number
  - `DateTime discoveredAt`: Discovery timestamp
  - `Map<String, String> attributes`: Additional service attributes

### 2.2 Services
1. **ServerDiscoveryService**:
   - Uses `multicast_dns` package for mDNS discovery
   - Service type: `_camstar._tcp` (custom service identifier)
   - Continuously scans for available servers
   - Maintains list of discovered servers
   - Handles server timeout/removal when unavailable

2. **ServerRegistrationService** (for Story 3, but plan now):
   - Registers server device on network using mDNS
   - Broadcasts server availability
   - Updates service attributes

### 2.3 State Management
- **Provider** or **Riverpod** for state management
  - `DiscoveredServersProvider`: List of discovered servers
  - `DiscoveryStateProvider`: Discovery status (scanning, idle, error)
  - Auto-updates UI when servers appear/disappear

### 2.4 UI Components
1. **Update ClientScreen**:
   - Show loading indicator while scanning
   - Display list of discovered servers
   - Show "No servers found" message if list is empty
   - Refresh button to restart discovery
   - Each server item shows: name, IP, discovery time
   - Tap on server to connect (Story 4)

## 3. File Structure
```
lib/
├── models/
│   ├── app_mode.dart
│   └── server_device.dart              # NEW
├── services/
│   ├── server_discovery_service.dart   # NEW
│   └── server_registration_service.dart # NEW (placeholder for Story 3)
├── providers/
│   └── server_discovery_provider.dart  # NEW
├── screens/
│   ├── mode_selection_screen.dart
│   ├── server/
│   │   └── server_screen.dart
│   └── client/
│       └── client_screen.dart          # UPDATED
└── widgets/
    ├── mode_selection_card.dart
    └── server_list_item.dart           # NEW
```

## 4. Dependencies Required
```yaml
dependencies:
  # State management
  provider: ^6.1.1

  # Network service discovery
  multicast_dns: ^0.3.2+7

  # Network info (get local IP)
  network_info_plus: ^6.0.1

  # Permissions
  permission_handler: ^11.3.1
```

## 5. mDNS Service Discovery Flow

```
Client App Launch
    ↓
Select Client Mode
    ↓
ClientScreen init
    ↓
Start ServerDiscoveryService
    ↓
Broadcast mDNS query: "_camstar._tcp.local"
    ↓
Listen for responses
    ↓
┌─────────────────────────┐
│ Server responds?        │
├─────────────────────────┤
│ YES: Add to list        │ → Update UI
│ NO: Show "No servers"   │ → Show empty state
└─────────────────────────┘
    ↓
Continuous monitoring
    ↓
Remove servers if not responding (timeout)
```

## 6. Data Flow

```
ServerDiscoveryService
        ↓
    (discovers servers)
        ↓
ServerDiscoveryProvider (ChangeNotifier/StateNotifier)
        ↓
    (notifies listeners)
        ↓
ClientScreen (Consumer widget)
        ↓
    (rebuilds with updated list)
        ↓
ServerListItem widgets
```

## 7. Key Classes and Responsibilities

### ServerDevice Model
```dart
class ServerDevice {
  final String id;
  final String name;
  final String ipAddress;
  final int port;
  final DateTime discoveredAt;
  final Map<String, String> attributes;

  // Methods: fromMDNSRecord, toJson, fromJson
}
```

### ServerDiscoveryService
```dart
class ServerDiscoveryService {
  // Properties
  final MDnsClient _mdnsClient;
  final String _serviceType = '_camstar._tcp';
  StreamController<List<ServerDevice>> _serversController;

  // Methods
  Future<void> startDiscovery();
  Future<void> stopDiscovery();
  Stream<List<ServerDevice>> get serversStream;
  void _handleServiceDiscovered(PtrResourceRecord ptr);
  void _removeExpiredServers();
}
```

### ServerDiscoveryProvider
```dart
class ServerDiscoveryProvider extends ChangeNotifier {
  List<ServerDevice> _servers = [];
  DiscoveryState _state = DiscoveryState.idle;

  // Getters
  List<ServerDevice> get servers => _servers;
  DiscoveryState get state => _state;

  // Methods
  void startDiscovery();
  void stopDiscovery();
  void refresh();
}
```

### Updated ClientScreen
```dart
class ClientScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ServerDiscoveryProvider()..startDiscovery(),
      child: Consumer<ServerDiscoveryProvider>(
        builder: (context, provider, child) {
          // Show loading, empty state, or server list
        },
      ),
    );
  }
}
```

## 8. UI/UX Design

### ClientScreen Updated Layout
```
┌─────────────────────────────────────┐
│  ← Client Mode                      │
├─────────────────────────────────────┤
│                                     │
│  Scanning for servers... 🔍         │
│                                     │
│  ┌──────────────────────────────┐  │
│  │ 📱 Living Room iPad          │  │
│  │ 192.168.1.105:8080           │  │
│  │ Discovered 2 seconds ago     │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │ 📱 Kitchen Phone              │  │
│  │ 192.168.1.108:8080           │  │
│  │ Discovered 5 seconds ago     │  │
│  └──────────────────────────────┘  │
│                                     │
│  [🔄 Refresh]                       │
│                                     │
└─────────────────────────────────────┘

Empty State:
┌─────────────────────────────────────┐
│  ← Client Mode                      │
├─────────────────────────────────────┤
│                                     │
│          🔍                          │
│                                     │
│   No servers found                  │
│                                     │
│   Make sure:                        │
│   • You're on the same Wi-Fi        │
│   • A server is running             │
│                                     │
│  [🔄 Refresh]                       │
│                                     │
└─────────────────────────────────────┘
```

## 9. Platform-Specific Considerations

### Android
- Requires `android.permission.INTERNET`
- Requires `android.permission.ACCESS_WIFI_STATE`
- Requires `android.permission.CHANGE_WIFI_MULTICAST_STATE`
- Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE"/>
```

### iOS
- Requires `NSLocalNetworkUsageDescription` in `Info.plist`
- Requires `NSBonjourServices` in `Info.plist` with `_camstar._tcp`
- Add to `Info.plist`:
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>CamStar needs local network access to discover camera servers</string>
<key>NSBonjourServices</key>
<array>
    <string>_camstar._tcp</string>
</array>
```

## 10. Error Handling
- Network unavailable: Show error message
- Permission denied: Request permissions, show explanation
- mDNS timeout: Implement retry logic
- No Wi-Fi connection: Show specific message

## 11. Testing Strategy

### Unit Tests
- ServerDevice model serialization/deserialization
- ServerDiscoveryService mDNS query construction
- Provider state management logic

### Widget Tests
- ClientScreen displays loading state
- ClientScreen displays server list
- ClientScreen displays empty state
- Refresh button triggers re-scan
- Server list items render correctly

### Integration Tests
- Full discovery flow (requires mock mDNS)
- Server appearing and disappearing
- Multiple servers discovery

## 12. Implementation Phases

### Phase 2A: Setup & Dependencies
1. Add dependencies to pubspec.yaml
2. Configure Android permissions
3. Configure iOS permissions

### Phase 2B: Models & Services
1. Create ServerDevice model
2. Create ServerDiscoveryService
3. Implement mDNS client wrapper
4. Add server timeout logic

### Phase 2C: State Management
1. Choose Provider vs Riverpod
2. Create ServerDiscoveryProvider
3. Wire up service to provider
4. Handle state updates

### Phase 2D: UI Implementation
1. Update ClientScreen with Provider
2. Create ServerListItem widget
3. Implement loading state
4. Implement empty state
5. Implement server list
6. Add refresh functionality

### Phase 3: Testing
1. Unit tests for models
2. Unit tests for services
3. Widget tests for UI components
4. Integration tests for discovery flow
5. Manual testing on real devices

## 13. Success Criteria
- ✅ Client automatically discovers servers within 2-3 seconds
- ✅ UI updates in real-time as servers appear/disappear
- ✅ "No servers found" message displays when no servers available
- ✅ Refresh functionality works correctly
- ✅ Server list shows name, IP, port, and discovery time
- ✅ Permissions requested and handled properly on both platforms
- ✅ All tests pass

## 14. Future Enhancements (Not in this story)
- Server filtering/sorting
- Server signal strength indicator
- Server metadata (camera type, resolution)
- Manual IP entry fallback
- Server favorites/history
