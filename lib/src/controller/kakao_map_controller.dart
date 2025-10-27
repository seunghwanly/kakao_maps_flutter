import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Offset;
import 'package:flutter/services.dart' show PlatformException;
import 'package:kakao_maps_flutter/src/data/data.dart';
import 'package:kakao_maps_flutter/src/method_call/kakao_map_method_call.dart';
import 'package:kakao_maps_flutter/src/method_call/kakao_map_web_method_call.dart';

import 'factory_impl/platform_controller_stub.dart'
    if (dart.library.io) 'factory_impl/platform_controller_mobile.dart'
    if (dart.library.html) 'factory_impl/platform_controller_web.dart';
import 'interface/kakao_map_controller_platform_interface.dart';

/// Kakao Map controller
/// [EN]
/// - Programmatic control over camera, markers, widgets and map settings
///
/// [KO]
/// - 카메라, 마커, 지도 위젯과 각종 설정을 제어하는 컨트롤러
class KakaoMapController {
  /// Create controller
  /// [EN]
  /// - Instantiate controller bound to [viewId]
  ///
  /// [KO]
  /// - [viewId]에 바인딩되는 컨트롤러 생성
  KakaoMapController({
    required this.viewId,
  }) {
    _platform = createPlatformControllerImpl(viewId);
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

  /// Android/iOS default layer id
  static const String defaultLabelLayerId = 'default_label_layer_id';

  /// View identifier
  final int viewId;

  late final KakaoMapControllerPlatform _platform;

  /// Label click stream
  /// [EN]
  /// - Emits when a label is clicked
  ///
  /// [KO]
  /// - 라벨 클릭 시 이벤트 스트림 발행
  Stream<LabelClickEvent> get onLabelClickedStream =>
      _platform.onLabelClickedStream;

  /// Info window click stream
  /// [EN]
  /// - Emits when an info window is clicked
  ///
  /// [KO]
  /// - 말풍선 클릭 시 이벤트 스트림 발행
  Stream<InfoWindowClickEvent> get onInfoWindowClickedStream =>
      _platform.onInfoWindowClickedStream;

  /// Camera move end stream
  /// [EN]
  /// - Emits when camera movement finishes
  ///
  /// [KO]
  /// - 카메라 이동이 완료될 때 이벤트 스트림 발행
  Stream<CameraMoveEndEvent> get onCameraMoveEndStream =>
      _platform.onCameraMoveEndStream;

  /// Cluster click stream
  /// [EN]
  /// - Emits when a marker cluster is clicked
  ///
  /// [KO]
  /// - 마커 클러스터 클릭 시 이벤트 스트림 발행
  Stream<ClusterClickEvent> get onClusterClickedStream =>
      _platform.onClusterClickedStream;

  /// Get zoom level
  /// [EN]
  /// - Returns null when unavailable
  ///
  /// [KO]
  /// - 가져올 수 없으면 null 반환
  Future<int?> getZoomLevel() {
    if (kIsWeb) {
      return _platform.callWebMethod(const WebGetZoomLevel());
    }
    return _platform.callMethod(const GetZoomLevel());
  }

  /// Set zoom level
  /// [EN]
  /// - Must be within SDK-supported range
  ///
  /// [KO]
  /// - SDK가 지원하는 범위 내 값 필요
  Future<void> setZoomLevel({
    required int zoomLevel,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(WebSetZoomLevel(zoomLevel: zoomLevel));
    }
    return _platform.callMethod(SetZoomLevel(zoomLevel: zoomLevel));
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
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(
        WebMoveCamera(
          cameraUpdate: cameraUpdate,
          animation: animation,
        ),
      );
    }
    return _platform.callMethod(
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
    required MarkerOption markerOption,
    String layerId = KakaoMapController.defaultLabelLayerId,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(WebAddMarker(markerOption: markerOption));
    }
    return _platform
        .callMethod(AddMarker(markerOption: markerOption, layerId: layerId));
  }

  /// Remove marker
  /// [EN]
  /// - Remove by marker id
  ///
  /// [KO]
  /// - 마커 id로 제거
  Future<void> removeMarker({
    required String id,
    String layerId = KakaoMapController.defaultLabelLayerId,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(WebRemoveMarker(id: id));
    }
    return _platform.callMethod(RemoveMarker(id: id, layerId: layerId));
  }

  /// Add markers
  /// [EN]
  /// - Batch add multiple labels/markers
  ///
  /// [KO]
  /// - 여러 라벨/마커 일괄 추가
  Future<void> addMarkers({
    required List<MarkerOption> markerOptions,
    String layerId = KakaoMapController.defaultLabelLayerId,
  }) {
    if (kIsWeb) {
      return _platform
          .callWebMethod(WebAddMarkers(markerOptions: markerOptions));
    }
    return _platform.callMethod(
      AddMarkers(markerOptions: markerOptions, layerId: layerId),
    );
  }

