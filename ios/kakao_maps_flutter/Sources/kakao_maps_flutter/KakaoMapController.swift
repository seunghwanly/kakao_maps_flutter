import Flutter
import KakaoMapsSDK
import UIKit

class KakaoMapController: NSObject, FlutterPlatformView, MapControllerDelegate, GuiEventDelegate, KakaoMapEventDelegate {
    private let viewContainer: KMViewContainer
    private let mapController: KMController
    private let methodChannel: FlutterMethodChannel
    private let kKakaoMapViewName = "mapview"
    
    
    private let initialPosition: MapPoint?
    private let initialLevel: Int?
    private let compassConfig: [String: Any]?
    private let scaleBarConfig: [String: Any]?
    private let logoConfig: [String: Any]?
    private var poiStyleRegistry: [String: PoiStyle] = [:]
    private var lodLabelLayers: [String: LodLabelLayer] = [:]
    
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
           let h = args["height"] as? NSNumber {
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
            codec: FlutterStandardMethodCodec.sharedInstance()
        )
        
        if let args = args as? [String: Any],
           let initialPositionData = args["initialPosition"] as? [String: Any],
           let latitude = initialPositionData["latitude"] as? Double,
           let longitude = initialPositionData["longitude"] as? Double {
            self.initialPosition = MapPoint(longitude: longitude, latitude: latitude)
        } else {
            self.initialPosition = nil
        }
        
        if let args = args as? [String: Any],
           let level = args["initialLevel"] as? Int {
            self.initialLevel = level
        } else {
            self.initialLevel = nil
        }
        
        if let args = args as? [String: Any],
           let compassConfig = args["compass"] as? [String: Any] {
            self.compassConfig = compassConfig
        } else {
            self.compassConfig = nil
        }
        
        if let args = args as? [String: Any],
           let scaleBarConfig = args["scaleBar"] as? [String: Any] {
            self.scaleBarConfig = scaleBarConfig
        } else {
            self.scaleBarConfig = nil
        }
        
        if let args = args as? [String: Any],
           let logoConfig = args["logo"] as? [String: Any] {
            self.logoConfig = logoConfig
        } else {
            self.logoConfig = nil
        }
        
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
        let defaultPosition = initialPosition ?? MapPoint(
            longitude: 127.108678,
            latitude: 37.402001
        )
        
        let defaultLevel = initialLevel ?? 7
        
        let mapviewInfo = MapviewInfo(
            viewName: kKakaoMapViewName,
            viewInfoName: "map",
            defaultPosition: defaultPosition,
            defaultLevel: defaultLevel
        )
        
