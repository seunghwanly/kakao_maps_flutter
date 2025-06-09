import Flutter
import KakaoMapsSDK
import UIKit

class KakaoMapController: NSObject, FlutterPlatformView, MapControllerDelegate {
  private let viewContainer: KMViewContainer
  private let mapController: KMController
  private let methodChannel: FlutterMethodChannel
  private let kKakaoMapViewName = "mapview"

  init(
    frame: CGRect,
    viewId: Int64,
    args: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    let width: CGFloat
    let height: CGFloat

    if let args = args as? [String: Any],
      let w = args["width"] as? NSNumber,
      let h = args["height"] as? NSNumber
    {
      width = CGFloat(truncating: w)
      height = CGFloat(truncating: h)
    } else {
      width = UIScreen.main.bounds.width
      height = UIScreen.main.bounds.height
    }

    let viewFrame = CGRect(x: 0, y: 0, width: width, height: height)

    self.viewContainer = KMViewContainer(frame: viewFrame)
    self.mapController = KMController(viewContainer: viewContainer)
    self.methodChannel = FlutterMethodChannel(
      name: "view.method_channel.kakao_maps_flutter#\(viewId)",
      binaryMessenger: messenger,
      codec: FlutterJSONMethodCodec.sharedInstance()
    )

    super.init()

    self.methodChannel.setMethodCallHandler(onMethodCall)

    self.mapController.delegate = self
    self.mapController.prepareEngine()
    self.mapController.activateEngine()
  }

  deinit {
    mapController.pauseEngine()
    mapController.resetEngine()
  }

  func view() -> UIView {
    return viewContainer
  }

  func addViews() {
    print("✅ addViews called!")

    let defaultPosition = MapPoint(
      longitude: 127.108678,
      latitude: 37.402001
    )

    let mapviewInfo = MapviewInfo(
      viewName: kKakaoMapViewName,
      viewInfoName: "map",
      defaultPosition: defaultPosition,
      defaultLevel: 7
    )

    mapController.addView(mapviewInfo)
  }

  func addViewSucceeded(_ viewName: String, viewInfoName: String) {
    print("✅ KakaoMap Attached")
    methodChannel.invokeMethod("onMapReady", arguments: true)
  }

  func addViewFailed(_ error: Error) {
    print("❌ KakaoMap Attach Failed: \(error.localizedDescription)")
  }

  private func onMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getZoomLevel":
      getZoomLevel(result)
    case "setZoomLevel":
      setZoomLevel(call, result)
    case "moveCamera":
      moveCamera(call, result)
    case "addMarker":
      addMarker(call, result)
    case "removeMarker":
      removeMarker(call, result)
    case "addMarkers":
      addMarkers(call, result)
    case "removeMarkers":
      removeMarkers(call, result)
    case "clearMarkers":
      clearMarkers(result)
    case "getCenter":
      getCenter(result)
    case "toScreenPoint":
      toScreenPoint(call, result)
    case "fromScreenPoint":
      fromScreenPoint(call, result)
    case "setPoiVisible":
      setPoiVisible(call, result)
    case "setPoiClickable":
      setPoiClickable(call, result)
    case "setPoiScale":
      setPoiScale(call, result)
    case "setPadding":
      setPadding(call, result)
    case "setViewport":
      setViewport(call, result)
    case "getViewportBounds":
      getViewportBounds(result)
    case "getMapInfo":
      getMapInfo(result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func withKakaoMapView(
    _ result: @escaping FlutterResult,
    block: (KakaoMap) -> Void
  ) {
    guard let baseView = mapController.getView(kKakaoMapViewName) as? KakaoMap else {
      result(FlutterError(code: "E000", message: "MapView not found", details: nil))
      return
    }
    block(baseView)
  }

  private func decodeBase64Image(_ base64: String) -> UIImage? {
    guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
      return nil
    }
    return UIImage(data: data)
  }

  private func createLabelLayer(_ layerID: String?) -> LabelLayer? {
    let view = mapController.getView(kKakaoMapViewName) as! KakaoMap
    let manager = view.getLabelManager()
    let existingLayer = manager.getLabelLayer(
      layerID: layerID ?? "PoiLayer"
    )
    if existingLayer != nil {
      return existingLayer!
    }

    let layerOption = LabelLayerOptions(
      layerID: layerID ?? "PoiLayer",
      competitionType: .none,
      competitionUnit: .symbolFirst,
      orderType: .rank,
      zOrder: 0
    )
    return manager.addLabelLayer(option: layerOption)
  }

  private func createPoiStyleWithImage(_ image: UIImage) -> String {
    let styleID = "PerLevelStyle"
    let view = mapController.getView(kKakaoMapViewName) as! KakaoMap
    let manager = view.getLabelManager()

    manager.removePoiStyle(styleID)

    let iconStyle = PoiIconStyle(
      symbol: image
    )
    let poiStyle = PoiStyle(
      styleID: styleID,
      styles: [
        PerLevelPoiStyle(iconStyle: iconStyle, level: 11),
        PerLevelPoiStyle(iconStyle: iconStyle, level: 21),
      ])
    manager.addPoiStyle(poiStyle)
    return styleID
  }

