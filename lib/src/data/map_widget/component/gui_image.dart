part of '../map_widget.dart';

/* 
//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.kakao.vectormap.mapwidget.component;

import android.graphics.Bitmap;

public class GuiImage extends GuiView {
    public int resourceId = 0;
    public Bitmap bitmap;
    public boolean isNinepatch = false;
    public String assetId = "";
    public GuiView child;
    public int left = 0;
    public int top = 0;
    public int right = 0;
    public int bottom = 0;

    public GuiImage(int resourceId, boolean isNinepatch) {
        this.type = isNinepatch ? 3 : 2;
        this.resourceId = resourceId;
        this.isNinepatch = isNinepatch;
    }

    public GuiImage(Bitmap bitmap) {
        this.type = 2;
        this.bitmap = bitmap;
    }

    public void setFixedArea(int left, int top, int right, int bottom) {
        this.left = left;
        this.top = top;
        this.right = right;
        this.bottom = bottom;
    }

    public void addChild(GuiView child) {
        this.child = child;
    }

    public GuiView getChild() {
        return this.child;
    }

    public int getResourceId() {
        return this.resourceId;
    }

    public boolean isNinepatch() {
        return this.isNinepatch;
    }

    public Bitmap getBitmap() {
        return this.bitmap;
    }
}
*/

/// GUI 이미지: 이미지를 표시하는 GUI 컴포넌트
///
/// 리소스 ID, Base64 인코딩된 이미지, Nine-patch 이미지, 자식 뷰 등을 지원합니다.
class GuiImage extends GuiView {
  /// 리소스 ID로 GUI 이미지를 생성합니다.
  ///
  /// [resourceId]는 Android 리소스 ID입니다.
  /// [isNinepatch]는 Nine-patch 이미지 여부입니다.
  /// [fixedArea]는 Nine-patch의 고정 영역을 설정합니다.
  /// [child]는 이미지 내부에 포함될 자식 뷰입니다.
  /// 나머지 매개변수는 부모 클래스 [GuiView]를 참조하세요.
  const GuiImage.fromResource({
    required this.resourceId,
    this.isNinepatch = false,
    this.base64EncodedImage,
    this.assetId,
    this.fixedArea = const GuiImageFixedArea(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
    ),
    this.child,
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
  }) : super(type: isNinepatch ? 3 : 2);

  /// Base64 인코딩된 이미지로 GUI 이미지를 생성합니다.
  ///
  /// [base64EncodedImage]는 Base64로 인코딩된 이미지 데이터입니다.
  /// [fixedArea]는 Nine-patch의 고정 영역을 설정합니다.
  /// [child]는 이미지 내부에 포함될 자식 뷰입니다.
  /// 나머지 매개변수는 부모 클래스 [GuiView]를 참조하세요.
  const GuiImage.fromBase64({
    required this.base64EncodedImage,
    this.resourceId = 0,
    this.isNinepatch = false,
    this.assetId = '',
    this.fixedArea = const GuiImageFixedArea(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
    ),
    this.child,
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
  }) : super(type: 2);

  /// Asset ID로 GUI 이미지를 생성합니다.
  ///
  /// [assetId]는 Flutter asset 경로입니다.
  /// [fixedArea]는 Nine-patch의 고정 영역을 설정합니다.
  /// [child]는 이미지 내부에 포함될 자식 뷰입니다.
  /// 나머지 매개변수는 부모 클래스 [GuiView]를 참조하세요.
  const GuiImage.fromAsset({
    required this.assetId,
    this.resourceId = 0,
    this.isNinepatch = false,
    this.base64EncodedImage,
    this.fixedArea = const GuiImageFixedArea(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
    ),
    this.child,
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
  }) : super(type: 2);

  /// Android 리소스 ID
  final int resourceId;

  /// Nine-patch 이미지 여부
  final bool isNinepatch;

  /// Base64로 인코딩된 이미지 데이터
  final String? base64EncodedImage;

  /// Flutter asset 경로
  final String? assetId;

  /// Nine-patch 이미지의 고정 영역
  final GuiImageFixedArea fixedArea;

  /// 이미지 내부에 포함될 자식 뷰
  final GuiView? child;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        ...super.toJson(),
        'resourceId': resourceId,
        'isNinepatch': isNinepatch,
        'base64EncodedImage': base64EncodedImage,
        'assetId': assetId,
        'fixedArea': fixedArea.toJson(),
        'child': child?.toJson(),
      };
}

/// GUI 이미지의 고정 영역을 나타내는 클래스
///
/// Nine-patch 이미지에서 늘어나지 않는 고정 영역을 설정합니다.
class GuiImageFixedArea extends Data {
  /// 고정 영역을 생성합니다.
  ///
  /// [left], [top], [right], [bottom]은 각각 왼쪽, 위쪽, 오른쪽, 아래쪽 고정 영역 크기입니다.
  const GuiImageFixedArea({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  /// 왼쪽 고정 영역 크기
  final int left;

  /// 위쪽 고정 영역 크기
  final int top;

  /// 오른쪽 고정 영역 크기
  final int right;

  /// 아래쪽 고정 영역 크기
  final int bottom;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'left': left,
        'top': top,
        'right': right,
        'bottom': bottom,
      };
}
