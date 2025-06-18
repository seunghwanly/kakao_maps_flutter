/// 클러스터링 시 마커 간 경쟁 단위
///
/// 공식문서
/// - [Android](https://apis.map.kakao.com/android_v2/reference/com/kakao/vectormap/label/CompetitionUnit.html)
/// - [iOS](https://apis.map.kakao.com/ios_v2/references/Enums/CompetitionUnit.html)
enum MarkerCompetitionUnit {
  /// 마커의 icon과 Text모두 경쟁에서 통과해야 그려진다.
  marker(value: 0),

  /// 마커의 icon만 경쟁 기준이 된다. 단, text가 경쟁에서 진 경우 text는 표출되지 않는다.
  style(value: 1);

  const MarkerCompetitionUnit({required this.value});

  /// API 내 사용되는 값
  final int value;
}
