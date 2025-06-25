# Kakao Maps Flutter Example

This example project demonstrates the capabilities and features of the Kakao Maps Flutter SDK v2. It provides a comprehensive showcase of various map functionalities and user interactions.

## Features

### 🗺️ Basic Map Controls
- Interactive map view with touch controls
- Zoom level control (1-21)
- Map center point retrieval
- Status bar showing map state (ready/loading, zoom level, POI settings)

### 🎥 Camera Movement & Events
- Animated camera transitions to preset locations:
  - Seoul Station
  - Jamsil Station
  - Gangnam Station
- Custom animation duration and elevation control
- Support for both animated and instant camera movements
- **Camera Move End Events**: Real-time notifications when camera movement completes
  - Displays current position (latitude, longitude)
  - Shows zoom level, tilt angle, and rotation
  - Toggle functionality to enable/disable listener
  - Works with both user gestures and programmatic movements

### 📌 Marker Management
- Add/remove individual markers
- Batch operations for multiple markers
- Custom marker images support
- Clear all markers functionality

### 🏢 POI (Points of Interest) Controls
- Toggle POI visibility
- Toggle POI clickability
- POI scale adjustment:
  - Small (0)
  - Regular (1)
  - Large (2)
  - XLarge (3)

### ⚙️ Advanced Features
- Coordinate conversion between screen and map points
- Map padding adjustment
- Map information retrieval:
  - Current zoom level
  - Map rotation
  - Map tilt
- Viewport bounds retrieval

## Project Structure

```
lib/
├── main.dart              # Main application entry point and map screen
├── assets/
│   └── example_assets.dart # Asset constants and resources
└── widgets/
    ├── widgets.dart        # Widget barrel file
    ├── drawer_components.dart # Reusable drawer components
    ├── feature_drawer.dart   # Main feature navigation drawer
    ├── status_bar.dart      # Map status display
    └── zoom_controls.dart   # Zoom and center controls
```

## Getting Started

1. Clone the repository
2. Replace `YOUR_API_KEY` in `main.dart` with your Kakao Maps API key
3. Run `flutter pub get` to install dependencies
4. Run the example app:
   ```bash
   flutter run
   ```

## Usage Notes

- The example demonstrates proper state management and error handling
- All map operations check for controller availability and widget mounting state
- Platform-specific behavior is handled (e.g., screen coordinate conversion on iOS)
- Comprehensive error messages and user feedback through SnackBars
- Modular widget architecture for better maintainability

## UI Components

### Status Bar
- Shows map readiness state
- Displays current zoom level
- Indicates POI visibility and scale

### Zoom Controls
- Floating action buttons for zoom in/out
- Get center point functionality
- Disabled when map is not ready

### Feature Drawer
- Organized sections for different feature categories
- Enable/disable controls based on map state
- Clear visual feedback for current settings
- **Camera Event Listeners** section with toggle for camera move end events

## Error Handling

The example implements robust error handling:
- Null safety checks for map controller
- Platform-specific feature availability checks
- Widget mounting state verification
- Comprehensive error messages for users
- Exception handling for coordinate conversions

## Best Practices

The code demonstrates Flutter best practices:
- Proper widget lifecycle management
- Efficient state management
- Consistent error handling
- Clean code organization
- Comprehensive documentation
- Platform-specific considerations
