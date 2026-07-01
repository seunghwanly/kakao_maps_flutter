import 'package:kakao_maps_flutter/src/data/data.dart';
import 'package:kakao_maps_flutter/src/data/marker/marker_style.dart' as marker;

sealed class KakaoMapWebMethodCall<R> {
  const KakaoMapWebMethodCall();

  String get name;

  Map<String, Object?>? encode();

  R decode(Object? value) => value as R;
}

// Basic Map Control
final class WebGetZoomLevel extends KakaoMapWebMethodCall<int?> {
  const WebGetZoomLevel();
  @override
  String get name => 'getZoomLevel';
  @override
  Map<String, Object?>? encode() => null;
  @override
  int? decode(Object? value) => value as int?;
}

final class WebSetZoomLevel extends KakaoMapWebMethodCall<void> {
  const WebSetZoomLevel({required this.zoomLevel});
  final int zoomLevel;
  @override
  String get name => 'setZoomLevel';
  @override
  Map<String, Object?>? encode() => {'level': zoomLevel};
}

final class WebMoveCamera extends KakaoMapWebMethodCall<void> {
  const WebMoveCamera({required this.cameraUpdate, this.animation});
  final CameraUpdate cameraUpdate;
  final CameraAnimation? animation;
  @override
  String get name => 'moveCamera';
  @override
  Map<String, Object?>? encode() => {
    'cameraUpdate': cameraUpdate.toJson(),
    'animation': animation?.toJson(),
  };
}

final class WebGetCenter extends KakaoMapWebMethodCall<LatLng?> {
  const WebGetCenter();
  @override
  String get name => 'getCenter';
  @override
  Map<String, Object?>? encode() => null;
  @override
  LatLng? decode(Object? value) {
    if (value == null || value is! Map<String, Object?>) return null;
    if (!value.containsKey('latitude') || !value.containsKey('longitude')) {
      return null;
    }
    return LatLng.fromJson(value);
  }
}

final class WebGetViewportBounds extends KakaoMapWebMethodCall<LatLngBounds?> {
  const WebGetViewportBounds();
  @override
  String get name => 'getViewportBounds';
  @override
  Map<String, Object?>? encode() => null;
  @override
  LatLngBounds? decode(Object? value) {
    if (value is! Map<String, Object?> ||
        !value.containsKey('southwest') ||
        !value.containsKey('northeast')) {
      return null;
    }
    return LatLngBounds.fromJson(value);
  }
}

final class WebGetMapInfo extends KakaoMapWebMethodCall<MapInfo?> {
  const WebGetMapInfo();
  @override
  String get name => 'getMapInfo';
  @override
  Map<String, Object?>? encode() => null;
  @override
  MapInfo? decode(Object? value) {
    if (value is! Map<String, Object?> ||
        !value.containsKey('zoomLevel') ||
        !value.containsKey('rotation') ||
        !value.containsKey('tilt')) {
      return null;
    }
    return MapInfo.fromJson(value);
  }
}

// Marker Methods (No Layers)
final class WebAddMarker extends KakaoMapWebMethodCall<void> {
  const WebAddMarker({required this.markerOption});
  final MarkerOption markerOption;
  @override
  String get name => 'addMarker';
  @override
  Map<String, Object?>? encode() => markerOption.toJson();
}

final class WebRemoveMarker extends KakaoMapWebMethodCall<void> {
  const WebRemoveMarker({required this.id});
  final String id;
  @override
  String get name => 'removeMarker';
  @override
  Map<String, Object?>? encode() => {'id': id};
}

final class WebAddMarkers extends KakaoMapWebMethodCall<void> {
  const WebAddMarkers({required this.markerOptions});
  final List<MarkerOption> markerOptions;
  @override
  String get name => 'addMarkers';
  @override
  Map<String, Object?>? encode() => {
    'markers': markerOptions.map((e) => e.toJson()).toList(),
  };
}

