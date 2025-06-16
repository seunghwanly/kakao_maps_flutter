part of 'main.dart';

class KakaoMapExampleStaticMapScreen extends StatelessWidget {
  const KakaoMapExampleStaticMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Static Map'),
      ),
      body: const Center(
        child: StaticKakaoMap(
          width: 600,
          height: 600,
          level: 7,
          center: LatLng(
            latitude: 37.54699,
            longitude: 127.09598,
          ),
        ),
      ),
    );
  }
}
