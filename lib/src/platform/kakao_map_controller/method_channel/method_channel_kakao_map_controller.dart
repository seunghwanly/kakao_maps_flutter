part of '../kakao_map_controller.dart';

class MethodChannelKakaoMapController extends KakaoMapControllerPlatform {
  MethodChannelKakaoMapController._(
    MethodChannel? channel,
  ) : _channel = channel;

  factory MethodChannelKakaoMapController.create(int viewId) {
    final channel = MethodChannel(
      'view.method_channel.kakao_maps_flutter#$viewId',
      const JSONMethodCodec(),
    )..setMethodCallHandler(
        (call) async {
          if (call.method == 'onMapReady') {
            _isReady = true;
            return;
          }

          if (call.method == 'onLabelClicked') {
            final event = LabelClickEvent.fromJson(call.arguments);
            _instance.onLabelClicked(event);
            return;
          }

          if (call.method == 'onInfoWindowClicked') {
            final event = InfoWindowClickEvent.fromJson(call.arguments);
            _instance.onInfoWindowClicked(event);
            return;
          }

          throw UnimplementedError(
            '[Flutter:MethodChannelKakaoMapController] ${call.method} not implemented',
          );
        },
      );

    return _instance = MethodChannelKakaoMapController._(channel);
  }

  static MethodChannelKakaoMapController get instance => _instance;

  static MethodChannelKakaoMapController _instance =
      MethodChannelKakaoMapController._(null);

  MethodChannel? _channel;

  static bool _isReady = false;

  @override
  Future<T> _callMethod<T>(KakaoMapMethodCall<T> methodCall) async {
    assert(_isReady);

    final result = await _channel?.invokeMethod(
      methodCall.name,
      methodCall.encode(),
    );

    return methodCall.decode(result);
  }
}
