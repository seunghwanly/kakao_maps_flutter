part of 'main.dart';

class KakaoMapExampleStaticMapScreen extends StatelessWidget {
  const KakaoMapExampleStaticMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Static Map'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: StaticKakaoMap(
              width: min(constraints.maxWidth, 300),
              height: min(constraints.maxHeight, 200),
              level: 3,
              center: const LatLng(
                latitude: 37.54699,
                longitude: 127.09598,
              ),
              marker: const LabelOption(
                id: 'marker',
                latLng: LatLng(
                  latitude: 37.54699,
                  longitude: 127.09598,
                ),
                base64EncodedImage: '',
              ),
              scaleRatio: MediaQuery.maybeDevicePixelRatioOf(context) ?? 1,
            ),
          );
        },
      ),
    );
  }
}
