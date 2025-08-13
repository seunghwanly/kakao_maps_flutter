import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_maps_flutter/src/data/camera/camera_move_end_event.dart';
import 'package:kakao_maps_flutter/src/data/data.dart'
    show
        CameraAnimation,
        CameraUpdate,
        InfoWindowClickEvent,
        InfoWindowOption,
        LabelOption,
        LatLng,
        LatLngBounds,
        MapInfo,
        MarkerStyle,
        LodMarkerLayerOptions;
import 'package:kakao_maps_flutter/src/data/label/label_click_event.dart';
import 'package:kakao_maps_flutter/src/platform/kakao_map_method_call/kakao_map_method_call.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../data/compass/compass.dart';
import '../../data/logo/logo.dart';

part 'interface/kakao_map_controller_platform_interface.dart';
part 'method_channel/method_channel_kakao_map_controller.dart';

/// Kakao Map controller
/// [EN]
/// - Programmatic control over camera, markers, widgets and map settings
///
/// [KO]
/// - 카메라, 마커, 지도 위젯과 각종 설정을 제어하는 컨트롤러
class KakaoMapController extends KakaoMapControllerPlatform {
  /// Create controller
  /// [EN]
  /// - Instantiate controller bound to [viewId]
  ///
  /// [KO]
  /// - [viewId]에 바인딩되는 컨트롤러 생성
  KakaoMapController({
    required this.viewId,
  }) {
    _platform = MethodChannelKakaoMapController.create(viewId);
  }

  /// Create controller for tests
  /// [EN]
  /// - Use custom [platform] for testing
  ///
  /// [KO]
  /// - 테스트를 위해 주입 가능한 [platform] 사용
  @visibleForTesting
  KakaoMapController.forTest({
    required KakaoMapControllerPlatform platform,
    required this.viewId,
  }) : _platform = platform;

  /// View identifier
  final int viewId;

  late final KakaoMapControllerPlatform _platform;

  /// Label click stream
  /// [EN]
  /// - Emits when a label is clicked
  ///
  /// [KO]
  /// - 라벨 클릭 시 이벤트 스트림 발행
  @override
  Stream<LabelClickEvent> get onLabelClickedStream =>
      _platform.onLabelClickedStream;

  /// Info window click stream
  /// [EN]
  /// - Emits when an info window is clicked
  ///
  /// [KO]
  /// - 말풍선 클릭 시 이벤트 스트림 발행
  @override
  Stream<InfoWindowClickEvent> get onInfoWindowClickedStream =>
      _platform.onInfoWindowClickedStream;

  /// Camera move end stream
  /// [EN]
  /// - Emits when camera movement finishes
  ///
  /// [KO]
  /// - 카메라 이동이 완료될 때 이벤트 스트림 발행
  @override
  Stream<CameraMoveEndEvent> get onCameraMoveEndStream =>
      _platform.onCameraMoveEndStream;

  @override
  Future<T> _callMethod<T>(KakaoMapMethodCall<T> methodCall) async {
    return _platform._callMethod(methodCall);
  }

  /// Get zoom level
  /// [EN]
  /// - Returns null when unavailable
  ///
  /// [KO]
  /// - 가져올 수 없으면 null 반환
  Future<int?> getZoomLevel() async {
    return _platform._callMethod(const GetZoomLevel());
  }

  /// Set zoom level
  /// [EN]
  /// - Must be within SDK-supported range
  ///
  /// [KO]
  /// - SDK가 지원하는 범위 내 값 필요
  Future<void> setZoomLevel({
    required int zoomLevel,
  }) async {
    await _platform._callMethod(SetZoomLevel(zoomLevel: zoomLevel));
  }

  /// Move camera
  /// [EN]
  /// - [cameraUpdate]: target camera parameters, [animation]: optional animation
  ///
  /// [KO]
  /// - [cameraUpdate]: 목표 카메라 값, [animation]: 선택적 애니메이션
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

  /// Add marker
  /// [EN]
  /// - Add a single label/marker to the map
  ///
  /// [KO]
  /// - 단일 라벨/마커 추가
  Future<void> addMarker({
    required LabelOption labelOption,
  }) async {
    await _platform._callMethod(AddMarker(labelOption: labelOption));
  }

  /// Remove marker
  /// [EN]
  /// - Remove by marker id
  ///
  /// [KO]
  /// - 마커 id로 제거
  Future<void> removeMarker({
    required String id,
  }) async {
    await _platform._callMethod(RemoveMarker(id: id));
  }

