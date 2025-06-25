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
        MapInfo;
import 'package:kakao_maps_flutter/src/data/label/label_click_event.dart';
import 'package:kakao_maps_flutter/src/platform/kakao_map_method_call/kakao_map_method_call.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../data/compass/compass.dart';
import '../../data/logo/logo.dart';

part 'interface/kakao_map_controller_platform_interface.dart';
part 'method_channel/method_channel_kakao_map_controller.dart';

/// Controller for interacting with a Kakao Map instance.
///
/// Provides methods to control the map camera, markers, and various settings.
class KakaoMapController extends KakaoMapControllerPlatform {
  /// Creates a new KakaoMapController for the given view ID.
  KakaoMapController({
    required this.viewId,
  }) {
    _platform = MethodChannelKakaoMapController.create(viewId);
  }

  /// Creates a KakaoMapController for testing purposes.
  @visibleForTesting
  KakaoMapController.forTest({
    required KakaoMapControllerPlatform platform,
    required this.viewId,
  }) : _platform = platform;

  /// The unique identifier for this map view.
  final int viewId;

  late final KakaoMapControllerPlatform _platform;

  /// Stream of label click events.
  ///
  /// Subscribe to this stream to receive notifications when markers on the
  /// map are clicked.
  @override
  Stream<LabelClickEvent> get onLabelClickedStream =>
      _platform.onLabelClickedStream;

  /// Stream of info window click events.
  ///
  /// Subscribe to this stream to receive notifications when info windows on the
  /// map are clicked.
  @override
  Stream<InfoWindowClickEvent> get onInfoWindowClickedStream =>
      _platform.onInfoWindowClickedStream;

  /// Stream of camera move end events.
  ///
  /// Subscribe to this stream to receive notifications when the camera movement ends and the map settles.
  @override
  Stream<CameraMoveEndEvent> get onCameraMoveEndStream =>
      _platform.onCameraMoveEndStream;

  @override
  Future<T> _callMethod<T>(KakaoMapMethodCall<T> methodCall) async {
    return _platform._callMethod(methodCall);
  }

  /// Gets the current zoom level of the map.
  ///
  /// Returns null if the zoom level cannot be retrieved.
  Future<int?> getZoomLevel() async {
    return _platform._callMethod(const GetZoomLevel());
  }

  /// Sets the zoom level of the map.
  ///
  /// The [zoomLevel] should be between the minimum and maximum zoom levels
  /// supported by Kakao Maps.
  Future<void> setZoomLevel({
    required int zoomLevel,
  }) async {
    await _platform._callMethod(SetZoomLevel(zoomLevel: zoomLevel));
  }

  /// Moves the camera to a new position with optional animation.
  ///
  /// The [cameraUpdate] defines the target camera position and settings.
  /// The [animation] defines how the camera movement should be animated.
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

  /// Adds a single marker to the map.
  ///
  /// The [labelOption] contains the marker's ID, position, and appearance
  /// settings.
  Future<void> addMarker({
    required LabelOption labelOption,
  }) async {
    await _platform._callMethod(AddMarker(labelOption: labelOption));
  }

  /// Removes a marker from the map by its ID.
  ///
  /// The [id] is the unique identifier of the marker to remove.
  Future<void> removeMarker({
    required String id,
  }) async {
    await _platform._callMethod(RemoveMarker(id: id));
  }

  /// Adds multiple markers to the map at once.
  ///
  /// The [labelOptions] is a list of marker configurations.
  Future<void> addMarkers({
    required List<LabelOption> labelOptions,
  }) async {
    await _platform._callMethod(AddMarkers(labelOptions: labelOptions));
  }

  /// Removes multiple markers from the map by their IDs.
  ///
  /// The [ids] is a list of unique identifiers of markers to remove.
  Future<void> removeMarkers({
    required List<String> ids,
  }) async {
    await _platform._callMethod(RemoveMarkers(ids: ids));
  }

  /// Removes all markers from the map.
  Future<void> clearMarkers() async {
    await _platform._callMethod(const ClearMarkers());
  }

  /// Gets the center position of the map's current viewport.
  ///
  /// Returns null if the center position cannot be retrieved.
  Future<LatLng?> getCenter() async {
    return _platform._callMethod(const GetCenter());
  }

  /// Converts a geographic position to screen coordinates.
  ///
  /// The [position] is the geographic location to convert.
  /// Returns the corresponding point on screen, or null if conversion fails.
  Future<Offset?> toScreenPoint({
    required LatLng position,
  }) async {
    return _platform._callMethod(ToScreenPoint(position: position));
  }

  /// Converts screen coordinates to a geographic position.
  ///
  /// The [point] is the screen point to convert.
  /// Returns the corresponding geographic location, or null if conversion fails.
  Future<LatLng?> fromScreenPoint({
    required Offset point,
  }) async {
    return _platform._callMethod(FromScreenPoint(point: point));
  }

