# Business Requirements Document (BRD)
### Project: Local Wi-Fi Video Streaming App (Flutter + Offline WebRTC)  
### Version: 1.1  

---

## 1. Purpose
Develop a cross-platform mobile application (Android & iOS) using **Flutter** that enables real-time camera video streaming between devices connected to the **same Wi-Fi network**, without using the internet or any paid third-party services.

---

## 2. Goals & Objectives
- Enable real-time, low-latency video streaming over a **local network** only.  
- Use **WebRTC** for peer-to-peer media transmission with offline signaling.  
- Provide simple user roles: **Server** (camera broadcaster) and **Client** (viewer).  
- Ensure no external servers, cloud services, or internet connectivity are required.

---

## 3. Scope

### In Scope
- Flutter-based Android & iOS application.  
- Local-only WebRTC communication.  
- LAN-based signaling (WebSocket server, mDNS, or local HTTP).  
- Mode selection: **Server** or **Client**.  
- Real-time camera streaming.  
- Multiple clients connecting to one server.

### Out of Scope
- Cloud or internet-based calling.  
- User authentication or account system.  
- Subscription-based or paid third-party services.  
- Recording, editing, or saving streams.

---

## 4. User Roles

### Server
- Starts video broadcast.  
- Selects front or back camera.  
- Allows multiple clients to connect and view stream.  

### Client
- Discovers available servers within the same Wi-Fi network.  
- Connects to selected server.  
- Views real-time video feed.

---

## 5. Functional Requirements

### 5.1 Mode Selection
- User chooses between **Server** and **Client** mode on app launch.

### 5.2 LAN Discovery
- Server advertises its availability over local Wi-Fi.  
- Client automatically discovers available servers using LAN broadcast/mDNS.

### 5.3 Offline WebRTC
- WebRTC peer connection must be established **without internet**.  
- Local signaling must be implemented within the same network.

### 5.4 Server Mode
- Access device camera.  
- Stream video via WebRTC to connected clients.  
- Handle multiple client connections.

### 5.5 Client Mode
- Display incoming video stream in real time.  
- Reconnect if connection drops.

### 5.6 Local-Only Communication
- All communication must remain inside the LAN.  
- App must work even if Wi-Fi router has **no internet connection**.

### 5.7 Permissions
- Camera access (Server mode).  
- Local network access (required especially on iOS).

---

## 6. Non-Functional Requirements

### 6.1 Performance
- Target real-time streaming with latency <150–200ms.  
- Adaptive video resolution based on network capability.

### 6.2 Compatibility
- Compatible with modern Android and iOS versions.  
- Implement using Flutter WebRTC plugin.

### 6.3 Reliability
- Smooth reconnection in case of Wi-Fi drops.  
- Stable multi-client viewing.

### 6.4 Security
- No data leaves the local network.  
- No external servers or paid services used.

### 6.5 Usability
- Intuitive UI with minimal setup steps.

---

## 7. Assumptions
- All devices are on the same Wi-Fi network.  
- Network supports peer-to-peer communication.  
- Users grant required permissions.  

---

## 8. Constraints
- No STUN/TURN servers hosted on the internet.  
- No paid third-party SDKs.  
- Offline-only WebRTC setup must work without internet.  
- iOS local network permission requirements must be respected.  

---

## 9. Success Criteria
- Server device streams its camera feed over LAN.  
- Client devices discover and view video with minimal delay.  
- App runs on both Android & iOS without internet dependency.  
- Video quality and latency meet real-time requirements.
