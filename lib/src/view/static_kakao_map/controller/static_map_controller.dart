part of '../static_kakao_map.dart';

/// 정적 지도(이미지 지도)를 생성하는 컨트롤러
class StaticMapController {
  const StaticMapController._(String webAPIKey) : _webAPIKey = webAPIKey;

  /// 정적 지도(이미지 지도)를 생성하는 컨트롤러의 인스턴스를 초기화
  ///
  /// 초기화 이후에는 인스턴스를 사용할 수 있습니다.
  factory StaticMapController.init(String webAPIKey) {
    return instance = StaticMapController._(webAPIKey);
  }

  /// 정적 지도(이미지 지도)를 생성하는 컨트롤러의 인스턴스, 싱글톤
  static late StaticMapController instance;

  final String _webAPIKey;

  /// - [width] : 지도의 너비(px)
  /// - [height] : 지도의 높이(px)
  /// - [level] : 지도의 확대 레벨
  /// - [center] : 지도의 중심좌표
  /// - [marker] : (optional) 지도에 표시할 마커
  String buildHTML({
    required double width,
    required double height,
    required int level,
    required LatLng center,
    MarkerOption? marker,
  }) {
    // Flutter 위젯 크기를 viewport로 설정하고 map-container가 100% fill
    final String htmlHeader = '''
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=${width.round()}, height=${height.round()}, user-scalable=no" />
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    html, body {
      width: 100%;
      height: 100%;
      overflow: hidden;
    }
    .map-container {
      width: 100%;
      height: 100%;
    }
  </style>
</head>
<body>
''';

    final String scriptHeader = '''
  <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=$_webAPIKey"></script>
''';

    const String htmlFooter = '''
</body>
</html>
''';

    // 커스텀 이미지 기반 마커는 LabelOption에서 제거되었으며,
    // 정적 지도에서도 기본 마커만 지원합니다.

    /// 기본 마커를 사용하는 정적 지도
    String? markerOption = '';
    if (marker != null) {
      markerOption = '''
marker: {
  position: new kakao.maps.LatLng(${marker.latLng.latitude}, ${marker.latLng.longitude})
},''';
    }

    return '''
$htmlHeader
  <div id="staticMap" class="map-container"></div>
$scriptHeader
  <script>
    var container = document.getElementById('staticMap');
    
    var options = {
      center: new kakao.maps.LatLng(${center.latitude}, ${center.longitude}),
      level: $level,
      $markerOption
    };

    var staticMap = new kakao.maps.StaticMap(container, options);
  </script>
$htmlFooter
''';
  }
}