  /// Add markers
  /// [EN]
  /// - Batch add multiple labels/markers
  ///
  /// [KO]
  /// - 여러 라벨/마커 일괄 추가
  Future<void> addMarkers({
    required List<LabelOption> labelOptions,
  }) async {
    await _platform._callMethod(AddMarkers(labelOptions: labelOptions));
  }

  /// Remove markers
  /// [EN]
  /// - Batch remove by ids
  ///
  /// [KO]
  /// - id 목록으로 일괄 제거
  Future<void> removeMarkers({
    required List<String> ids,
  }) async {
    await _platform._callMethod(RemoveMarkers(ids: ids));
  }

  /// Clear all markers
  Future<void> clearMarkers() async {
    await _platform._callMethod(const ClearMarkers());
  }

  /// Register marker styles
  /// [EN]
  /// - Register style bundles referenced by [LabelOption.styleId]
  ///
  /// [KO]
  /// - [LabelOption.styleId]에서 참조하는 스타일 묶음을 등록
  Future<void> registerMarkerStyles({
    required List<MarkerStyle> styles,
  }) async {
    await _platform._callMethod(RegisterMarkerStyles(styles: styles));
  }

  /// Remove marker styles
  Future<void> removeMarkerStyles({
    required List<String> styleIds,
  }) async {
    await _platform._callMethod(RemoveMarkerStyles(styleIds: styleIds));
  }

  /// Clear all marker styles
  Future<void> clearMarkerStyles() async {
    await _platform._callMethod(const ClearMarkerStyles());
  }

  /// Get map center
  /// [EN]
  /// - Returns null when unavailable
  ///
  /// [KO]
  /// - 가져올 수 없으면 null 반환
  Future<LatLng?> getCenter() async {
    return _platform._callMethod(const GetCenter());
  }

  /// To screen point
  /// [EN]
  /// - Convert [position] to screen coordinates, returns null on failure
  ///
  /// [KO]
  /// - [position]을 화면 좌표로 변환, 실패 시 null 반환
  Future<Offset?> toScreenPoint({
    required LatLng position,
  }) async {
    return _platform._callMethod(ToScreenPoint(position: position));
  }

  /// From screen point
  /// [EN]
  /// - Convert [point] to geographic position, returns null on failure
  ///
  /// [KO]
  /// - [point]을 지리 좌표로 변환, 실패 시 null 반환
  Future<LatLng?> fromScreenPoint({
    required Offset point,
  }) async {
    return _platform._callMethod(FromScreenPoint(point: point));
  }

  /// Set POI visibility
  Future<void> setPoiVisible({
    required bool isVisible,
  }) async {
    return _platform._callMethod(SetPoiVisible(isVisible: isVisible));
  }

  /// Set POI clickability
  Future<void> setPoiClickable({
    required bool isClickable,
  }) async {
    return _platform._callMethod(SetPoiClickable(isClickable: isClickable));
  }

  /// Set POI scale
  /// [EN]
  /// - 0: SMALL, 1: REGULAR, 2: LARGE, 3: XLARGE
  ///
  /// [KO]
  /// - 0: SMALL, 1: REGULAR, 2: LARGE, 3: XLARGE
  Future<void> setPoiScale({
    required int scale,
  }) async {
    return _platform._callMethod(SetPoiScale(scale: scale));
  }

  /// Set map padding
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

  /// Set viewport size
  Future<void> setViewport({
    required int width,
    required int height,
  }) async {
    return _platform._callMethod(SetViewport(width: width, height: height));
  }

  /// Get viewport bounds
  Future<LatLngBounds?> getViewportBounds() async {
    return _platform._callMethod(const GetViewportBounds());
  }

  /// Get map info
  Future<MapInfo?> getMapInfo() async {
    return _platform._callMethod(const GetMapInfo());
  }

  /// Add info window
  Future<void> addInfoWindow({
    required InfoWindowOption infoWindowOption,
  }) async {
    await _platform
        ._callMethod(AddInfoWindow(infoWindowOption: infoWindowOption));
  }

  /// Remove info window
  Future<void> removeInfoWindow({
    required String id,
  }) async {
    await _platform._callMethod(RemoveInfoWindow(id: id));
  }

  /// Add info windows
  Future<void> addInfoWindows({
    required List<InfoWindowOption> infoWindowOptions,
  }) async {
    await _platform
        ._callMethod(AddInfoWindows(infoWindowOptions: infoWindowOptions));
  }

  /// Remove info windows
  Future<void> removeInfoWindows({
    required List<String> ids,
  }) async {
    await _platform._callMethod(RemoveInfoWindows(ids: ids));
  }

  /// Clear all info windows
  Future<void> clearInfoWindows() async {
    await _platform._callMethod(const ClearInfoWindows());
  }

