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
    LabelOption? marker,
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

    /// 다른 이미지 마커가 있는 경우, 일반 지도 API 사용
    /// StaticMap은 커스텀 마커 이미지를 지원하지 않음
    if (marker != null &&
        marker.base64EncodedImage != null &&
        marker.base64EncodedImage!.isNotEmpty) {
      return '''
$htmlHeader
  <div id="map" class="map-container"></div>
$scriptHeader
  <script>
    var container = document.getElementById('map');
    
    var options = {
      center: new kakao.maps.LatLng(${center.latitude}, ${center.longitude}),
      level: $level,
      draggable: false,
      disableDoubleClick: true,
      disableDoubleClickZoom: true,
      keyboardShortcuts: false
    };

    var map = new kakao.maps.Map(container, options);

    var imageSrc = 'data:image/svg+xml;base64,${marker.base64EncodedImage}';
    var markerImage = new kakao.maps.MarkerImage(imageSrc);
    var markerPosition = new kakao.maps.LatLng(${marker.latLng.latitude}, ${marker.latLng.longitude});

    var mapMarker = new kakao.maps.Marker({
      position: markerPosition,
      image: markerImage
    });

    mapMarker.setMap(map);
    
    // 추가적인 사용자 상호작용 방지
    map.setDraggable(false);
    map.setZoomable(false);
  </script>
$htmlFooter
''';
    }

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
