// ignore_for_file: depend_on_referenced_packages

import 'dart:math';

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
  /// - [errorMessage] : 에러 발생 시 표시할 메시지
  /// - [retryButtonText] : 재시도 버튼 텍스트
  /// - [onRetry] : 재시도 버튼 클릭 시 콜백 (기본값: reload)
  /// - [loadingWidget] : 로딩 중 표시할 위젯
  const StaticKakaoMap({
    required this.width,
    required this.height,
    required this.center,
    this.level = 4,
    this.marker,
    this.isLoadingProgressEnabled = true,
    this.backgroundColor = Colors.white,
    this.scaleRatio = 1,
    this.errorMessage = 'Loading Failed',
    this.retryButtonText = 'Retry',
    this.onRetry,
    this.loadingWidget,
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

  /// 지도의 비율 (기본값: 1)
  final double scaleRatio;

  /// 에러 발생 시 표시할 메시지
  final String errorMessage;

  /// 재시도 버튼 텍스트
  final String retryButtonText;

  /// 재시도 버튼 클릭 시 콜백 (기본값: reload)
  final VoidCallback? onRetry;

  /// 로딩 중 표시할 위젯
  final Widget? loadingWidget;

  @override
  State<StaticKakaoMap> createState() => _StaticKakaoMapState();
}

class _StaticKakaoMapState extends State<StaticKakaoMap> {
  late final WebViewController controller;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    _initializeController();
  }

  void _initializeController() {
    try {
      // 검증된 패턴을 사용하여 컨트롤러 생성
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
              if (!mounted) return;

              setState(() => isLoading = false);
            },
          ),
        )

        // 작동하는 패턴을 사용하여 HTML 로드
        ..loadHtmlString(
          StaticMapController.instance.buildHTML(
            width: widget.width * widget.scaleRatio,
            height: widget.height * widget.scaleRatio,
            level: widget.level,
            center: widget.center,
            marker: widget.marker,
          ),
        );
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 안전한 크기 계산
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;

        final finalWidth = min(widget.width, availableWidth);
        final finalHeight = min(widget.height, availableHeight);

        // 로딩 상태
        if (widget.isLoadingProgressEnabled && isLoading) {
          return ColoredBox(
            color: widget.backgroundColor,
            child: SizedBox(
              width: finalWidth,
              height: finalHeight,
              child: Center(
                child: widget.loadingWidget ??
                    const CircularProgressIndicator.adaptive(),
              ),
            ),
          );
        }

        // 성공 상태 - 작동하는 구현과 같은 간단한 WebView
        return SizedBox(
          width: finalWidth,
          height: finalHeight,
          child: IgnorePointer(
            child: WebViewWidget(controller: controller),
          ),
        );
      },
    );
  }
}