  /// Sets the visibility of POI (Points of Interest) on the map.
  ///
  /// The [isVisible] determines whether POIs should be shown or hidden.
  Future<void> setPoiVisible({
    required bool isVisible,
  }) async {
    return _platform._callMethod(SetPoiVisible(isVisible: isVisible));
  }

  /// Sets whether POI (Points of Interest) on the map are clickable.
  ///
  /// The [isClickable] determines whether users can interact with POIs.
  Future<void> setPoiClickable({
    required bool isClickable,
  }) async {
    return _platform._callMethod(SetPoiClickable(isClickable: isClickable));
  }

  /// Sets the scale of POI (Points of Interest) icons on the map.
  ///
  /// The [scale] determines the size of POI icons:
  /// * 0: SMALL
  /// * 1: REGULAR
  /// * 2: LARGE
  /// * 3: XLARGE
  Future<void> setPoiScale({
    required int scale,
  }) async {
    return _platform._callMethod(SetPoiScale(scale: scale));
  }

  /// Sets the padding for the map view.
  ///
  /// The [left], [top], [right], [bottom] define the padding in pixels on
  /// each side.
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

  /// Sets the viewport size for the map.
  ///
  /// The [width] and [height] define the viewport dimensions in pixels.
  Future<void> setViewport({
    required int width,
    required int height,
  }) async {
    return _platform._callMethod(SetViewport(width: width, height: height));
  }

  /// Gets the current viewport bounds of the map.
  ///
  /// Returns the geographic bounds of what is currently visible on screen.
  Future<LatLngBounds?> getViewportBounds() async {
    return _platform._callMethod(const GetViewportBounds());
  }

  /// Gets information about the current state of the map.
  ///
  /// Returns details like zoom level, rotation, and tilt.
  Future<MapInfo?> getMapInfo() async {
    return _platform._callMethod(const GetMapInfo());
  }

  /// Adds an info window to the map.
  ///
  /// The [infoWindowOption] contains the info window's configuration including
  /// position, content, and appearance settings.
  Future<void> addInfoWindow({
    required InfoWindowOption infoWindowOption,
  }) async {
    await _platform
        ._callMethod(AddInfoWindow(infoWindowOption: infoWindowOption));
  }

  /// Removes an info window by its ID.
  ///
  /// The [id] is the unique identifier of the info window to remove.
  Future<void> removeInfoWindow({
    required String id,
  }) async {
    await _platform._callMethod(RemoveInfoWindow(id: id));
  }

  /// Adds multiple info windows to the map.
  ///
  /// The [infoWindowOptions] contains a list of info window configurations.
  Future<void> addInfoWindows({
    required List<InfoWindowOption> infoWindowOptions,
  }) async {
    await _platform
        ._callMethod(AddInfoWindows(infoWindowOptions: infoWindowOptions));
  }

  /// Removes multiple info windows by their IDs.
  ///
  /// The [ids] contains a list of info window identifiers to remove.
  Future<void> removeInfoWindows({
    required List<String> ids,
  }) async {
    await _platform._callMethod(RemoveInfoWindows(ids: ids));
  }

  /// Removes all info windows from the map.
  Future<void> clearInfoWindows() async {
    await _platform._callMethod(const ClearInfoWindows());
  }

  /// Shows the compass on the map.
  ///
  /// The compass will be displayed according to its current configuration.
  Future<void> showCompass() async {
    await _platform._callMethod(const ShowCompass());
  }

  /// Hides the compass from the map.
  ///
  /// The compass will be hidden but its configuration is preserved.
  Future<void> hideCompass() async {
    await _platform._callMethod(const HideCompass());
  }

  /// Shows the scale bar on the map.
  ///
  /// The scale bar will be displayed according to its current configuration.
  Future<void> showScaleBar() async {
    await _platform._callMethod(const ShowScaleBar());
  }

  /// Hides the scale bar from the map.
  ///
  /// The scale bar will be hidden but its configuration is preserved.
  Future<void> hideScaleBar() async {
    await _platform._callMethod(const HideScaleBar());
  }

  /// Updates the compass position on the map.
  ///
  /// The compass will be repositioned according to the specified alignment and offset.
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

  /// Shows the logo on the map.
  ///
  /// Throws [PlatformException] on Android because logo show/hide is only supported on iOS.
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

  /// Hides the logo on the map.
  ///
  /// Throws [PlatformException] on Android because logo show/hide is only supported on iOS.
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

  /// Sets the logo position on the map.
  ///
  /// The [alignment] determines the position of the logo.
  /// The [offset] provides additional positioning offset from the alignment point.
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
}
