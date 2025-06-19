import 'package:kakao_maps_flutter/src/base/data.dart';

import '../lat_lng/lat_lng.dart';

/// Configuration for an info window to be displayed on the map.
///
/// Contains the info window's identifier, position, and content.
class InfoWindowOption extends Data {
  /// Creates a new InfoWindowOption with the specified parameters.
  ///
  /// The [id] is a unique identifier for this info window.
  /// The [latLng] specifies the geographic position of the info window.
  /// The [title] is the main text content of the info window.
  /// The [snippet] is optional additional text content.
  /// The [isVisible] determines whether the info window should be shown initially.
  /// The [offset] allows positioning the info window relative to its anchor point.
  const InfoWindowOption({
    required this.id,
    required this.latLng,
    required this.title,
    this.snippet,
    this.isVisible = true,
    this.offset = const InfoWindowOffset(x: 0, y: 0),
  });

  /// The unique identifier for this info window.
  final String id;

  /// The geographic position where this info window should be displayed.
  final LatLng latLng;

  /// The main title text of the info window.
  final String title;

  /// Optional additional text content below the title.
  final String? snippet;

  /// Whether the info window should be visible when created.
  final bool isVisible;

  /// The offset positioning relative to the anchor point.
  final InfoWindowOffset offset;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'latLng': latLng.toJson(),
        'title': title,
        'snippet': snippet,
        'isVisible': isVisible,
        'offset': offset.toJson(),
      };
}

/// Represents the offset positioning for an info window.
class InfoWindowOffset extends Data {
  /// Creates a new InfoWindowOffset with x and y coordinates.
  ///
  /// The [x] represents horizontal offset in pixels.
  /// The [y] represents vertical offset in pixels.
  const InfoWindowOffset({
    required this.x,
    required this.y,
  });

  /// Creates an InfoWindowOffset from a JSON map.
  factory InfoWindowOffset.fromJson(Map<String, Object?> json) =>
      InfoWindowOffset(
        x: (json['x']! as num).toDouble(),
        y: (json['y']! as num).toDouble(),
      );

  /// The horizontal offset in pixels.
  final double x;

  /// The vertical offset in pixels.
  final double y;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'x': x,
        'y': y,
      };
}
