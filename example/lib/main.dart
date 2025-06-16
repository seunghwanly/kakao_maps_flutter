import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';

import 'assets/example_assets.dart';
import 'widgets/widgets.dart';

part 'kakao_map_example_screen.dart';
part 'kakao_map_example_static_map_screen.dart';

const String $title = 'KakaoMapsSDK v2 Flutter Demo';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  /// TODO: Replace with your own API key
  await KakaoMapsFlutter.init(
    dotenv.get('KAKAO_API_KEY'),
    webAPIKey: dotenv.maybeGet('KAKAO_WEB_API_KEY'),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: $title,
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        useMaterial3: true,
      ),
      home: const KakaoMapExampleScreen(),
      routes: {
        '/static/map_1': (context) => const KakaoMapExampleStaticMapScreen(),
      },
    );
  }
}
