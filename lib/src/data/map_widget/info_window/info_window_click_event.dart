part of '../map_widget.dart';

/// Event data for when an info window is clicked on the map.
///
/// Contains information about the clicked info window and its position.
class InfoWindowClickEvent extends Data {
  /// Creates a new InfoWindowClickEvent with the specified parameters.
  ///
  /// The [infoWindowId] is the unique identifier of the clicked info window.
  /// The [latLng] is the geographic position where the click occurred.
  const InfoWindowClickEvent({
    required this.infoWindowId,
    required this.latLng,
  });

  /// Creates an InfoWindowClickEvent instance from a JSON map.
  factory InfoWindowClickEvent.fromJson(Map<String, Object?> json) =>
      InfoWindowClickEvent(
        infoWindowId: json['infoWindowId']! as String,
        latLng: LatLng.fromJson(json['latLng']! as Map<String, Object?>),
      );

  /// The unique identifier of the clicked info window.
  final String infoWindowId;

  /// The geographic position where the click occurred.
  final LatLng latLng;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'infoWindowId': infoWindowId,
        'latLng': latLng.toJson(),
      };
}
