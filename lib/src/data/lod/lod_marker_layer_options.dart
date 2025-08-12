import 'package:kakao_maps_flutter/src/base/data.dart';

/// Flutter/Dart 측 LOD 전용 마커 레이어 옵션
///
/// 네이티브(Android: LodLabelLayer, iOS: LodLabelLayer)에 매핑됩니다.
class LodMarkerLayerOptions extends Data {
  factory LodMarkerLayerOptions.fromJson(Map<String, Object?> json) =>
      LodMarkerLayerOptions(
        layerId: json['layerId']! as String,
        competitionType: LodMarkerCompetitionTypeX.fromName(
          json['competitionType'] as String?,
        ),
        competitionUnit: LodMarkerCompetitionUnitX.fromName(
          json['competitionUnit'] as String?,
        ),
        orderType: LodMarkerOrderTypeX.fromName(
          json['orderType'] as String?,
        ),
        zOrder: json['zOrder'] as int?,
        radius: (json['radius'] as num?)?.toDouble(),
      );
  const LodMarkerLayerOptions({
    required this.layerId,
    this.competitionType = LodMarkerCompetitionType.none,
    this.competitionUnit = LodMarkerCompetitionUnit.symbolFirst,
    this.orderType = LodMarkerOrderType.rank,
    this.zOrder,
    this.radius,
  });

  final String layerId;
  final LodMarkerCompetitionType competitionType;
  final LodMarkerCompetitionUnit competitionUnit;
  final LodMarkerOrderType orderType;
  final int? zOrder;
  final double? radius;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'layerId': layerId,
        'competitionType': competitionType.name,
        'competitionUnit': competitionUnit.name,
        'orderType': orderType.name,
        'zOrder': zOrder,
        'radius': radius,
      };
}

enum LodMarkerCompetitionType { none, upper, same, lower, background }

extension LodMarkerCompetitionTypeX on LodMarkerCompetitionType {
  static LodMarkerCompetitionType fromName(String? name) {
    switch (name) {
      case 'upper':
        return LodMarkerCompetitionType.upper;
      case 'same':
        return LodMarkerCompetitionType.same;
      case 'lower':
        return LodMarkerCompetitionType.lower;
      case 'background':
        return LodMarkerCompetitionType.background;
      case 'none':
      default:
        return LodMarkerCompetitionType.none;
    }
  }
}

enum LodMarkerCompetitionUnit { poi, symbolFirst }

extension LodMarkerCompetitionUnitX on LodMarkerCompetitionUnit {
  static LodMarkerCompetitionUnit fromName(String? name) {
    switch (name) {
      case 'poi':
        return LodMarkerCompetitionUnit.poi;
      case 'symbolFirst':
      default:
        return LodMarkerCompetitionUnit.symbolFirst;
    }
  }
}

enum LodMarkerOrderType { rank, closerFromLeftBottom }

extension LodMarkerOrderTypeX on LodMarkerOrderType {
  static LodMarkerOrderType fromName(String? name) {
    switch (name) {
      case 'closerFromLeftBottom':
        return LodMarkerOrderType.closerFromLeftBottom;
      case 'rank':
      default:
        return LodMarkerOrderType.rank;
    }
  }
}