  // MARK: - Existing Methods

  private func getZoomLevel(_ result: @escaping FlutterResult) {
    withKakaoMapView(result) { view in
      result(view.zoomLevel)
    }
  }

  private func setZoomLevel(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard
      let args = call.arguments as? [String: Any],
      let zoomLevel = args["level"] as? Int
    else {
      result(FlutterError(code: "E001", message: "Invalid arguments", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      let cameraUpdate = CameraUpdate.make(zoomLevel: zoomLevel, mapView: view)
      view.moveCamera(cameraUpdate)
      result(nil)
    }
  }

  private func moveCamera(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "E002", message: "Invalid arguments", details: nil))
      return
    }

    // cameraUpdate 필드 먼저 파싱
    guard let cameraUpdateJson = args["cameraUpdate"] as? [String: Any] else {
      result(FlutterError(code: "E003", message: "cameraUpdate missing", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      // CameraUpdate 생성
      guard let cameraUpdate = CameraUpdate.fromJson(cameraUpdateJson, mapView: view) else {
        result(FlutterError(code: "E004", message: "Invalid cameraUpdate arguments", details: nil))
        return
      }

      // animation 필드 파싱 (optional)
      if let animationJson = args["animation"] as? [String: Any],
        let animationOptions = CameraAnimationOptions.fromJson(animationJson)
      {
        view.animateCamera(cameraUpdate: cameraUpdate, options: animationOptions)
        result(nil)
        return
      }

      // moveCamera 실행
      view.moveCamera(cameraUpdate)
      result(nil)
    }
  }

  private func addMarker(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let id = args["id"] as? String,
      let latLng = args["latLng"] as? [String: Any],
      let latitude = latLng["latitude"] as? Double,
      let longitude = latLng["longitude"] as? Double,
      let base64EncodedImage = args["base64EncodedImage"] as? String
    else {
      result(FlutterError(code: "E001", message: "Invalid arguments for addMarker", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      let point = MapPoint(
        longitude: longitude, latitude: latitude
      )

      // 1️⃣ LabelLayer 가져오기 (없으면 생성)
      let labelLayer = createLabelLayer("PoiLayer")

      guard let targetLayer = labelLayer else {
        result(
          FlutterError(code: "E002", message: "Failed to get or create LabelLayer", details: nil))
        return
      }

      // 2️⃣ Base64 -> UIImage
      guard let image = decodeBase64Image(base64EncodedImage) else {
        result(FlutterError(code: "E003", message: "Invalid image data", details: nil))
        return
      }

      // 3️⃣ PoiOptions 설정
      let poiStyleID = createPoiStyleWithImage(image)

      let poiOption = PoiOptions(
        styleID: poiStyleID,
        poiID: id
      )

      // 4️⃣ Poi 추가
      let poi = targetLayer.addPoi(
        option: poiOption,
        at: point
      )

      poi?.show()

      result(poi != nil)
    }
  }

  private func removeMarker(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let id = args["id"] as? String
    else {
      result(
        FlutterError(code: "E001", message: "Invalid arguments for removeMarker", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      let labelLayer = createLabelLayer("PoiLayer")

      guard let targetLayer = labelLayer else {
        result(
          FlutterError(code: "E002", message: "Failed to get or create LabelLayer", details: nil))
        return
      }

      targetLayer.removePoi(poiID: id)

      result(nil)
    }
  }

  // MARK: - New Methods to match Android implementation

  private func addMarkers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let markersArray = args["markers"] as? [[String: Any]]
    else {
      result(FlutterError(code: "E001", message: "Invalid arguments for addMarkers", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      let labelLayer = createLabelLayer("PoiLayer")

      guard let targetLayer = labelLayer else {
        result(
          FlutterError(code: "E002", message: "Failed to get or create LabelLayer", details: nil))
        return
      }

      for markerData in markersArray {
        guard let id = markerData["id"] as? String,
          let latLng = markerData["latLng"] as? [String: Any],
          let latitude = latLng["latitude"] as? Double,
          let longitude = latLng["longitude"] as? Double,
          let base64EncodedImage = markerData["base64EncodedImage"] as? String,
          let image = decodeBase64Image(base64EncodedImage)
        else {
          continue
        }

        let point = MapPoint(longitude: longitude, latitude: latitude)
        let poiStyleID = createPoiStyleWithImage(image)
        let poiOption = PoiOptions(styleID: poiStyleID, poiID: id)

        let poi = targetLayer.addPoi(option: poiOption, at: point)
        poi?.show()
      }

      result(nil)
    }
  }

  private func removeMarkers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let ids = args["ids"] as? [String]
    else {
      result(
        FlutterError(code: "E001", message: "Invalid arguments for removeMarkers", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      let labelLayer = createLabelLayer("PoiLayer")

      guard let targetLayer = labelLayer else {
        result(
          FlutterError(code: "E002", message: "Failed to get or create LabelLayer", details: nil))
        return
      }

      for id in ids {
        targetLayer.removePoi(poiID: id)
      }

      result(nil)
    }
  }

  private func clearMarkers(_ result: @escaping FlutterResult) {
    withKakaoMapView(result) { view in
      let manager = view.getLabelManager()
      manager.clearAllLabelLayers()
      result(nil)
    }
  }

  private func getCenter(_ result: @escaping FlutterResult) {
    withKakaoMapView(result) { view in
      // Get center of current viewport
      let centerPoint = CGPoint(x: view.viewRect.width / 2, y: view.viewRect.height / 2)
      let mapPoint = view.getPosition(centerPoint)

      result([
        "latitude": mapPoint.wgsCoord.latitude,
        "longitude": mapPoint.wgsCoord.longitude,
      ])
    }
  }

  private func toScreenPoint(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let position = args["position"] as? [String: Any],
      let latitude = position["latitude"] as? Double,
      let longitude = position["longitude"] as? Double
    else {
      result(
        FlutterError(code: "E001", message: "Invalid arguments for toScreenPoint", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      let mapPoint = MapPoint(longitude: longitude, latitude: latitude)

      // Note: iOS SDK doesn't have direct toScreenPoint method
      // We'll need to implement this differently or return null if not supported
      result([
        "dx": NSNull(),
        "dy": NSNull(),
      ])
    }
  }

  private func fromScreenPoint(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let dx = args["dx"] as? Double,
      let dy = args["dy"] as? Double
    else {
      result(
        FlutterError(code: "E001", message: "Invalid arguments for fromScreenPoint", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      let screenPoint = CGPoint(x: dx, y: dy)
      let mapPoint = view.getPosition(screenPoint)

      result([
        "latitude": mapPoint.wgsCoord.latitude,
        "longitude": mapPoint.wgsCoord.longitude,
      ])
    }
  }

  private func setPoiVisible(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let isVisible = args["isVisible"] as? Bool
    else {
      result(
        FlutterError(code: "E001", message: "Invalid arguments for setPoiVisible", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      view.setPoiEnabled(isVisible)
      result(nil)
    }
  }

  private func setPoiClickable(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let isClickable = args["isClickable"] as? Bool
    else {
      result(
        FlutterError(code: "E001", message: "Invalid arguments for setPoiClickable", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      view.poiClickable = isClickable
      result(nil)
    }
  }

  private func setPoiScale(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let scale = args["scale"] as? Int
    else {
      result(FlutterError(code: "E001", message: "Invalid arguments for setPoiScale", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      // Convert int to PoiScaleType based on Android mapping:
      // 0: SMALL, 1: REGULAR, 2: LARGE, 3: XLARGE
      let scaleType: PoiScaleType
      switch scale {
      case 0:
        scaleType = .small
      case 1:
        scaleType = .regular
      case 2:
        scaleType = .large
      default:
        scaleType = .regular  // Use regular as fallback since xlarge doesn't exist
      }

      view.poiScale = scaleType
      result(nil)
    }
  }

  private func setPadding(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let left = args["left"] as? Int,
      let top = args["top"] as? Int,
      let right = args["right"] as? Int,
      let bottom = args["bottom"] as? Int
    else {
      result(FlutterError(code: "E001", message: "Invalid arguments for setPadding", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      let insets = UIEdgeInsets(
        top: CGFloat(top),
        left: CGFloat(left),
        bottom: CGFloat(bottom),
        right: CGFloat(right)
      )
      view.setMargins(insets)
      result(nil)
    }
  }

  private func setViewport(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
      let width = args["width"] as? Int,
      let height = args["height"] as? Int
    else {
      result(FlutterError(code: "E001", message: "Invalid arguments for setViewport", details: nil))
      return
    }

    withKakaoMapView(result) { view in
      // Note: iOS KakaoMapsSDK doesn't have direct setViewport method
      // We'll update the view frame instead
      viewContainer.frame = CGRect(
        x: viewContainer.frame.origin.x,
        y: viewContainer.frame.origin.y,
        width: CGFloat(width),
        height: CGFloat(height)
      )
      result(nil)
    }
  }

  private func getViewportBounds(_ result: @escaping FlutterResult) {
    withKakaoMapView(result) { view in
      // Get current viewport bounds using corner coordinates
      let frame = view.viewRect

      // Get corners of viewport
      let topLeft = view.getPosition(CGPoint(x: 0, y: 0))
      let bottomRight = view.getPosition(CGPoint(x: frame.width, y: frame.height))

      result([
        "southwest": [
          "latitude": bottomRight.wgsCoord.latitude,
          "longitude": topLeft.wgsCoord.longitude,
        ],
        "northeast": [
          "latitude": topLeft.wgsCoord.latitude,
          "longitude": bottomRight.wgsCoord.longitude,
        ],
      ])
    }
  }

  private func getMapInfo(_ result: @escaping FlutterResult) {
    withKakaoMapView(result) { view in
      result([
        "zoomLevel": view.zoomLevel,
        "rotation": view.rotationAngle,
        "tilt": view.tiltAngle,
      ])
    }
  }
}
