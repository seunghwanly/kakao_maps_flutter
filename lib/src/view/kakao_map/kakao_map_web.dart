import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui show platformViewRegistry;

import 'package:flutter/widgets.dart';
import 'package:kakao_maps_flutter/src/controller/kakao_map_controller.dart';
import 'package:kakao_maps_flutter/src/data/lat_lng/lat_lng.dart';
import 'package:web/web.dart' as web;

import 'kakao_map_js_interop.dart';

/// Web-specific implementation for creating the Kakao Map view.
Widget buildWebView(
  int webViewId,
  void Function(KakaoMapController controller) onMapCreated,
  LatLng? initialPosition,
  int? initialLevel,
) {
  final viewId = 'kakao-map-$webViewId';

  // Register the view factory for this specific map instance
  ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
    final mapDiv = web.HTMLDivElement()
      ..id = 'map-container-$webViewId'
      ..style.width = '100%'
      ..style.height = '100%';

    // Initialize the map after a short delay to ensure the DOM is ready
    Future.microtask(() {
      _initializeWebMap(
        mapDiv,
        webViewId,
        onMapCreated,
        initialPosition,
        initialLevel,
      );
    });

    return mapDiv;
  });

  return HtmlElementView(viewType: viewId);
}

void _initializeWebMap(
  web.HTMLDivElement container,
  int webViewId,
  void Function(KakaoMapController controller) onMapCreated,
  LatLng? initialPosition,
  int? initialLevel,
) {
  // Use default position and level if not provided
  final position =
      initialPosition ?? const LatLng(latitude: 37.5441, longitude: 127.0558);
  final level = initialLevel ?? 14;

  // Use setTimeout to ensure DOM is fully mounted before initializing map
  web.window.setTimeout(
    (() {
      // Check if Kakao Maps SDK is loaded
      if (!isKakaoMapsLoaded()) {
        web.console.error('Kakao Maps SDK is not loaded'.toJS);
        return;
      }

      try {
        // Get kakao.maps namespace
        final k = kakao;
        if (k == null) {
          web.console.error('Kakao object not found'.toJS);
          return;
        }

        final maps = k['maps'] as JSObject?;
        if (maps == null) {
          web.console.error('Kakao Maps namespace not found'.toJS);
          return;
        }

        // Get constructors
        final latLngCtor = maps['LatLng'] as JSFunction?;
        final mapCtor = maps['Map'] as JSFunction?;

        if (latLngCtor == null || mapCtor == null) {
          web.console.error('Kakao Maps constructors not available'.toJS);
          return;
        }

        // Create LatLng
        final latLng = latLngCtor.callAsConstructor<JSObject>(
          position.latitude.toJS,
          position.longitude.toJS,
        );

        // Get projectionId
        final projectionId = maps['ProjectionId'] as JSObject?;

        // Create options
        final options = JSObject();
        options['center'] = latLng;
        options['level'] = level.toJS;
        if (projectionId != null) {
          options['projectionId'] = projectionId['NONE'];
        }

        // Create Map
        final map = mapCtor.callAsConstructor<JSObject>(
          container as JSAny,
          options,
        );

        // Store map instance for future reference
        _storeMapInstance(webViewId, map);

        web.console.log(
          'Kakao map initialized successfully for viewId: $webViewId'.toJS,
        );

        // Notify that the map is ready
        final controller = KakaoMapController(viewId: webViewId);
        onMapCreated(controller);
      } catch (e) {
        web.console.error('Failed to create Kakao map: $e'.toJS);
      }
    }).toJS,
    100.toJS, // Wait 100ms for DOM to be ready
  );
}

/// Store map instance in window object for future reference
void _storeMapInstance(int viewId, JSObject map) {
  final windowObj = web.window as JSObject;
  final kakaoMapsObj = windowObj['kakaoMaps'] as JSObject?;

  if (kakaoMapsObj == null) {
    final newMapsObj = JSObject();
    windowObj['kakaoMaps'] = newMapsObj;
    newMapsObj[viewId.toString()] = map as JSAny;
  } else {
    kakaoMapsObj[viewId.toString()] = map as JSAny;
  }
}
