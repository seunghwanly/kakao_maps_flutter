import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'interface/kakao_maps_flutter_platform_interface.dart';
part 'method_channel/method_channel_kakao_maps_flutter.dart';

class KakaoMapsFlutter {
  static Future<void> init(String token) async {
    assert(
      token.isNotEmpty,
      '🚧 Initialization Failed: token should not be empty',
    );
    return KakaoMapsFlutterPlatform.instance.init(token);
  }
}
