import 'package:flutter/material.dart' show Offset;
import 'package:kakao_maps_flutter/src/data/data.dart';
import 'package:kakao_maps_flutter/src/enum/enum.dart';

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

/// SDK 내 [LodLabelLayer] 를 생성합니다.
/// - Android: https://apis.map.kakao.com/android_v2/docs/api-guide/label/lodlabel/#2-lodlabellayer
/// - iOS: https://apis.map.kakao.com/ios_v2/docs/map/04_label/03_lodpoi/#lodlabellayer
///
/// 생성한 Marker를 지도 레벨에 따라 클러스터링을 합니다. 공식문서에 따르면 플랫폼에서 각자 아래처럼 명시되어있습니다.
/// - Android: [Label]
/// - iOS: [Poi]
final class CreateMarkerClustering extends KakaoMapMethodCall<void> {
  const CreateMarkerClustering({
    required this.layerId,
    required this.competitionType,
    required this.competitionUnit,
    required this.orderingType,
    required this.zOrder,
    required this.radius,
    this.isVisible = true,
    this.isClickable = true,
  });

  final String layerId;

  final MarkerCompetitionType competitionType;

  final MarkerCompetitionUnit competitionUnit;

  final MarkerOrderingType orderingType;

  final int zOrder;

  final double radius;

  final bool isVisible;

  final bool isClickable;

  @override
  Map<String, Object?>? encode() => {
        'layerId': layerId,
        'competitionType': competitionType.value,
        'competitionUnit': competitionUnit.value,
        'orderingType': orderingType.value,
        'zOrder': zOrder,
        'radius': radius,
        'isVisible': isVisible,
        'isClickable': isClickable,
      };

  @override
  String get name => 'createLodLabelLayer';
}
