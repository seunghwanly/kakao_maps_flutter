import KakaoMapsSDK

extension CameraAnimationOptions {
    static func fromJson(_ json: [String: Any]) -> CameraAnimationOptions? {
        guard let autoElevation = json["autoElevation"] as? Bool,
              let duration = json["duration"] as? Int,
              let isConsecutive = json["isConsecutive"] as? Bool
        else {
            return nil
        }
        
        return CameraAnimationOptions(
            autoElevation: ObjCBool(autoElevation),
            consecutive: ObjCBool(isConsecutive),
            durationInMillis: UInt(duration)
        )
    }
}
