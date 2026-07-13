import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_maps_flutter/src/controller/web/web_gui_scale.dart';

void main() {
  group('scaleWebGuiValue', () {
    test('dp scale을 적용하면 CSS 논리 픽셀 값을 유지한다', () {
      for (final devicePixelRatio in [1.0, 2.0, 3.0]) {
        expect(
          scaleWebGuiValue(
            24,
            applyDpScale: true,
            devicePixelRatio: devicePixelRatio,
          ),
          24,
        );
      }
    });

    test('dp scale을 생략하거나 끄면 기존 DPR 나눗셈을 유지한다', () {
      expect(scaleWebGuiValue(24, applyDpScale: null, devicePixelRatio: 2), 12);
      expect(
        scaleWebGuiValue(24, applyDpScale: false, devicePixelRatio: 2),
        12,
      );
      expect(scaleWebGuiValue(24, applyDpScale: false, devicePixelRatio: 3), 8);
    });

    test('유효하지 않은 DPR에서는 원본 값을 유지한다', () {
      for (final devicePixelRatio in [0.0, -1.0, double.nan, double.infinity]) {
        expect(
          scaleWebGuiValue(
            24,
            applyDpScale: false,
            devicePixelRatio: devicePixelRatio,
          ),
          24,
        );
      }
    });
  });
}
