import 'package:kakao_maps_flutter/src/base/data.dart';

import '../lat_lng/lat_lng.dart';

/// Event data for when a label (marker) is clicked on the map.
///
/// Contains information about the clicked label and its position.
class LabelClickEvent extends Data {
  /// Creates a new LabelClickEvent with the specified parameters.
  ///
  /// The [labelId] is the unique identifier of the clicked label.
  /// The [latLng] is the geographic position where the click occurred.
  /// The [layerId] is an optional layer identifier.
  const LabelClickEvent({
    required this.labelId,
    required this.latLng,
    this.layerId,
  });

  /// Creates a LabelClickEvent instance from a JSON map.
  factory LabelClickEvent.fromJson(Map<String, Object?> json) =>
      LabelClickEvent(
        labelId: json['labelId']! as String,
        latLng: LatLng.fromJson(json['latLng']! as Map<String, Object?>),
        layerId: json['layerId'] as String?,
      );

  /// The unique identifier of the clicked label.
  final String labelId;

  /// The geographic position where the click occurred.
  final LatLng latLng;

  /// The optional layer identifier where the label belongs.
  final String? layerId;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'labelId': labelId,
        'latLng': latLng.toJson(),
        'layerId': layerId,
      };
}
