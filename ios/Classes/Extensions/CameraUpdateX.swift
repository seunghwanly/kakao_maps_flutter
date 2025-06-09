import KakaoMapsSDK

extension CameraUpdate {
  static func fromJson(_ json: [String: Any], mapView: KakaoMap) -> CameraUpdate? {
    guard let positionJson = json["position"] as? [String: Any],
      let point = MapPoint.fromJson(positionJson),
      let zoomLevel = json["zoomLevel"] as? Int
      // TODO(seunghwanly): 추가 기능 개발
      //   let tiltAngle = json["tiltAngle"] as? Double,
      //   let rotationAngle = json["rotationAngle"] as? Double,
      //   let height = json["height"] as? Double,
      //   let fitPointsJson = json["fitPoints"] as? [[String: Any]],
      //   let fitPoints = fitPointsJson?.compactMap { MapPoint.fromJson($0) },
      //   let padding = json["padding"] as? Int,
      //   let type = json["type"] as? Int
    else {
      return nil
    }
    return CameraUpdate.make(target: point, zoomLevel: zoomLevel, mapView: mapView)
  }
}
