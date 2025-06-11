import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../platform/kakao_map_controller/kakao_map_controller.dart';

const String _$viewTypeId = 'kakao_map_view';

/// A widget that displays a Kakao Map view.
///
/// This widget creates a platform-specific view (AndroidView/UiKitView) that
/// displays the native Kakao Map with the specified configuration.
class KakaoMap extends StatefulWidget {
  /// Creates a KakaoMap widget.
  ///
  /// The [onMapCreated] callback is called when the map is ready to be used.
  /// The [creationParams] can be used to pass additional parameters during
  /// map creation. The [width] and [height] specify the dimensions of the
  /// map widget.
  const KakaoMap({
    this.onMapCreated,
    this.creationParams = const <String, Object?>{},
    this.width,
    this.height,
    super.key,
  });

  /// Additional parameters to pass during map creation.
  ///
  /// These parameters are merged with default width/height values.
  final Map<String, Object?> creationParams;

  /// Callback function called when the map is created and ready to use.
  ///
  /// Provides a [KakaoMapController] instance to interact with the map.
  final void Function(KakaoMapController controller)? onMapCreated;

  /// The width of the map widget.
  ///
  /// If null, uses the maximum available width.
  final double? width;

  /// The height of the map widget.
  ///
  /// If null, uses the maximum available height.
  final double? height;

  @override
  State<KakaoMap> createState() => _KakaoMapState();
}

class _KakaoMapState extends State<KakaoMap> {
  KakaoMapController? controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use LayoutBuilder to get the actual available space
        final width = widget.width ?? constraints.maxWidth;
        final height = widget.height ?? constraints.maxHeight;

        final creationParams = {
          'width': width,
          'height': height,
          ...widget.creationParams,
        };

        return SizedBox(
          width: width,
          height: height,
          child: switch (defaultTargetPlatform) {
            TargetPlatform.android => AndroidView(
                viewType: _$viewTypeId,
                creationParams: creationParams,
                creationParamsCodec: const JSONMessageCodec(),
                onPlatformViewCreated: (id) async {
                  if (controller != null) return;

                  controller = KakaoMapController(viewId: id);
                  widget.onMapCreated?.call(controller!);
                },
              ),
            TargetPlatform.iOS => UiKitView(
                viewType: _$viewTypeId,
                creationParams: creationParams,
                creationParamsCodec: const JSONMessageCodec(),
                onPlatformViewCreated: (id) async {
                  if (controller != null) return;

                  controller = KakaoMapController(viewId: id);
                  widget.onMapCreated?.call(controller!);
                },
              ),
            _ => throw UnsupportedError(
                'Unsupported platform: $defaultTargetPlatform',
              ),
          },
        );
      },
    );
  }
}
