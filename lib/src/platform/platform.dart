/// Platform layer for native SDKs
/// [EN]
/// - Controllers, method calls and interfaces to communicate with native Kakao Maps SDK
///
/// [KO]
/// - 네이티브 Kakao Maps SDK와 통신하는 컨트롤러, 메서드 호출, 인터페이스 집합
library kakao_maps_flutter.platform;

export '../controller/kakao_map_controller.dart';
export '../method_call/kakao_map_method_call.dart';
export 'interface/kakao_maps_flutter_platform_interface.dart';
export 'kakao_maps_flutter.dart';
export 'method_channel/method_channel_kakao_maps_flutter.dart';