  /// Remove markers
  /// [EN]
  /// - Batch remove by ids
  ///
  /// [KO]
  /// - id 목록으로 일괄 제거
  Future<void> removeMarkers({
    required List<String> ids,
    String layerId = KakaoMapController.defaultLabelLayerId,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(WebRemoveMarkers(ids: ids));
    }
    return _platform.callMethod(RemoveMarkers(ids: ids, layerId: layerId));
  }

  /// Clear all markers in specific layer
  Future<void> clearMarkers({
    String layerId = KakaoMapController.defaultLabelLayerId,
  }) {
    if (kIsWeb) {
      // On web, clearMarkers doesn't use layerId and clears all non-clustered markers.
      return _platform.callWebMethod(const WebClearMarkers());
    }
    return _platform.callMethod(ClearMarkers(layerId: layerId));
  }

  /// Register marker styles
  /// [EN]
  /// - Register style bundles referenced by [MarkerOption.styleId]
  ///
  /// [KO]
  /// - [MarkerOption.styleId]에서 참조하는 스타일 묶음을 등록
  Future<void> registerMarkerStyles({
    required List<MarkerStyle> styles,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(WebRegisterMarkerStyles(styles: styles));
    }
    return _platform.callMethod(RegisterMarkerStyles(styles: styles));
  }

  /// Remove marker styles
  Future<void> removeMarkerStyles({
    required List<String> styleIds,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(WebRemoveMarkerStyles(styleIds: styleIds));
    }
    return _platform.callMethod(RemoveMarkerStyles(styleIds: styleIds));
  }

  /// Clear all marker styles
  Future<void> clearMarkerStyles() {
    if (kIsWeb) {
      return _platform.callWebMethod(const WebClearMarkerStyles());
    }
    return _platform.callMethod(const ClearMarkerStyles());
  }

  /// Get map center
  /// [EN]
  /// - Returns null when unavailable
  ///
  /// [KO]
  /// - 가져올 수 없으면 null 반환
  Future<LatLng?> getCenter() {
    if (kIsWeb) {
      return _platform.callWebMethod(const WebGetCenter());
    }
    return _platform.callMethod(const GetCenter());
  }

  /// To screen point
  /// [EN]
  /// - Convert [position] to screen coordinates, returns null on failure
  /// - Not supported on Web
  ///
  /// [KO]
  /// - [position]을 화면 좌표로 변환, 실패 시 null 반환
  /// - 웹 미지원
  Future<Offset?> toScreenPoint({
    required LatLng position,
  }) {
    if (kIsWeb) {
      // TODO: Implement using getProjection().containerPointFromCoords() if needed
      return Future.value();
    }
    return _platform.callMethod(ToScreenPoint(position: position));
  }

  /// From screen point
  /// [EN]
  /// - Convert [point] to geographic position, returns null on failure
  /// - Not supported on Web
  ///
  /// [KO]
  /// - [point]을 지리 좌표로 변환, 실패 시 null 반환
  /// - 웹 미지원
  Future<LatLng?> fromScreenPoint({
    required Offset point,
  }) {
    if (kIsWeb) {
      // TODO: Implement using getProjection().coordsFromContainerPoint() if needed
      return Future.value();
    }
    return _platform.callMethod(FromScreenPoint(point: point));
  }

