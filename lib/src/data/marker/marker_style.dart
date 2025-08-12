import 'package:flutter/foundation.dart';
import 'package:kakao_maps_flutter/src/base/data.dart';

/// 마커 텍스트 스타일 정의.
///
/// - [fontSize]: 텍스트 크기(px)
/// - [fontColorArgb]: ARGB32 정수 값(예: 0xFF000000)
/// - [strokeThickness]: 테두리 두께(px)
/// - [strokeColorArgb]: 테두리 색상(ARGB32)
class MarkerTextStyle extends Data {
  /// 텍스트 스타일을 생성합니다.
  const MarkerTextStyle({
    required this.fontSize,
    required this.fontColorArgb,
    this.strokeThickness,
    this.strokeColorArgb,
  });

  /// 텍스트 크기(px)
  final int fontSize;

  /// 텍스트 색상(ARGB32)
  final int fontColorArgb;

  /// 텍스트 테두리 두께(px)
  final int? strokeThickness;

  /// 텍스트 테두리 색상(ARGB32)
  final int? strokeColorArgb;

  /// 플랫폼 채널 전송을 위한 직렬화 데이터로 변환합니다.
  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'fontSize': fontSize,
        'fontColor': fontColorArgb,
        'strokeThickness': strokeThickness,
        'strokeColor': strokeColorArgb,
      };
}

/// 줌 레벨별 마커 스타일(아이콘/텍스트) 정의.
///
/// iOS의 `PerLevelPoiStyle`에 대응합니다. Android는 첫 항목을 우선 사용합니다.
class MarkerPerLevelStyle extends Data {
  /// Base64로 인코딩된 아이콘 이미지와 선택적 텍스트 스타일, 적용 레벨을 받습니다.
  const MarkerPerLevelStyle({
    required this.bytes,
    this.textStyle,
    this.level,
  });

  /// 아이콘 바이트 배열로부터 스타일을 생성합니다.
  factory MarkerPerLevelStyle.fromBytes({
    required Uint8List bytes,
    MarkerTextStyle? textStyle,
    int? level,
  }) =>
      MarkerPerLevelStyle(
        bytes: bytes,
        textStyle: textStyle,
        level: level,
      );

  /// Base64로 인코딩된 아이콘 이미지 데이터
  final Uint8List bytes;

  /// 텍스트 스타일(선택)
  final MarkerTextStyle? textStyle;

  /// 적용 레벨(iOS에서 사용). null 이면 기본 동작.
  final int? level; // iOS에서만 사용됨

  /// 직렬화 표현으로 변환합니다.
  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'icon': bytes,
        'textStyle': textStyle?.toJson(),
        'level': level,
      };
}

/// 마커 스타일 집합 정의.
///
/// 하나의 `styleId` 아래에 여러 레벨별 스타일을 묶어 관리합니다.
class MarkerStyle extends Data {
  /// 스타일 ID와 레벨별 스타일 리스트를 받아 생성합니다.
  const MarkerStyle({
    required this.styleId,
    required this.perLevels,
  });

  /// 고유 스타일 ID(플랫폼 공통 참조 키)
  final String styleId;

  /// 레벨별 스타일 목록
  final List<MarkerPerLevelStyle> perLevels;

  /// 직렬화 표현으로 변환합니다.
  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'styleId': styleId,
        'perLevels': perLevels.map((e) => e.toJson()).toList(),
      };
}
