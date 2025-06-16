// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

part 'controller/static_map_controller.dart';

/// KakaoMap 정적 지도 Widget
class StaticKakaoMap extends StatefulWidget {
  /// 정적 지도를 생성하는 위젯
  ///
  /// - [width] : 지도의 너비(px)
  /// - [height] : 지도의 높이(px)
  /// - [center] : 지도의 중심좌표
  /// - [marker] : (optional) 지도에 표시할 마커
  /// - [isLoadingProgressEnabled] : 로딩 진행 상태 표시 여부
  /// - [backgroundColor] : 지도의 배경색
  const StaticKakaoMap({
    required this.width,
    required this.height,
    required this.center,
    this.level = 4,
    this.marker,
    this.isLoadingProgressEnabled = true,
    this.backgroundColor = Colors.white,
    super.key,
  });

  /// 지도의 너비(px)
  final double width;

  /// 지도의 높이(px)
  final double height;

  /// 지도의 중심좌표
  final LatLng center;

  /// 지도에 표시할 마커
  ///
  /// 1개의 마커만 지원합니다.
  final LabelOption? marker;

  /// 지도의 확대 레벨
  final int level;

  /// 로딩 진행 상태 표시 여부
  final bool isLoadingProgressEnabled;

  /// 지도의 배경색
  final Color backgroundColor;

  @override
  State<StaticKakaoMap> createState() => _StaticKakaoMapState();
}

class _StaticKakaoMapState extends State<StaticKakaoMap> {
  late final WebViewController controller;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(widget.backgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            // TODO(seunghwanly): remove loading state
            if (!mounted) return;

            setState(() => isLoading = false);
          },
        ),
      )
      // TODO(seunghwanly): Info.plist 내 설정 필요 WEB 호환성
      ..loadHtmlString(
        StaticMapController.instance.buildHTML(
          width: widget.width.toInt(),
          height: widget.height.toInt(),
          level: widget.level,
          center: widget.center,
          marker: widget.marker,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingProgressEnabled && isLoading) {
      return ColoredBox(
        color: widget.backgroundColor,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: IgnorePointer(
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
