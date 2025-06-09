part of '../kakao_maps_flutter.dart';

abstract class KakaoMapsFlutterPlatform extends PlatformInterface {
  /// Constructs a KakaoMapsFlutterPlatform.
  KakaoMapsFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static KakaoMapsFlutterPlatform _instance = MethodChannelKakaoMapsFlutter();

  /// The default instance of [KakaoMapsFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelKakaoMapsFlutter].
  static KakaoMapsFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [KakaoMapsFlutterPlatform] when
  /// they register themselves.
  static set instance(KakaoMapsFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initialize KakaoMaps SDK
  Future<void> init(String token) {
    throw UnimplementedError('init() has not been implemented.');
  }
}
