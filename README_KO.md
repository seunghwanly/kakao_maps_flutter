# kakao_maps_flutter (🇰🇷 KO)

[![pub package](https://img.shields.io/pub/v/kakao_maps_flutter.svg)](https://pub.dev/packages/kakao_maps_flutter)
[![Platform](https://img.shields.io/badge/platform-android%20|%20ios-green.svg)](https://github.com/seunghwanly/kakao_maps_flutter)
[![Documentation](https://img.shields.io/badge/documentation-91.4%25-brightgreen.svg)](https://pub.dev/documentation/kakao_maps_flutter)

Flutter용 Kakao Maps SDK v2 플러그인

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

### 사전 준비
1. [Kakao Developers Console](https://developers.kakao.com/console/app)에서 API 키 발급
2. 플랫폼별 SDK 설정 구성

### 참고 문서
- Android Getting Started: https://apis.map.kakao.com/android_v2/docs/getting-started/
- iOS Getting Started: https://apis.map.kakao.com/ios_v2/docs/getting-started/gettingstarted/

### 약관 및 사용 안내
- 이 패키지를 사용하려면 별도로 **Kakao Maps SDK 이용약관 동의**가 필요해요
- Kakao 개발자 사이트: https://developers.kakao.com/console/app
- 상업적 사용 시 할당량 제한 적용 안내

### 설치
`pubspec.yaml` 추가

```yaml
dependencies:
  kakao_maps_flutter: ^latest_version
```

SDK 초기화

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KakaoMapsFlutter.init('YOUR_API_KEY');
  runApp(const MyApp());
}
```

지도 위젯 추가

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

### 예제

1. 카메라 이동
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

2. 마커 추가/제거
```dart
await controller.addMarker(
  markerOption: const MarkerOption(
    id: 'marker_id',
    latLng: LatLng(latitude: 37.5665, longitude: 126.9780),
  ),
);

await controller.removeMarker(id: 'marker_id');
```

3. POI 표시 토글
```dart
await controller.setPoiVisible(isVisible: true); // or false
```

4. 카메라 이동 종료 이벤트 구독
```dart
final cameraMoveEndSub = controller.onCameraMoveEndStream.listen((event) {
  debugPrint('moved: ${event.latitude}, ${event.longitude}');
});
```

5. 라벨 클릭 이벤트 구독
```dart
final labelClickSub = controller.onLabelClickedStream.listen((event) {
  debugPrint('label clicked: ${event.labelId}');
});
```

6. 인포윈도우 추가/제거
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

7. MarkerStyle 등록과 적용
```dart
// import 'dart:convert'; // for base64Decode

// 1) 스타일 정의
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

// 2) 등록
await controller.registerMarkerStyles(styles: styles);

// 3) 사용
await controller.addMarker(
  markerOption: MarkerOption(
    id: 'marker_with_style',
    latLng: LatLng(latitude: 37.5665, longitude: 126.9780),
    styleId: 'default_marker_style_001',
  ),
);
```

### 🔧 문제 해결: Kakao Maps Android SDK 저장소
Gradle 에러 발생 시 저장소 추가 필요

```
Could not find com.kakao.maps.open:android:2.12.8.
```

`android/build.gradle`의 `allprojects > repositories`에 추가

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

모든 Issue와 Pull Request는 언제나 환영이에요. PR 전 가이드라인을 참고해 주세요.

## License

MIT License

## Acknowledgments

**@Kakao**에서 KakaoMapsSDK를 제공해주셔서 감사합니다.

**모든 기여자분들**께는 이 프로젝트를 함께 만들어가 주셔서 진심으로 감사드립니다 🙏


