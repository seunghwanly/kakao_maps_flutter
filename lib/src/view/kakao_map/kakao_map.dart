import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui show platformViewRegistry;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

import '../../data/compass/compass.dart';
import '../../data/lat_lng/lat_lng.dart';
import '../../data/logo/logo.dart';
import '../../data/scalebar/scalebar.dart';
import '../../platform/kakao_map_controller/kakao_map_controller.dart';
import 'kakao_map_js_interop.dart';

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
  static int _nextViewId = 0;
  late final int _webViewId;

  @override
  void initState() {
    super.initState();
    _webViewId = _nextViewId++;
  }

  Widget _buildWebView(Map<String, Object?> creationParams) {
    if (!kIsWeb) {
      throw UnsupportedError(
        '_buildWebView can only be called on web platform',
      );
    }

    // Generate unique view ID for this map instance
    final viewId = 'kakao-map-$_webViewId';

    // Register the view factory for this specific map instance
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final mapDiv = web.HTMLDivElement()
        ..id = 'map-container-$_webViewId'
        ..style.width = '100%'
        ..style.height = '100%';

      // Initialize the map after a short delay to ensure the DOM is ready
      Future.microtask(() {
        _initializeWebMap(mapDiv, creationParams);
      });

      return mapDiv;
    });

    return HtmlElementView(viewType: viewId);
  }

  void _initializeWebMap(
    web.HTMLDivElement container,
    Map<String, Object?> creationParams,
  ) {
    // Extract initial position and level from creationParams
    final initialPosition = widget.initialPosition ??
        const LatLng(latitude: 37.5441, longitude: 127.0558);
    final initialLevel = widget.initialLevel ?? 14;

    // Use setTimeout to ensure DOM is fully mounted before initializing map
    web.window.setTimeout(
      (() {
        // Check if Kakao Maps SDK is loaded
        if (!isKakaoMapsLoaded()) {
          web.console.error('Kakao Maps SDK is not loaded'.toJS);
          return;
        }

        try {
          // Get kakao.maps namespace
          final k = kakao;
          if (k == null) {
            web.console.error('Kakao object not found'.toJS);
            return;
          }

          final maps = k['maps'] as JSObject?;
          if (maps == null) {
            web.console.error('Kakao Maps namespace not found'.toJS);
            return;
          }

          // Get constructors
          final latLngCtor = maps['LatLng'] as JSFunction?;
          final mapCtor = maps['Map'] as JSFunction?;

          if (latLngCtor == null || mapCtor == null) {
            web.console.error('Kakao Maps constructors not available'.toJS);
            return;
          }

          // Create LatLng
          final latLng = latLngCtor.callAsConstructor<JSObject>(
            initialPosition.latitude.toJS,
            initialPosition.longitude.toJS,
          );

          // Create options
          final options = JSObject();
          options['center'] = latLng;
          options['level'] = initialLevel.toJS;

          // Create Map
          final map = mapCtor.callAsConstructor<JSObject>(
            container as JSAny,
            options,
          );

          // Store map instance for future reference
          _storeMapInstance(_webViewId, map);

          web.console.log(
            'Kakao map initialized successfully for viewId: $_webViewId'.toJS,
          );

          // Notify that the map is ready
          if (controller == null) {
            controller = KakaoMapController(viewId: _webViewId);
            widget.onMapCreated?.call(controller!);
          }
        } catch (e) {
          web.console.error('Failed to create Kakao map: $e'.toJS);
        }
      }).toJS,
      100.toJS, // Wait 100ms for DOM to be ready
    );
  }

  /// Store map instance in window object for future reference
  void _storeMapInstance(int viewId, JSObject map) {
    final windowObj = web.window as JSObject;
    final kakaoMapsObj = windowObj['kakaoMaps'] as JSObject?;

    if (kakaoMapsObj == null) {
      final newMapsObj = JSObject();
      windowObj['kakaoMaps'] = newMapsObj;
      newMapsObj[viewId.toString()] = map as JSAny;
    } else {
      kakaoMapsObj[viewId.toString()] = map as JSAny;
    }
  }

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
          child: kIsWeb
              ? _buildWebView(creationParams)
              : switch (defaultTargetPlatform) {
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
