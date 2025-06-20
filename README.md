# kakao_maps_flutter

[![pub package](https://img.shields.io/pub/v/kakao_maps_flutter.svg)](https://pub.dev/packages/kakao_maps_flutter)
[![Platform](https://img.shields.io/badge/platform-android%20|%20ios-green.svg)](https://github.com/seunghwanly/kakao_maps_flutter)

A Flutter plugin for integrating Kakao Maps SDK v2, providing a native map experience for both Android and iOS platforms.

## 📱 Platform Support

| Feature | Android | iOS |
|---------|---------|-----|
| Camera Controls | ✅ | ✅ |
| Marker Management | ✅ | ✅ |
| POI Controls | ✅ | ✅ |
| Coordinate Conversion | ✅ | ❌ |
| Map Information | ✅ | ✅ |

## Features

### 🗺️ Core Map Features

- Native map view integration for Android and iOS
- Zoom level control (1-21)
- Camera position and movement control
- Map center point retrieval
- Map information (zoom, rotation, tilt)
- Viewport bounds management

### 📍 Marker Management

- Add/remove individual markers
- Batch operations for multiple markers
- Custom marker images support (base64 encoded)
- Clear all markers functionality

### 🏢 POI (Points of Interest) Controls

- Toggle POI visibility
- Toggle POI clickability
- Adjustable POI scale levels:
  - Small (0)
  - Regular (1)
  - Large (2)
  - XLarge (3)

### 🎥 Camera Controls

- Animated camera movements
- Custom animation duration
- Auto elevation support
- Consecutive movement control
- Tilt and rotation adjustments

### 🔄 Coordinate Conversion

- Convert between map coordinates (LatLng) and screen points
- Support for viewport bounds calculation
- Map padding adjustment

## Getting Started

### Prerequisites

1. Obtain a Kakao Maps API key from the [Kakao Developers Console](https://developers.kakao.com)
2. Configure your project for Kakao Maps SDK (see platform-specific setup below)

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  kakao_maps_flutter: ^latest_version
```

### Basic Usage

1. Initialize the SDK:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KakaoMapsFlutter.init('YOUR_API_KEY');
  runApp(const MyApp());
}
```

2. Add a map to your widget:

```dart
class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KakaoMap(
        onMapCreated: (controller) {
          // Store controller for map operations
        },
        initialPosition: LatLng(latitude: 37.5665, longitude: 126.9780), // Seoul City Hall
        initialLevel: 15, // Zoom level 15
      ),
    );
  }
}
```

### Map Widget Parameters

The `KakaoMap` widget accepts the following parameters:

- `onMapCreated`: Callback function called when the map is created and ready to use
- `initialPosition`: Optional `LatLng` that sets the initial center position of the map. If not provided, the map will use its default center position
- `initialLevel`: Optional `int` that sets the initial zoom level of the map. Valid range is 1-21. If not provided, the map will use its default zoom level
- `width`: Optional width of the map widget. If null, uses the maximum available width
- `height`: Optional height of the map widget. If null, uses the maximum available height

### Map Operations

1. Camera Movement:

```dart
await controller.moveCamera(
  cameraUpdate: CameraUpdate.fromLatLng(
    LatLng(latitude: 37.5665, longitude: 126.9780),
  ),
  animation: const CameraAnimation(
    duration: 1500,
    autoElevation: true,
    isConsecutive: false,
  ),
);
```

2. Marker Management:

```dart
// Add a marker
await controller.addMarker(
  labelOption: LabelOption(
    id: 'marker_id',
    latLng: LatLng(latitude: 37.5665, longitude: 126.9780),
    base64EncodedImage: 'your_base64_image',
  ),
);

// Remove a marker
await controller.removeMarker(id: 'marker_id');
```

3. POI Controls:

```dart
// Toggle POI visibility
await controller.setPoiVisible(isVisible: true);

// Set POI scale
await controller.setPoiScale(scale: 1); // Regular size
```

4. Map Information:

```dart
// Get current map info
final mapInfo = await controller.getMapInfo();
print('Zoom: ${mapInfo?.zoomLevel}');
print('Rotation: ${mapInfo?.rotation}°');
print('Tilt: ${mapInfo?.tilt}°');
```

---

### Troubleshooting: Kakao Maps Android SDK Dependency Error

If you see the following error when building your project:

```
Could not find com.kakao.maps.open:android:2.12.8.
```

You need to add the Kakao Maps Maven repository to your `android/build.gradle` file. Open `android/build.gradle` and add the following inside the `allprojects > repositories` block:

```groovy
allprojects {
    repositories {
        // ... other repositories ...
        maven { url 'https://devrepo.kakao.com/nexus/repository/kakaomap-releases/' }
    }
}
```

This will allow Gradle to find and download the Kakao Maps SDK for Android.

## Future Plans

### Upcoming Features

1. Map Events and Callbacks
   - Touch events
   - Camera movement events

2. Advanced Marker Features
   - Custom marker views
   - Marker clustering
   - Marker animations
   - InfoWindow customization

3. Polyline and Polygon Support
   - Draw paths and regions
   - Customize styles
   - Interactive editing

4. Local Search Integration
   - POI search
   - Address search
   - Reverse geocoding

5. Advanced Map Features
   - Custom map styles
   - Indoor maps
   - 3D building display
   - Traffic information

6. Performance Optimizations
   - Marker rendering optimization
   - Memory management improvements
   - Caching mechanisms

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Thanks to Kakao for providing the Maps SDK
- Special thanks to all contributors