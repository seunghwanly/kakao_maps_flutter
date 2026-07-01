// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:kakao_maps_flutter_example/main.dart';

void main() {
  testWidgets('renders demo shell', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the current demo shell is rendered.
    expect(find.text('KakaoMapsSDK v2 Flutter Demo'), findsOneWidget);
  });
}
