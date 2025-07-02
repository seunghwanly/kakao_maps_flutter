## 0.0.1-beta3+1

### 🎉 Features
* Added `zOrder` property to `InfoWindowOptions` for controlling InfoWindow rendering order
* Added `rank` property to `LabelOption` for label rendering order and updated related functionalities

### ♻️ API Changes
* `InfoWindowOptions` now supports `zOrder` property for explicit rendering order
* `LabelOption` now includes `rank` property; related methods updated to utilize `rank` for label ordering

### 🔧 Improvements
* Enhanced Android initial position, zoom level, compass, scale bar, and logo configuration parsing for better flexibility and error handling

### 🐛 Bug Fixes
* Fixed initialPosition parser on Android to support both Map and JSONObject types

### ⚠️ Breaking Changes
* None

---

## 0.0.1-beta3+1 (Korean)

### 🎉 기능 추가
* `InfoWindowOptions`에 `zOrder` 속성을 추가하여 InfoWindow의 렌더링 순서 제어 가능
* `LabelOption`에 `rank` 속성 추가 및 관련 기능 업데이트로 라벨 렌더링 순서 지정 가능

### ♻️ API 변경
* `InfoWindowOptions`에 `zOrder` 속성 추가로 렌더링 순서 명시적 지정 가능
* `LabelOption`에 `rank` 속성 추가 및 관련 메서드가 `rank`를 활용하여 라벨 정렬 지원

### 🔧 개선 사항
* Android에서 초기 위치, 줌 레벨, 나침반, 스케일바, 로고 설정 파싱 로직 개선 및 오류 처리 강화

### 🐛 버그 수정
* Android에서 initialPosition 파서가 Map과 JSONObject 타입 모두 지원하도록 수정

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
