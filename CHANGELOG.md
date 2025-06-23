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