final class WebRemoveMarkers extends KakaoMapWebMethodCall<void> {
  const WebRemoveMarkers({required this.ids});
  final List<String> ids;
  @override
  String get name => 'removeMarkers';
  @override
  Map<String, Object?>? encode() => {'ids': ids};
}

final class WebClearMarkers extends KakaoMapWebMethodCall<void> {
  const WebClearMarkers();
  @override
  String get name => 'clearMarkers';
  @override
  Map<String, Object?>? encode() => null;
}

// Marker Style Registration
final class WebRegisterMarkerStyles extends KakaoMapWebMethodCall<void> {
  const WebRegisterMarkerStyles({required this.styles});
  final List<marker.MarkerStyle> styles;
  @override
  String get name => 'registerMarkerStyles';
  @override
  Map<String, Object?>? encode() => {
    'styles': styles.map((e) => e.toJson()).toList(),
  };
}

final class WebRemoveMarkerStyles extends KakaoMapWebMethodCall<void> {
  const WebRemoveMarkerStyles({required this.styleIds});
  final List<String> styleIds;
  @override
  String get name => 'removeMarkerStyles';
  @override
  Map<String, Object?>? encode() => {'styleIds': styleIds};
}

final class WebClearMarkerStyles extends KakaoMapWebMethodCall<void> {
  const WebClearMarkerStyles();
  @override
  String get name => 'clearMarkerStyles';
  @override
  Map<String, Object?>? encode() => null;
}

// InfoWindow Methods
final class WebAddInfoWindow extends KakaoMapWebMethodCall<void> {
  const WebAddInfoWindow({required this.infoWindowOption});
  final InfoWindowOption infoWindowOption;
  @override
  String get name => 'addInfoWindow';
  @override
  Map<String, Object?>? encode() => infoWindowOption.toJson();
}

final class WebUpdateInfoWindow extends KakaoMapWebMethodCall<void> {
  const WebUpdateInfoWindow({required this.infoWindowOption});
  final InfoWindowOption infoWindowOption;
  @override
  String get name => 'updateInfoWindow';
  @override
  Map<String, Object?>? encode() => infoWindowOption.toJson();
}

final class WebRemoveInfoWindow extends KakaoMapWebMethodCall<void> {
  const WebRemoveInfoWindow({required this.id});
  final String id;
  @override
  String get name => 'removeInfoWindow';
  @override
  Map<String, Object?>? encode() => {'id': id};
}

final class WebAddInfoWindows extends KakaoMapWebMethodCall<void> {
  const WebAddInfoWindows({required this.infoWindowOptions});
  final List<InfoWindowOption> infoWindowOptions;
  @override
  String get name => 'addInfoWindows';
  @override
  Map<String, Object?>? encode() => {
    'infoWindowOptions': infoWindowOptions
        .map((option) => option.toJson())
        .toList(),
  };
}

final class WebRemoveInfoWindows extends KakaoMapWebMethodCall<void> {
  const WebRemoveInfoWindows({required this.ids});
  final List<String> ids;
  @override
  String get name => 'removeInfoWindows';
  @override
  Map<String, Object?>? encode() => {'ids': ids};
}

final class WebClearInfoWindows extends KakaoMapWebMethodCall<void> {
  const WebClearInfoWindows();
  @override
  String get name => 'clearInfoWindows';
  @override
  Map<String, Object?>? encode() => null;
}

final class WebSetInfoWindowVisible extends KakaoMapWebMethodCall<void> {
  const WebSetInfoWindowVisible({required this.id, required this.visible});
  final String id;
  final bool visible;
  @override
  String get name => 'setInfoWindowVisible';
  @override
  Map<String, Object?>? encode() => {'id': id, 'visible': visible};
}

// ===== Web-Only Marker Clusterer support =====
final class AddWebMarkerClusterer extends KakaoMapWebMethodCall<void> {
  const AddWebMarkerClusterer({
    required this.clustererId,
    this.gridSize = 60,
    this.averageCenter = false,
    this.minLevel = 0,
    this.minClusterSize = 2,
    this.disableClickZoom = false,
    this.calculator = const [10, 100, 1000, 10000],
    this.clickable = false,
    this.hoverable = false,
    this.texts = const [],
    this.styles = const [],
  });

