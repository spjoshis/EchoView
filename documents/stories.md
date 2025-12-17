# User Stories

## Story 1: Select App Mode
**As a** user  
**I want** to choose between Server mode and Client mode when I open the app  
**So that** I can either broadcast my camera or view another device's stream.

**Acceptance Criteria:**
- User is shown a clear choice: “Server” or “Client.”
- Selection leads to respective mode screens.
- Mode can be changed by restarting the app or via settings (optional).


## Story 2: Discover Server Devices on Local Network
**As a** client user  
**I want** the app to automatically discover all available server devices on the same Wi-Fi network  
**So that** I can easily select and connect to a camera stream.

**Acceptance Criteria:**
- Server devices are visible within a few seconds using LAN discovery (mDNS or broadcast).
- Client sees a list of available servers.
- If no servers are found, user is shown a clear message.


## Story 3: Broadcast Camera Feed in Server Mode
**As a** server user  
**I want** to start streaming my device’s camera using WebRTC over the local network  
**So that** other devices can view the live video feed.

**Acceptance Criteria:**
- Server can select front or back camera.
- Server successfully streams video to one or more clients.
- Stream is local-only and works without internet.
- Streaming can be started or stopped anytime.


## Story 4: View Live Video Stream in Client Mode
**As a** client user  
**I want** to connect to a selected server and view the real-time video feed  
**So that** I can see the camera stream instantly and smoothly.

**Acceptance Criteria:**
- Client connects using offline WebRTC signaling.
- Video feed displays with minimal latency (<200ms target).
- Automatic reconnection on minor network interruptions.
- User can exit stream anytime.


## Story 5: Ensure Local-Only Secure Communication
**As a** privacy-conscious user  
**I want** all video communication to stay strictly within the local Wi-Fi network  
**So that** no data is sent to the internet or external servers.

**Acceptance Criteria:**
- No external STUN/TURN servers are used.
- All signaling and media exchange remain within local LAN.
- App functions even if router has no internet.
- Permissions (camera, local network) are requested transparently.
