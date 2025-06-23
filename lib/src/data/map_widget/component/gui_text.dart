part of '../map_widget.dart';

/// GUI 텍스트: 텍스트를 표시하는 GUI 컴포넌트
///
/// 텍스트 내용, 크기, 색상, 테두리 등을 설정할 수 있습니다.
class GuiText extends GuiView {
  /// GUI 텍스트를 생성합니다.
  ///
  /// [text]는 표시할 텍스트 내용입니다.
  /// [textSize]는 텍스트 크기입니다.
  /// [textColor]는 텍스트 색상입니다.
  /// [strokeSize]는 텍스트 테두리 두께입니다.
  /// [strokeColor]는 텍스트 테두리 색상입니다.
  /// 나머지 매개변수는 부모 클래스 [GuiView]를 참조하세요.
  const GuiText({
    required this.text,
    this.textSize = 14,
    this.textColor = 0xFF000000, // -16777216 (black)
    this.strokeSize = 0,
    this.strokeColor = 0x00000000, // transparent
    super.id,
    super.clickable,
    super.paddingLeft,
    super.paddingTop,
    super.paddingRight,
    super.paddingBottom,
    super.verticalOrigin,
    super.horizontalOrigin,
    super.verticalAlign,
    super.horizontalAlign,
    super.tag,
  }) : super(type: 4);

  /// 표시할 텍스트 내용
  final String text;

  /// 텍스트 크기
  final int textSize;

  /// 텍스트 색상 (ARGB 형식)
  final int textColor;

  /// 텍스트 테두리 두께
  final int strokeSize;

  /// 텍스트 테두리 색상 (ARGB 형식)
  final int strokeColor;

  /// 텍스트 줄 수 계산
  int get lineCount {
    if (text.isEmpty) return 0;

    final lines = text.split(RegExp(r'\r?\n'));
    return lines.length;
  }

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        ...super.toJson(),
        'text': text,
        'textSize': textSize,
        'textColor': textColor,
        'strokeSize': strokeSize,
        'strokeColor': strokeColor,
        'lineCount': lineCount,
      };
}
