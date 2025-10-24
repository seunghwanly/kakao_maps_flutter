import 'package:flutter/widgets.dart';
import 'package:kakao_maps_flutter/src/controller/kakao_map_controller.dart'
    show KakaoMapController;

/// Stub implementation for web view creation on non-web platforms.
Widget buildWebView(
  Map<String, Object?> creationParams,
  int webViewId,
  void Function(KakaoMapController controller) onMapCreated,
) {
  throw UnsupportedError('Web view is not supported on this platform.');
}
