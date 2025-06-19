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

  final StreamController<LabelClickEvent> _onLabelClickController =
      StreamController<LabelClickEvent>.broadcast();

  final StreamController<InfoWindowClickEvent> _onInfoWindowClickController =
      StreamController<InfoWindowClickEvent>.broadcast();

  Stream<LabelClickEvent> get onLabelClickedStream =>
      _onLabelClickController.stream;

  Stream<InfoWindowClickEvent> get onInfoWindowClickedStream =>
      _onInfoWindowClickController.stream;

  Future<T> _callMethod<T>(KakaoMapMethodCall<T> methodCall) async {
    throw UnimplementedError(
      '[Flutter:KakaoMapControllerPlatform] callMethod not implemented',
    );
  }

  void onLabelClicked(LabelClickEvent event) =>
      _onLabelClickController.add(event);

  void onInfoWindowClicked(InfoWindowClickEvent event) =>
      _onInfoWindowClickController.add(event);

  void dispose() {
    _onLabelClickController.close();
    _onInfoWindowClickController.close();
  }
}
