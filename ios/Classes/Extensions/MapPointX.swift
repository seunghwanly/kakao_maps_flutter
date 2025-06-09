import KakaoMapsSDK

extension MapPoint {
  static func fromJson(_ json: [String: Any]) -> MapPoint? {
    guard let latitude = json["latitude"] as? Double,
      let longitude = json["longitude"] as? Double
    else {
      return nil
    }

      return MapPoint(longitude: longitude, latitude: latitude)
  }
}
