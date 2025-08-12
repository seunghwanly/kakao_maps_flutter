import 'package:flutter/material.dart' show Offset;
import 'package:kakao_maps_flutter/src/data/data.dart';
import 'package:kakao_maps_flutter/src/data/marker/marker_style.dart' as marker;

sealed class KakaoMapMethodCall<R> {
  const KakaoMapMethodCall();

  String get name;

  Map<String, Object?>? encode();

  R decode(Object? value) => value as R;
}

final class GetZoomLevel extends KakaoMapMethodCall<int?> {
  const GetZoomLevel();

  @override
  String get name => 'getZoomLevel';

  @override
  Map<String, Object?>? encode() => null;

  @override
  int? decode(Object? value) => value as int?;
}

final class SetZoomLevel extends KakaoMapMethodCall<void> {
  const SetZoomLevel({
    required this.zoomLevel,
  });

  final int zoomLevel;

  @override
  String get name => 'setZoomLevel';

  @override
  Map<String, Object?>? encode() => {'level': zoomLevel};
}

final class MoveCamera extends KakaoMapMethodCall<void> {
  const MoveCamera({
    required this.cameraUpdate,
    this.animation,
  });

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

final class AddMarker extends KakaoMapMethodCall<void> {
  const AddMarker({
    required this.labelOption,
  });

  final LabelOption labelOption;

  @override
  String get name => 'addMarker';

  @override
  Map<String, Object?>? encode() => labelOption.toJson();
}

final class RemoveMarker extends KakaoMapMethodCall<void> {
  const RemoveMarker({
    required this.id,
  });

  final String id;

  @override
  String get name => 'removeMarker';

  @override
  Map<String, Object?>? encode() => {'id': id};
}

final class AddMarkers extends KakaoMapMethodCall<void> {
  const AddMarkers({
    required this.labelOptions,
  });

  final List<LabelOption> labelOptions;

  @override
  String get name => 'addMarkers';

  @override
  Map<String, Object?>? encode() => {
        'markers': labelOptions.map((e) => e.toJson()).toList(),
      };
}

final class RemoveMarkers extends KakaoMapMethodCall<void> {
  const RemoveMarkers({
    required this.ids,
  });

  final List<String> ids;

  @override
  String get name => 'removeMarkers';

  @override
  Map<String, Object?>? encode() => {'ids': ids};
}

final class ClearMarkers extends KakaoMapMethodCall<void> {
  const ClearMarkers();

  @override
  String get name => 'clearMarkers';

  @override
  Map<String, Object?>? encode() => null;
}

// Marker Style Registration Methods

final class RegisterMarkerStyles extends KakaoMapMethodCall<void> {
  const RegisterMarkerStyles({required this.styles});

  final List<marker.MarkerStyle> styles;

  @override
  String get name => 'registerMarkerStyles';

  @override
  Map<String, Object?>? encode() => {
        'styles': styles.map((e) => e.toJson()).toList(),
      };
}

final class RemoveMarkerStyles extends KakaoMapMethodCall<void> {
  const RemoveMarkerStyles({required this.styleIds});

  final List<String> styleIds;

  @override
  String get name => 'removeMarkerStyles';

  @override
  Map<String, Object?>? encode() => {
        'styleIds': styleIds,
      };
}

final class ClearMarkerStyles extends KakaoMapMethodCall<void> {
  const ClearMarkerStyles();

  @override
  String get name => 'clearMarkerStyles';

  @override
  Map<String, Object?>? encode() => null;
}

final class GetCenter extends KakaoMapMethodCall<LatLng?> {
  const GetCenter();

  @override
  String get name => 'getCenter';

  @override
  Map<String, Object?>? encode() => null;

  @override
  LatLng? decode(Object? value) {
    assert(value is Map<String, Object?>);
    return LatLng.fromJson(value! as Map<String, Object?>);
  }
}

final class ToScreenPoint extends KakaoMapMethodCall<Offset?> {
  const ToScreenPoint({
    required this.position,
  });

  final LatLng position;

  @override
  String get name => 'toScreenPoint';

  @override
  Map<String, Object?>? encode() => {'position': position.toJson()};

  @override
  Offset? decode(Object? value) {
    if (value == null || value is! Map<String, Object?>) return null;

    final dx = value['dx'];
    final dy = value['dy'];

    if (dx == null || dy == null || dx is! num || dy is! num) return null;

    return Offset(
      dx.toDouble(),
      dy.toDouble(),
    );
  }
}

final class FromScreenPoint extends KakaoMapMethodCall<LatLng?> {
  const FromScreenPoint({
    required this.point,
  });

  final Offset point;

  @override
  String get name => 'fromScreenPoint';

  @override
  Map<String, Object?>? encode() => {'dx': point.dx, 'dy': point.dy};

  @override
  LatLng? decode(Object? value) {
    if (value is! Map<String, Object?> ||
        !value.containsKey('latitude') ||
        !value.containsKey('longitude')) {
      return null;
    }

    return LatLng.fromJson(value);
  }
}

final class SetPoiVisible extends KakaoMapMethodCall<void> {
  const SetPoiVisible({
    required this.isVisible,
  });

  final bool isVisible;

  @override
  String get name => 'setPoiVisible';

  @override
  Map<String, Object?>? encode() => {'isVisible': isVisible};
}

final class SetPoiClickable extends KakaoMapMethodCall<void> {
  const SetPoiClickable({
    required this.isClickable,
  });