  /// Set info window layer visibility
  Future<void> setInfoWindowLayerVisible({required bool visible}) async {
    await _platform._callMethod(SetInfoWindowLayerVisible(visible: visible));
  }

  /// Set single info window visibility
  Future<void> setInfoWindowVisible({
    required String id,
    required bool visible,
  }) async {
    await _platform._callMethod(SetInfoWindowVisible(id: id, visible: visible));
  }

  /// Show compass
  Future<void> showCompass() async {
    await _platform._callMethod(const ShowCompass());
  }

  /// Hide compass
  Future<void> hideCompass() async {
    await _platform._callMethod(const HideCompass());
  }

  /// Show scale bar
  Future<void> showScaleBar() async {
    await _platform._callMethod(const ShowScaleBar());
  }

  /// Hide scale bar
  Future<void> hideScaleBar() async {
    await _platform._callMethod(const HideScaleBar());
  }

  /// Set compass position
  Future<void> setCompassPosition({
    required CompassAlignment alignment,
    required Offset offset,
  }) async {
    await _platform._callMethod(
      SetCompassPosition(
        alignment: alignment,
        offset: offset,
      ),
    );
  }

  /// Show logo
  Future<void> showLogo() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      throw PlatformException(
        code: 'UNSUPPORTED',
        message:
            'Logo show/hide is only supported on iOS. The Kakao Maps Android SDK requires the logo to always be visible.',
      );
    }
    return _platform._callMethod(const ShowLogo());
  }

  /// Hide logo
  Future<void> hideLogo() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      throw PlatformException(
        code: 'UNSUPPORTED',
        message:
            'Logo show/hide is only supported on iOS. The Kakao Maps Android SDK requires the logo to always be visible.',
      );
    }
    return _platform._callMethod(const HideLogo());
  }

  /// Set logo position
  Future<void> setLogoPosition({
    required LogoAlignment alignment,
    required Offset offset,
  }) async {
    return _platform._callMethod(
      SetLogoPosition(
        alignment: alignment,
        offset: offset,
      ),
    );
  }

  // ===== LOD Marker (LodLabel/LodPoi) APIs =====

  /// Add LOD marker layer
  Future<void> addLodMarkerLayer({
    required LodMarkerLayerOptions options,
  }) async {
    await _platform._callMethod(AddLodMarkerLayer(options: options));
  }

  /// Remove LOD marker layer
  Future<void> removeLodMarkerLayer({
    required String layerId,
  }) async {
    await _platform._callMethod(RemoveLodMarkerLayer(layerId: layerId));
  }

  /// Add LOD marker
  Future<void> addLodMarker({
    required LabelOption option,
    required String layerId,
  }) async {
    await _platform._callMethod(AddLodMarker(option: option, layerId: layerId));
  }

  /// Add LOD markers
  Future<void> addLodMarkers({
    required List<LabelOption> options,
    required String layerId,
  }) async {
    await _platform
        ._callMethod(AddLodMarkers(options: options, layerId: layerId));
  }

  /// Remove specific LOD markers
  Future<void> removeLodMarkers({
    required String layerId,
    required List<String> ids,
  }) async {
    await _platform._callMethod(RemoveLodMarkers(layerId: layerId, ids: ids));
  }

  /// Clear all LOD markers in layer
  Future<void> clearAllLodMarkers({
    required String layerId,
  }) async {
    await _platform._callMethod(ClearAllLodMarkers(layerId: layerId));
  }

  /// Show all LOD markers in layer
  Future<void> showAllLodMarkers({
    required String layerId,
  }) async {
    await _platform._callMethod(ShowAllLodMarkers(layerId: layerId));
  }

  /// Hide all LOD markers in layer
  Future<void> hideAllLodMarkers({
    required String layerId,
  }) async {
    await _platform._callMethod(HideAllLodMarkers(layerId: layerId));
  }

  /// Show LOD markers by ids
  Future<void> showLodMarkers({
    required String layerId,
    required List<String> ids,
  }) async {
    await _platform._callMethod(ShowLodMarkers(layerId: layerId, ids: ids));
  }

  /// Hide LOD markers by ids
  Future<void> hideLodMarkers({
    required String layerId,
    required List<String> ids,
  }) async {
    await _platform._callMethod(HideLodMarkers(layerId: layerId, ids: ids));
  }

  /// Set LOD layer clickability
  Future<void> setLodMarkerLayerClickable({
    required String layerId,
    required bool clickable,
  }) async {
    await _platform._callMethod(
      SetLodMarkerLayerClickable(layerId: layerId, clickable: clickable),
    );
  }
}
