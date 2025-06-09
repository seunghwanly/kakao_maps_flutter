import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../platform/kakao_map_controller/kakao_map_controller.dart';

const String _$viewTypeId = 'kakao_map_view';

class KakaoMap extends StatefulWidget {
  const KakaoMap({
    this.onMapCreated,
    this.creationParams = const <String, Object?>{},
    this.width,
    this.height,
    super.key,
  });

  final Map<String, Object?> creationParams;

  final void Function(KakaoMapController controller)? onMapCreated;

  final double? width;
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
