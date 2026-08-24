import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

PlatformWebViewControllerCreationParams
createWebViewControllerCreationParams() {
  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    return WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
      mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    );
  }

  return const PlatformWebViewControllerCreationParams();
}
