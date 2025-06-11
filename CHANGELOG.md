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
