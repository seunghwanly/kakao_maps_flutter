import Flutter
import KakaoMapsSDK
import UIKit

public class KakaoMapsFlutterPlugin: NSObject, FlutterPlugin {
    private static var initializationChannel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Register platform view
        let factory = KakaoMapFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "kakao_map_view")
        
        // Register method channel for init
        let channel = FlutterMethodChannel(
            name: "kakao_maps_flutter",
            binaryMessenger: registrar.messenger(),
            codec: FlutterStandardMethodCodec.sharedInstance()
        )
        initializationChannel = channel
        
        let instance = KakaoMapsFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "init":
            if let args = call.arguments as? [String: Any],
               let appKey = args["appKey"] as? String
            {
                SDKInitializer.InitSDK(appKey: appKey)
                result(true)
            } else {
                result(FlutterError(code: "E001", message: "Missing appKey", details: nil))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
