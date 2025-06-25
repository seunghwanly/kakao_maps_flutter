# kakao_maps_flutter

[![pub package](https://img.shields.io/pub/v/kakao_maps_flutter.svg)](https://pub.dev/packages/kakao_maps_flutter)
[![Platform](https://img.shields.io/badge/platform-android%20|%20ios-green.svg)](https://github.com/seunghwanly/kakao_maps_flutter)

A Flutter plugin for integrating Kakao Maps SDK v2, providing a native map experience for both Android and iOS platforms.

## 📱 Platform Support

| Feature | Android | iOS |
|---------|---------|-----|
| Camera Controls | ✅ | ✅ |
| Marker Management | ✅ | ✅ |
| InfoWindow Management | ✅ | ✅ |
| Custom GUI Components | ✅ | ✅ |
| POI Controls | ✅ | ✅ |
| Compass Controls | ✅ | ✅ |
| ScaleBar Controls | ✅ | ✅ |
| Logo Controls | ✅ | ✅ |
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

### 💬 InfoWindow Management

- Add/remove individual info windows
- Batch operations for multiple info windows
- Text-based info windows with title and snippet
- Custom GUI-based info windows with rich layouts
- Click event handling for info windows
- Offset positioning for precise placement
- Custom background images and styling

### 🎨 Custom GUI Components (InfoWindows)

- **GuiText**: Customizable text components with color, size, and stroke
- **GuiImage**: Support for base64 images, resources, and nine-patch scaling
- **GuiLayout**: Flexible container layouts (horizontal/vertical orientation)
- **Complex Layouts**: Nested components for rich info window designs

### 🏢 POI (Points of Interest) Controls

- Toggle POI visibility
- Toggle POI clickability
- Adjustable POI scale levels:
  - Small (0)
  - Regular (1)
  - Large (2)
  - XLarge (3)

### 🧭 Compass Controls

- Show/hide compass widget
- Position compass with custom alignment and offset
- Configure back-to-north functionality on click
- Supported alignments: `topLeft`, `topRight`, `bottomLeft`, `bottomRight`, `center`, `topCenter`, `bottomCenter`, `leftCenter`, `rightCenter`

### 📏 ScaleBar Controls

- Show/hide scale bar widget
- Configure auto-hide functionality
- Customize fade in/out timing and retention duration
- Position scale bar with custom alignment and offset

### 🏷️ Logo Controls

- Show/hide Kakao logo
- Position logo with custom alignment and offset
- Note: Logo position control is limited on Android due to SDK restrictions

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
        // Optional: Configure compass, scalebar, and logo
        compass: CompassOption(
          alignment: 'topRight',
          offset: Offset(16, 16),
          isBackToNorthOnClick: true,
        ),
        scaleBar: ScaleBarOption(
          alignment: 'bottomLeft',
          offset: Offset(16, 16),
          isAutoHide: false,
          fadeInTime: 300,
          fadeOutTime: 300,
          retentionTime: 3000,
        ),
        logo: LogoOption(
          alignment: 'bottomRight',
          offset: Offset(16, 16),
        ),
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
- `compass`: Optional `CompassOption` to configure the compass widget
- `scaleBar`: Optional `ScaleBarOption` to configure the scale bar widget
- `logo`: Optional `LogoOption` to configure the logo widget

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

4. Compass Controls:

```dart
// Show/hide compass
await controller.showCompass();
await controller.hideCompass();

// Set compass position
await controller.setCompassPosition(
  alignment: 'topRight',
  offset: Offset(16, 16),
);
```

5. ScaleBar Controls:

```dart
// Show/hide scale bar
await controller.showScaleBar();
await controller.hideScaleBar();

// Configure scale bar (done through initial configuration)
// Auto-hide, fade timing, and retention duration are set during map creation
```

6. Logo Controls:

```dart
// Show/hide logo
await controller.showLogo();
await controller.hideLogo();

// Set logo position
await controller.setLogoPosition(
  alignment: 'bottomRight',
  offset: Offset(16, 16),
);
```

7. InfoWindow Management:

```dart
// Add a simple text-based info window
await controller.addInfoWindow(
  infoWindowOption: InfoWindowOption(
    id: 'info_1',
    latLng: LatLng(latitude: 37.5665, longitude: 126.9780),
    title: 'Seoul Station',
    snippet: 'Main railway station in Seoul',
    offset: InfoWindowOffset(x: 0, y: -20),
  ),
);

// Add a custom GUI-based info window
const customInfoWindow = InfoWindowOption.custom(
  id: 'custom_info',
  latLng: LatLng(latitude: 37.5665, longitude: 126.9780),
  body: GuiLayout(
    orientation: Orientation.horizontal,
    children: [
      GuiImage.fromBase64(
        base64EncodedImage: 'your_base64_image',
      ),
      GuiText(
        text: 'Custom InfoWindow',
        textSize: 16,
        textColor: 0xFF333333,
      ),
    ],
    background: GuiImage.fromBase64(
      base64EncodedImage: 'background_image',
      isNinepatch: true,
      fixedArea: GuiImageFixedArea(left: 10, top: 10, right: 10, bottom: 10),
    ),
  ),
);

await controller.addInfoWindow(infoWindowOption: customInfoWindow);

// Listen to info window click events
controller.onInfoWindowClickedStream.listen((event) {
  print('InfoWindow clicked: ${event.infoWindowId}');
});

// Remove an info window
await controller.removeInfoWindow(id: 'info_1');

// Clear all info windows
await controller.clearInfoWindows();
```

8. Map Information:

```dart
// Get current map info
final mapInfo = await controller.getMapInfo();
print('Zoom: ${mapInfo?.zoomLevel}');
print('Rotation: ${mapInfo?.rotation}°');
print('Tilt: ${mapInfo?.tilt}°');
```

### Configuration Options

#### CompassOption

```dart
CompassOption({
  String alignment = 'topRight',  // Position alignment
  Offset offset = Offset.zero,    // Offset from alignment position
  bool isBackToNorthOnClick = true, // Enable back-to-north on click
})
```

#### ScaleBarOption

```dart
ScaleBarOption({
  String alignment = 'bottomLeft', // Position alignment
  Offset offset = Offset.zero,     // Offset from alignment position
  bool isAutoHide = false,         // Auto-hide functionality
  int fadeInTime = 300,            // Fade in duration (ms)
  int fadeOutTime = 300,           // Fade out duration (ms)
  int retentionTime = 3000,        // Retention duration (ms)
})
```

#### LogoOption

```dart
LogoOption({
  String alignment = 'bottomRight', // Position alignment
  Offset offset = Offset.zero,      // Offset from alignment position
})
```

### Supported Alignments

All widget positioning supports the following alignment values:

- `topLeft`: Top-left corner
- `topRight`: Top-right corner
- `bottomLeft`: Bottom-left corner
- `bottomRight`: Bottom-right corner
- `center`: Center of the map
- `topCenter`: Top center
- `bottomCenter`: Bottom center
- `leftCenter`: Left center
- `rightCenter`: Right center

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

### ✅ Recently Implemented

- **Compass Controls**: Complete support for compass widget with positioning and back-to-north functionality
- **ScaleBar Controls**: Full control over scale bar widget with auto-hide and fade timing options
- **Logo Controls**: Logo visibility and positioning controls (with platform-specific limitations)
- **InfoWindow Management**: Complete support for text-based and GUI-based info windows
- **Custom GUI Components**: Rich layout system with GuiText, GuiImage, and GuiLayout
- **InfoWindow Events**: Click event handling and callbacks
- **Nine-patch Images**: Support for scalable background images

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Thanks to Kakao for providing the Maps SDK
- Special thanks to all contributors