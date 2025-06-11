import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_maps_flutter/src/data/data.dart'
    show
        CameraAnimation,
        CameraUpdate,
        LabelOption,
        LatLng,
        LatLngBounds,
        MapInfo;
import 'package:kakao_maps_flutter/src/data/label/label_click_event.dart';
import 'package:kakao_maps_flutter/src/platform/kakao_map_method_call/kakao_map_method_call.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'interface/kakao_map_controller_platform_interface.dart';
part 'method_channel/method_channel_kakao_map_controller.dart';

class KakaoMapController extends KakaoMapControllerPlatform {
  KakaoMapController({
    required this.viewId,
  }) {
    _platform = MethodChannelKakaoMapController.create(viewId);
  }

  @visibleForTesting
  KakaoMapController.forTest({
    required KakaoMapControllerPlatform platform,
    required this.viewId,
  }) : _platform = platform;

  final int viewId;

  late final KakaoMapControllerPlatform _platform;

  @override
  Stream<LabelClickEvent> get onLabelClickedStream =>
      _platform.onLabelClickedStream;

  @override
  Future<T> _callMethod<T>(KakaoMapMethodCall<T> methodCall) async {
    return _platform._callMethod(methodCall);
  }

  Future<int?> getZoomLevel() async {
    return _platform._callMethod(const GetZoomLevel());
  }

  Future<void> setZoomLevel({
    required int zoomLevel,
  }) async {
    await _platform._callMethod(SetZoomLevel(zoomLevel: zoomLevel));
  }

  Future<void> moveCamera({
    required CameraUpdate cameraUpdate,
    CameraAnimation? animation,
  }) async {
    await _platform._callMethod(
      MoveCamera(
        cameraUpdate: cameraUpdate,
        animation: animation,
      ),
    );
  }

  Future<void> addMarker({
    required LabelOption labelOption,
  }) async {
    await _platform._callMethod(AddMarker(labelOption: labelOption));
  }

  Future<void> removeMarker({
    required String id,
  }) async {
    await _platform._callMethod(RemoveMarker(id: id));
  }

  Future<void> addMarkers({
    required List<LabelOption> labelOptions,
  }) async {
    await _platform._callMethod(AddMarkers(labelOptions: labelOptions));
  }

  Future<void> removeMarkers({
    required List<String> ids,
  }) async {
    await _platform._callMethod(RemoveMarkers(ids: ids));
  }

  Future<void> clearMarkers() async {
    await _platform._callMethod(const ClearMarkers());
  }

  Future<LatLng?> getCenter() async {
    return _platform._callMethod(const GetCenter());
  }

  Future<Offset?> toScreenPoint({
    required LatLng position,
  }) async {
    return _platform._callMethod(ToScreenPoint(position: position));
  }

  Future<LatLng?> fromScreenPoint({
    required Offset point,
  }) async {
    return _platform._callMethod(FromScreenPoint(point: point));
  }

  Future<void> setPoiVisible({
    required bool isVisible,
  }) async {
    return _platform._callMethod(SetPoiVisible(isVisible: isVisible));
  }

  Future<void> setPoiClickable({
    required bool isClickable,
  }) async {
    return _platform._callMethod(SetPoiClickable(isClickable: isClickable));
  }

  Future<void> setPoiScale({
    required int scale,
  }) async {
    return _platform._callMethod(SetPoiScale(scale: scale));
  }

  Future<void> setPadding({
    required int left,
    required int top,
    required int right,
    required int bottom,
  }) async {
    return _platform._callMethod(
      SetPadding(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
    );
  }

  Future<void> setViewport({
    required int width,
    required int height,
  }) async {
    return _platform._callMethod(SetViewport(width: width, height: height));
  }

  Future<LatLngBounds?> getViewportBounds() async {
    return _platform._callMethod(const GetViewportBounds());
  }

  Future<MapInfo?> getMapInfo() async {
    return _platform._callMethod(const GetMapInfo());
  }
}
