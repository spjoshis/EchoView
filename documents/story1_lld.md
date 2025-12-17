# Story 1: Select App Mode - Low-Level Design (LLD)

## 1. Overview
Implement an app mode selection screen that allows users to choose between Server mode (broadcast camera) and Client mode (view camera stream).

## 2. Architecture Components

### 2.1 Data Models
- **AppMode** (enum): Defines the two operation modes
  - `server`: Device will broadcast camera feed
  - `client`: Device will view camera stream

### 2.2 Screens/Pages
1. **ModeSelectionScreen**:
   - Entry point of the app
   - Displays two prominent cards/buttons for Server and Client modes
   - Handles navigation to respective mode screens

2. **ServerScreen** (Placeholder for Story 3):
   - Will handle camera broadcasting
   - For now: Simple screen acknowledging Server mode

3. **ClientScreen** (Placeholder for Story 2/4):
   - Will handle server discovery and stream viewing
   - For now: Simple screen acknowledging Client mode

### 2.3 Widgets
- **ModeSelectionCard**: Reusable card widget
  - Properties: title, description, icon, onTap callback
  - Styled with Material 3 design
  - Responsive and accessible

## 3. File Structure
```
lib/
├── main.dart                           # App entry point, MaterialApp setup
├── models/
│   └── app_mode.dart                  # AppMode enum definition
├── screens/
│   ├── mode_selection_screen.dart     # Mode selection UI
│   ├── server/
│   │   └── server_screen.dart         # Server mode screen (placeholder)
│   └── client/
│       └── client_screen.dart         # Client mode screen (placeholder)
└── widgets/
    └── mode_selection_card.dart       # Reusable selection card widget
```

## 4. Navigation Flow
```
App Launch
    ↓
ModeSelectionScreen
    ├─→ [Server Selected] → ServerScreen
    └─→ [Client Selected] → ClientScreen
```

## 5. State Management
- **Approach**: Simple stateless navigation (no complex state needed for Story 1)
- **Future**: Will introduce Provider/Riverpod for WebRTC state in Stories 2-5
- **Navigation**: Using Navigator.push for screen transitions

## 6. UI/UX Design

### ModeSelectionScreen Layout
```
┌─────────────────────────────────────┐
│          CamStar                    │
│                                     │
│  ┌──────────────────────────────┐  │
│  │       📡 Server Mode          │  │
│  │                               │  │
│  │  Broadcast your camera feed   │  │
│  │  to other devices             │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │       📱 Client Mode          │  │
│  │                               │  │
│  │  View camera streams from     │  │
│  │  other devices                │  │
│  └──────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### Design Specifications
- **Colors**: Material 3 color scheme with primary/secondary colors
- **Typography**:
  - Title: headlineMedium (24-28sp)
  - Description: bodyLarge (16sp)
- **Spacing**: 16-24dp padding, 16dp gap between cards
- **Card Elevation**: 2dp default, 8dp on hover/press
- **Icons**: Material Icons (cast, devices_other)

## 7. Key Classes and Responsibilities

### AppMode (enum)
```dart
enum AppMode {
  server,
  client,
}
```

### ModeSelectionScreen (StatelessWidget)
- Responsibilities:
  - Display app title/logo
  - Render two ModeSelectionCard widgets
  - Handle navigation on card tap

### ModeSelectionCard (StatelessWidget)
- Properties:
  - `String title`: Card title
  - `String description`: Card description
  - `IconData icon`: Display icon
  - `VoidCallback onTap`: Tap handler
- Responsibilities:
  - Render card with consistent styling
  - Handle tap interactions
  - Provide visual feedback

### ServerScreen (StatelessWidget)
- Placeholder screen
- Will show "Server Mode Active" message
- Back button to return to mode selection

### ClientScreen (StatelessWidget)
- Placeholder screen
- Will show "Client Mode Active" message
- Back button to return to mode selection

## 8. Dependencies Required
```yaml
# No additional dependencies for Story 1
# Using only flutter/material
```

## 9. Accessibility Considerations
- Semantic labels for screen readers
- Minimum touch target size (48x48dp)
- High contrast text/background
- Clear focus indicators

## 10. Testing Strategy

### Unit Tests
- AppMode enum values

### Widget Tests
- ModeSelectionCard widget rendering
- Navigation behavior on card tap
- Proper text and icons display

### Integration Tests
- Complete flow: Launch → Select Mode → Navigate to Screen
- Back navigation from Server/Client screens

## 11. Implementation Phases

### Phase 2A: Core Implementation
1. Create AppMode enum
2. Create ModeSelectionCard widget
3. Create ModeSelectionScreen
4. Create placeholder ServerScreen and ClientScreen
5. Update main.dart to use ModeSelectionScreen as home

### Phase 2B: Polish
1. Add animations/transitions
2. Improve styling and theming
3. Add proper spacing and responsive design

### Phase 3: Testing
1. Write widget tests for ModeSelectionCard
2. Write widget tests for ModeSelectionScreen
3. Write integration test for navigation flow
4. Manual testing on different screen sizes

## 12. Success Criteria
- ✅ User sees clear Server/Client choice on app launch
- ✅ Tapping Server navigates to ServerScreen
- ✅ Tapping Client navigates to ClientScreen
- ✅ Back button returns to mode selection
- ✅ UI is responsive and accessible
- ✅ All tests pass