  final String clustererId;
  final int gridSize;
  final bool averageCenter;
  final int minLevel;
  final int minClusterSize;
  final bool disableClickZoom;
  final List<int> calculator;
  final bool clickable;
  final bool hoverable;
  final List<String> texts;
  final List<Map<String, Object?>> styles;

  @override
  String get name => 'addWebMarkerClusterer';
  @override
  Map<String, Object?>? encode() => {
    'clustererId': clustererId,
    'gridSize': gridSize,
    'averageCenter': averageCenter,
    'minLevel': minLevel,
    'minClusterSize': minClusterSize,
    'disableClickZoom': disableClickZoom,
    'calculator': calculator,
    'clickable': clickable,
    'hoverable': hoverable,
    'texts': texts,
    'styles': styles,
  };
}

final class RemoveWebMarkerClusterer extends KakaoMapWebMethodCall<void> {
  const RemoveWebMarkerClusterer({required this.clustererId});
  final String clustererId;
  @override
  String get name => 'removeWebMarkerClusterer';
  @override
  Map<String, Object?>? encode() => {'clustererId': clustererId};
}

final class AddClustererMarker extends KakaoMapWebMethodCall<void> {
  const AddClustererMarker({required this.option, required this.clustererId});
  final MarkerOption option;
  final String clustererId;
  @override
  String get name => 'addClustererMarker';
  @override
  Map<String, Object?>? encode() => {
    'clustererId': clustererId,
    'option': option.toJson(),
  };
}

final class AddClustererMarkers extends KakaoMapWebMethodCall<void> {
  const AddClustererMarkers({required this.options, required this.clustererId});
  final List<MarkerOption> options;
  final String clustererId;
  @override
  String get name => 'addClustererMarkers';
  @override
  Map<String, Object?>? encode() => {
    'clustererId': clustererId,
    'options': options.map((e) => e.toJson()).toList(),
  };
}

final class RemoveClustererMarkers extends KakaoMapWebMethodCall<void> {
  const RemoveClustererMarkers({required this.clustererId, required this.ids});
  final String clustererId;
  final List<String> ids;
  @override
  String get name => 'removeClustererMarkers';
  @override
  Map<String, Object?>? encode() => {'clustererId': clustererId, 'ids': ids};
}

final class ClearAllClustererMarkers extends KakaoMapWebMethodCall<void> {
  const ClearAllClustererMarkers({required this.clustererId});
  final String clustererId;
  @override
  String get name => 'clearAllClustererMarkers';
  @override
  Map<String, Object?>? encode() => {'clustererId': clustererId};
}

final class ShowAllClustererMarkers extends KakaoMapWebMethodCall<void> {
  const ShowAllClustererMarkers({required this.clustererId});
  final String clustererId;
  @override
  String get name => 'showAllClustererMarkers';
  @override
  Map<String, Object?>? encode() => {'clustererId': clustererId};
}

final class HideAllClustererMarkers extends KakaoMapWebMethodCall<void> {
  const HideAllClustererMarkers({required this.clustererId});
  final String clustererId;
  @override
  String get name => 'hideAllClustererMarkers';
  @override
  Map<String, Object?>? encode() => {'clustererId': clustererId};
}

final class ShowClustererMarkers extends KakaoMapWebMethodCall<void> {
  const ShowClustererMarkers({required this.clustererId, required this.ids});
  final String clustererId;
  final List<String> ids;
  @override
  String get name => 'showClustererMarkers';
  @override
  Map<String, Object?>? encode() => {'clustererId': clustererId, 'ids': ids};
}

final class HideClustererMarkers extends KakaoMapWebMethodCall<void> {
  const HideClustererMarkers({required this.clustererId, required this.ids});
  final String clustererId;
  final List<String> ids;
  @override
  String get name => 'hideClustererMarkers';
  @override
  Map<String, Object?>? encode() => {'clustererId': clustererId, 'ids': ids};
}
