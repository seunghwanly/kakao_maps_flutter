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

  static const String _headTag = '''
<head>
    <meta charset="utf-8">
</head>
''';

  /// - [width] : 지도의 너비(px)
  /// - [height] : 지도의 높이(px)
  /// - [level] : 지도의 확대 레벨
  /// - [center] : 지도의 중심좌표
  /// - [marker] : (optional) 지도에 표시할 마커
  String buildHTML({
    required int width,
    required int height,
    required int level,
    required LatLng center,
    LabelOption? marker,
  }) {
    /// 다른 이미지 마커가 있는 경우, 일반 지도 API 사용
    if (marker != null &&
        marker.base64EncodedImage != null &&
        marker.base64EncodedImage!.isNotEmpty) {
      return '''
<!DOCTYPE html>
<html>
$_headTag
<body>
<!-- 이미지 지도를 표시할 div 입니다 -->
<div id="map" style="width:${width}px;height:${height}px;"></div>    

<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=$_webAPIKey"></script>
<script>
// 정적 지도(이미지 지도)는 기본 마커 이외의 다른 이미지 마커를 지원하지 않기 떄문에
// 일반 지도 API를 활용 합니다.
var mapContainer = document.getElementById('map'), // 지도를 표시할 div 
    mapOption = { 
        center: new kakao.maps.LatLng(${center.latitude}, ${center.longitude}), // 지도의 중심좌표
        level: $level // 지도의 확대 레벨
    };

var map = new kakao.maps.Map(mapContainer, mapOption); // 지도를 생성합니다

var imageSrc = 'data:image/svg+xml;base64,${marker.base64EncodedImage}'; // 마커이미지의 주소입니다    
    // TODO(seunghwanly): 마커의 크기 및 옵션 지원, LabelOption 확장 필요
    //imageSize = new kakao.maps.Size(64, 69), // 마커이미지의 크기입니다
    //imageOption = {offset: new kakao.maps.Point(27, 69)}; // 마커이미지의 옵션입니다. 마커의 좌표와 일치시킬 이미지 안에서의 좌표를 설정합니다.
      
// 마커의 이미지정보를 가지고 있는 마커이미지를 생성합니다
var markerImage = new kakao.maps.MarkerImage(imageSrc), // 지원예정: imageSize, imageOption
    markerPosition = new kakao.maps.LatLng(${marker.latLng.latitude}, ${marker.latLng.longitude}); // 마커가 표시될 위치입니다

// 마커를 생성합니다
var marker = new kakao.maps.Marker({
    position: markerPosition, 
    image: markerImage // 마커이미지 설정 
});

// 마커가 지도 위에 표시되도록 설정합니다
marker.setMap(map);  
map.setDraggable(false);
</script>
</body>
</html>
''';
    }

    /// 이미지 지도에 표시할 마커입니다
    /// 이미지 지도에 표시할 마커는 Object 형태입니다
    String? markerKeyValue;
    if (marker != null) {
      markerKeyValue = '''
marker: {
  position: new kakao.maps.LatLng(${marker.latLng.latitude}, ${marker.latLng.longitude})
}
''';
    }

    return '''
<!DOCTYPE html>
<html>
$_headTag
<body>
<!-- 이미지 지도를 표시할 div 입니다 -->
<div id="staticMap" style="width:${width}px;height:${height}px;"></div>    

<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=$_webAPIKey"></script>
<script>
var staticMapContainer  = document.getElementById('staticMap'), // 이미지 지도를 표시할 div  
    staticMapOption = { 
        center: new kakao.maps.LatLng(${center.latitude}, ${center.longitude}), // 이미지 지도의 중심좌표
        level: $level, // 이미지 지도의 확대 레벨
        ${markerKeyValue ?? ''} // 이미지 지도에서 표시할 마커
    };    

// 이미지 지도를 생성합니다
var staticMap = new kakao.maps.StaticMap(staticMapContainer, staticMapOption);
</script>
</body>
</html>
    ''';
  }
}
