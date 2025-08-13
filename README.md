# kakao_maps_flutter

[![pub package](https://img.shields.io/pub/v/kakao_maps_flutter.svg)](https://pub.dev/packages/kakao_maps_flutter)
[![Platform](https://img.shields.io/badge/platform-android%20|%20ios-green.svg)](https://github.com/seunghwanly/kakao_maps_flutter)
[![Documentation](https://img.shields.io/badge/documentation-91.4%25-brightgreen.svg)](https://pub.dev/documentation/kakao_maps_flutter)

Note: Korean documentation is available at [README_KO.md](README_KO.md).

A Flutter plugin for integrating Kakao Maps SDK v2, providing a native map experience for both Android and iOS platforms.

## 📱 Platform Support

| Feature | Android | iOS | Documentation |
|---------|---------|-----|---------------|
| Camera Controls | ✅ | ✅ | ✅ |
| Camera Move End Events | ✅ | ✅ | ✅ |
| Label Click Events | ✅ | ✅ | ✅ |
| InfoWindow Click Events | ✅ | ✅ | ✅ |
| Marker Management | ✅ | ✅ | ✅ |
| MarkerStyle Registration | ✅ | ✅ | ✅ |
| LOD Marker Layer | ✅ | ✅ | ✅ |
| InfoWindow Management | ✅ | ✅ | ✅ |
| InfoWindow Layer Visibility | ✅ | ✅ | ✅ |
| Custom GUI Components | ✅ | ✅ | ✅ |
| POI Controls | ✅ | ✅ | ✅ |
| Compass Controls | ✅ | ✅ | ✅ |
| ScaleBar Controls | ✅ | ✅ | ✅ |
| Logo Position | ✅ | ✅ | ✅ |
| Logo Visibility | ❌ | ✅ | ✅ |
| Coordinate Conversion | ✅ | ❌ | ✅ |
| Map Information | ✅ | ✅ | ✅ |

---

## Getting Started

### Prerequisites
1. Get API key from [Kakao Developers Console](https://developers.kakao.com/console/app)
2. Configure platform-specific SDK setup

### References
- Android Getting Started: https://apis.map.kakao.com/android_v2/docs/getting-started/
- iOS Getting Started: https://apis.map.kakao.com/ios_v2/docs/getting-started/gettingstarted/

### Terms and usage notes
- Separate agreement to Kakao Maps SDK Terms of Use required
- Kakao developer site: https://developers.kakao.com/console/app
- Quota limits may apply for commercial use

### Installation
Add to `pubspec.yaml`

```yaml
dependencies:
  kakao_maps_flutter: ^latest_version
```

SDK initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KakaoMapsFlutter.init('YOUR_API_KEY');
  runApp(const MyApp());
}
```

Add map widget

```dart
class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KakaoMap(
        onMapCreated: (controller) {},
        initialPosition: LatLng(latitude: 37.5665, longitude: 126.9780),
        initialLevel: 15,
      ),
    );
  }
}
```


### Usage

1. Camera movement
```dart
await controller.moveCamera(
  cameraUpdate: CameraUpdate.fromLatLng(
    LatLng(latitude: 37.5665, longitude: 126.9780),
  ),
  animation: const CameraAnimation(
    duration: 1000,
    autoElevation: true,
    isConsecutive: false,
  ),
);
```

2. Add/Remove marker
```dart
await controller.addMarker(
  markerOption: const MarkerOption(
    id: 'marker_id',
    latLng: LatLng(latitude: 37.5665, longitude: 126.9780),
  ),
);

await controller.removeMarker(id: 'marker_id');
```

3. Toggle POI visibility
```dart
await controller.setPoiVisible(isVisible: true); // or false
```

4. Camera move end events
```dart
final cameraMoveEndSub = controller.onCameraMoveEndStream.listen((event) {
  debugPrint('moved: ${event.latitude}, ${event.longitude}');
});
```

5. Label click events
```dart
final labelClickSub = controller.onLabelClickedStream.listen((event) {
  debugPrint('label clicked: ${event.labelId}');
});
```

6. Add/Remove InfoWindow
```dart
await controller.addInfoWindow(
  infoWindowOption: const InfoWindowOption(
    id: 'info_1',
    latLng: LatLng(latitude: 37.5665, longitude: 126.9780),
    title: 'Seoul Station',
    snippet: 'Main railway station in Seoul',
    offset: InfoWindowOffset(x: 0, y: -20),
  ),
);

await controller.removeInfoWindow(id: 'info_1');
```


7. Add/Use MarkerStyle
```dart
// import 'dart:convert'; // for base64Decode

// 1) Define Styles
final styles = [
  MarkerStyle(
    styleId: 'default_marker_style_001',
    perLevels: [
      MarkerPerLevelStyle.fromBytes(
        bytes: base64Decode('BASE64_IMAGE_2X'),
        textStyle: const MarkerTextStyle(
          fontSize: 24,
          fontColorArgb: 0xFF000000,
        ),
        level: 6,
      ),
      MarkerPerLevelStyle.fromBytes(
        bytes: base64Decode('BASE64_IMAGE_4X'),
        textStyle: const MarkerTextStyle(
          fontSize: 20,
          fontColorArgb: 0xFF000000,
        ),
        level: 21,
      ),
    ],
  ),
];

// 2) Register
await controller.registerMarkerStyles(styles: styles);

// 3) Use
await controller.addMarker(
  markerOption: MarkerOption(
    id: 'marker_with_style',
    latLng: LatLng(latitude: 37.5665, longitude: 126.9780),
    styleId: 'default_marker_style_001',
  ),
);
```


### 🔧 Troubleshooting: Kakao Maps Android SDK repository
Add repository on Gradle when error occurs

```
Could not find com.kakao.maps.open:android:2.12.8.
```

Add to `android/build.gradle`

```groovy
allprojects {
    repositories {
        // ... other repositories ...
        maven { url 'https://devrepo.kakao.com/nexus/repository/kakaomap-releases/' }
    }
}
```

---

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

**@Kakao** for providing the excellent KakaoMapsSDK.

**All contributors** for helping build this project together 🙏
