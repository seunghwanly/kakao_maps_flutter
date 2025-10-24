import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Orientation;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_maps_flutter/kakao_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'assets/example_assets.dart';
import 'screens/compass_scalebar_example.dart';
import 'screens/kakao_map_example_static_map_screen.dart';
import 'widgets/widgets.dart';

const String $title = 'KakaoMapsSDK v2 Flutter Demo';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

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
        '/compass_scalebar': (context) => const CompassScaleBarExampleScreen(),
      },
    );
  }
}

class KakaoMapExampleScreen extends StatefulWidget {
  const KakaoMapExampleScreen({super.key});

  @override
  State<KakaoMapExampleScreen> createState() => _KakaoMapExampleScreenState();
}

class _KakaoMapExampleScreenState extends State<KakaoMapExampleScreen> {
  KakaoMapController? mapController;

  StreamSubscription<LabelClickEvent>? labelClickSubscription;
  StreamSubscription<CameraMoveEndEvent>? cameraMoveEndSubscription;
  StreamSubscription<ClusterClickEvent>? clusterClickSubscription;

  final ValueNotifier<bool> mapReadyNotifier = ValueNotifier(false);

  int currentZoomLevel = 14;
  bool isPoisVisible = true;
  bool isPoisClickable = true;
  int poiScale = 1;
  bool isCameraMoveEndListenerEnabled = true;

