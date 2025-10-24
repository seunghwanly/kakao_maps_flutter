import 'package:flutter/widgets.dart';
import 'package:kakao_maps_flutter/src/controller/kakao_map_controller.dart'
    show KakaoMapController;
import 'package:kakao_maps_flutter/src/data/lat_lng/lat_lng.dart';

/// Stub implementation for web view creation on non-web platforms.
Widget buildWebView({
  required int webViewId,
  required void Function(KakaoMapController controller) onMapCreated,
  LatLng? initialPosition,
  int? initialLevel,
}) {
  throw UnsupportedError('Web view is not supported on this platform.');
}
