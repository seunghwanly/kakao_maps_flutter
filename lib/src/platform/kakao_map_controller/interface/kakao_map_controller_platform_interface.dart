part of '../kakao_map_controller.dart';

abstract class KakaoMapControllerPlatform extends PlatformInterface {
  KakaoMapControllerPlatform() : super(token: _token);

  static final Object _token = Object();

  static KakaoMapControllerPlatform get instance => _instance;

  static KakaoMapControllerPlatform _instance =
      MethodChannelKakaoMapController.instance;

  static set instance(KakaoMapControllerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<T> _callMethod<T>(KakaoMapMethodCall<T> methodCall) async {
    throw UnimplementedError(
      '[Flutter:KakaoMapControllerPlatform] callMethod not implemented',
    );
  }
}