  final List<MarkerStyle> markerStyles = [
    MarkerStyle(
      styleId: 'default_marker_style_001',
      perLevels: [
        MarkerPerLevelStyle.fromBytes(
          bytes: base64Decode(
            kIsWeb ? ExampleAssets.marker1x : ExampleAssets.marker2x,
          ),
          textStyle: const MarkerTextStyle(
            fontSize: 24,
            fontColorArgb: 0xFF000000,
            strokeThickness: 4,
            strokeColorArgb: 0xFFFFFFFF,
          ),
          level: 6,
        ),
        MarkerPerLevelStyle.fromBytes(
          bytes: base64Decode(
            kIsWeb ? ExampleAssets.marker1x : ExampleAssets.marker4x,
          ),
          textStyle: const MarkerTextStyle(
            fontSize: 20,
            fontColorArgb: 0xFF000000,
            strokeThickness: 4,
            strokeColorArgb: 0xFFFFFFFF,
          ),
          level: 21,
        ),
      ],
    ),
  ];

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
    cameraMoveEndSubscription?.cancel();
    clusterClickSubscription?.cancel();
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
        initialPosition: const LatLng(
          latitude: 37.5441,
          longitude: 127.0558,
        ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      drawer: ValueListenableBuilder<bool>(
        valueListenable: mapReadyNotifier,
        builder: (context, isReady, _) {
          final drawer = FeatureDrawer(
            isMapReady: isReady,
            onCameraMove: onCameraMove,
            onMarkerAdd: onMarkerAdd,
            onMarkerRemove: onMarkerRemove,
            onMarkersAdd: onMarkersAdd,
            onMarkersRemove: onMarkersRemove,
            onMarkersClear: onMarkersClear,
            onPoiVisibilityToggle:
                kIsWeb ? onUnsupported : onPoiVisibilityToggle,
            onPoiClickabilityToggle:
                kIsWeb ? onUnsupported : onPoiClickabilityToggle,
            onPoiScaleChange: kIsWeb ? onUnsupported : onPoiScaleChange,
            onCameraMoveEndListenerToggle: onCameraMoveEndListenerToggle,
            onCoordinateTest: kIsWeb ? onUnsupported : onCoordinateTest,
            onPaddingSet: kIsWeb ? onUnsupported : onPaddingSet,
            onMapInfoGet: onMapInfoGet,
            onViewportBoundsGet: onViewportBoundsGet,
            isPoisVisible: isPoisVisible,
            isPoisClickable: isPoisClickable,
            poiScale: poiScale,
            isCameraMoveEndListenerEnabled: isCameraMoveEndListenerEnabled,
            onInfoWindowAdd: onInfoWindowAdd,
            onInfoWindowRemove: onInfoWindowRemove,
            onInfoWindowsAddAll: onInfoWindowsAddAll,
            onInfoWindowsClear: onInfoWindowsClear,
            onInfoWindowLayerShow:
                kIsWeb ? onUnsupported : onInfoWindowLayerShow,
            onInfoWindowLayerHide:
                kIsWeb ? onUnsupported : onInfoWindowLayerHide,
            onShowSeoulInfoWindow: onShowSeoulInfoWindow,
            onHideSeoulInfoWindow: onHideSeoulInfoWindow,
            onStaticMapButtonPressed: onStaticMapButtonPressed,
            onGuiInfoWindowCustomBubble: onGuiInfoWindowCustomBubble,
            onGuiInfoWindowComplex: onGuiInfoWindowComplex,
            onGuiInfoWindowIconText: onGuiInfoWindowIconText,
            onGuiInfoWindowAndroidSDK: onGuiInfoWindowAndroidSDK,
            onGuiInfoWindowTimeBased: onGuiInfoWindowTimeBased,
            onLodCreateLayer: onLodCreateLayer,
            onLodAddMany: onLodAddMany,
            onLodShowAll: onLodShowAll,
            onLodHideAll: onLodHideAll,
            onLodClear: onLodClear,
          );

          if (kIsWeb) {
            return PointerInterceptor(child: drawer);
          }

          return drawer;
        },
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

    /// Listen to cluster click events
    clusterClickSubscription = controller.onClusterClickedStream.listen(
      onClusterClicked,
    );

    /// Listen to camera move end events only if enabled
    if (isCameraMoveEndListenerEnabled) {
      cameraMoveEndSubscription = controller.onCameraMoveEndStream.listen(
        onCameraMoveEnd,
      );
    }

    if (mounted) setState(() => mapReadyNotifier.value = true);

    controller.moveCamera(
      cameraUpdate: const CameraUpdate(position: jamsilStation, zoomLevel: 12),
    );
  }

  Future<void> setupInitialMap() async {
    if (!mapReadyNotifier.value || mapController == null) return;

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!kIsWeb) {
      /// Set initial POI scale for better marker visibility
      await mapController!.setPoiScale(scale: poiScale);
    }

    await mapController!.registerMarkerStyles(styles: markerStyles);

    // Create default LabelLayer for normal markers before using addMarker/addMarkers
    if (!kIsWeb) {
      await mapController!.addMarkerLayer(
        layerId: KakaoMapController.defaultLabelLayerId,
        zOrder: 1000,
        clickable: true,
      );
    }

    // Optionally prepare LOD layer immediately (iOS fully; Android zOrder only)
    await onLodCreateLayer();
  }

  Future<void> onZoomIn() async {
    if (mapController == null) return;

    final currentZoom = await mapController!.getZoomLevel();
    if (currentZoom == null || currentZoom >= 21) return;

    final newZoom = currentZoom + 1;
    await mapController!.setZoomLevel(zoomLevel: newZoom);
    if (mounted) {
      setState(() => currentZoomLevel = newZoom);
    }
  }

  Future<void> onZoomOut() async {
    if (mapController == null) return;

    final currentZoom = await mapController!.getZoomLevel();
    if (currentZoom == null || currentZoom <= 1) return;

    final newZoom = currentZoom - 1;
    await mapController!.setZoomLevel(zoomLevel: newZoom);
    if (mounted) {
      setState(() => currentZoomLevel = newZoom);
    }
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
      markerOption: MarkerOption(
        id: id,
        latLng: position,
        rank: 9999,
        styleId: 'default_marker_style_001',
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
      MarkerOption(
        id: 'seoul_station',
        latLng: seoulStation,
        styleId: 'default_marker_style_001',
        text: '여기는 서울역!',
      ),
      MarkerOption(
        id: 'jamsil_station',
        latLng: jamsilStation,
        styleId: 'default_marker_style_001',
      ),
      MarkerOption(
        id: 'gangnam_station',
        latLng: gangnamStation,
        styleId: 'default_marker_style_001',
      ),
    ];

    await mapController!.addMarkers(markerOptions: markers);
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

    if (mounted) {
      setState(() => isPoisVisible = newVisibility);
    }

    showSnackBar('👁️ POIs ${newVisibility ? 'shown' : 'hidden'}');
  }

