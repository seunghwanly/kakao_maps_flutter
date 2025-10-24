import 'dart:async';
import 'dart:convert' show base64Encode;
import 'dart:js_interop' if (dart.library.io) 'dart:typed_data';
import 'dart:js_interop_unsafe';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_maps_flutter/src/data/camera/camera_move_end_event.dart';
import 'package:kakao_maps_flutter/src/data/cluster/cluster_event.dart'
    show ClusterClickEvent;
import 'package:kakao_maps_flutter/src/data/data.dart'
    show
        CameraAnimation,
        CameraUpdate,
        InfoWindowClickEvent,
        InfoWindowOption,
        MarkerOption,
        LatLng,
        LatLngBounds,
        MapInfo,
        MarkerStyle,
        LodMarkerLayerOptions,
        GuiView,
        GuiText,
        GuiImage,
        GuiLayout;
import 'package:kakao_maps_flutter/src/data/label/label_click_event.dart';
import 'package:kakao_maps_flutter/src/data/map_widget/map_widget.dart'
    show Orientation;
import 'package:kakao_maps_flutter/src/platform/kakao_map_method_call/kakao_map_method_call.dart';
import 'package:kakao_maps_flutter/src/platform/kakao_map_method_call/kakao_map_web_method_call.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:web/web.dart' if (dart.library.io) 'dart:html' as web;

import '../../data/compass/compass.dart';
import '../../data/logo/logo.dart';
import '../../view/kakao_map/kakao_map_js_interop.dart';