  final bool isClickable;

  @override
  String get name => 'setPoiClickable';

  @override
  Map<String, Object?>? encode() => {'isClickable': isClickable};
}

final class SetPoiScale extends KakaoMapMethodCall<void> {
  const SetPoiScale({
    required this.scale,
  });

  /// - 0: SMALL
  /// - 1: REGULAR
  /// - 2: LARGE
  /// - 3: XLARGE
  final int scale;

  @override
  String get name => 'setPoiScale';

  @override
  Map<String, Object?>? encode() => {'scale': scale};
}

final class SetPadding extends KakaoMapMethodCall<void> {
  const SetPadding({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final int left;

  final int top;

  final int right;

  final int bottom;

  @override
  String get name => 'setPadding';

  @override
  Map<String, Object?>? encode() => {
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
      };
}

final class SetViewport extends KakaoMapMethodCall<void> {
  const SetViewport({
    required this.width,
    required this.height,
  });

  final int width;

  final int height;

  @override
  String get name => 'setViewport';

  @override
  Map<String, Object?>? encode() => {'width': width, 'height': height};
}

final class GetViewportBounds extends KakaoMapMethodCall<LatLngBounds?> {
  const GetViewportBounds();

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

final class GetMapInfo extends KakaoMapMethodCall<MapInfo?> {
  const GetMapInfo();

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

final class AddInfoWindow extends KakaoMapMethodCall<void> {
  const AddInfoWindow({
    required this.infoWindowOption,
  });

  final InfoWindowOption infoWindowOption;

  @override
  String get name => 'addInfoWindow';

  @override
  Map<String, Object?>? encode() => infoWindowOption.toJson();
}

final class UpdateInfoWindow extends KakaoMapMethodCall<void> {
  const UpdateInfoWindow({
    required this.infoWindowOption,
  });

  final InfoWindowOption infoWindowOption;

  @override
  String get name => 'updateInfoWindow';

  @override
  Map<String, Object?>? encode() => infoWindowOption.toJson();
}

final class RemoveInfoWindow extends KakaoMapMethodCall<void> {
  const RemoveInfoWindow({
    required this.id,
  });

  final String id;

  @override
  String get name => 'removeInfoWindow';

  @override
  Map<String, Object?>? encode() => {'id': id};
}

final class AddInfoWindows extends KakaoMapMethodCall<void> {
  const AddInfoWindows({
    required this.infoWindowOptions,
  });

  final List<InfoWindowOption> infoWindowOptions;

  @override
  String get name => 'addInfoWindows';

  @override
  Map<String, Object?>? encode() => {
        'infoWindowOptions':
            infoWindowOptions.map((option) => option.toJson()).toList(),
      };
}

final class RemoveInfoWindows extends KakaoMapMethodCall<void> {
  const RemoveInfoWindows({
    required this.ids,
  });

  final List<String> ids;

  @override
  String get name => 'removeInfoWindows';

  @override
  Map<String, Object?>? encode() => {'ids': ids};
}

final class ClearInfoWindows extends KakaoMapMethodCall<void> {
  const ClearInfoWindows();

  @override
  String get name => 'clearInfoWindows';

  @override
  Map<String, Object?>? encode() => null;
}

final class ShowCompass extends KakaoMapMethodCall<void> {
  const ShowCompass();

  @override
  String get name => 'showCompass';

  @override
  Map<String, Object?>? encode() => null;
}

final class HideCompass extends KakaoMapMethodCall<void> {
  const HideCompass();

  @override
  String get name => 'hideCompass';

  @override
  Map<String, Object?>? encode() => null;
}

final class ShowScaleBar extends KakaoMapMethodCall<void> {
  const ShowScaleBar();

  @override
  String get name => 'showScaleBar';

  @override
  Map<String, Object?>? encode() => null;
}

final class HideScaleBar extends KakaoMapMethodCall<void> {
  const HideScaleBar();

  @override
  String get name => 'hideScaleBar';

  @override
  Map<String, Object?>? encode() => null;
}

final class SetCompassPosition extends KakaoMapMethodCall<void> {
  const SetCompassPosition({
    required this.alignment,
    required this.offset,
  });

  final CompassAlignment alignment;
  final Offset offset;

  @override
  String get name => 'setCompassPosition';

  @override
  Map<String, Object?>? encode() => {
        'alignment': alignment.name,
        'offset': {
          'dx': offset.dx,
          'dy': offset.dy,
        },
      };
}

final class ShowLogo extends KakaoMapMethodCall<void> {
  const ShowLogo();

  @override
  String get name => 'showLogo';

  @override
  Map<String, Object?>? encode() => null;
}

final class HideLogo extends KakaoMapMethodCall<void> {
  const HideLogo();

  @override
  String get name => 'hideLogo';

  @override
  Map<String, Object?>? encode() => null;
}

final class SetLogoPosition extends KakaoMapMethodCall<void> {
  const SetLogoPosition({
    required this.alignment,
    required this.offset,
  });

  final LogoAlignment alignment;
  final Offset offset;

  @override
  String get name => 'setLogoPosition';

  @override
  Map<String, Object?>? encode() => {
        'alignment': alignment.name,
        'offset': {
          'dx': offset.dx,
          'dy': offset.dy,
        },
      };
}
