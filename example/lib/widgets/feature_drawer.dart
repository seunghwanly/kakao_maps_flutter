part of 'widgets.dart';

/// Feature drawer widget for Kakao Maps example
class FeatureDrawer extends StatelessWidget {
  const FeatureDrawer({
    required this.isMapReady,
    required this.onCameraMove,
    required this.onMarkerAdd,
    required this.onMarkerRemove,
    required this.onMarkersAdd,
    required this.onMarkersRemove,
    required this.onMarkersClear,
    required this.onPoiVisibilityToggle,
    required this.onPoiClickabilityToggle,
    required this.onPoiScaleChange,
    required this.onCoordinateTest,
    required this.onPaddingSet,
    required this.onMapInfoGet,
    required this.onViewportBoundsGet,
    required this.isPoisVisible,
    required this.isPoisClickable,
    required this.poiScale,
    super.key,
  });

  final bool isMapReady;
  final Future<void> Function(LatLng, {bool animated}) onCameraMove;
  final Future<void> Function(String, LatLng) onMarkerAdd;
  final Future<void> Function(String) onMarkerRemove;
  final VoidCallback onMarkersAdd;
  final VoidCallback onMarkersRemove;
  final VoidCallback onMarkersClear;
  final VoidCallback onPoiVisibilityToggle;
  final VoidCallback onPoiClickabilityToggle;
  final Future<void> Function(int) onPoiScaleChange;
  final VoidCallback onCoordinateTest;
  final VoidCallback onPaddingSet;
  final VoidCallback onMapInfoGet;
  final VoidCallback onViewportBoundsGet;
  final bool isPoisVisible;
  final bool isPoisClickable;
  final int poiScale;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const KakaoDrawerHeader(),

          /// Camera Movement Section
          KakaoDrawerSection(
            title: '🎥 Camera Movement',
            children: [
              KakaoDrawerTile(
                title: 'Move to Seoul Station',
                enabled: isMapReady,
                onTap: () => moveToAndPop(
                  context,
                  const LatLng(latitude: 37.555946, longitude: 126.972317),
                ),
              ),
              KakaoDrawerTile(
                title: 'Move to Jamsil Station',
                enabled: isMapReady,
                onTap: () => moveToAndPop(
                  context,
                  const LatLng(latitude: 37.5132612, longitude: 127.1001336),
                ),
              ),
              KakaoDrawerTile(
                title: 'Move to Gangnam Station',
                enabled: isMapReady,
                onTap: () => moveToAndPop(
                  context,
                  const LatLng(latitude: 37.4979, longitude: 127.0276),
                ),
              ),
            ],
          ),

          /// Marker Management Section
          KakaoDrawerSection(
            title: '📌 Marker Management',
            children: [
              KakaoDrawerTile(
                title: 'Add Jamsil Marker',
                enabled: isMapReady,
                onTap: () {
                  onMarkerAdd(
                    'jamsil_marker',
                    const LatLng(latitude: 37.5132612, longitude: 127.1001336),
                  );
                  Navigator.of(context).pop();
                },
              ),
              KakaoDrawerTile(
                title: 'Remove Jamsil Marker',
                enabled: isMapReady,
                onTap: () {
                  onMarkerRemove('jamsil_marker');
                  Navigator.of(context).pop();
                },
              ),
              KakaoDrawerTile(
                title: 'Add All Station Markers',
                enabled: isMapReady,
                onTap: () {
                  onMarkersAdd();
                  Navigator.of(context).pop();
                },
              ),
              KakaoDrawerTile(
                title: 'Remove Station Markers',
                enabled: isMapReady,
                onTap: () {
                  onMarkersRemove();
                  Navigator.of(context).pop();
                },
              ),
              KakaoDrawerTile(
                title: 'Clear All Markers',
                enabled: isMapReady,
                onTap: () {
                  onMarkersClear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),

          /// POI Controls Section
          KakaoDrawerSection(
            title: '🏢 POI Controls',
            children: [
              KakaoDrawerTile(
                title: 'Toggle POI Visibility',
                subtitle:
                    isPoisVisible ? 'Currently: Visible' : 'Currently: Hidden',
                enabled: isMapReady,
                onTap: () {
                  onPoiVisibilityToggle();
                  Navigator.of(context).pop();
                },
              ),
              KakaoDrawerTile(
                title: 'Toggle POI Clickable',
                subtitle: isPoisClickable
                    ? 'Currently: Clickable'
                    : 'Currently: Non-clickable',
                enabled: isMapReady,
                onTap: () {
                  onPoiClickabilityToggle();
                  Navigator.of(context).pop();
                },
              ),
              KakaoDrawerTile(
                title: 'POI Scale: Small',
                enabled: isMapReady,
                onTap: () {
                  onPoiScaleChange(0);
                  Navigator.of(context).pop();
                },
              ),
              KakaoDrawerTile(
                title: 'POI Scale: Regular',
                enabled: isMapReady,
                onTap: () {
                  onPoiScaleChange(1);
                  Navigator.of(context).pop();
                },
              ),
              KakaoDrawerTile(
                title: 'POI Scale: Large',
                enabled: isMapReady,
                onTap: () {
                  onPoiScaleChange(2);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),

          /// Advanced Features Section
          KakaoDrawerSection(
            title: '⚙️ Advanced Features',
            children: [
              KakaoDrawerTile(
                title: 'Test Coordinate Conversion',
                enabled: isMapReady,
                onTap: () {
                  onCoordinateTest();
                  Navigator.of(context).pop();
                },
              ),
              KakaoDrawerTile(
                title: 'Set Map Padding',
                enabled: isMapReady,
                onTap: () {
                  onPaddingSet();
                  Navigator.of(context).pop();
                },
              ),
              KakaoDrawerTile(
                title: 'Get Map Info',
                enabled: isMapReady,
                onTap: () {
                  onMapInfoGet();
                  Navigator.of(context).pop();
                },
              ),
              KakaoDrawerTile(
                title: 'Get Viewport Bounds',
                enabled: isMapReady,
                onTap: () {
                  onViewportBoundsGet();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void moveToAndPop(BuildContext context, LatLng target) {
    onCameraMove(target);
    Navigator.of(context).pop();
  }
}
