import Foundation
import KakaoMapsSDK

struct InfoWindowClickEvent {
  let infoWindowId: String
  let latLng: MapPoint

  init(infoWindowId: String, latLng: MapPoint) {
    self.infoWindowId = infoWindowId
    self.latLng = latLng
  }

  func toMap() -> [String: Any] {
    return [
      "infoWindowId": infoWindowId,
      "latLng": [
        "latitude": latLng.wgsCoord.latitude,
        "longitude": latLng.wgsCoord.longitude,
      ],
    ]
  }
}
