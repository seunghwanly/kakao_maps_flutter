part of '../map_widget.dart';

/// Info window click event
/// [EN]
/// - Identifier and position of clicked info window
///
/// [KO]
/// - 클릭된 말풍선의 식별자와 위치 정보
class InfoWindowClickEvent extends Data {
  /// Create event
  /// [EN]
  /// - [infoWindowId]: clicked window id, [latLng]: click position
  ///
  /// [KO]
  /// - [infoWindowId]: 클릭된 창 id, [latLng]: 클릭 위치
  const InfoWindowClickEvent({
    required this.infoWindowId,
    required this.latLng,
  });

  /// From JSON map
  factory InfoWindowClickEvent.fromJson(Map<String, Object?> json) =>
      InfoWindowClickEvent(
        infoWindowId: json['infoWindowId']! as String,
        latLng: LatLng.fromJson(json['latLng']! as Map<String, Object?>),
      );

  /// Clicked window id
  final String infoWindowId;

  /// Click position
  final LatLng latLng;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'infoWindowId': infoWindowId,
        'latLng': latLng.toJson(),
      };
}