  Future<void> onPoiClickabilityToggle() async {
    if (mapController == null) return;

    final newClickability = !isPoisClickable;
    await mapController!.setPoiClickable(isClickable: newClickability);

    if (mounted) {
      setState(() => isPoisClickable = newClickability);
    }

    showSnackBar('👆 POIs ${newClickability ? 'clickable' : 'non-clickable'}');
  }

  Future<void> onPoiScaleChange(int scale) async {
    if (mapController == null) return;

    await mapController!.setPoiScale(scale: scale);

    if (mounted) {
      setState(() => poiScale = scale);
    }

    const scaleNames = ['Small', 'Regular', 'Large', 'XLarge'];
    final scaleName = scale < scaleNames.length ? scaleNames[scale] : 'Unknown';
    showSnackBar('📏 POI scale: $scaleName');
  }

  Future<void> onCameraMoveEndListenerToggle() async {
    if (mapController == null) return;

    final newEnabled = !isCameraMoveEndListenerEnabled;

    if (newEnabled) {
      /// Enable the listener
      cameraMoveEndSubscription = mapController!.onCameraMoveEndStream.listen(
        onCameraMoveEnd,
      );
    } else {
      /// Disable the listener
      await cameraMoveEndSubscription?.cancel();
      cameraMoveEndSubscription = null;
    }

    if (mounted) {
      setState(() => isCameraMoveEndListenerEnabled = newEnabled);
    }

    showSnackBar(
      '📷 Camera move end listener ${newEnabled ? 'enabled' : 'disabled'}',
    );
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

  // ===== LOD marker demo =====
  static const String lodLayerId = 'demo_lod_layer';

  Future<void> onLodCreateLayer() async {
    if (mapController == null) return;

    if (kIsWeb) {
      return mapController!.addWebMarkerClusterer(
        clustererId: lodLayerId,
        gridSize: 40,
        minLevel: 1,
        clickable: true, // Make sure clusters are clickable
        disableClickZoom: true, // Disable default zoom to use custom one
        styles: [
          {
            'width': '30px',
            'height': '30px',
            'background': 'rgba(255, 82, 82, .8)',
            'border-radius': '15px',
            'color': '#fff',
            'text-align': 'center',
            'font-weight': 'bold',
            'line-height': '30px',
          },
          {
            'width': '40px',
            'height': '40px',
            'background': 'rgba(51, 153, 255, .8)',
            'border-radius': '20px',
            'color': '#fff',
            'text-align': 'center',
            'font-weight': 'bold',
            'line-height': '40px',
          },
          {
            'width': '50px',
            'height': '50px',
            'background': 'rgba(51, 204, 51, .8)',
            'border-radius': '25px',
            'color': '#fff',
            'text-align': 'center',
            'font-weight': 'bold',
            'line-height': '50px',
          },
        ],
      );
    }

    return mapController!.addLodMarkerLayer(
      options: const LodMarkerLayerOptions(
        layerId: lodLayerId,
        zOrder: 0,
        radius: 20,
      ),
    );
  }

  Future<void> onLodAddMany() async {
    if (mapController == null) return;
    // 1000 random around Jamsil
    const base = jamsilStation;
    final options = List<MarkerOption>.generate(1000, (i) {
      final dx = (i % 50) * 0.0002;
      final dy = (i ~/ 50) * 0.0002;
      return MarkerOption(
        id: 'lod_$i',
        latLng: LatLng(
          latitude: base.latitude + dy,
          longitude: base.longitude + dx,
        ),
        styleId: 'default_marker_style_001',
        rank: i + 1,
        text: 'L$i',
      );
    });
    await mapController!.addLodMarkers(options: options, layerId: lodLayerId);
    showSnackBar('⚡ Added 1000 LOD markers');
  }

  Future<void> onLodShowAll() async {
    if (mapController == null) return;
    await mapController!.showAllLodMarkers(layerId: lodLayerId);
    showSnackBar('👁️ Show all LOD markers');
  }

  Future<void> onLodHideAll() async {
    if (mapController == null) return;
    await mapController!.hideAllLodMarkers(layerId: lodLayerId);
    showSnackBar('🙈 Hide all LOD markers');
  }

  Future<void> onLodClear() async {
    if (mapController == null) return;
    await mapController!.clearAllLodMarkers(layerId: lodLayerId);
    showSnackBar('🧹 Cleared LOD markers');
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

  void onClusterClicked(ClusterClickEvent event) {
    // When a cluster is clicked, smoothly zoom to fit its bounds.
    mapController?.moveCamera(
      cameraUpdate: CameraUpdate.fromBounds(event.bounds),
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
        zOrder: id.contains('jamsil') ? 1000 : 0,
        body: id.contains('jamsil')
            ? const GuiImage.fromBase64(
                base64EncodedImage: kIsWeb
                    ? ExampleAssets.infoWindowBackgroundImage1x
                    : ExampleAssets.infoWindowBackgroundImage2x,
              )
            : null,
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

  // ===== New: InfoWindow visibility demo =====
  Future<void> onInfoWindowLayerShow() async {
    if (mapController == null) return;
    await mapController!.setInfoWindowLayerVisible(visible: true);
    showSnackBar('👁️ InfoWindow layer: visible');
  }

  Future<void> onInfoWindowLayerHide() async {
    if (mapController == null) return;
    await mapController!.setInfoWindowLayerVisible(visible: false);
    showSnackBar('🙈 InfoWindow layer: hidden');
  }

  Future<void> onShowSeoulInfoWindow() async {
    if (mapController == null) return;
    await mapController!.setInfoWindowVisible(id: 'seoul_info', visible: true);
    showSnackBar('👁️ Show "seoul_info"');
  }

  Future<void> onHideSeoulInfoWindow() async {
    if (mapController == null) return;
    await mapController!.setInfoWindowVisible(id: 'seoul_info', visible: false);
    showSnackBar('🙈 Hide "seoul_info"');
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
      base64EncodedImage: kIsWeb
          ? ExampleAssets.infoWindowBackgroundImage2x
          : ExampleAssets.infoWindowBackgroundImage4x,
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
      base64EncodedImage: kIsWeb
          ? ExampleAssets.infoWindowBackgroundImage2x
          : ExampleAssets.infoWindowBackgroundImage4x,
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
      base64EncodedImage:
          kIsWeb ? ExampleAssets.marker1x : ExampleAssets.marker2x,
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
      base64EncodedImage: kIsWeb
          ? ExampleAssets.infoWindowBackgroundImage2x
          : ExampleAssets.infoWindowBackgroundImage4x,
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

  void onCameraMoveEnd(CameraMoveEndEvent event) {
    showSnackBar(
      '📍 Camera moved to:\n'
      'Lat: ${event.latitude.toStringAsFixed(6)}\n'
      'Lng: ${event.longitude.toStringAsFixed(6)}\n'
      'Zoom: ${event.zoomLevel.toStringAsFixed(2)}\n'
      'Tilt: ${event.tilt.toStringAsFixed(2)}°\n'
      'Rotation: ${event.rotation.toStringAsFixed(2)}°',
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> onUnsupported([dynamic _]) async {
    showSnackBar(
      '⚠️ This feature is not supported on the current platform.',
      duration: const Duration(seconds: 3),
    );
  }
}
