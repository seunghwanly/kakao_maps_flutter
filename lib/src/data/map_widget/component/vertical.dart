part of '../map_widget.dart';

/* 
package com.kakao.vectormap.mapwidget.component;

public enum Vertical {
    Top(0),
    Center(1),
    Bottom(2);

    private final int value;

    private Vertical(int value) {
        this.value = value;
    }

    public int getValue() {
        return this.value;
    }

    public static Vertical getEnum(int value) {
        switch (value) {
            case 0:
                return Top;
            case 1:
                return Center;
            case 2:
                return Bottom;
            default:
                return Center;
        }
    }
}

*/

/// GUI 뷰의 수직 정렬
enum Vertical {
  /// 상단
  top(value: 0),

  /// 중앙
  center(value: 1),

  /// 하단
  bottom(value: 2);

  const Vertical({
    required this.value,
  });

  /// 설정값
  final int value;

  /// 설정값[value] 에 따른 enum 반환
  static Vertical getEnum(int value) => switch (value) {
        0 => top,
        1 => center,
        2 => bottom,
        _ => center,
      };
}
