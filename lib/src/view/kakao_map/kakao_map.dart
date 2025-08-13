import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/compass/compass.dart';
import '../../data/lat_lng/lat_lng.dart';
import '../../data/logo/logo.dart';
import '../../data/scalebar/scalebar.dart';
import '../../platform/kakao_map_controller/kakao_map_controller.dart';

const String _$viewTypeId = 'kakao_map_view';

/// Interactive Kakao Map widget
/// [EN]
/// - Embeds a native Kakao Map using AndroidView/UiKitView with given configuration
///
/// [KO]
/// - AndroidView/UiKitView를 통해 네이티브 Kakao Map을 임베드하는 대화형 지도 위젯
class KakaoMap extends StatefulWidget {
  /// Create interactive map
  /// [EN]
  /// - [onMapCreated]: callback when map is ready with [KakaoMapController]
  /// - [initialPosition]: initial center position
  /// - [initialLevel]: initial zoom level
  /// - [width], [height]: widget size
  /// - [compass]: compass configuration
  /// - [scaleBar]: scale bar configuration
  /// - [logo]: logo configuration
  ///
  /// [KO]
  /// - [onMapCreated]: 맵 준비 완료 시 호출되는 [KakaoMapController] 제공 콜백
  /// - [initialPosition]: 초기 중심좌표
  /// - [initialLevel]: 초기 줌 레벨
  /// - [width], [height]: 위젯 크기
  /// - [compass]: 나침반 설정
  /// - [scaleBar]: 축척바 설정
  /// - [logo]: 로고 설정
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

  /// Map ready callback
  /// [EN]
  /// - Provides [KakaoMapController] to interact with the map
  ///
  /// [KO]
  /// - 맵 제어를 위한 [KakaoMapController] 제공 콜백
  final void Function(KakaoMapController controller)? onMapCreated;

  /// Initial center position
  /// [EN]
  /// - Uses default center when null
  ///
  /// [KO]
  /// - null이면 기본 중심 위치 사용
  final LatLng? initialPosition;

  /// Initial zoom level
  /// [EN]
  /// - Valid range 1-21, uses default when null
  ///
  /// [KO]
  /// - 유효 범위 1-21, null이면 기본 줌 레벨 사용
  final int? initialLevel;

  /// Map width
  /// [EN]
  /// - Uses max available width when null
  ///
  /// [KO]
  /// - null이면 사용 가능 최대 너비 사용
  final double? width;

  /// Map height
  /// [EN]
  /// - Uses max available height when null
  ///
  /// [KO]
  /// - null이면 사용 가능 최대 높이 사용
  final double? height;

  /// Compass configuration
  /// [EN]
  /// - When null, compass is hidden
  ///
  /// [KO]
  /// - null이면 나침반 표시 안 함
  final Compass? compass;

  /// Scale bar configuration
  /// [EN]
  /// - When null, scale bar is hidden
  ///
  /// [KO]
  /// - null이면 축척바 표시 안 함
  final ScaleBar? scaleBar;

  /// Logo configuration
  /// [EN]
  /// - When null, logo is hidden
  ///
  /// [KO]
  /// - null이면 로고 표시 안 함
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
