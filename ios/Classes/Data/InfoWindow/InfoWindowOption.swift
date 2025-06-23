import Foundation
import KakaoMapsSDK

struct InfoWindowOption {
  let id: String
  let latLng: MapPoint
  let title: String
  let snippet: String?
  let isVisible: Bool
  let offset: InfoWindowOffset

  init(
    id: String, latLng: MapPoint, title: String, snippet: String? = nil, isVisible: Bool = true,
    offset: InfoWindowOffset = InfoWindowOffset(x: 0, y: 0)
  ) {
    self.id = id
    self.latLng = latLng
    self.title = title
    self.snippet = snippet
    self.isVisible = isVisible
    self.offset = offset
  }

  static func fromDictionary(_ dict: [String: Any]) -> InfoWindowOption? {
    guard let id = dict["id"] as? String,
      let latLngDict = dict["latLng"] as? [String: Any],
      let latitude = latLngDict["latitude"] as? Double,
      let longitude = latLngDict["longitude"] as? Double,
      let title = dict["title"] as? String
    else {
      return nil
    }

    let snippet = dict["snippet"] as? String
    let isVisible = dict["isVisible"] as? Bool ?? true

    var offset = InfoWindowOffset(x: 0, y: 0)
    if let offsetDict = dict["offset"] as? [String: Any] {
      offset = InfoWindowOffset.fromDictionary(offsetDict)
    }

    let mapPoint = MapPoint(longitude: longitude, latitude: latitude)

    return InfoWindowOption(
      id: id,
      latLng: mapPoint,
      title: title,
      snippet: snippet,
      isVisible: isVisible,
      offset: offset
    )
  }
}

struct InfoWindowOffset {
  let x: Double
  let y: Double

  init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }

  static func fromDictionary(_ dict: [String: Any]) -> InfoWindowOffset {
    let x = dict["x"] as? Double ?? 0.0
    let y = dict["y"] as? Double ?? 0.0
    return InfoWindowOffset(x: x, y: y)
  }
}
