import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';

void main() {
  const latLng = LatLng(latitude: 37.5, longitude: 127);

  group('InfoWindowOption.applyDpScale', () {
    test('기본 생성자는 플랫폼의 기존 동작을 유지한다', () {
      const option = InfoWindowOption(id: 'default', latLng: latLng);

      expect(option.applyDpScale, isNull);
      expect(option.toJson(), isNot(contains('applyDpScale')));
    });

    test('text 생성자는 dp scale 적용을 명시할 수 있다', () {
      const option = InfoWindowOption.text(
        id: 'text',
        latLng: latLng,
        title: 'InfoWindow',
        applyDpScale: true,
      );

      expect(option.applyDpScale, isTrue);
      expect(option.toJson()['applyDpScale'], isTrue);
    });

    test('custom 생성자는 기존 Web 스케일을 명시적으로 유지할 수 있다', () {
      const option = InfoWindowOption.custom(
        id: 'custom',
        latLng: latLng,
        body: GuiText(text: 'InfoWindow'),
        applyDpScale: false,
      );

      expect(option.applyDpScale, isFalse);
      expect(option.toJson()['applyDpScale'], isFalse);
    });
  });
}
