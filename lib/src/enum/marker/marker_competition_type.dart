/// 클러스터링 시 마커 간 경쟁 유형
///
/// 공식문서에 따르면 플랫폼에서 각자 아래처럼 명시되어있습니다.
/// - Android: [CompetitionType](https://apis.map.kakao.com/android_v2/reference/com/kakao/vectormap/label/CompetitionType.html)
/// - iOS: [CompetitionType](https://apis.map.kakao.com/ios_v2/references/Enums/CompetitionType.html)
enum MarkerCompetitionType {
  /// 경쟁하지 않고 겹쳐서 그리기
  none(value: 0),

  /// upper, same, lower 모든 속성을 가지고 경쟁
  all(value: 1),

  /// 자신보다 우선순위가 높은 Layer와 경쟁
  ///
  /// 우선순위가 높은 Layer에 우선권이 있으므로, 우선순위가 높은 Layer와의 경쟁할 경우 무조건 지게 되므로 표시되지 않는다.
  upper(value: 2),

  /// Upper속성과 Lower속성을 가지고 경쟁
  upperLower(value: 3),

  /// Upper속성과 Same속성을 가지고 경쟁
  upperSame(value: 4),

  /// 같은 우선순위를 가진 Layer에 있는 Poi와 경쟁한다. 경쟁 룰은 OrderingType에 따라 결정된다.
  same(value: 5),

  /// Same과 Lower속성을 가지고 경쟁
  sameLower(value: 6),

  /// 낮은 우선순위를 가진 Layer와 경쟁
  ///
  /// 상위 Layer에 우선권이 있으므로, 표출된 위치에 "upper"속성이 들어간 하위 Layer의 Poi는 그려지지 않는다.
  lower(value: 7);

  const MarkerCompetitionType({required this.value});

  /// API 내 사용되는 값
  final int value;
}
