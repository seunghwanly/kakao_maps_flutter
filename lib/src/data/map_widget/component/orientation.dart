part of '../map_widget.dart';

/* 

//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.kakao.vectormap.mapwidget.component;

public enum Orientation {
    Horizontal(0),
    Vertical(1);

    private final int value;

    private Orientation(int value) {
        this.value = value;
    }

    public int getValue() {
        return this.value;
    }

    public static Orientation getEnum(int value) {
        switch (value) {
            case 0:
                return Horizontal;
            case 1:
                return Vertical;
            default:
                return Horizontal;
        }
    }
}
*/

/// GUI 뷰의 방향
enum Orientation {
  /// 수평
  horizontal(value: 0),

  /// 수직
  vertical(value: 1);

  const Orientation({
    required this.value,
  });

  /// 설정값
  final int value;

  /// 설정값[value] 에 따른 enum 반환
  static Orientation getEnum(int value) => switch (value) {
        0 => horizontal,
        1 => vertical,
        _ => horizontal,
      };
}
