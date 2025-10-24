import 'package:kakao_maps_flutter/src/controller/interface/kakao_map_controller_platform_interface.dart';
import 'package:kakao_maps_flutter/src/controller/method_channel/method_channel_kakao_map_controller.dart';

KakaoMapControllerPlatform createPlatformControllerImpl(int viewId) =>
    MethodChannelKakaoMapController.create(viewId);
