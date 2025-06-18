/// 클러스터링 시 정렬 방식
///
/// 공식문서
/// - [Android](https://apis.map.kakao.com/android_v2/reference/com/kakao/vectormap/label/OrderingType.html)
/// - [iOS](https://apis.map.kakao.com/ios_v2/references/Enums/OrderingType.html)
enum MarkerOrderingType {
  /// 마커 별로 가지고 있는 rank 속성값이 높을수록 경쟁에서 우선순위를 갖는다.
  rank(value: 0),

  /// 화면 좌하단과 거리가 가까울수록 높은 우선순위를 갖는다.
  closerToLeftBottom(value: 1);

  const MarkerOrderingType({required this.value});

  /// API 내 사용되는 값
  final int value;
}
