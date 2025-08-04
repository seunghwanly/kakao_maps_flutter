## 0.0.1-beta3+2

### 🎉 Features
* **Performance Optimization** for label and POI batch operations on both Android and iOS platforms

### ♻️ API Changes
* Enhanced Android label management with batch add/remove operations using `addLabels()` and `remove(*labels.toTypedArray())`
* Improved iOS POI management with batch operations using `addPois()` and `removePois()`

### 🔧 Improvements
* **Android Performance**: Optimized label operations by collecting all labels first, then performing batch operations
* **iOS Performance**: Enhanced POI operations with batch processing for better memory efficiency
* Updated iOS project configuration with improved CocoaPods integration
* Enhanced iOS build phases for better framework embedding and resource management

### 🐛 Bug Fixes
* Fixed iOS project structure for better compatibility with latest Xcode versions
* Improved iOS Podfile.lock management and dependency resolution

### ⚠️ Breaking Changes
* None

---

## 0.0.1-beta3+2 (Korean)

### 🎉 기능 추가
* **성능 최적화** - Android와 iOS 플랫폼에서 라벨 및 POI 배치 작업 성능 향상

### ♻️ API 변경
* Android 라벨 관리 개선: `addLabels()` 및 `remove(*labels.toTypedArray())`를 사용한 배치 추가/제거 작업
* iOS POI 관리 개선: `addPois()` 및 `removePois()`를 사용한 배치 작업

### 🔧 개선 사항
* **Android 성능**: 모든 라벨을 먼저 수집한 후 배치 작업을 수행하여 라벨 작업 최적화
* **iOS 성능**: 배치 처리를 통한 POI 작업 향상으로 메모리 효율성 개선
* iOS 프로젝트 설정 업데이트로 CocoaPods 통합 개선
* iOS 빌드 단계 개선으로 프레임워크 임베딩 및 리소스 관리 향상

### 🐛 버그 수정
* 최신 Xcode 버전과의 호환성을 위한 iOS 프로젝트 구조 수정
* iOS Podfile.lock 관리 및 의존성 해결 개선

### ⚠️ 주요 변경/호환성
* 없음

## 0.0.1-beta3

### 🎉 Features
* **Camera Move End Events** with `onCameraMoveEndStream` listener for real-time camera movement completion notifications
* **Compass Controls** with complete positioning and interaction management
* **ScaleBar Controls** with auto-hide functionality and fade timing configurations
* **Logo Controls** with platform-specific visibility and positioning support
* **Enhanced Event System** for camera movements with detailed position, zoom, tilt, and rotation data

### ♻️ API Changes
* Added `CameraMoveEndEvent` class for camera movement notifications
* Added `Compass`, `ScaleBar`, and `Logo` configuration classes with alignment and offset support
* Added `onCameraMoveEndStream` property to `KakaoMapController`
* Added compass, scalebar, and logo control methods to `KakaoMapController`
* Enhanced `KakaoMap` widget with `compass`, `scaleBar`, and `logo` parameters

### 🔧 Improvements
* **91.4% API Documentation Coverage** - Comprehensive documentation for public APIs
* Enhanced error handling for platform-specific features (e.g., Android logo limitations)
* Improved type safety with proper enum-based alignment systems
* Better performance with optimized event streaming
* Enhanced example app with interactive compass and scalebar demonstrations

### 📝 Documentation
* Comprehensive README updates with new feature examples
* Enhanced API documentation coverage to 91.4%
* Updated example app demonstrating all new features
* Platform-specific notes and limitations clearly documented

### 🐛 Bug Fixes
* Fixed coordinate conversion reliability
* Improved memory management in event streams
* Enhanced platform compatibility checks

### ⚠️ Breaking Changes
* None - backward compatible with previous beta versions

## 0.0.1-beta2

### 🎉 Features
* **StaticKakaoMap widget** for displaying static map images with customizable markers
* **InfoWindow management** with add, remove, and batch operations
* **Custom GUI components** (GuiText, GuiImage, GuiLayout) for rich InfoWindow layouts
* **InfoWindow click events** with `onInfoWindowClickedStream` callback
* **Initial map position and zoom level** support in KakaoMap widget

### ♻️ API Changes
* Added `InfoWindowOption` for InfoWindow configuration
* Added `StaticMapController` for static map generation
* Added `initialPosition` and `initialLevel` parameters to KakaoMap widget

### 🔧 Improvements
* Enhanced iOS Info.plist for network permissions and embedded views
* Updated example app with InfoWindow and StaticMap demonstrations
* Improved error handling for InfoWindow and StaticMap operations
* Added Nine-patch image support for custom InfoWindow backgrounds

### 📝 Documentation
* Updated README with InfoWindow management examples
* Added troubleshooting guide for Kakao Maps Android SDK dependency
* Enhanced map widget parameters documentation

## 0.0.1-beta1+2

### 🎉 Features
* EventHandler support with `LabelClickEvent` and `onLabelClicked` callback
* Swift Package Manager support for iOS
* Enhanced documentation and examples
* `.env` file integration for API key management

### ♻️ API Changes
* Modernized KakaoMapController with property-based API
* Replaced deprecated methods (`setPoiVisible` → `isPoiVisible`, `getCameraPosition` → `cameraPosition`)

### 🔧 Improvements
* Code cleanup and organization
* New example app with `KakaoMapExampleScreen`
* Added marker assets and data structure refactoring

## 0.0.1-beta1

Initial release of the Kakao Maps Flutter plugin with core functionality:

### 🎉 Features
* Native Kakao Maps SDK v2 integration for Android and iOS
* Basic map view with touch controls
* Zoom level control (1-21)
* Camera position and movement with animation support
* Marker management (add, remove, batch operations)
* POI controls (visibility, clickability, scale)
* Coordinate conversion between map and screen points
* Map information retrieval (zoom, rotation, tilt)
* Viewport bounds management

### 📝 Documentation
* Basic usage examples
* Platform-specific setup instructions
* API documentation for core features

### 🔧 Technical Details
* Null safety support
* Platform interface implementation
* Method channel communication
* Error handling and validation
* Type-safe API design

### ⚠️ Notes
* This is a pre-release version for early adopters
* API may undergo changes based on feedback
* Some advanced features planned for future releases
