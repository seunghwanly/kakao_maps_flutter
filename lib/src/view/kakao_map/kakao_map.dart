import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/compass/compass.dart';
import '../../data/lat_lng/lat_lng.dart';
import '../../data/logo/logo.dart';
import '../../data/scalebar/scalebar.dart';
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
  /// The [initialPosition] sets the initial center position of the map.
  /// The [initialLevel] sets the initial zoom level of the map.
  /// The [width] and [height] specify the dimensions of the map widget.
  /// The [compass] configures the compass widget on the map.
  /// The [scaleBar] configures the scale bar widget on the map.
  /// The [logo] configures the logo widget on the map.
  const KakaoMap({
    this.onMapCreated,
    this.initialPosition,
    this.initialLevel,
    this.width,
    this.height,
    this.compass,
    this.scaleBar,
    this.logo,
    super.key,
  });

  /// Callback function called when the map is created and ready to use.
  ///
  /// Provides a [KakaoMapController] instance to interact with the map.
  final void Function(KakaoMapController controller)? onMapCreated;

  /// The initial center position of the map.
  ///
  /// If null, the map will use its default center position.
  final LatLng? initialPosition;

  /// The initial zoom level of the map.
  ///
  /// Valid range is 1-21. If null, the map will use its default zoom level.
  final int? initialLevel;

  /// The width of the map widget.
  ///
  /// If null, uses the maximum available width.
  final double? width;

  /// The height of the map widget.
  ///
  /// If null, uses the maximum available height.
  final double? height;

  /// Configuration for the compass widget on the map.
  ///
  /// If null, the compass will not be shown.
  final Compass? compass;

  /// Configuration for the scale bar widget on the map.
  ///
  /// If null, the scale bar will not be shown.
  final ScaleBar? scaleBar;

  /// Configuration for the logo widget on the map.
  ///
  /// If null, the logo will not be shown.
  final Logo? logo;

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

        final creationParams = <String, Object?>{
          'width': width,
          'height': height,
        };

        // Add initialPosition to creationParams if provided
        if (widget.initialPosition != null) {
          creationParams['initialPosition'] = widget.initialPosition!.toJson();
        }

        // Add initialLevel to creationParams if provided
        if (widget.initialLevel != null) {
          creationParams['initialLevel'] = widget.initialLevel;
        }

        // Add compass configuration to creationParams if provided
        if (widget.compass != null) {
          creationParams['compass'] = widget.compass!.toJson();
        }

        // Add scaleBar configuration to creationParams if provided
        if (widget.scaleBar != null) {
          creationParams['scaleBar'] = widget.scaleBar!.toJson();
        }

        // Add logo configuration to creationParams if provided
        if (widget.logo != null) {
          creationParams['logo'] = widget.logo!.toJson();
        }

        return SizedBox(
          width: width,
          height: height,
          child: switch (defaultTargetPlatform) {
            TargetPlatform.android => AndroidView(
                viewType: _$viewTypeId,
                creationParams: creationParams,
                creationParamsCodec: const StandardMessageCodec(),
                onPlatformViewCreated: (id) async {
                  if (controller != null) return;

                  controller = KakaoMapController(viewId: id);
                  widget.onMapCreated?.call(controller!);
                },
              ),
            TargetPlatform.iOS => UiKitView(
                viewType: _$viewTypeId,
                creationParams: creationParams,
                creationParamsCodec: const StandardMessageCodec(),
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
