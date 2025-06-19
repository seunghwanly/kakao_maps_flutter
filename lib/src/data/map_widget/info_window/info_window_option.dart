part of '../map_widget.dart';

/// Configuration for an info window to be displayed on the map.
///
/// Contains the info window's identifier, position, and content.
class InfoWindowOption extends Data {
  /// Creates a new InfoWindowOption with the specified parameters.
  ///
  /// The [id] is a unique identifier for this info window.
  /// The [latLng] specifies the geographic position of the info window.
  /// The [title] is the main text content of the info window (used when [body] is null).
  /// The [snippet] is optional additional text content (used when [body] is null).
  /// The [body] is a custom GUI layout for the info window content.
  /// The [tail] is an optional tail image for speech bubble effect.
  /// The [isVisible] determines whether the info window should be shown initially.
  /// The [offset] allows positioning the info window relative to its anchor point.
  /// The [bodyOffset] allows positioning the body relative to its anchor point.
  const InfoWindowOption({
    required this.id,
    required this.latLng,
    this.title,
    this.snippet,
    this.body,
    this.tail,
    this.isVisible = true,
    this.offset = const InfoWindowOffset(x: 0, y: 0),
    this.bodyOffset = const InfoWindowOffset(x: 0, y: 0),
  });

  /// Creates a simple text-based InfoWindow (legacy style).
  ///
  /// This is a convenience constructor for creating InfoWindows with just text content.
  const InfoWindowOption.text({
    required this.id,
    required this.latLng,
    required String this.title,
    this.snippet,
    this.isVisible = true,
    this.offset = const InfoWindowOffset(x: 0, y: 0),
    this.bodyOffset = const InfoWindowOffset(x: 0, y: 0),
  })  : body = null,
        tail = null;

  /// Creates a custom GUI-based InfoWindow.
  ///
  /// This constructor allows for complex UI layouts using GuiView components.
  const InfoWindowOption.custom({
    required this.id,
    required this.latLng,
    required GuiView this.body,
    this.tail,
    this.isVisible = true,
    this.offset = const InfoWindowOffset(x: 0, y: 0),
    this.bodyOffset = const InfoWindowOffset(x: 0, y: 0),
  })  : title = null,
        snippet = null;

  /// The unique identifier for this info window.
  final String id;

  /// The geographic position where this info window should be displayed.
  final LatLng latLng;

  /// The main title text of the info window (used when body is null).
  final String? title;

  /// Optional additional text content below the title (used when body is null).
  final String? snippet;

  /// Custom GUI layout for the info window content.
  ///
  /// When provided, this takes precedence over [title] and [snippet].
  final GuiView? body;

  /// Optional tail image for speech bubble effect.
  final GuiImage? tail;

  /// Whether the info window should be visible when created.
  final bool isVisible;

  /// The offset positioning relative to the anchor point.
  final InfoWindowOffset offset;

  /// The body offset positioning relative to its anchor point.
  final InfoWindowOffset bodyOffset;

  /// Whether this InfoWindow uses custom GUI components.
  bool get hasCustomBody => body != null;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        ...latLng.toJson(),
        'title': title,
        'snippet': snippet,
        'body': body?.toJson(),
        'tail': tail?.toJson(),
        'isVisible': isVisible,
        'offset': offset.toJson(),
        'bodyOffset': bodyOffset.toJson(),
        'hasCustomBody': hasCustomBody,
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
