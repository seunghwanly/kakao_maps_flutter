part of '../map_widget.dart';

/// GUI 레이아웃: 여러 GUI 뷰를 포함하는 컨테이너
///
/// 수평 또는 수직 방향으로 자식 뷰들을 배치하고, 배경 이미지를 설정할 수 있습니다.
class GuiLayout extends GuiView {
  /// GUI 레이아웃을 생성합니다.
  ///
  /// [orientation]은 자식 뷰들의 배치 방향입니다.
  /// [children]은 레이아웃에 포함될 자식 뷰들의 목록입니다.
  /// [background]는 레이아웃의 배경 이미지입니다.
  /// 나머지 매개변수는 부모 클래스 [GuiView]를 참조하세요.
  const GuiLayout({
    required this.orientation,
    this.children = const <GuiView>[],
    this.background,
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
  }) : super(type: orientation == Orientation.horizontal ? 0 : 1);

  /// 자식 뷰들의 배치 방향
  final Orientation orientation;

  /// 레이아웃에 포함된 자식 뷰들
  final List<GuiView> children;

  /// 레이아웃의 배경 이미지
  final GuiImage? background;

  /// 자식 뷰가 있는지 확인
  bool get hasChildren => children.isNotEmpty;

  /// 인덱스로 자식 뷰 가져오기
  ///
  /// [index]에 해당하는 자식 뷰를 반환합니다.
  /// 인덱스가 범위를 벗어나면 null을 반환합니다.
  GuiView? getChildAt(int index) {
    if (index < 0 || index >= children.length) return null;
    return children[index];
  }

  /// ID로 자식 뷰 찾기
  ///
  /// [id]에 해당하는 자식 뷰를 반환합니다.
  /// 찾지 못하면 null을 반환합니다.
  GuiView? getChildById(String id) {
    for (final child in children) {
      if (child.id == id) return child;
    }
    return null;
  }

  /// 자식 뷰 추가된 새로운 레이아웃 생성
  ///
  /// 현재 레이아웃에 [child]를 추가한 새로운 레이아웃을 반환합니다.
  /// 기존 레이아웃은 변경되지 않습니다.
  GuiLayout addChild(GuiView child) {
    final newChildren = List<GuiView>.from(children)..add(child);
    return GuiLayout(
      orientation: orientation,
      children: newChildren,
      background: background,
      id: id,
      clickable: clickable,
      paddingLeft: paddingLeft,
      paddingTop: paddingTop,
      paddingRight: paddingRight,
      paddingBottom: paddingBottom,
      verticalOrigin: verticalOrigin,
      horizontalOrigin: horizontalOrigin,
      verticalAlign: verticalAlign,
      horizontalAlign: horizontalAlign,
      tag: tag,
    );
  }

  /// 배경 이미지가 설정된 새로운 레이아웃 생성
  ///
  /// 현재 레이아웃에 [backgroundImage]를 설정한 새로운 레이아웃을 반환합니다.
  /// 기존 레이아웃은 변경되지 않습니다.
  GuiLayout withBackground(GuiImage backgroundImage) {
    return GuiLayout(
      orientation: orientation,
      children: children,
      background: backgroundImage,
      id: id,
      clickable: clickable,
      paddingLeft: paddingLeft,
      paddingTop: paddingTop,
      paddingRight: paddingRight,
      paddingBottom: paddingBottom,
      verticalOrigin: verticalOrigin,
      horizontalOrigin: horizontalOrigin,
      verticalAlign: verticalAlign,
      horizontalAlign: horizontalAlign,
      tag: tag,
    );
  }

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        ...super.toJson(),
        'orientation': orientation.value,
        'children': children.map((child) => child.toJson()).toList(),
        'background': background?.toJson(),
        'hasChildren': hasChildren,
      };
}