part 'interface/kakao_map_controller_platform_interface.dart';
part 'method_channel/method_channel_kakao_map_controller.dart';
part 'web/web_kakao_map_controller.dart';

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
    _platform = kIsWeb
        ? WebKakaoMapController.create(viewId)
        : MethodChannelKakaoMapController.create(viewId);
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

  /// Cluster click stream
  /// [EN]
  /// - Emits when a marker cluster is clicked
  /// - Only available on Web
  ///
  /// [KO]
  /// - 마커 클러스터 클릭 시 이벤트 스트림 발행
  /// - 웹에서만 사용 가능
  @override
  Stream<ClusterClickEvent> get onClusterClickedStream =>
      _platform.onClusterClickedStream;

  @override
  Future<T> _callMethod<T>(KakaoMapMethodCall<T> methodCall) async {
    return _platform._callMethod(methodCall);
  }

  @override
  Future<T> _callWebMethod<T>(KakaoMapWebMethodCall<T> methodCall) async {
    return _platform._callWebMethod(methodCall);
  }

  /// Get zoom level
  /// [EN]
  /// - Returns null when unavailable
  ///
  /// [KO]
  /// - 가져올 수 없으면 null 반환
  Future<int?> getZoomLevel() {
    if (kIsWeb) {
      return _platform._callWebMethod(const WebGetZoomLevel());
    }
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
  }) {
    if (kIsWeb) {
      return _platform._callWebMethod(WebSetZoomLevel(zoomLevel: zoomLevel));
    }
    return _platform._callMethod(SetZoomLevel(zoomLevel: zoomLevel));
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
      return _platform._callWebMethod(
        WebMoveCamera(
          cameraUpdate: cameraUpdate,
          animation: animation,
        ),
      );
    }
    return _platform._callMethod(
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
      return _platform._callWebMethod(WebAddMarker(markerOption: markerOption));
    }
    return _platform
        ._callMethod(AddMarker(markerOption: markerOption, layerId: layerId));
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
      return _platform._callWebMethod(WebRemoveMarker(id: id));
    }
    return _platform._callMethod(RemoveMarker(id: id, layerId: layerId));
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
          ._callWebMethod(WebAddMarkers(markerOptions: markerOptions));
    }
    return _platform._callMethod(
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
      return _platform._callWebMethod(WebRemoveMarkers(ids: ids));
    }
    return _platform._callMethod(RemoveMarkers(ids: ids, layerId: layerId));
  }

  /// Clear all markers in specific layer
  Future<void> clearMarkers({
    String layerId = KakaoMapController.defaultLabelLayerId,
  }) {
    if (kIsWeb) {
      // On web, clearMarkers doesn't use layerId and clears all non-clustered markers.
      return _platform._callWebMethod(const WebClearMarkers());
    }
    return _platform._callMethod(ClearMarkers(layerId: layerId));
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
      return _platform._callWebMethod(WebRegisterMarkerStyles(styles: styles));
    }
    return _platform._callMethod(RegisterMarkerStyles(styles: styles));
  }

  /// Remove marker styles
  Future<void> removeMarkerStyles({
    required List<String> styleIds,
  }) {
    if (kIsWeb) {
      return _platform
          ._callWebMethod(WebRemoveMarkerStyles(styleIds: styleIds));
    }
    return _platform._callMethod(RemoveMarkerStyles(styleIds: styleIds));
  }

  /// Clear all marker styles
  Future<void> clearMarkerStyles() {
    if (kIsWeb) {
      return _platform._callWebMethod(const WebClearMarkerStyles());
    }
    return _platform._callMethod(const ClearMarkerStyles());
  }

  /// Get map center
  /// [EN]
  /// - Returns null when unavailable
  ///
  /// [KO]
  /// - 가져올 수 없으면 null 반환
  Future<LatLng?> getCenter() {
    if (kIsWeb) {
      return _platform._callWebMethod(const WebGetCenter());
    }
    return _platform._callMethod(const GetCenter());
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
    return _platform._callMethod(ToScreenPoint(position: position));
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
    return _platform._callMethod(FromScreenPoint(point: point));
  }

  /// Set POI visibility
  Future<void> setPoiVisible({
    required bool isVisible,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform._callMethod(SetPoiVisible(isVisible: isVisible));
  }

  /// Set POI clickability
  Future<void> setPoiClickable({
    required bool isClickable,
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
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
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform._callMethod(SetPoiScale(scale: scale));
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
  }) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform._callMethod(SetViewport(width: width, height: height));
  }

  /// Get viewport bounds
  Future<LatLngBounds?> getViewportBounds() {
    if (kIsWeb) {
      return _platform._callWebMethod(const WebGetViewportBounds());
    }
    return _platform._callMethod(const GetViewportBounds());
  }

  /// Get map info
  Future<MapInfo?> getMapInfo() {
    if (kIsWeb) {
      return _platform._callWebMethod(const WebGetMapInfo());
    }
    return _platform._callMethod(const GetMapInfo());
  }

  /// Add info window
  Future<void> addInfoWindow({
    required InfoWindowOption infoWindowOption,
  }) {
    if (kIsWeb) {
      return _platform
          ._callWebMethod(WebAddInfoWindow(infoWindowOption: infoWindowOption));
    }
    return _platform
        ._callMethod(AddInfoWindow(infoWindowOption: infoWindowOption));
  }

  /// Update info window
  Future<void> updateInfoWindow({
    required InfoWindowOption infoWindowOption,
  }) {
    if (kIsWeb) {
      return _platform._callWebMethod(
        WebUpdateInfoWindow(infoWindowOption: infoWindowOption),
      );
    }
    return _platform
        ._callMethod(UpdateInfoWindow(infoWindowOption: infoWindowOption));
  }

  /// Remove info window
  Future<void> removeInfoWindow({
    required String id,
  }) {
    if (kIsWeb) {
      return _platform._callWebMethod(WebRemoveInfoWindow(id: id));
    }
    return _platform._callMethod(RemoveInfoWindow(id: id));
  }

  /// Add info windows
  Future<void> addInfoWindows({
    required List<InfoWindowOption> infoWindowOptions,
  }) {
    if (kIsWeb) {
      return _platform._callWebMethod(
        WebAddInfoWindows(infoWindowOptions: infoWindowOptions),
      );
    }
    return _platform
        ._callMethod(AddInfoWindows(infoWindowOptions: infoWindowOptions));
  }

  /// Remove info windows
  Future<void> removeInfoWindows({
    required List<String> ids,
  }) {
    if (kIsWeb) {
      return _platform._callWebMethod(WebRemoveInfoWindows(ids: ids));
    }
    return _platform._callMethod(RemoveInfoWindows(ids: ids));
  }

  /// Clear all info windows
  Future<void> clearInfoWindows() {
    if (kIsWeb) {
      return _platform._callWebMethod(const WebClearInfoWindows());
    }
    return _platform._callMethod(const ClearInfoWindows());
  }

  /// Set info window layer visibility
  Future<void> setInfoWindowLayerVisible({required bool visible}) {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform._callMethod(SetInfoWindowLayerVisible(visible: visible));
  }

  /// Set single info window visibility
  Future<void> setInfoWindowVisible({
    required String id,
    required bool visible,
  }) {
    if (kIsWeb) {
      return _platform
          ._callWebMethod(WebSetInfoWindowVisible(id: id, visible: visible));
    }
    return _platform
        ._callMethod(SetInfoWindowVisible(id: id, visible: visible));
  }

  /// Show compass
  Future<void> showCompass() {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform._callMethod(const ShowCompass());
  }

  /// Hide compass
  Future<void> hideCompass() {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform._callMethod(const HideCompass());
  }

  /// Show scale bar
  Future<void> showScaleBar() {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform._callMethod(const ShowScaleBar());
  }

  /// Hide scale bar
  Future<void> hideScaleBar() {
    if (kIsWeb) {
      // Not supported on web
      return Future.value();
    }
    return _platform._callMethod(const HideScaleBar());
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
    return _platform._callMethod(
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
    return _platform._callMethod(const ShowLogo());
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
    return _platform._callMethod(const HideLogo());
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
    return _platform._callMethod(
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
    return _platform._callMethod(
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
    return _platform._callMethod(
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
    return _platform._callMethod(
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
    return _platform._callMethod(
      HideAllMarkers(layerId: layerId),
    );
  }

  // ===== LOD / Clusterer APIs =====

  /// Add LOD marker layer (Mobile only)
  Future<void> addLodMarkerLayer({
    required LodMarkerLayerOptions options,
  }) {
    if (kIsWeb) {
      web.console.warn(
        'addLodMarkerLayer is deprecated on web. Please use addWebMarkerClusterer.'
            .toJS,
      );
      return Future.value();
    }
    return _platform._callMethod(AddLodMarkerLayer(options: options));
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
    return _platform._callWebMethod(
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
          ._callWebMethod(RemoveWebMarkerClusterer(clustererId: layerId));
    }
    return _platform._callMethod(RemoveLodMarkerLayer(layerId: layerId));
  }

  /// Add LOD marker (Mobile) or Clusterer marker (Web)
  Future<void> addLodMarker({
    required MarkerOption option,
    required String layerId,
  }) {
    if (kIsWeb) {
      return _platform._callWebMethod(
        AddClustererMarker(option: option, clustererId: layerId),
      );
    }
    return _platform
        ._callMethod(AddLodMarker(option: option, layerId: layerId));
  }

  /// Add LOD markers (Mobile) or Clusterer markers (Web)
  Future<void> addLodMarkers({
    required List<MarkerOption> options,
    required String layerId,
  }) {
    if (kIsWeb) {
      return (_platform as WebKakaoMapController)._callWebMethod(
        AddClustererMarkers(options: options, clustererId: layerId),
      );
    }
    return _platform
        ._callMethod(AddLodMarkers(options: options, layerId: layerId));
  }

  /// Remove specific LOD/Clusterer markers
  Future<void> removeLodMarkers({
    required String layerId,
    required List<String> ids,
  }) {
    if (kIsWeb) {
      return (_platform as WebKakaoMapController)._callWebMethod(
        RemoveClustererMarkers(clustererId: layerId, ids: ids),
      );
    }
    return _platform._callMethod(RemoveLodMarkers(layerId: layerId, ids: ids));
  }

  /// Clear all LOD/Clusterer markers in layer
  Future<void> clearAllLodMarkers({
    required String layerId,
  }) {
    if (kIsWeb) {
      return _platform
          ._callWebMethod(ClearAllClustererMarkers(clustererId: layerId));
    }
    return _platform._callMethod(ClearAllLodMarkers(layerId: layerId));
  }

  /// Show all LOD/Clusterer markers in layer
  Future<void> showAllLodMarkers({
    required String layerId,
  }) {
    if (kIsWeb) {
      return _platform
          ._callWebMethod(ShowAllClustererMarkers(clustererId: layerId));
    }
    return _platform._callMethod(ShowAllLodMarkers(layerId: layerId));
  }

  /// Hide all LOD/Clusterer markers in layer
  Future<void> hideAllLodMarkers({
    required String layerId,
  }) {
    if (kIsWeb) {
      return _platform
          ._callWebMethod(HideAllClustererMarkers(clustererId: layerId));
    }
    return _platform._callMethod(HideAllLodMarkers(layerId: layerId));
  }

  /// Show LOD/Clusterer markers by ids
  Future<void> showLodMarkers({
    required String layerId,
    required List<String> ids,
  }) {
    if (kIsWeb) {
      return _platform
          ._callWebMethod(ShowClustererMarkers(clustererId: layerId, ids: ids));
    }
    return _platform._callMethod(ShowLodMarkers(layerId: layerId, ids: ids));
  }

  /// Hide LOD/Clusterer markers by ids
  Future<void> hideLodMarkers({
    required String layerId,
    required List<String> ids,
  }) {
    if (kIsWeb) {
      return _platform
          ._callWebMethod(HideClustererMarkers(clustererId: layerId, ids: ids));
    }
    return _platform._callMethod(HideLodMarkers(layerId: layerId, ids: ids));
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
    return _platform._callMethod(
      SetLodMarkerLayerClickable(layerId: layerId, clickable: clickable),
    );
  }
}
