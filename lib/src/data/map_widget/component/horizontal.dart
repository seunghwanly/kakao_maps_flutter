part of '../map_widget.dart';

/* 
//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.kakao.vectormap.mapwidget.component;

public enum Horizontal {
    Left(0),
    Center(1),
    Right(2);

    private final int value;

    private Horizontal(int value) {
        this.value = value;
    }

    public int getValue() {
        return this.value;
    }

    public static Horizontal getEnum(int value) {
        switch (value) {
            case 0:
                return Left;
            case 1:
                return Center;
            case 2:
                return Right;
            default:
                return Center;
        }
    }
}

*/

/// GUI 뷰의 수평 정렬
enum Horizontal {
  /// 왼쪽
  left(value: 0),

  /// 중앙
  center(value: 1),

  /// 오른쪽
  right(value: 2);

  const Horizontal({
    required this.value,
  });

  /// 설정값
  final int value;

  /// 설정값[value] 에 따른 enum 반환
  static Horizontal getEnum(int value) => switch (value) {
        0 => left,
        1 => center,
        2 => right,
        _ => center,
      };
}
