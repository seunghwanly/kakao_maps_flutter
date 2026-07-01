import 'dart:async';

import 'package:flutter/services.dart';
import 'package:kakao_maps_flutter/src/data/data.dart';
import 'package:kakao_maps_flutter/src/method_call/kakao_map_method_call.dart';

import '../interface/kakao_map_controller_platform_interface.dart';

class MethodChannelKakaoMapController extends KakaoMapControllerPlatform {
  MethodChannelKakaoMapController._(this._channel) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onMapReady') {
        if (!_readyCompleter.isCompleted) {
          _readyCompleter.complete();
        }
        return;
      }

      if (call.method == 'onLabelClicked') {
        final event = LabelClickEvent.fromJson(
          _asStringKeyedMap(call.arguments),
        );
        onLabelClicked(event);
        return;
      }

      if (call.method == 'onInfoWindowClicked') {
        final event = InfoWindowClickEvent.fromJson(
          _asStringKeyedMap(call.arguments),
        );
        onInfoWindowClicked(event);
        return;
      }

      if (call.method == 'onCameraMoveEnd') {
        final event = CameraMoveEndEvent.fromJson(
          _asStringKeyedMap(call.arguments),
        );
        onCameraMoveEnd(event);
        return;
      }

      throw UnimplementedError(
        '[Flutter:MethodChannelKakaoMapController] ${call.method} not implemented',
      );
    });
  }

  factory MethodChannelKakaoMapController.create(int viewId) {
    final channel = MethodChannel(
      'view.method_channel.kakao_maps_flutter#$viewId',
    );
    return MethodChannelKakaoMapController._(channel);
  }

  final MethodChannel _channel;

  final Completer<void> _readyCompleter = Completer<void>();

  @override
  Future<T> callMethod<T>(KakaoMapMethodCall<T> methodCall) async {
    await _readyCompleter.future;

    final result = await _channel.invokeMethod(
      methodCall.name,
      methodCall.encode(),
    );

    return methodCall.decode(_normalizeStandardCodec(result));
  }

  static Object? _normalizeStandardCodec(Object? value) {
    if (value is Map) {
      return value.map<String, Object?>(
        (key, dynamic val) =>
            MapEntry(key.toString(), _normalizeStandardCodec(val)),
      );
    }
    if (value is List) {
      return value.map<Object?>((e) => _normalizeStandardCodec(e)).toList();
    }
    return value;
  }

  static Map<String, Object?> _asStringKeyedMap(Object? arguments) {
    final normalized = _normalizeStandardCodec(arguments);
    return (normalized! as Map).cast<String, Object?>();
  }
}