        mapController.addView(mapviewInfo)
    }
    
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        withKakaoMapView({ _ in }) { view in
            if let compassConfig = self.compassConfig {
                view.showCompass()
                
                if let alignment = compassConfig["alignment"] as? String,
                   let offsetData = compassConfig["offset"] as? [String: Any],
                   let dx = offsetData["dx"] as? Double,
                   let dy = offsetData["dy"] as? Double {
                    
                    let guiAlignment = self.convertAlignmentString(alignment)
                    let offset = CGPoint(x: dx, y: dy)
                    view.setCompassPosition(origin: guiAlignment, position: offset)
                }
            }
            
            if let scaleBarConfig = self.scaleBarConfig {
                view.showScaleBar()
                
                if let isAutoHide = scaleBarConfig["isAutoHide"] as? Bool {
                    view.setScaleBarAutoDisappear(isAutoHide)
                }
                
                if let fadeInTime = scaleBarConfig["fadeInTime"] as? Int,
                   let fadeOutTime = scaleBarConfig["fadeOutTime"] as? Int,
                   let retentionTime = scaleBarConfig["retentionTime"] as? Int {
                    let fadeOptions = FadeInOutOptions(
                        fadeInTime: UInt32(fadeInTime),
                        fadeOutTime: UInt32(fadeOutTime),
                        retentionTime: UInt32(retentionTime)
                    )
                    view.setScaleBarFadeInOutOption(fadeOptions)
                }
            }
            
            if let logoConfig = self.logoConfig {
                if let alignment = logoConfig["alignment"] as? String,
                   let offsetData = logoConfig["offset"] as? [String: Any],
                   let dx = offsetData["dx"] as? Double,
                   let dy = offsetData["dy"] as? Double {
                    
                    let guiAlignment = self.convertAlignmentString(alignment)
                    let offset = CGPoint(x: dx, y: dy)
                    view.setLogoPosition(origin: guiAlignment, position: offset)
                }
            }
        }
        
        methodChannel.invokeMethod("onMapReady", arguments: true)
    }
    
    func addViewFailed(_ error: Error) {
        methodChannel.invokeMethod("onMapFailed", arguments: ["error": error.localizedDescription])
    }
    
    private func onMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "registerMarkerStyles":
            registerMarkerStyles(call, result)
        case "removeMarkerStyles":
            removeMarkerStyles(call, result)
        case "clearMarkerStyles":
            clearMarkerStyles(result)
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
        case "addInfoWindow":
            addInfoWindow(call, result)
        case "removeInfoWindow":
            removeInfoWindow(call, result)
        case "addInfoWindows":
            addInfoWindows(call, result)
        case "removeInfoWindows":
            removeInfoWindows(call, result)
        case "clearInfoWindows":
            clearInfoWindows(result)
        case "showCompass":
            showCompass(result)
        case "hideCompass":
            hideCompass(result)
        case "showScaleBar":
            showScaleBar(result)
        case "hideScaleBar":
            hideScaleBar(result)
        case "setCompassPosition":
            setCompassPosition(call, result)
        case "showLogo":
            showLogo(result)
        case "hideLogo":
            hideLogo(result)
        case "setLogoPosition":
            setLogoPosition(call, result)
        // LOD Marker APIs
        case "addLodMarkerLayer":
            addLodMarkerLayer(call, result)
        case "removeLodMarkerLayer":
            removeLodMarkerLayer(call, result)
        case "addLodMarker":
            addLodMarker(call, result)
        case "addLodMarkers":
            addLodMarkers(call, result)
        case "removeLodMarkers":
            removeLodMarkers(call, result)
        case "clearAllLodMarkers":
            clearAllLodMarkers(call, result)
        case "showAllLodMarkers":
            showAllLodMarkers(call, result)
        case "hideAllLodMarkers":
            hideAllLodMarkers(call, result)
        case "showLodMarkers":
            showLodMarkers(call, result)
        case "hideLodMarkers":
            hideLodMarkers(call, result)
        case "setLodMarkerLayerClickable":
            setLodMarkerLayerClickable(call, result)
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
        baseView.eventDelegate = self
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
        let existingLayer = manager.getLabelLayer(layerID: layerID ?? "PoiLayer")
        
        if existingLayer != nil {
            return existingLayer!
        }
        
        let layerOption = LabelLayerOptions(
            layerID: layerID ?? "PoiLayer",
            competitionType: .none,
            competitionUnit: .symbolFirst,
            orderType: .rank,
            zOrder: 10000
        )
        return manager.addLabelLayer(option: layerOption)
    }
    
    // Removed: dynamic style creation per marker (anti-pattern)
    
    // MARK: - Map Event Functions
    
    private func getZoomLevel(_ result: @escaping FlutterResult) {
        withKakaoMapView(result) { view in
            result(view.zoomLevel)
        }
    }

    // MARK: - LOD Marker Helpers (LodLabel/LodPoi)
    private func getOrCreateLodLabelLayer(_ options: [String: Any]) -> LodLabelLayer? {
        guard let view = mapController.getView(kKakaoMapViewName) as? KakaoMap else { return nil }
        let manager = view.getLabelManager()
        guard let layerId = options["layerId"] as? String else { return nil }
        if let existing = lodLabelLayers[layerId] { return existing }

        let compType: CompetitionType = {
            switch (options["competitionType"] as? String) ?? "none" {
            case "upper": return .upper
            case "same": return .same
            case "lower": return .lower
            case "background": return .all
            default: return .none
            }
        }()
        let compUnit: CompetitionUnit = {
            switch (options["competitionUnit"] as? String) ?? "symbolFirst" {
            case "poi": return .poi
            default: return .symbolFirst
            }
        }()
        let orderType: OrderingType = {
            switch (options["orderType"] as? String) ?? "rank" {
            case "closerFromLeftBottom": return .closerFromLeftBottom
            default: return .rank
            }
        }()
        let zOrder = options["zOrder"] as? Int ?? 0
        let radius = (options["radius"] as? NSNumber)?.doubleValue ?? 20.0

        let layerOptions = LodLabelLayerOptions(
            layerID: layerId,
            competitionType: compType,
            competitionUnit: compUnit,
            orderType: orderType,
            zOrder: zOrder,
            radius: Float(radius)
        )
        let layer = manager.addLodLabelLayer(option: layerOptions)
        if let layer = layer { lodLabelLayers[layerId] = layer }
        return layer
    }

    private func addLodMarkerLayer(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let options = call.arguments as? [String: Any] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for addLodMarkerLayer", details: nil))
            return
        }
        _ = getOrCreateLodLabelLayer(options)
        result(nil)
    }

    private func removeLodMarkerLayer(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let layerId = args["layerId"] as? String else {
            result(FlutterError(code: "E001", message: "Invalid arguments for removeLodMarkerLayer", details: nil))
            return
        }
        if let layer = lodLabelLayers.removeValue(forKey: layerId) {
            layer.clearAllItems()
            layer.clearAllExitTransitionLodPois()
        }
        result(nil)
    }

    private func addLodMarker(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let layerId = args["layerId"] as? String,
              let option = args["option"] as? [String: Any],
              let id = option["id"] as? String,
              let latLng = option["latLng"] as? [String: Any],
              let latitude = latLng["latitude"] as? Double,
              let longitude = latLng["longitude"] as? Double else {
            result(FlutterError(code: "E001", message: "Invalid arguments for addLodMarker", details: nil))
            return
        }
        withKakaoMapView(result) { view in
            guard let layer = self.lodLabelLayers[layerId] ?? self.getOrCreateLodLabelLayer(["layerId": layerId]) else {
                result(FlutterError(code: "E002", message: "Failed to get LodLabelLayer", details: nil))
                return
            }
            let point = MapPoint(longitude: longitude, latitude: latitude)
            let styleId = (option["styleId"] as? String) ?? "__default__"
            let poiOption = PoiOptions(styleID: styleId, poiID: id)
            poiOption.clickable = true
            poiOption.rank = option["rank"] as? Int ?? 0
            if let poiText = option["text"] as? String {
                poiOption.addText(PoiText(text: poiText, styleIndex: 0))
            }
            let poi = layer.addLodPoi(option: poiOption, at: point)
            poi?.show()
            result(poi != nil)
        }
    }

    private func addLodMarkers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let layerId = args["layerId"] as? String,
              let options = args["options"] as? [[String: Any]] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for addLodMarkers", details: nil))
            return
        }
        withKakaoMapView(result) { _ in
            guard let layer = self.lodLabelLayers[layerId] ?? self.getOrCreateLodLabelLayer(["layerId": layerId]) else {
                result(FlutterError(code: "E002", message: "Failed to get LodLabelLayer", details: nil))
                return
            }

            var poiOptions: [PoiOptions] = []
            var positions: [MapPoint] = []
            for item in options {
                guard let id = item["id"] as? String,
                      let latLng = item["latLng"] as? [String: Any],
                      let latitude = latLng["latitude"] as? Double,
                      let longitude = latLng["longitude"] as? Double else { continue }
                let styleId = (item["styleId"] as? String) ?? "__default__"
                let opt = PoiOptions(styleID: styleId, poiID: id)
                opt.clickable = true
                opt.rank = item["rank"] as? Int ?? 0
                if let t = item["text"] as? String { opt.addText(PoiText(text: t, styleIndex: 0)) }
                poiOptions.append(opt)
                positions.append(MapPoint(longitude: longitude, latitude: latitude))
            }
            _ = layer.addLodPois(options: poiOptions, at: positions)
            layer.showAllLodPois()
            result(nil)
        }
    }

    private func removeLodMarkers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let layerId = args["layerId"] as? String,
              let ids = args["ids"] as? [String] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for removeLodMarkers", details: nil))
            return
        }
        withKakaoMapView(result) { _ in
            guard let layer = self.lodLabelLayers[layerId] else { result(nil); return }
            layer.removeLodPois(poiIDs: ids) { 
                result(nil)
            }
        }
    }

    private func clearAllLodMarkers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let layerId = args["layerId"] as? String else {
            result(FlutterError(code: "E001", message: "Invalid arguments for clearAllLodMarkers", details: nil))
            return
        }
        withKakaoMapView(result) { _ in
            guard let layer = self.lodLabelLayers[layerId] else { result(nil); return }
            layer.clearAllItems()
            layer.clearAllExitTransitionLodPois()
            result(nil)
        }
    }

    private func showAllLodMarkers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let layerId = args["layerId"] as? String else {
            result(FlutterError(code: "E001", message: "Invalid arguments for showAllLodMarkers", details: nil))
            return
        }
        withKakaoMapView(result) { _ in
            self.lodLabelLayers[layerId]?.showAllLodPois()
            result(nil)
        }
    }

    private func hideAllLodMarkers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let layerId = args["layerId"] as? String else {
            result(FlutterError(code: "E001", message: "Invalid arguments for hideAllLodMarkers", details: nil))
            return
        }
        withKakaoMapView(result) { _ in
            self.lodLabelLayers[layerId]?.hideAllLodPois()
            result(nil)
        }
    }

    private func showLodMarkers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let layerId = args["layerId"] as? String,
              let ids = args["ids"] as? [String] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for showLodMarkers", details: nil))
            return
        }
        withKakaoMapView(result) { _ in
            _ = self.lodLabelLayers[layerId]?.showLodPois(poiIDs: ids)
            result(nil)
        }
    }

    private func hideLodMarkers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let layerId = args["layerId"] as? String,
              let ids = args["ids"] as? [String] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for hideLodMarkers", details: nil))
            return
        }
        withKakaoMapView(result) { _ in
            _ = self.lodLabelLayers[layerId]?.hideLodPois(poiIDs: ids)
            result(nil)
        }
    }

    private func setLodMarkerLayerClickable(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let layerId = args["layerId"] as? String,
              let clickable = args["clickable"] as? Bool else {
            result(FlutterError(code: "E001", message: "Invalid arguments for setLodMarkerLayerClickable", details: nil))
            return
        }
        withKakaoMapView(result) { _ in
            self.lodLabelLayers[layerId]?.setClickable(clickable)
            result(nil)
        }
    }
    
    private func setZoomLevel(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let zoomLevel = args["level"] as? Int else {
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
        guard let args = call.arguments as? [String: Any],
              let cameraUpdateJson = args["cameraUpdate"] as? [String: Any] else {
            result(FlutterError(code: "E002", message: "Invalid arguments", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            guard let cameraUpdate = CameraUpdate.fromJson(cameraUpdateJson, mapView: view) else {
                result(FlutterError(code: "E004", message: "Invalid cameraUpdate arguments", details: nil))
                return
            }
            
            if let animationJson = args["animation"] as? [String: Any],
               let animationOptions = CameraAnimationOptions.fromJson(animationJson) {
                view.animateCamera(cameraUpdate: cameraUpdate, options: animationOptions)
                result(nil)
                return
            }
            
            view.moveCamera(cameraUpdate)
            result(nil)
        }
    }
    
    private func addMarker(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String,
              let latLng = args["latLng"] as? [String: Any],
              let latitude = latLng["latitude"] as? Double,
              let longitude = latLng["longitude"] as? Double else {
            result(FlutterError(code: "E001", message: "Invalid arguments for addMarker", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let point = MapPoint(longitude: longitude, latitude: latitude)
            
            let labelLayer = createLabelLayer("PoiLayer")
            guard let targetLayer = labelLayer else {
                result(FlutterError(code: "E002", message: "Failed to get or create LabelLayer", details: nil))
                return
            }
            
            let styleId = args["styleId"] as? String
            let poiStyleID = styleId ?? "__default__"
            
            let poiOption = PoiOptions(styleID: poiStyleID, poiID: id)
            poiOption.clickable = true
            poiOption.rank = args["rank"] as? Int ?? 0
            if let poiText = args["text"] as? String {
                poiOption.addText(PoiText(text: poiText, styleIndex: 0))
            }
            
            let poi = targetLayer.addPoi(option: poiOption, at: point)
            poi?.show()
            
            result(poi != nil)
        }
    }
    
    private func removeMarker(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String else {
            result(FlutterError(code: "E001", message: "Invalid arguments for removeMarker", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let labelLayer = createLabelLayer("PoiLayer")
            guard let targetLayer = labelLayer else {
                result(FlutterError(code: "E002", message: "Failed to get or create LabelLayer", details: nil))
                return
            }
            
            targetLayer.removePoi(poiID: id)
            result(nil)
        }
    }
    
    private func addMarkers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let markersArray = args["markers"] as? [[String: Any]] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for addMarkers", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let labelLayer = createLabelLayer("PoiLayer")
            guard let targetLayer = labelLayer else {
                result(FlutterError(code: "E002", message: "Failed to get or create LabelLayer", details: nil))
                return
            }
            
            var poiOptions: [PoiOptions] = []
            var poiPositions: [MapPoint] = []
            
            for markerData in markersArray {
                guard let id = markerData["id"] as? String,
                      let latLng = markerData["latLng"] as? [String: Any],
                      let latitude = latLng["latitude"] as? Double,
                      let longitude = latLng["longitude"] as? Double else {
                    continue
                }
                
                let point = MapPoint(longitude: longitude, latitude: latitude)
                let styleId = markerData["styleId"] as? String ?? "__default__"
                let poiOption = PoiOptions(styleID: styleId, poiID: id)
                poiOption.clickable = true
                poiOption.rank = args["rank"] as? Int ?? 0
                
                poiOptions.append(poiOption)
                poiPositions.append(
                    MapPoint(longitude: longitude, latitude: latitude)
                )
            }
            
            let _ = targetLayer.addPois(
                options: poiOptions,
                at: poiPositions
            )
            let _ = targetLayer.showPois(
                poiIDs: poiOptions.map(\.itemID!)
            )
            
            result(nil)
        }
    }

    // MARK: - Marker Styles Registration
    private func registerMarkerStyles(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let styles = args["styles"] as? [[String: Any]] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for registerMarkerStyles", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let manager = view.getLabelManager()
            for style in styles {
                guard let styleId = style["styleId"] as? String,
                      let perLevels = style["perLevels"] as? [[String: Any]] else { continue }
                var perLevelStyles: [PerLevelPoiStyle] = []
                for pl in perLevels {
                    // icon: Uint8List(ByteArray) 또는 base64(String) 모두 허용
                    var iconImage: UIImage? = nil
                    if let bytes = pl["icon"] as? FlutterStandardTypedData {
                        iconImage = UIImage(data: bytes.data)
                    } else if let list = pl["icon"] as? [UInt8] {
                        iconImage = UIImage(data: Data(list))
                    } else if let iconBase64 = pl["icon"] as? String,
                              let iconData = Data(base64Encoded: iconBase64, options: .ignoreUnknownCharacters) {
                        iconImage = UIImage(data: iconData)
                    }
                    guard let iconImage else { continue }
                    let iconStyle = PoiIconStyle(symbol: iconImage)
                    var textStyle: PoiTextStyle? = nil
                    if let ts = pl["textStyle"] as? [String: Any] {
                        let fontSize = (ts["fontSize"] as? Int).map { UInt($0) } ?? 14
                        let fontColor = (ts["fontColor"] as? Int).map { UIColor.fromArgb($0) } ?? UIColor.black
                        let strokeThickness = (ts["strokeThickness"] as? Int).map { UInt($0) } ?? 2
                        let strokeColor = (ts["strokeColor"] as? Int).map { UIColor.fromArgb($0) } ?? UIColor.white
                        textStyle = PoiTextStyle(textLineStyles: [
                            PoiTextLineStyle(textStyle: TextStyle(
                                fontSize: fontSize,
                                fontColor: fontColor,
                                strokeThickness: strokeThickness,
                                strokeColor: strokeColor
                            ))
                        ])
                    }
                    let level = (pl["level"] as? Int) ?? 11
                    if let ts = textStyle {
                        perLevelStyles.append(PerLevelPoiStyle(iconStyle: iconStyle, textStyle: ts, level: level))
                    } else {
                        perLevelStyles.append(PerLevelPoiStyle(iconStyle: iconStyle, level: level))
                    }
                }
                let poiStyle = PoiStyle(styleID: styleId, styles: perLevelStyles)
                manager.removePoiStyle(styleId)
                manager.addPoiStyle(poiStyle)
                poiStyleRegistry[styleId] = poiStyle
            }
            result(nil)
        }
    }
    
    private func removeMarkerStyles(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let styleIds = args["styleIds"] as? [String] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for removeMarkerStyles", details: nil))
            return
        }
        withKakaoMapView(result) { view in
            let manager = view.getLabelManager()
            for sid in styleIds {
                manager.removePoiStyle(sid)
                poiStyleRegistry.removeValue(forKey: sid)
            }
            result(nil)
        }
    }
    
    private func clearMarkerStyles(_ result: @escaping FlutterResult) {
        withKakaoMapView(result) { view in
            let manager = view.getLabelManager()
            // Kakao SDK에 스타일 일괄 제거가 별도로 없다면, 등록된 키 기반으로 제거
            for sid in poiStyleRegistry.keys { manager.removePoiStyle(sid) }
            poiStyleRegistry.removeAll()
            result(nil)
        }
    }
    
    private func removeMarkers(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let ids = args["ids"] as? [String] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for removeMarkers", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let labelLayer = createLabelLayer("PoiLayer")
            guard let targetLayer = labelLayer else {
                result(FlutterError(code: "E002", message: "Failed to get or create LabelLayer", details: nil))
                return
            }
            
            targetLayer.removePois(poiIDs: ids)
            
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
            let centerPoint = CGPoint(x: view.viewRect.width / 2, y: view.viewRect.height / 2)
            let mapPoint = view.getPosition(centerPoint)
            
            result([
                "latitude": mapPoint.wgsCoord.latitude,
                "longitude": mapPoint.wgsCoord.longitude
            ])
        }
    }
    
    private func toScreenPoint(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let position = args["position"] as? [String: Any],
              let latitude = position["latitude"] as? Double,
              let longitude = position["longitude"] as? Double else {
            result(FlutterError(code: "E001", message: "Invalid arguments for toScreenPoint", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let mapPoint = MapPoint(longitude: longitude, latitude: latitude)
            
            result([
                "dx": NSNull(),
                "dy": NSNull()
            ])
        }
    }
    
    private func fromScreenPoint(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let dx = args["dx"] as? Double,
              let dy = args["dy"] as? Double else {
            result(FlutterError(code: "E001", message: "Invalid arguments for fromScreenPoint", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let screenPoint = CGPoint(x: dx, y: dy)
            let mapPoint = view.getPosition(screenPoint)
            
            result([
                "latitude": mapPoint.wgsCoord.latitude,
                "longitude": mapPoint.wgsCoord.longitude
            ])
        }
    }
    
    private func setPoiVisible(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let isVisible = args["isVisible"] as? Bool else {
            result(FlutterError(code: "E001", message: "Invalid arguments for setPoiVisible", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            view.setPoiEnabled(isVisible)
            result(nil)
        }
    }
    
    private func setPoiClickable(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let isClickable = args["isClickable"] as? Bool else {
            result(FlutterError(code: "E001", message: "Invalid arguments for setPoiClickable", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            view.poiClickable = isClickable
            result(nil)
        }
    }
    
    private func setPoiScale(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let scale = args["scale"] as? Int else {
            result(FlutterError(code: "E001", message: "Invalid arguments for setPoiScale", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let scaleType: PoiScaleType
            switch scale {
            case 0:
                scaleType = .small
            case 1:
                scaleType = .regular
            case 2:
                scaleType = .large
            default:
                scaleType = .regular
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
              let bottom = args["bottom"] as? Int else {
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
              let height = args["height"] as? Int else {
            result(FlutterError(code: "E001", message: "Invalid arguments for setViewport", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
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
            let frame = view.viewRect
            let topLeft = view.getPosition(CGPoint(x: 0, y: 0))
            let bottomRight = view.getPosition(CGPoint(x: frame.width, y: frame.height))
            
            result([
                "southwest": [
                    "latitude": bottomRight.wgsCoord.latitude,
                    "longitude": topLeft.wgsCoord.longitude
                ],
                "northeast": [
                    "latitude": topLeft.wgsCoord.latitude,
                    "longitude": bottomRight.wgsCoord.longitude
                ]
            ])
        }
    }
    
    private func getMapInfo(_ result: @escaping FlutterResult) {
        withKakaoMapView(result) { view in
            result([
                "zoomLevel": view.zoomLevel,
                "rotation": view.rotationAngle,
                "tilt": view.tiltAngle
            ])
        }
    }
    
    // MARK: - InfoWindow Management
    
    private func addInfoWindow(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for addInfoWindow", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            guard let infoWindow = args.toNativeInfoWindow() else {
                result(FlutterError(code: "E003", message: "Failed to create InfoWindow from arguments", details: nil))
                return
            }
            
            infoWindow.delegate = self
            
            let guiManager = view.getGuiManager()
            let _ = guiManager.infoWindowLayer.addInfoWindow(infoWindow)
            infoWindow.show()
            result(nil)
        }
    }
    
    private func removeInfoWindow(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String else {
            result(FlutterError(code: "E001", message: "Invalid arguments for removeInfoWindow", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let guiManager = view.getGuiManager()
            let _ = guiManager.infoWindowLayer.removeInfoWindow(
                guiName: id
            )
            
            result(nil)
        }
    }
    
    private func addInfoWindows(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let infoWindowOptions = args["infoWindowOptions"] as? [[String: Any]] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for addInfoWindows", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let guiManager = view.getGuiManager()

            for infoWindowDict in infoWindowOptions {
                guard let infoWindow = infoWindowDict.toNativeInfoWindow() else {
                    continue
                }
                
                infoWindow.delegate = self
                
                let isVisible = infoWindowDict["isVisible"] as? Bool ?? true
                
                if isVisible {
                    let _ = guiManager.infoWindowLayer.addInfoWindow(infoWindow)
                    infoWindow.show()
                }
            }
            result(nil)
        }
    }
    
    private func removeInfoWindows(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let ids = args["ids"] as? [String] else {
            result(FlutterError(code: "E001", message: "Invalid arguments for removeInfoWindows", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let guiManager = view.getGuiManager()
            
            for id in ids {
                let _ = guiManager.infoWindowLayer.removeInfoWindow(guiName: id)
            }
            result(nil)
        }
    }
    
    private func clearInfoWindows(_ result: @escaping FlutterResult) {
        withKakaoMapView(result) { view in
            let guiManager = view.getGuiManager()
            let _ = guiManager.infoWindowLayer.clear()
            result(nil)
        }
    }
    
    // MARK: - GuiEventDelegate
    
    func guiDidTapped(_ gui: GuiBase, componentName: String) {
        if let infoWindow = gui as? InfoWindow {
            let id = infoWindow.name
            
            let eventData: [String: Any] = [
                "infoWindowId": id,
                "latLng": [
                    "latitude": infoWindow.position?.wgsCoord.latitude ?? 0.0,
                    "longitude": infoWindow.position?.wgsCoord.longitude ?? 0.0
                ]
            ]
            
            methodChannel.invokeMethod("onInfoWindowClicked", arguments: eventData)
        }
    }
    
    // MARK: - KakaoMapEventDelegate
    
    func poiDidTapped(kakaoMap: KakaoMap, layerID: String, poiID: String, position: MapPoint) {
        let eventData = LabelClickEvent(labelId: poiID, latLng: position, layerId: layerID)
        methodChannel.invokeMethod("onLabelClicked", arguments: eventData.toMap())
    }
    
    func cameraDidStopped(kakaoMap: KakaoMap, by: MoveBy) {
        guard let view = mapController.getView(kKakaoMapViewName) as? KakaoMap else {
            return
        }
        
        let centerPoint = CGPoint(x: view.viewRect.width / 2, y: view.viewRect.height / 2)
        let center = kakaoMap.getPosition(centerPoint)
        let eventData: [String: Any] = [
            "latitude": center.wgsCoord.latitude,
            "longitude": center.wgsCoord.longitude,
            "zoomLevel": kakaoMap.zoomLevel,
            "tilt": kakaoMap.tiltAngle,
            "rotation": kakaoMap.rotationAngle
        ]
        methodChannel.invokeMethod("onCameraMoveEnd", arguments: eventData)
    }
    
    // MARK: - Helper Methods
    
    private func convertAlignmentString(_ alignment: String) -> GuiAlignment {
        switch alignment {
        case "topLeft":
            return GuiAlignment(vAlign: .top, hAlign: .left)
        case "topRight":
            return GuiAlignment(vAlign: .top, hAlign: .right)
        case "bottomLeft":
            return GuiAlignment(vAlign: .bottom, hAlign: .left)
        case "bottomRight":
            return GuiAlignment(vAlign: .bottom, hAlign: .right)
        case "center":
            return GuiAlignment(vAlign: .middle, hAlign: .center)
        case "topCenter":
            return GuiAlignment(vAlign: .top, hAlign: .center)
        case "bottomCenter":
            return GuiAlignment(vAlign: .bottom, hAlign: .center)
        case "leftCenter":
            return GuiAlignment(vAlign: .middle, hAlign: .left)
        case "rightCenter":
            return GuiAlignment(vAlign: .middle, hAlign: .right)
        default:
            return GuiAlignment(vAlign: .top, hAlign: .right)
        }
    }
    
    // MARK: - Compass and ScaleBar Control Methods
    
    private func showCompass(_ result: @escaping FlutterResult) {
        withKakaoMapView(result) { view in
            view.showCompass()
            result(nil)
        }
    }
    
    private func hideCompass(_ result: @escaping FlutterResult) {
        withKakaoMapView(result) { view in
            view.hideCompass()
            result(nil)
        }
    }
    
    private func showScaleBar(_ result: @escaping FlutterResult) {
        withKakaoMapView(result) { view in
            view.showScaleBar()
            result(nil)
        }
    }
    
    private func hideScaleBar(_ result: @escaping FlutterResult) {
        withKakaoMapView(result) { view in
            view.hideScaleBar()
            result(nil)
        }
    }
    
    private func setCompassPosition(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let alignment = args["alignment"] as? String,
              let offset = args["offset"] as? [String: Any],
              let dx = offset["dx"] as? Double,
              let dy = offset["dy"] as? Double else {
            result(FlutterError(code: "E001", message: "Invalid arguments for setCompassPosition", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let guiAlignment = self.convertAlignmentString(alignment)
            let offset = CGPoint(x: dx, y: dy)
            view.setCompassPosition(origin: guiAlignment, position: offset)
            result(nil)
        }
    }
    
    private func showLogo(_ result: @escaping FlutterResult) {
        withKakaoMapView(result) { view in
            result(nil)
        }
    }
    
    private func hideLogo(_ result: @escaping FlutterResult) {
        withKakaoMapView(result) { view in
            result(nil)
        }
    }
    
    private func setLogoPosition(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let alignment = args["alignment"] as? String,
              let offset = args["offset"] as? [String: Any],
              let dx = offset["dx"] as? Double,
              let dy = offset["dy"] as? Double else {
            result(FlutterError(code: "E001", message: "Invalid arguments for setLogoPosition", details: nil))
            return
        }
        
        withKakaoMapView(result) { view in
            let guiAlignment = self.convertAlignmentString(alignment)
            let offset = CGPoint(x: dx, y: dy)
            view.setLogoPosition(origin: guiAlignment, position: offset)
            result(nil)
        }
    }
}
