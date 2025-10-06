# 0.1.2

### 🐛 Bug Fixes
* (Android) Fixed an issue where LodMarker/Label text was not visible (#27)
* (Android) Addressed cases where default text style was not applied when style was unspecified

### 🔧 Improvements
* (Android) Unified default marker/label text style to match iOS: based on `DefaultLabelTextStyle` and `DefaultLabelStyle` in `android/src/main/kotlin/io/seunghwanly/kakao_maps_flutter/constant/Constants.kt`
* (Android) Updated Kakao Maps SDK to 2.12.18
* (Android) Bumped compileSdk to 35, updated Android Gradle Plugin to 8.1.1 and Gradle to 8.5

### 📝 Documentation
* Documented the source and location of default marker/label text style: `constant/Constants.kt`

# 0.1.1

### 🔧 Improvements
* Smoother camera animations with reduced jank on low-end devices
* Faster batch add/remove operations for labels and POIs on Android
* Clearer error messages and safer null-handling across platform channels

### 🐛 Bug Fixes
* Fixed occasional crash when disposing the map view during active animations
* Resolved race condition in `onCameraMoveEndStream` listener
* Addressed a memory leak in InfoWindow/Label event streams

### 📝 Documentation
* Clarified platform-specific notes and troubleshooting steps


# 0.1.0

### 🎉 Features
* Implemented LodMarker, LodPoi, LodLabel
* MarkerStyle can be added independently
* InfoWindowLayer show/hide controls

### ♻️ API Changes
* Changed marker style application method

### ⚠️ Notes (Breaking Changes)
* Compatibility impact for beta users due to marker style application change

### 📝 Documentation
* Applied unified public API comment template across the codebase



# 0.0.1-beta3+5

### 🐛 Bug Fixes
* (iOS) Removed separate comma



# 0.0.1-beta3+4

### 🐛 Bug Fixes
* (Android) Added type on constructor



# 0.0.1-beta3+3

### 🎉 Features
* Added text-related properties to `LabelOption` for enhanced label customization
* Added `text`, `textColor`, `textSize`, `strokeThickness`, and `strokeColor` properties to support rich text labels

### ♻️ API Changes
* Enhanced `LabelOption` data class with text styling capabilities
* Updated JSON conversion logic to handle new text properties
* Improved POI style creation with text styling support on both iOS and Android

### 🔧 Improvements
* Enhanced iOS and Android POI style generation with text rendering
* Updated constructor parameters for better text property handling
* Improved text color and stroke color processing with ARGB32 conversion

### 🐛 Bug Fixes
* Fixed cache removal issues for better memory management




# 0.0.1-beta3+2

### 🎉 Features
* Performance optimization for label and POI batch operations on both Android and iOS platforms

### ♻️ API Changes
* Enhanced Android label management with batch add/remove operations using `addLabels()` and `remove(*labels.toTypedArray())`
* Improved iOS POI management with batch operations using `addPois()` and `removePois()`

### 🔧 Improvements
* Android performance: optimized label operations by collecting all labels first, then performing batch operations
* iOS performance: enhanced POI operations with batch processing for better memory efficiency
* Updated iOS project configuration with improved CocoaPods integration
* Enhanced iOS build phases for better framework embedding and resource management

### 🐛 Bug Fixes
* Fixed iOS project structure for better compatibility with latest Xcode versions
* Improved iOS Podfile.lock management and dependency resolution

### ⚠️ Notes (Breaking Changes)
* None



# 0.0.1-beta3

### 🎉 Features
* Camera Move End Events with `onCameraMoveEndStream` listener for real-time camera movement completion notifications
* Compass controls with complete positioning and interaction management
* ScaleBar controls with auto-hide functionality and fade timing configurations
* Logo controls with platform-specific visibility and positioning support
* Enhanced event system for camera movements with detailed position, zoom, tilt, and rotation data

### ♻️ API Changes
* Added `CameraMoveEndEvent` class for camera movement notifications
* Added `Compass`, `ScaleBar`, and `Logo` configuration classes with alignment and offset support
* Added `onCameraMoveEndStream` property to `KakaoMapController`
* Added compass, scalebar, and logo control methods to `KakaoMapController`
* Enhanced `KakaoMap` widget with `compass`, `scaleBar`, and `logo` parameters

### 🔧 Improvements
* 91.4% API documentation coverage for public APIs
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




# 0.0.1-beta2

### 🎉 Features
* StaticKakaoMap widget for displaying static map images with customizable markers
* InfoWindow management with add, remove, and batch operations
* Custom GUI components (GuiText, GuiImage, GuiLayout) for rich InfoWindow layouts
* InfoWindow click events with `onInfoWindowClickedStream` callback
* Initial map position and zoom level support in KakaoMap widget

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



# 0.0.1-beta1+2

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




# 0.0.1-beta1

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

### 🔧 Improvements
* Null safety support
* Platform interface implementation
* Method channel communication
* Error handling and validation
* Type-safe API design

### ⚠️ Notes (Breaking Changes)
* This is a pre-release version for early adopters
* API may undergo changes based on feedback
* Some advanced features planned for future releases
