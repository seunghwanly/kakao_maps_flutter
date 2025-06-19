part of 'main.dart';

class KakaoMapExampleScreen extends StatefulWidget {
  const KakaoMapExampleScreen({super.key});

  @override
  State<KakaoMapExampleScreen> createState() => _KakaoMapExampleScreenState();
}

class _KakaoMapExampleScreenState extends State<KakaoMapExampleScreen> {
  KakaoMapController? mapController;

  StreamSubscription<LabelClickEvent>? labelClickSubscription;

  final ValueNotifier<bool> mapReadyNotifier = ValueNotifier(false);

  int currentZoomLevel = 14;
  bool isPoisVisible = true;
  bool isPoisClickable = true;
  int poiScale = 1;

  /// 0: Small, 1: Regular, 2: Large, 3: XLarge

  /// Sample locations in Seoul
  static const LatLng seoulStation = LatLng(
    latitude: 37.555946,
    longitude: 126.972317,
  );
  static const LatLng jamsilStation = LatLng(
    latitude: 37.5132612,
    longitude: 127.1001336,
  );
  static const LatLng gangnamStation = LatLng(
    latitude: 37.4979,
    longitude: 127.0276,
  );

  @override
  void initState() {
    super.initState();

    mapReadyNotifier.addListener(setupInitialMap);
  }