  /// Set POI visibility
  Future<void> setPoiVisible({
    required bool isVisible,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(SetPoiVisible(isVisible: isVisible));
  }

  /// Set POI clickability
  Future<void> setPoiClickable({
    required bool isClickable,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(SetPoiClickable(isClickable: isClickable));
  }

  /// Set POI scale
  /// [EN]
  /// - 0: SMALL, 1: REGULAR, 2: LARGE, 3: XLARGE
  ///
  /// [KO]
  /// - 0: SMALL, 1: REGULAR, 2: LARGE, 3: XLARGE
  Future<void> setPoiScale({
    required int scale,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(SetPoiScale(scale: scale));
  }

  /// Set map padding
  Future<void> setPadding({
    required int left,
    required int top,
    required int right,
    required int bottom,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(
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
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(SetViewport(width: width, height: height));
  }

  /// Get viewport bounds
  Future<LatLngBounds?> getViewportBounds() {
    if (kIsWeb) {
      return _platform.callWebMethod(const WebGetViewportBounds());
    }
    return _platform.callMethod(const GetViewportBounds());
  }

  /// Get map info
  Future<MapInfo?> getMapInfo() {
    if (kIsWeb) {
      return _platform.callWebMethod(const WebGetMapInfo());
    }
    return _platform.callMethod(const GetMapInfo());
  }

  /// Add info window
  Future<void> addInfoWindow({
    required InfoWindowOption infoWindowOption,
  }) {
    if (kIsWeb) {
      return _platform
          .callWebMethod(WebAddInfoWindow(infoWindowOption: infoWindowOption));
    }
    return _platform
        .callMethod(AddInfoWindow(infoWindowOption: infoWindowOption));
  }

  /// Update info window
  Future<void> updateInfoWindow({
    required InfoWindowOption infoWindowOption,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(
        WebUpdateInfoWindow(infoWindowOption: infoWindowOption),
      );
    }
    return _platform
        .callMethod(UpdateInfoWindow(infoWindowOption: infoWindowOption));
  }

  /// Remove info window
  Future<void> removeInfoWindow({
    required String id,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(WebRemoveInfoWindow(id: id));
    }
    return _platform.callMethod(RemoveInfoWindow(id: id));
  }

  /// Add info windows
  Future<void> addInfoWindows({
    required List<InfoWindowOption> infoWindowOptions,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(
        WebAddInfoWindows(infoWindowOptions: infoWindowOptions),
      );
    }
    return _platform
        .callMethod(AddInfoWindows(infoWindowOptions: infoWindowOptions));
  }

  /// Remove info windows
  Future<void> removeInfoWindows({
    required List<String> ids,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(WebRemoveInfoWindows(ids: ids));
    }
    return _platform.callMethod(RemoveInfoWindows(ids: ids));
  }

  /// Clear all info windows
  Future<void> clearInfoWindows() {
    if (kIsWeb) {
      return _platform.callWebMethod(const WebClearInfoWindows());
    }
    return _platform.callMethod(const ClearInfoWindows());
  }

  /// Set info window layer visibility
  Future<void> setInfoWindowLayerVisible({required bool visible}) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(SetInfoWindowLayerVisible(visible: visible));
  }

  /// Set single info window visibility
  Future<void> setInfoWindowVisible({
    required String id,
    required bool visible,
  }) {
    if (kIsWeb) {
      return _platform
          .callWebMethod(WebSetInfoWindowVisible(id: id, visible: visible));
    }
    return _platform.callMethod(SetInfoWindowVisible(id: id, visible: visible));
  }

  /// Show compass
  Future<void> showCompass() {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(const ShowCompass());
  }

  /// Hide compass
  Future<void> hideCompass() {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(const HideCompass());
  }

  /// Show scale bar
  Future<void> showScaleBar() {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(const ShowScaleBar());
  }

  /// Hide scale bar
  Future<void> hideScaleBar() {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(const HideScaleBar());
  }

  /// Set compass position
  Future<void> setCompassPosition({
    required CompassAlignment alignment,
    required Offset offset,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(
      SetCompassPosition(
        alignment: alignment,
        offset: offset,
      ),
    );
  }

  /// Show logo
  Future<void> showLogo() {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      throw PlatformException(
        code: 'UNSUPPORTED',
        message:
            'Logo show/hide is only supported on iOS. The Kakao Maps Android SDK requires the logo to always be visible.',
      );
    }
    return _platform.callMethod(const ShowLogo());
  }

  /// Hide logo
  Future<void> hideLogo() {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      throw PlatformException(
        code: 'UNSUPPORTED',
        message:
            'Logo show/hide is only supported on iOS. The Kakao Maps Android SDK requires the logo to always be visible.',
      );
    }
    return _platform.callMethod(const HideLogo());
  }

  /// Set logo position
  Future<void> setLogoPosition({
    required LogoAlignment alignment,
    required Offset offset,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(
      SetLogoPosition(
        alignment: alignment,
        offset: offset,
      ),
    );
  }

  // ===== LabelLayer control (non-LOD) =====

  /// Add a normal LabelLayer managed by LabelManager
  Future<void> addMarkerLayer({
    required String layerId,
    int? zOrder,
    bool? clickable,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(
      AddMarkerLayer(layerId: layerId, zOrder: zOrder, clickable: clickable),
    );
  }

  /// Set layer visible by layerId
  Future<void> setMarkerLayerVisible({
    required String layerId,
    required bool visible,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(
      SetMarkerLayerVisible(layerId: layerId, visible: visible),
    );
  }

  /// Show all markers in the specified layer
  Future<void> showAllMarkers({
    required String layerId,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(
      ShowAllMarkers(layerId: layerId),
    );
  }

  /// Hide all markers in the specified layer
  Future<void> hideAllMarkers({
    required String layerId,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform.callMethod(
      HideAllMarkers(layerId: layerId),
    );
  }

  // ===== LOD / Clusterer APIs =====

  /// Add LOD marker layer (Mobile only)
  Future<void> addLodMarkerLayer({
    required LodMarkerLayerOptions options,
  }) {
    if (kIsWeb) {
      throw PlatformException(
        code: 'UNSUPPORTED',
        message:
            'Use addWebMarkerClusterer() to add a marker clusterer on web platform.',
      );
    }
    return _platform.callMethod(AddLodMarkerLayer(options: options));
  }

  /// Add a web marker clusterer (Web only)
  Future<void> addWebMarkerClusterer({
    required String clustererId,
    int gridSize = 60,
    bool averageCenter = false,
    int minLevel = 0,
    int minClusterSize = 2,
    bool disableClickZoom = false,
    List<int> calculator = const [10, 100, 1000, 10000],
    bool clickable = false,
    bool hoverable = false,
    List<String> texts = const [],
    List<Map<String, Object?>> styles = const [],
  }) {
    if (!kIsWeb) {
      return Future.value();
    }
    return _platform.callWebMethod(
      AddWebMarkerClusterer(
        clustererId: clustererId,
        gridSize: gridSize,
        averageCenter: averageCenter,
        minLevel: minLevel,
        minClusterSize: minClusterSize,
        disableClickZoom: disableClickZoom,
        calculator: calculator,
        clickable: clickable,
        hoverable: hoverable,
        texts: texts,
        styles: styles,
      ),
    );
  }

  /// Remove LOD marker layer (Mobile) or Clusterer (Web)
  Future<void> removeLodMarkerLayer({
    required String layerId,
  }) {
    if (kIsWeb) {
      return _platform
          .callWebMethod(RemoveWebMarkerClusterer(clustererId: layerId));
    }
    return _platform.callMethod(RemoveLodMarkerLayer(layerId: layerId));
  }

  /// Add LOD marker (Mobile) or Clusterer marker (Web)
  Future<void> addLodMarker({
    required MarkerOption option,
    required String layerId,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(
        AddClustererMarker(option: option, clustererId: layerId),
      );
    }
    return _platform.callMethod(AddLodMarker(option: option, layerId: layerId));
  }

  /// Add LOD markers (Mobile) or Clusterer markers (Web)
  Future<void> addLodMarkers({
    required List<MarkerOption> options,
    required String layerId,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(
        AddClustererMarkers(options: options, clustererId: layerId),
      );
    }
    return _platform
        .callMethod(AddLodMarkers(options: options, layerId: layerId));
  }

  /// Remove specific LOD/Clusterer markers
  Future<void> removeLodMarkers({
    required String layerId,
    required List<String> ids,
  }) {
    if (kIsWeb) {
      return _platform.callWebMethod(
        RemoveClustererMarkers(clustererId: layerId, ids: ids),
      );
    }
    return _platform.callMethod(RemoveLodMarkers(layerId: layerId, ids: ids));
  }

  /// Clear all LOD/Clusterer markers in layer
  Future<void> clearAllLodMarkers({
    required String layerId,
  }) {
    if (kIsWeb) {
      return _platform
          .callWebMethod(ClearAllClustererMarkers(clustererId: layerId));
    }
    return _platform.callMethod(ClearAllLodMarkers(layerId: layerId));
  }

  /// Show all LOD/Clusterer markers in layer
  Future<void> showAllLodMarkers({
    required String layerId,
  }) {
    if (kIsWeb) {
      return _platform
          .callWebMethod(ShowAllClustererMarkers(clustererId: layerId));
    }
    return _platform.callMethod(ShowAllLodMarkers(layerId: layerId));
  }

  /// Hide all LOD/Clusterer markers in layer
  Future<void> hideAllLodMarkers({
    required String layerId,
  }) {
    if (kIsWeb) {
      return _platform
          .callWebMethod(HideAllClustererMarkers(clustererId: layerId));
    }
    return _platform.callMethod(HideAllLodMarkers(layerId: layerId));
  }

  /// Show LOD/Clusterer markers by ids
  Future<void> showLodMarkers({
    required String layerId,
    required List<String> ids,
  }) {
    if (kIsWeb) {
      return _platform
          .callWebMethod(ShowClustererMarkers(clustererId: layerId, ids: ids));
    }
    return _platform.callMethod(ShowLodMarkers(layerId: layerId, ids: ids));
  }

  /// Hide LOD/Clusterer markers by ids
  Future<void> hideLodMarkers({
    required String layerId,
    required List<String> ids,
  }) {
    if (kIsWeb) {
      return _platform
          .callWebMethod(HideClustererMarkers(clustererId: layerId, ids: ids));
    }
    return _platform.callMethod(HideLodMarkers(layerId: layerId, ids: ids));
  }

  /// Set LOD layer clickability (Mobile only)
  Future<void> setLodMarkerLayerClickable({
    required String layerId,
    required bool clickable,
  }) {
    if (kIsWeb) {
      // Not supported on web, clickability is set on clusterer creation
      return Future.value();
    }
    return _platform.callMethod(
      SetLodMarkerLayerClickable(layerId: layerId, clickable: clickable),
    );
  }

  void dispose() {
    _platform.dispose();
  }
}
