import Foundation
import KakaoMapsSDK

struct LabelClickEvent {
  let labelId: String
  let latLng: MapPoint
  let layerId: String?

  init(labelId: String, latLng: MapPoint, layerId: String? = nil) {
    self.labelId = labelId
    self.latLng = latLng
    self.layerId = layerId
  }

  static func fromPoi(_ poi: Poi) -> LabelClickEvent {
    return LabelClickEvent(
      labelId: poi.itemID,
      latLng: poi.position,
      layerId: poi.layerID
    )
  }

  func toMap() -> [String: Any?] {
    return [
      "labelId": labelId,
      "latLng": [
        "latitude": latLng.wgsCoord.latitude,
        "longitude": latLng.wgsCoord.longitude,
      ],
      "layerId": layerId,
    ]
  }
}
