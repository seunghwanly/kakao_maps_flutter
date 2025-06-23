part of '../map_widget.dart';

/*
//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.kakao.vectormap.mapwidget.component;

public abstract class GuiView {
    public int type;
    public String id = "";
    public boolean clickable = true;
    public int paddingLeft = 0;
    public int paddingTop = 0;
    public int paddingRight = 0;
    public int paddingBottom = 0;
    public int verticalOrigin;
    public int horizontalOrigin;
    public int verticalAlign;
    public int horizontalAlign;
    public Object tag;

    public GuiView() {
        this.verticalOrigin = Vertical.Bottom.getValue();
        this.horizontalOrigin = Horizontal.Center.getValue();
        this.verticalAlign = Vertical.Center.getValue();
        this.horizontalAlign = Horizontal.Center.getValue();
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getId() {
        return this.id;
    }

    public void setClickable(boolean clickable) {
        this.clickable = clickable;
    }

    public boolean isClickable() {
        return this.clickable;
    }

    public void setPadding(int left, int top, int right, int bottom) {
        this.paddingLeft = left;
        this.paddingTop = top;
        this.paddingRight = right;
        this.paddingBottom = bottom;
    }

    public void setOrigin(Vertical vertical, Horizontal horizontal) {
        this.verticalOrigin = vertical.getValue();
        this.horizontalOrigin = horizontal.getValue();
    }

    public void setAlign(Vertical vertical, Horizontal horizontal) {
        this.verticalAlign = vertical.getValue();
        this.horizontalAlign = horizontal.getValue();
    }

    public void setVerticalOrigin(Vertical align) {
        this.verticalOrigin = align.getValue();
    }

    public void setHorizontalOrigin(Horizontal align) {
        this.horizontalOrigin = align.getValue();
    }

    public Vertical getVerticalOrigin() {
        return Vertical.getEnum(this.verticalOrigin);
    }

    public Horizontal getHorizontalOrigin() {
        return Horizontal.getEnum(this.horizontalOrigin);
    }

    public Vertical getVerticalAlign() {
        return Vertical.getEnum(this.verticalAlign);
    }

    public Horizontal getHorizontalAlign() {
        return Horizontal.getEnum(this.horizontalAlign);
    }

    public int getPaddingLeft() {
        return this.paddingLeft;
    }

    public int getPaddingTop() {
        return this.paddingTop;
    }

    public int getPaddingRight() {
        return this.paddingRight;
    }

    public int getPaddingBottom() {
        return this.paddingBottom;
    }

    public Object getTag() {
        return this.tag;
    }

    public void setTag(Object tag) {
        this.tag = tag;
    }
}

 */

/// GUI 뷰: 추상클래스
///
/// [MapWidget]과 [InfoWindow]에서 UI 그리는 데 사용되는 컴포넌트 클래스
abstract class GuiView extends Data {
  /// GUI 뷰를 생성합니다.
  ///
  /// [type]은 뷰의 타입을 나타냅니다.
  /// [id]는 뷰의 고유 식별자입니다.
  /// [clickable]은 터치 이벤트 수신 여부입니다.
  /// [paddingLeft], [paddingTop], [paddingRight], [paddingBottom]은 패딩 값입니다.
  /// [verticalOrigin], [horizontalOrigin]은 원점 정렬 방식입니다.
  /// [verticalAlign], [horizontalAlign]은 뷰 정렬 방식입니다.
  /// [tag]는 추가 데이터를 저장할 수 있는 객체입니다.
  const GuiView({
    required this.type,
    this.id = '',
    this.clickable = true,
    this.paddingLeft = 0,
    this.paddingTop = 0,
    this.paddingRight = 0,
    this.paddingBottom = 0,
    this.verticalOrigin = Vertical.bottom,
    this.horizontalOrigin = Horizontal.center,
    this.verticalAlign = Vertical.center,
    this.horizontalAlign = Horizontal.center,
    this.tag,
  });

  /// 뷰의 타입
  final int type;

  /// 뷰의 고유 식별자
  final String id;

  /// 터치 이벤트 수신 여부
  final bool clickable;

  /// 왼쪽 패딩
  final int paddingLeft;

  /// 위쪽 패딩
  final int paddingTop;

  /// 오른쪽 패딩
  final int paddingRight;

  /// 아래쪽 패딩
  final int paddingBottom;

  /// 수직 원점 정렬
  final Vertical verticalOrigin;

  /// 수평 원점 정렬
  final Horizontal horizontalOrigin;

  /// 수직 뷰 정렬
  final Vertical verticalAlign;

  /// 수평 뷰 정렬
  final Horizontal horizontalAlign;

  /// 추가 데이터 저장 객체
  final Object? tag;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': type,
        'id': id,
        'clickable': clickable,
        'paddingLeft': paddingLeft,
        'paddingTop': paddingTop,
        'paddingRight': paddingRight,
        'paddingBottom': paddingBottom,
        'verticalOrigin': verticalOrigin.value,
        'horizontalOrigin': horizontalOrigin.value,
        'verticalAlign': verticalAlign.value,
        'horizontalAlign': horizontalAlign.value,
        'tag': tag,
      };
}