  @override
  void dispose() {
    labelClickSubscription?.cancel();
    mapReadyNotifier.removeListener(setupInitialMap);
    mapReadyNotifier.dispose();
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text($title),
        backgroundColor: const Color(0xFFFEE500),
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(38),
          child: ValueListenableBuilder<bool>(
            valueListenable: mapReadyNotifier,
            builder: (context, isReady, _) => StatusBar(
              isMapReady: isReady,
              zoomLevel: currentZoomLevel,
              isPoisVisible: isPoisVisible,
              poiScale: poiScale,
            ),
          ),
        ),
      ),
      body: KakaoMap(
        onMapCreated: onMapCreated,
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: mapReadyNotifier,
        builder: (context, isReady, _) => ZoomControls(
          onZoomIn: onZoomIn,
          onZoomOut: onZoomOut,
          onGetCenter: onGetCenter,
          enabled: isReady,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      drawer: ValueListenableBuilder<bool>(
        valueListenable: mapReadyNotifier,
        builder: (context, isReady, _) => FeatureDrawer(
          isMapReady: isReady,
          onCameraMove: onCameraMove,
          onMarkerAdd: onMarkerAdd,
          onMarkerRemove: onMarkerRemove,
          onMarkersAdd: onMarkersAdd,
          onMarkersRemove: onMarkersRemove,
          onMarkersClear: onMarkersClear,
          onPoiVisibilityToggle: onPoiVisibilityToggle,
          onPoiClickabilityToggle: onPoiClickabilityToggle,
          onPoiScaleChange: onPoiScaleChange,
          onCoordinateTest: onCoordinateTest,
          onPaddingSet: onPaddingSet,
          onMapInfoGet: onMapInfoGet,
          onViewportBoundsGet: onViewportBoundsGet,
          isPoisVisible: isPoisVisible,
          isPoisClickable: isPoisClickable,
          poiScale: poiScale,
          onInfoWindowAdd: onInfoWindowAdd,
          onInfoWindowRemove: onInfoWindowRemove,
          onInfoWindowsAddAll: onInfoWindowsAddAll,
          onInfoWindowsClear: onInfoWindowsClear,
          onStaticMapButtonPressed: onStaticMapButtonPressed,
          onGuiInfoWindowCustomBubble: onGuiInfoWindowCustomBubble,
          onGuiInfoWindowComplex: onGuiInfoWindowComplex,
          onGuiInfoWindowIconText: onGuiInfoWindowIconText,
          onGuiInfoWindowAndroidSDK: onGuiInfoWindowAndroidSDK,
          onGuiInfoWindowTimeBased: onGuiInfoWindowTimeBased,
        ),
      ),
    );
  }

  void onMapCreated(KakaoMapController controller) {
    mapController = controller;

    labelClickSubscription = controller.onLabelClickedStream.listen(
      onLabelClicked,
    );

    /// Listen to InfoWindow click events
    controller.onInfoWindowClickedStream.listen(
      onInfoWindowClicked,
    );

    if (mounted) setState(() => mapReadyNotifier.value = true);
  }

  Future<void> setupInitialMap() async {
    if (!mapReadyNotifier.value || mapController == null) return;

    await Future.delayed(const Duration(milliseconds: 800));

    /// Set initial POI scale for better marker visibility
    await mapController!.setPoiScale(scale: poiScale);

    /// Move to Seoul Station with animation
    await mapController!.moveCamera(
      cameraUpdate: CameraUpdate.fromLatLng(seoulStation),
      animation: const CameraAnimation(
        duration: 1500,
        autoElevation: true,
        isConsecutive: false,
      ),
    );
  }

  Future<void> onZoomIn() async {
    if (mapController == null) return;

    final currentZoom = await mapController!.getZoomLevel();
    if (currentZoom == null || currentZoom >= 21) return;

    final newZoom = currentZoom + 1;
    await mapController!.setZoomLevel(zoomLevel: newZoom);
    if (!mounted) return;
    setState(() => currentZoomLevel = newZoom);
  }

  Future<void> onZoomOut() async {
    if (mapController == null) return;

    final currentZoom = await mapController!.getZoomLevel();
    if (currentZoom == null || currentZoom <= 1) return;

    final newZoom = currentZoom - 1;
    await mapController!.setZoomLevel(zoomLevel: newZoom);
    if (!mounted) return;
    setState(() => currentZoomLevel = newZoom);
  }

  Future<void> onGetCenter() async {
    if (mapController == null) return;

    final center = await mapController!.getCenter();
    if (center == null) return;

    showSnackBar(
      '📍 Center: ${center.latitude.toStringAsFixed(6)}, ${center.longitude.toStringAsFixed(6)}',
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> onCameraMove(LatLng target, {bool animated = true}) async {
    if (mapController == null) return;

    if (!animated) {
      await mapController!.moveCamera(
        cameraUpdate: CameraUpdate.fromLatLng(target),
      );
      return;
    }

    await mapController!.moveCamera(
      cameraUpdate: CameraUpdate.fromLatLng(target),
      animation: const CameraAnimation(
        duration: 1000,
        autoElevation: true,
        isConsecutive: false,
      ),
    );
  }

  Future<void> onMarkerAdd(String id, LatLng position) async {
    if (mapController == null) return;

    await mapController!.addMarker(
      labelOption: LabelOption(
        id: id,
        latLng: position,
        base64EncodedImage: ExampleAssets.marker2x,
      ),
    );
    showSnackBar('📌 Marker "$id" added');
  }

  Future<void> onMarkerRemove(String id) async {
    if (mapController == null) return;

    await mapController!.removeMarker(id: id);
    showSnackBar('🗑️ Marker "$id" removed');
  }

  Future<void> onMarkersAdd() async {
    if (mapController == null) return;

    const markers = [
      LabelOption(
        id: 'seoul_station',
        latLng: seoulStation,
        base64EncodedImage: ExampleAssets.marker2x,
      ),
      LabelOption(
        id: 'jamsil_station',
        latLng: jamsilStation,
        base64EncodedImage: ExampleAssets.marker2x,
      ),
      LabelOption(
        id: 'gangnam_station',
        latLng: gangnamStation,
        base64EncodedImage: ExampleAssets.marker2x,
      ),
    ];

    await mapController!.addMarkers(labelOptions: markers);
    showSnackBar('📌 Added 3 station markers');
  }

  Future<void> onMarkersRemove() async {
    if (mapController == null) return;

    const ids = ['seoul_station', 'jamsil_station', 'gangnam_station'];
    await mapController!.removeMarkers(ids: ids);
    showSnackBar('🗑️ Removed station markers');
  }

  Future<void> onMarkersClear() async {
    if (mapController == null) return;

    await mapController!.clearMarkers();
    showSnackBar('🧹 All markers cleared');
  }

  Future<void> onPoiVisibilityToggle() async {
    if (mapController == null) return;

    final newVisibility = !isPoisVisible;
    await mapController!.setPoiVisible(isVisible: newVisibility);

    if (!mounted) return;
    setState(() => isPoisVisible = newVisibility);

    showSnackBar('👁️ POIs ${newVisibility ? 'shown' : 'hidden'}');
  }

  Future<void> onPoiClickabilityToggle() async {
    if (mapController == null) return;

    final newClickability = !isPoisClickable;
    await mapController!.setPoiClickable(isClickable: newClickability);

    if (!mounted) return;
    setState(() => isPoisClickable = newClickability);

    showSnackBar('👆 POIs ${newClickability ? 'clickable' : 'non-clickable'}');
  }

  Future<void> onPoiScaleChange(int scale) async {
    if (mapController == null) return;

    await mapController!.setPoiScale(scale: scale);

    if (!mounted) return;
    setState(() => poiScale = scale);

    const scaleNames = ['Small', 'Regular', 'Large', 'XLarge'];
    final scaleName = scale < scaleNames.length ? scaleNames[scale] : 'Unknown';
    showSnackBar('📏 POI scale: $scaleName');
  }

  Future<void> onCoordinateTest() async {
    if (mapController == null) return;

    try {
      const testPosition = seoulStation;

      final screenPoint = await mapController!.toScreenPoint(
        position: testPosition,
      );

      if (screenPoint == null) {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          return showSnackBar(
            '⚠️ Screen coordinate conversion not supported on iOS.\n'
            'This feature only works on Android.',
            duration: const Duration(seconds: 3),
          );
        }

        return showSnackBar(
          '❌ Screen coordinate conversion failed.\n'
          'The position might be outside the visible area.',
          duration: const Duration(seconds: 3),
        );
      }

      // Convert back to map coordinates
      final mapPoint = await mapController!.fromScreenPoint(point: screenPoint);

      showSnackBar(
        '🔄 Coordinate test success:\n'
        'Original: ${testPosition.latitude.toStringAsFixed(6)}, ${testPosition.longitude.toStringAsFixed(6)}\n'
        'Screen: (${screenPoint.dx.toStringAsFixed(1)}, ${screenPoint.dy.toStringAsFixed(1)})\n'
        'Converted back: ${mapPoint?.latitude.toStringAsFixed(6)}, ${mapPoint?.longitude.toStringAsFixed(6)}',
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      showSnackBar(
        '❌ Coordinate test failed: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> onPaddingSet() async {
    if (mapController == null) return;

    await mapController!.setPadding(
      left: 20,
      top: 80,
      right: 20,
      bottom: 20,
    );

    showSnackBar('📐 Map padding applied');
  }

  Future<void> onMapInfoGet() async {
    if (mapController == null) return;

    final mapInfo = await mapController!.getMapInfo();
    if (mapInfo == null) return;

    showSnackBar(
      'ℹ️ Map Info:\n'
      'Zoom: ${mapInfo.zoomLevel}\n'
      'Rotation: ${mapInfo.rotation.toStringAsFixed(2)}°\n'
      'Tilt: ${mapInfo.tilt.toStringAsFixed(2)}°',
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> onViewportBoundsGet() async {
    if (mapController == null) return;

    final bounds = await mapController!.getViewportBounds();
    if (bounds == null) return;

    showSnackBar(
      '🗺️ Viewport Bounds:\n'
      'SW: ${bounds.southwest.latitude.toStringAsFixed(4)}, ${bounds.southwest.longitude.toStringAsFixed(4)}\n'
      'NE: ${bounds.northeast.latitude.toStringAsFixed(4)}, ${bounds.northeast.longitude.toStringAsFixed(4)}',
      duration: const Duration(seconds: 4),
    );
  }

  void showSnackBar(String message, {Duration? duration}) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  void onLabelClicked(LabelClickEvent event) {
    showSnackBar(
      '📍 Label clicked: ${event.labelId}',
      duration: const Duration(seconds: 3),
    );
  }

  /// InfoWindow management methods
  Future<void> onInfoWindowAdd(
    String id,
    LatLng position,
    String title, {
    String? snippet,
  }) async {
    if (mapController == null) return;

    await mapController!.addInfoWindow(
      infoWindowOption: InfoWindowOption(
        id: id,
        latLng: position,
        title: title,
        snippet: snippet,
        offset: const InfoWindowOffset(x: 0, y: -20),
      ),
    );
    showSnackBar('💬 InfoWindow "$id" added');
  }

  Future<void> onInfoWindowRemove(String id) async {
    if (mapController == null) return;

    await mapController!.removeInfoWindow(id: id);
    showSnackBar('❌ InfoWindow "$id" removed');
  }

  Future<void> onInfoWindowsClear() async {
    if (mapController == null) return;

    await mapController!.clearInfoWindows();
    showSnackBar('🧹 All InfoWindows cleared');
  }

  Future<void> onInfoWindowsAddAll() async {
    if (mapController == null) return;

    final infoWindows = [
      const InfoWindowOption(
        id: 'seoul_info',
        latLng: seoulStation,
        title: 'Seoul Station',
        snippet: 'Main railway station in Seoul',
        offset: InfoWindowOffset(x: 0, y: -20),
      ),
      const InfoWindowOption(
        id: 'jamsil_info',
        latLng: jamsilStation,
        title: 'Jamsil Station',
        snippet: 'Sports complex and shopping area',
        offset: InfoWindowOffset(x: 0, y: -20),
      ),
      const InfoWindowOption(
        id: 'gangnam_info',
        latLng: gangnamStation,
        title: 'Gangnam Station',
        snippet: 'Business district center',
        offset: InfoWindowOffset(x: 0, y: -20),
      ),
    ];

    await mapController!.addInfoWindows(infoWindowOptions: infoWindows);
    showSnackBar('💬 Added 3 station InfoWindows');
  }

  void onInfoWindowClicked(InfoWindowClickEvent event) {
    showSnackBar(
      '💬 InfoWindow clicked: ${event.infoWindowId}\n'
      'Position: ${event.latLng.latitude.toStringAsFixed(6)}, ${event.latLng.longitude.toStringAsFixed(6)}',
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> onStaticMapButtonPressed() async {
    if (!mounted) return;

    await Navigator.of(context).pushNamed('/static/map_1');
  }

  /// GUI InfoWindow methods
  Future<void> onGuiInfoWindowCustomBubble() async {
    if (mapController == null) return;

    // Create background with nine-patch (Android SDK style)
    const bgImage = GuiImage.fromBase64(
      base64EncodedImage: ExampleAssets.infoWindowBackgroundImage4x,
      isNinepatch: true,
      fixedArea: GuiImageFixedArea(
        left: 14, // 7 * 2 for 4x scale
        top: 14,
        right: 14,
        bottom: 14,
      ),
    );

    // Create text component
    const textComponent = GuiText(
      text: 'Custom GUI InfoWindow!',
      textSize: 30,
      strokeSize: 1,
      strokeColor: 0xFFFFFFFF,
    );

    // Create layout (equivalent to Android's GuiLayout)
    const body = GuiLayout(
      orientation: Orientation.horizontal,
      children: [textComponent],
      background: bgImage,
      paddingLeft: 20,
      paddingTop: 20,
      paddingRight: 20,
      paddingBottom: 18,
    );

    // Create InfoWindow with GUI body
    const infoWindow = InfoWindowOption.custom(
      id: 'gui_custom_bubble',
      latLng: seoulStation,
      body: body,
      bodyOffset: InfoWindowOffset(x: 0, y: -4),
    );

    await mapController!.addInfoWindow(infoWindowOption: infoWindow);
    showSnackBar('✨ GUI Custom Bubble InfoWindow added');
  }

  Future<void> onGuiInfoWindowComplex() async {
    if (mapController == null) return;

    // Create multiple text components
    const titleText = GuiText(
      text: 'Jamsil Station',
      textSize: 28,
      textColor: 0xFF1a1a1a,
      strokeSize: 1,
      strokeColor: 0xFFFFFFFF,
    );

    const subtitleText = GuiText(
      text: 'Sports & Shopping Complex',
      textSize: 18,
      textColor: 0xFF555555,
    );

    const descriptionText = GuiText(
      text: 'Home to Lotte World Tower\nand Olympic Sports Complex',
      textColor: 0xFF777777,
    );

    // Create vertical layout for stacked text
    const textLayout = GuiLayout(
      orientation: Orientation.vertical,
      children: [titleText, subtitleText, descriptionText],
      paddingLeft: 16,
      paddingTop: 12,
      paddingRight: 16,
      paddingBottom: 12,
    );

    // Background with nine-patch scaling
    const backgroundImage = GuiImage.fromBase64(
      base64EncodedImage: ExampleAssets.infoWindowBackgroundImage4x,
      isNinepatch: true,
      fixedArea: GuiImageFixedArea(left: 14, top: 14, right: 14, bottom: 14),
    );

    // Main container
    const body = GuiLayout(
      orientation: Orientation.horizontal,
      children: [textLayout],
      background: backgroundImage,
      paddingLeft: 8,
      paddingTop: 8,
      paddingRight: 8,
      paddingBottom: 8,
    );

    const infoWindow = InfoWindowOption.custom(
      id: 'gui_complex_info',
      latLng: jamsilStation,
      body: body,
      bodyOffset: InfoWindowOffset(x: 0, y: -6),
    );

    await mapController!.addInfoWindow(infoWindowOption: infoWindow);
    showSnackBar('🏢 GUI Complex InfoWindow added');
  }

  Future<void> onGuiInfoWindowIconText() async {
    if (mapController == null) return;

    // Create icon from base64 data
    const icon = GuiImage.fromBase64(
      base64EncodedImage: ExampleAssets.marker2x,
    );

    // Create text component
    const textComponent = GuiText(
      text: 'Gangnam Station',
      textSize: 20,
      strokeSize: 1,
      strokeColor: 0xFFFFFFFF,
    );

    // Use 2x image for smaller InfoWindow
    const backgroundImage = GuiImage.fromBase64(
      base64EncodedImage: ExampleAssets.infoWindowBackgroundImage2x,
      isNinepatch: true,
      fixedArea: GuiImageFixedArea(left: 7, top: 7, right: 7, bottom: 7),
    );

    // Horizontal layout with icon and text
    const body = GuiLayout(
      orientation: Orientation.horizontal,
      children: [icon, textComponent],
      background: backgroundImage,
      paddingLeft: 12,
      paddingTop: 8,
      paddingRight: 12,
      paddingBottom: 8,
    );

    const infoWindow = InfoWindowOption.custom(
      id: 'gui_icon_text',
      latLng: gangnamStation,
      body: body,
    );

    await mapController!.addInfoWindow(infoWindowOption: infoWindow);
    showSnackBar('🚇 GUI Icon + Text InfoWindow added');
  }

  Future<void> onGuiInfoWindowAndroidSDK() async {
    if (mapController == null) return;

    // Android SDK exact recreation:
    // GuiLayout body = new GuiLayout(Orientation.Horizontal);
    // body.setPadding(20, 20, 20, 18);
    // GuiImage bgImage = new GuiImage(R.drawable.window_body, true);
    // image.setFixedArea(7, 7, 7, 7);
    // body.setBackground(bgImage);
    // GuiText text = new GuiText("InfoWindow!");
    // text.setTextSize(30);
    // body.addView(text);

    const text = GuiText(text: 'Android SDK Style!', textSize: 30);

    const bgImage = GuiImage.fromBase64(
      base64EncodedImage: ExampleAssets.infoWindowBackgroundImage2x,
      isNinepatch: true,
      fixedArea: GuiImageFixedArea(left: 7, top: 7, right: 7, bottom: 7),
    );

    const body = GuiLayout(
      orientation: Orientation.horizontal,
      children: [text],
      background: bgImage,
      paddingLeft: 20,
      paddingTop: 20,
      paddingRight: 20,
      paddingBottom: 18,
    );

    // Show at a slightly different position to differentiate
    const position = LatLng(latitude: 37.565, longitude: 126.975);

    const infoWindow = InfoWindowOption.custom(
      id: 'gui_android_sdk_equivalent',
      latLng: position,
      body: body,
      bodyOffset: InfoWindowOffset(x: 0, y: -4),
    );

    await mapController!.addInfoWindow(infoWindowOption: infoWindow);
    showSnackBar('🤖 Android SDK Style InfoWindow added');
  }

  Future<void> onGuiInfoWindowTimeBased() async {
    if (mapController == null) return;

    final isEvening = DateTime.now().hour >= 18;
    final message = isEvening ? 'Good Evening! 🌆' : 'Good Day! ☀️';
    final textColor = isEvening ? 0xFF4A90E2 : 0xFFFF9500;

    final textComponent = GuiText(
      text: message,
      textSize: 24,
      textColor: textColor,
      strokeSize: 1,
      strokeColor: 0xFFFFFFFF,
    );

    const bgImage = GuiImage.fromBase64(
      base64EncodedImage: ExampleAssets.infoWindowBackgroundImage4x,
      isNinepatch: true,
      fixedArea: GuiImageFixedArea(left: 14, top: 14, right: 14, bottom: 14),
    );

    final body = GuiLayout(
      orientation: Orientation.horizontal,
      children: [textComponent],
      background: bgImage,
      paddingLeft: 16,
      paddingTop: 12,
      paddingRight: 16,
      paddingBottom: 12,
    );

    // Show at a position near the center
    const position = LatLng(latitude: 37.57, longitude: 126.98);

    final infoWindow = InfoWindowOption.custom(
      id: 'gui_time_based',
      latLng: position,
      body: body,
    );

    await mapController!.addInfoWindow(infoWindowOption: infoWindow);

    final timeOfDay = isEvening ? 'evening' : 'day';
    showSnackBar('⏰ Time-based InfoWindow added ($timeOfDay theme)');
  }
}
