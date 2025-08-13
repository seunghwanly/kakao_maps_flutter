/// Kakao Maps integration for Flutter
/// [EN]
/// - Widgets and controllers to display and control Kakao Maps on Android and iOS
///
/// [KO]
/// - Android, iOS에서 Kakao Maps를 표시하고 제어하는 위젯과 컨트롤러
library kakao_maps_flutter;

/// Data models
/// [EN]
/// - Core data classes used by the Kakao Maps SDK
///
/// [KO]
/// - Kakao Maps SDK에서 사용하는 핵심 데이터 모델
export 'src/data/data.dart';

/// Platform layer
/// [EN]
/// - Platform implementations and interfaces for native Kakao Maps SDKs
///
/// [KO]
/// - 네이티브 Kakao Maps SDK 연동을 위한 플랫폼 구현과 인터페이스
export 'src/platform/platform.dart';

/// View widgets
/// [EN]
/// - Widgets and views for embedding Kakao Maps in Flutter apps
///
/// [KO]
/// - Flutter 앱에 Kakao Maps를 포함하는 위젯과 뷰
export 'src/view/view.dart';
