part of '../map_widget.dart';

/// Info window configuration
/// [EN]
/// - Identifier, position and content configuration for info windows
///
/// [KO]
/// - 지도에 표시되는 말풍선의 식별자, 위치, 콘텐츠 구성
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
  /// The [zOrder] is the rendering order of the [InfoWindow]
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
    this.zOrder,
  });

  /// Create text-only info window
  /// [EN]
  /// - Convenience constructor for legacy text content
  ///
  /// [KO]
  /// - 텍스트만 포함하는 간단한 말풍선 생성
  const InfoWindowOption.text({
    required this.id,
    required this.latLng,
    required String this.title,
    this.snippet,
    this.isVisible = true,
    this.offset = const InfoWindowOffset(x: 0, y: 0),
    this.bodyOffset = const InfoWindowOffset(x: 0, y: 0),
    this.zOrder,
  })  : body = null,
        tail = null;

  /// Create custom GUI info window
  /// [EN]
  /// - Build complex UI via [GuiView]
  ///
  /// [KO]
  /// - [GuiView] 구성 요소를 사용해 커스텀 UI 기반 말풍선 생성
  const InfoWindowOption.custom({
    required this.id,
    required this.latLng,
    required GuiView this.body,
    this.tail,
    this.isVisible = true,
    this.offset = const InfoWindowOffset(x: 0, y: 0),
    this.bodyOffset = const InfoWindowOffset(x: 0, y: 0),
    this.zOrder,
  })  : title = null,
        snippet = null;

  /// The unique identifier for this info window.
  final String id;

  /// Geographic position
  final LatLng latLng;

  /// The main title text of the info window (used when body is null).
  final String? title;

  /// Optional additional text content below the title (used when body is null).
  final String? snippet;

  /// Custom GUI layout
  /// [EN]
  /// - Takes precedence over [title] and [snippet]
  ///
  /// [KO]
  /// - 제공되면 [title], [snippet]보다 우선 적용
  final GuiView? body;

  /// Optional tail image for speech bubble effect.
  final GuiImage? tail;

  /// Whether the info window should be visible when created.
  final bool isVisible;

  /// Body-free offset
  final InfoWindowOffset offset;

  /// Body offset
  final InfoWindowOffset bodyOffset;

  /// Whether this InfoWindow uses custom GUI components.
  bool get hasCustomBody => body != null;

  /// [MarkerOption]과 렌더링 순위를 별도로 관리, [InfoWindowOption] 끼리만 서로 유효
  final int? zOrder;

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
        'zOrder': zOrder,
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
