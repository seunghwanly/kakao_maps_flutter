part of '../kakao_map_controller.dart';

/// Web implementation of KakaoMapController
/// Uses JS interop to call Kakao Maps Web API directly
/// Web API Documentation: https://apis.map.kakao.com/web/documentation/
class WebKakaoMapController extends KakaoMapControllerPlatform {
  WebKakaoMapController._(this.viewId);

  factory WebKakaoMapController.create(int viewId) {
    return _instances.putIfAbsent(
      viewId,
      () => WebKakaoMapController._(viewId),
    );
  }

  static final Map<int, WebKakaoMapController> _instances = {};

  final int viewId;

  bool _areListenersAdded = false;

  /// Storage for markers by ID
  final Map<String, JSObject> _markers = {};

  /// Storage for info windows (custom overlays) by ID
  final Map<String, JSObject> _infoWindows = {};

  /// Storage for registered marker styles
  /// Map<styleId, {imageUrl, width, height}>
  final Map<String, Map<String, dynamic>> _markerStyles = {};

  /// Storage for LOD marker clusterers by layerId
  /// Map<layerId, MarkerClusterer>
  final Map<String, JSObject> _lodClusterers = {};

  /// Storage for LOD markers by layerId
  /// Map<layerId, Map<markerId, Marker>>
  final Map<String, Map<String, JSObject>> _lodMarkers = {};

  /// Get the kakao.maps namespace
  JSObject? get _kakaoMaps {
    final k = kakao;
    if (k == null) return null;
    return k['maps'] as JSObject?;
  }

  /// Get the JS map instance for this viewId
  JSObject? get _mapInstance {
    final windowObj = web.window as JSObject;
    final kakaoMapsObj = windowObj['kakaoMaps'] as JSObject?;
    if (kakaoMapsObj == null) return null;
    return kakaoMapsObj[viewId.toString()] as JSObject?;
  }

  /// Create a LatLng object
  JSObject? _createLatLng(double latitude, double longitude) {
    final maps = _kakaoMaps;
    if (maps == null) return null;

    final latLngCtor = maps['LatLng'] as JSFunction?;
    if (latLngCtor == null) return null;

    return latLngCtor.callAsConstructor<JSObject>(
      latitude.toJS,
      longitude.toJS,
    );
  }

  /// Extract latitude from LatLng object
  double? _getLatitude(JSObject latLng) {
    try {
      final getLat = latLng['getLat'] as JSFunction?;
      if (getLat == null) return null;
      final result = getLat.callAsFunction(latLng);
      return (result as JSNumber?)?.toDartDouble;
    } catch (e) {
      return null;
    }
  }

  /// Extract longitude from LatLng object
  double? _getLongitude(JSObject latLng) {
    try {
      final getLng = latLng['getLng'] as JSFunction?;
      if (getLng == null) return null;
      final result = getLng.callAsFunction(latLng);
      return (result as JSNumber?)?.toDartDouble;
    } catch (e) {
      return null;
    }
  }

  /// Call a method on a map instance
  JSAny? _callMapMethod(
    JSObject obj,
    String methodName, [
    List<JSAny?>? args,
  ]) {
    try {
      final method = obj[methodName] as JSFunction?;
      if (method == null) {
        web.console.warn('Method $methodName not found on object'.toJS);
        web.console.log('Available methods: ${obj.toString()}'.toJS);
        return null;
      }

      web.console.log(
        'Calling $methodName with ${args?.length ?? 0} arguments'.toJS,
      );

      if (args == null || args.isEmpty) {
        return method.callAsFunction(obj);
      }

      // Call with arguments - obj is 'this', followed by actual arguments
      // callAsFunction signature: callAsFunction(thisArg, ...args)
      switch (args.length) {
        case 1:
          return method.callAsFunction(obj, args[0]);
        case 2:
          return method.callAsFunction(obj, args[0], args[1]);
        case 3:
          return method.callAsFunction(obj, args[0], args[1], args[2]);
        case 4:
          return method.callAsFunction(obj, args[0], args[1], args[2], args[3]);
        default:
          web.console.warn(
            'Too many arguments (${args.length}) for $methodName'.toJS,
          );
          return method.callAsFunction(
            obj,
            args[0],
            args[1],
            args[2],
            args[3],
          );
      }
    } catch (e) {
      web.console.error('Error calling $methodName: $e'.toJS);
      return null;
    }
  }

  /// Set map center
  void _setMapCenter(JSObject map, double latitude, double longitude) {
    final latLng = _createLatLng(latitude, longitude);
    if (latLng == null) return;
    _callMapMethod(map, 'setCenter', [latLng]);
  }

  /// Get map center
  JSObject? _getMapCenter(JSObject map) {
    final result = _callMapMethod(map, 'getCenter');
    return result as JSObject?;
  }

  /// Convert platform-agnostic zoom level to Kakao Maps Web level
  ///
  /// Platform differences:
  /// - Android/iOS: 6-21 range, higher = more zoomed in
  /// - Web: 1-14 range, lower = more zoomed in (REVERSED!)
  ///
  /// Conversion strategy:
  /// - Web level 1 (most zoomed in) ≈ Mobile level 21
  /// - Web level 14 (most zoomed out) ≈ Mobile level 1
  /// - Formula: webLevel = 15 - mobileLevel (clamped to 1-14)
  int _convertToWebZoomLevel(int mobileLevel) {
    // Clamp mobile level to expected range (6-21)
    final clampedMobile = mobileLevel.clamp(6, 21);

    // Convert: invert the scale
    // Mobile 1 (far) → Web 14 (far)
    // Mobile 21 (close) → Web 1 (close)
    final webLevel = 15 - clampedMobile;

    // Ensure web level is in valid range
    return webLevel.clamp(1, 14);
  }

  /// Convert Kakao Maps Web level to platform-agnostic zoom level
  int _convertFromWebZoomLevel(int webLevel) {
    // Reverse the conversion
    return 15 - webLevel.clamp(1, 14);
  }

  /// Set map level (zoom)
  /// Valid range: 1-14 for ROADMAP, 0-14 for SKYVIEW/HYBRID
  ///
  /// Note: Automatically converts from mobile zoom levels (1-21, higher=closer)
  /// to web zoom levels (1-14, lower=closer)
  void _setMapLevel(JSObject map, int level) {
    web.console.log('_setMapLevel called with mobile level: $level'.toJS);

    // Convert mobile zoom level to web zoom level
    final webLevel = _convertToWebZoomLevel(level);
    web.console.log('Converted to web level: $webLevel (1=close, 14=far)'.toJS);

    final result = _callMapMethod(map, 'setLevel', [webLevel.toJS]);
    web.console.log('setLevel result: $result'.toJS);

    // Verify the level was actually set (get raw web level for verification)
    final verifyResult = _callMapMethod(map, 'getLevel');
    final actualWebLevel = (verifyResult as JSNumber?)?.toDartInt;
    web.console.log('Actual web level after setLevel: $actualWebLevel'.toJS);
  }

  /// Get map level (zoom)
  /// Returns mobile-compatible zoom level (1-21, higher=closer)
  int? _getMapLevel(JSObject map) {
    try {
      final result = _callMapMethod(map, 'getLevel');
      final webLevel = (result as JSNumber?)?.toDartInt;

      if (webLevel == null) return null;

      // Convert web level back to mobile level
      return _convertFromWebZoomLevel(webLevel);
    } catch (e) {
      return null;
    }
  }

  /// Pan to location (animated)
  void _panTo(JSObject map, double latitude, double longitude) {
    final latLng = _createLatLng(latitude, longitude);
    if (latLng == null) return;
    _callMapMethod(map, 'panTo', [latLng]);
  }

  /// Get map bounds
  JSObject? _getMapBounds(JSObject map) {
    final result = _callMapMethod(map, 'getBounds');
    return result as JSObject?;
  }

  /// Create marker on map
  JSObject? _createMarker({
    required JSObject map,
    required double latitude,
    required double longitude,
    String? title,
    String? imageUrl,
    int? imageWidth,
    int? imageHeight,
  }) {
    final maps = _kakaoMaps;
    if (maps == null) return null;

    final markerCtor = maps['Marker'] as JSFunction?;
    if (markerCtor == null) return null;

    final latLng = _createLatLng(latitude, longitude);
    if (latLng == null) return null;

    final options = JSObject();
    options['position'] = latLng;
    options['map'] = map;

    if (title != null) {
      options['title'] = title.toJS;
    }

    // Add custom marker image if provided
    if (imageUrl != null && imageWidth != null && imageHeight != null) {
      final markerImage = _createMarkerImage(
        imageUrl: imageUrl,
        width: imageWidth,
        height: imageHeight,
      );

      if (markerImage != null) {
        options['image'] = markerImage;
      }
    }

    return markerCtor.callAsConstructor<JSObject>(options);
  }

  /// Create MarkerImage from URL or base64
  JSObject? _createMarkerImage({
    required String imageUrl,
    required int width,
    required int height,
  }) {
    final maps = _kakaoMaps;
    if (maps == null) return null;

    // Get constructors
    final sizeCtor = maps['Size'] as JSFunction?;
    final markerImageCtor = maps['MarkerImage'] as JSFunction?;

    if (sizeCtor == null || markerImageCtor == null) return null;

    try {
      // Create Size object: new kakao.maps.Size(width, height)
      final size = sizeCtor.callAsConstructor<JSObject>(
        width.toJS,
        height.toJS,
      );

      // Create MarkerImage: new kakao.maps.MarkerImage(imageSrc, imageSize)
      final markerImage = markerImageCtor.callAsConstructor<JSObject>(
        imageUrl.toJS,
        size,
      );

      web.console.log('Created MarkerImage: ${width}x$height'.toJS);

      return markerImage;
    } catch (e) {
      web.console.error('Error creating MarkerImage: $e'.toJS);
      return null;
    }
  }

  /// Remove marker from map
  void _removeMarker(JSObject marker) {
    _callMapMethod(marker, 'setMap', [null]);
  }

  /// Extract image dimensions from image bytes
  /// Returns a Future that resolves to a map with 'width' and 'height'
  Future<Map<String, int>?> _getImageSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      web.console.error('Error decoding image size: $e'.toJS);
      return null;
    }
  }

  /// Register marker styles (convert bytes to base64 data URLs)
  Future<void> _registerMarkerStyles(List<MarkerStyle> styles) async {
    for (final style in styles) {
      if (style.perLevels.isEmpty) continue;

      // For web, use the first perLevel style
      final perLevel = style.perLevels.first;
      final bytes = perLevel.bytes;

      // Convert Uint8List to base64 data URL
      final base64String = base64Encode(bytes);
      final dataUrl = 'data:image/png;base64,$base64String';

      // Extract image dimensions
      final size = await _getImageSize(bytes);
      final width = size?['width'] ?? 24; // Default to 24 if extraction fails
      final height = size?['height'] ?? 24;

      web.console.log(
        'Registered marker style "${style.styleId}": ${width}x$height'.toJS,
      );

      _markerStyles[style.styleId] = {
        'imageUrl': dataUrl,
        'width': width,
        'height': height,
      };
    }
  }

  /// Get marker style data by styleId
  Map<String, dynamic>? _getMarkerStyleData(String styleId) {
    return _markerStyles[styleId];
  }

  /// Remove marker styles
  void _removeMarkerStyles(List<String> styleIds) {
    for (final styleId in styleIds) {
      _markerStyles.remove(styleId);
    }
  }

  /// Clear all marker styles
  void _clearMarkerStyles() {
    _markerStyles.clear();
  }

  /// Add marker click listener
  void _addMarkerClickListener(
    JSObject marker,
    String markerId,
    String layerId,
    LatLng position,
  ) {
    final maps = _kakaoMaps;
    if (maps == null) return;

    final eventNs = maps['event'] as JSObject?;
    if (eventNs == null) return;

    final addListener = eventNs['addListener'] as JSFunction?;
    if (addListener == null) return;

    addListener.callAsFunction(
      eventNs,
      marker,
      'click'.toJS,
      ((JSObject? event) {
        onLabelClicked(
          LabelClickEvent(
            labelId: markerId,
            layerId: layerId,
            latLng: position,
          ),
        );
      }).toJS,
    );
  }

  /// Create custom overlay (info window)
  JSObject? _createCustomOverlay({
    required JSObject map,
    required double latitude,
    required double longitude,
    required JSAny content,
    int? xAnchor,
    int? yAnchor,
  }) {
    final maps = _kakaoMaps;
    if (maps == null) return null;

    final overlayCtor = maps['CustomOverlay'] as JSFunction?;
    if (overlayCtor == null) return null;

    final latLng = _createLatLng(latitude, longitude);
    if (latLng == null) return null;

    final options = JSObject();
    options['position'] = latLng;
    options['content'] = content;

    if (xAnchor != null && yAnchor != null) {
      options['xAnchor'] = (xAnchor / 100.0).toJS;
      options['yAnchor'] = (yAnchor / 100.0).toJS;
    }

    final overlay = overlayCtor.callAsConstructor<JSObject>(options);
    _callMapMethod(overlay, 'setMap', [map]);

    return overlay;
  }

  /// Remove custom overlay from map
  void _removeCustomOverlay(JSObject overlay) {
    _callMapMethod(overlay, 'setMap', [null]);
  }

  /// Add event listeners to the map instance
  void _addEventListeners(JSObject map) {
    final maps = _kakaoMaps;
    if (maps == null) return;

    final eventNs = maps['event'] as JSObject?;
    if (eventNs == null) return;

    final addListener = eventNs['addListener'] as JSFunction?;
    if (addListener == null) return;

    // onCameraMoveEnd
    addListener.callAsFunction(
      eventNs,
      map,
      'idle'.toJS,
      () {
        final center = _handleGetCenter(map);
        final zoom = _getMapLevel(map);
        if (center != null && zoom != null) {
          onCameraMoveEnd(
            CameraMoveEndEvent(
              latitude: center.latitude,
              longitude: center.longitude,
              zoomLevel: zoom.toDouble(),
              tilt: -1,
              rotation: -1,
            ),
          );
        }
      }.toJS,
    );
  }

  @override
  Future<T> _callMethod<T>(KakaoMapMethodCall<T> methodCall) async {
    final map = _mapInstance;
    if (map == null) {
      web.console.warn('Map instance not found for viewId: $viewId'.toJS);
      return null as T;
    }

    if (!_areListenersAdded) {
      _addEventListeners(map);
      _areListenersAdded = true;
    }

    // Get methods that return values
    if (methodCall is GetZoomLevel) {
      final level = _getMapLevel(map);
      web.console.log('GetZoomLevel returning: $level'.toJS);
      return level as T;
    }

    if (methodCall is GetCenter) {
      return _handleGetCenter(map) as T;
    }

    if (methodCall is GetMapInfo) {
      return _handleGetMapInfo(map) as T;
    }

    if (methodCall is GetViewportBounds) {
      return _handleGetViewportBounds(map) as T;
    }

    // Set/action methods that return void
    if (methodCall is SetZoomLevel) {
      final zoomLevel = (methodCall as SetZoomLevel).zoomLevel;
      web.console.log('SetZoomLevel called with zoomLevel: $zoomLevel'.toJS);
      _setMapLevel(map, zoomLevel);
      return null as T;
    }

    if (methodCall is MoveCamera) {
      _handleMoveCamera(map, methodCall as MoveCamera);
      return null as T;
    }

    if (methodCall is AddMarker) {
      _handleAddMarker(map, methodCall as AddMarker);
      return null as T;
    }

    if (methodCall is RemoveMarker) {
      _handleRemoveMarker(methodCall as RemoveMarker);
      return null as T;
    }

    if (methodCall is AddMarkers) {
      final call = methodCall as AddMarkers;
      for (final option in call.markerOptions) {
        _handleAddMarker(
          map,
          AddMarker(
            markerOption: option,
            layerId: call.layerId,
          ),
        );
      }
      return null as T;
    }

    if (methodCall is RemoveMarkers) {
      final call = methodCall as RemoveMarkers;
      for (final id in call.ids) {
        _handleRemoveMarker(
          RemoveMarker(id: id, layerId: call.layerId),
        );
      }
      return null as T;
    }

    if (methodCall is ClearMarkers) {
      _handleClearMarkers();
      return null as T;
    }

    if (methodCall is RegisterMarkerStyles) {
      await _registerMarkerStyles((methodCall as RegisterMarkerStyles).styles);
      return null as T;
    }

    if (methodCall is RemoveMarkerStyles) {
      _removeMarkerStyles((methodCall as RemoveMarkerStyles).styleIds);
      return null as T;
    }

    if (methodCall is ClearMarkerStyles) {
      _clearMarkerStyles();
      return null as T;
    }

    if (methodCall is AddInfoWindow) {
      _handleAddInfoWindow(map, methodCall as AddInfoWindow);
      return null as T;
    }

    if (methodCall is RemoveInfoWindow) {
      _handleRemoveInfoWindow(methodCall as RemoveInfoWindow);
      return null as T;
    }

    if (methodCall is AddInfoWindows) {
      final call = methodCall as AddInfoWindows;
      for (final option in call.infoWindowOptions) {
        _handleAddInfoWindow(map, AddInfoWindow(infoWindowOption: option));
      }
      return null as T;
    }

    if (methodCall is RemoveInfoWindows) {
      for (final id in (methodCall as RemoveInfoWindows).ids) {
        _handleRemoveInfoWindow(RemoveInfoWindow(id: id));
      }
      return null as T;
    }

    if (methodCall is ClearInfoWindows) {
      _handleClearInfoWindows();
      return null as T;
    }

    // LOD Marker operations (using MarkerClusterer on web)
    if (methodCall is AddLodMarkerLayer) {
      _handleAddLodMarkerLayer(map, methodCall as AddLodMarkerLayer);
      return null as T;
    }

    if (methodCall is RemoveLodMarkerLayer) {
      _handleRemoveLodMarkerLayer((methodCall as RemoveLodMarkerLayer).layerId);
      return null as T;
    }

    if (methodCall is AddLodMarker) {
      _handleAddLodMarker(map, methodCall as AddLodMarker);
      return null as T;
    }

    if (methodCall is AddLodMarkers) {
      _handleAddLodMarkers(map, methodCall as AddLodMarkers);
      return null as T;
    }

    if (methodCall is RemoveLodMarkers) {
      _handleRemoveLodMarkers(
        (methodCall as RemoveLodMarkers).layerId,
        (methodCall as RemoveLodMarkers).ids,
      );
      return null as T;
    }

    if (methodCall is ClearAllLodMarkers) {
      _handleClearAllLodMarkers((methodCall as ClearAllLodMarkers).layerId);
      return null as T;
    }

    if (methodCall is ShowAllLodMarkers) {
      _handleShowAllLodMarkers((methodCall as ShowAllLodMarkers).layerId);
      return null as T;
    }

    if (methodCall is HideAllLodMarkers) {
      _handleHideAllLodMarkers((methodCall as HideAllLodMarkers).layerId);
      return null as T;
    }

    if (methodCall is ShowLodMarkers) {
      _handleShowLodMarkers(
        (methodCall as ShowLodMarkers).layerId,
        (methodCall as ShowLodMarkers).ids,
      );
      return null as T;
    }

    if (methodCall is HideLodMarkers) {
      _handleHideLodMarkers(
        (methodCall as HideLodMarkers).layerId,
        (methodCall as HideLodMarkers).ids,
      );
      return null as T;
    }

    if (methodCall is SetLodMarkerLayerClickable) {
      // Clickability is always enabled for clusterer on web
      web.console.log('SetLodMarkerLayerClickable: always enabled on web'.toJS);
      return null as T;
    }

    // Unsupported methods
    if (methodCall is ToScreenPoint || methodCall is FromScreenPoint) {
      web.console.warn(
        '${methodCall.name} not supported on web platform'.toJS,
      );
      return null as T;
    }

    // Default: not yet implemented
    web.console.warn(
      'Method ${methodCall.name} not yet implemented for web'.toJS,
    );
    return null as T;
  }

  LatLng? _handleGetCenter(JSObject map) {
    final center = _getMapCenter(map);
    if (center == null) return null;

    final lat = _getLatitude(center);
    final lng = _getLongitude(center);

    if (lat == null || lng == null) return null;

    return LatLng(latitude: lat, longitude: lng);
  }

  void _handleMoveCamera(JSObject map, MoveCamera methodCall) {
    final update = methodCall.cameraUpdate;
    final hasAnimation = methodCall.animation != null;

    web.console.log(
      'MoveCamera: zoomLevel=${update.zoomLevel}, position=${update.position}, hasAnimation=$hasAnimation'
          .toJS,
    );

    // Get current state before changes
    final currentLevel = _getMapLevel(map);
    final currentCenter = _handleGetCenter(map);
    web.console.log(
      'Before MoveCamera: level=$currentLevel, center=$currentCenter'.toJS,
    );

    // Move to position if provided
    if (update.position != null) {
      final target = update.position!;

      if (hasAnimation) {
        _panTo(map, target.latitude, target.longitude);
      } else {
        _setMapCenter(map, target.latitude, target.longitude);
      }
    }

    // Set zoom level if provided (default is -1 which means no change)
    if (update.zoomLevel >= 0) {
      web.console.log('Applying zoom level: ${update.zoomLevel}'.toJS);
      _setMapLevel(map, update.zoomLevel);
    } else {
      web.console
          .log('Skipping zoom level (sentinel: ${update.zoomLevel})'.toJS);
    }

    // Verify final state
    final finalLevel = _getMapLevel(map);
    final finalCenter = _handleGetCenter(map);
    web.console.log(
      'After MoveCamera: level=$finalLevel, center=$finalCenter'.toJS,
    );

    // Note: Web API doesn't support tilt and rotation
    // tiltAngle and rotationAngle are ignored on web platform
  }

  void _handleAddMarker(JSObject map, AddMarker methodCall) {
    final option = methodCall.markerOption;

    // Get marker image from registered styles if styleId is provided
    String? imageUrl;
    int? imageWidth;
    int? imageHeight;

    if (option.styleId != null) {
      final styleData = _getMarkerStyleData(option.styleId!);
      if (styleData != null) {
        imageUrl = styleData['imageUrl'] as String?;
        imageWidth = styleData['width'] as int?;
        imageHeight = styleData['height'] as int?;
      }
    }

    final marker = _createMarker(
      map: map,
      latitude: option.latLng.latitude,
      longitude: option.latLng.longitude,
      title: option.text,
      imageUrl: imageUrl,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
    );

    if (marker != null) {
      _markers[option.id] = marker;

      // Add click listener
      _addMarkerClickListener(
        marker,
        option.id,
        methodCall.layerId,
        option.latLng,
      );
    }
  }

  void _handleRemoveMarker(RemoveMarker methodCall) {
    final marker = _markers.remove(methodCall.id);
    if (marker != null) {
      _removeMarker(marker);
    }
  }

  void _handleClearMarkers() {
    for (final marker in _markers.values) {
      _removeMarker(marker);
    }
    _markers.clear();
  }

  void _handleAddInfoWindow(JSObject map, AddInfoWindow methodCall) {
    final option = methodCall.infoWindowOption;

    web.Element container;

    if (option.body != null) {
      // New logic to handle Gui body
      container = _buildGuiElement(option.body!);
    } else {
      // Existing logic for title/snippet
      container = web.HTMLDivElement()
        ..style.padding = '8px'
        ..style.cursor = 'pointer';

      if (option.title != null) {
        container.append(
          web.HTMLDivElement()
            ..style.fontWeight = 'bold'
            ..style.marginBottom = '4px'
            ..innerText = option.title!,
        );
      }

      if (option.snippet != null) {
        container.append(
          web.HTMLDivElement()
            ..style.fontSize = '12px'
            ..innerText = option.snippet!,
        );
      }
    }

    // Add click listener to the container
    container.onClick.listen((event) {
      onInfoWindowClicked(
        InfoWindowClickEvent(
          infoWindowId: option.id,
          latLng: option.latLng,
        ),
      );
    });

    // Create overlay
    final overlay = _createCustomOverlay(
      map: map,
      latitude: option.latLng.latitude,
      longitude: option.latLng.longitude,
      content: container,
      xAnchor: option.offset.x.toInt(),
      yAnchor: option.offset.y.toInt(),
    );

    if (overlay != null) {
      _infoWindows[option.id] = overlay;
    }
  }

  void _handleRemoveInfoWindow(RemoveInfoWindow methodCall) {
    final overlay = _infoWindows.remove(methodCall.id);
    if (overlay != null) {
      _removeCustomOverlay(overlay);
    }
  }

  void _handleClearInfoWindows() {
    for (final overlay in _infoWindows.values) {
      _removeCustomOverlay(overlay);
    }
    _infoWindows.clear();
  }

  MapInfo? _handleGetMapInfo(JSObject map) {
    final level = _getMapLevel(map);
    if (level == null) return null;

    return MapInfo(
      zoomLevel: level,
      rotation: 0,
      tilt: 0,
    );
  }

  LatLngBounds? _handleGetViewportBounds(JSObject map) {
    final boundsJS = _getMapBounds(map);
    if (boundsJS == null) return null;

    try {
      final getSw = boundsJS['getSouthWest'] as JSFunction?;
      final getNe = boundsJS['getNorthEast'] as JSFunction?;

      if (getSw == null || getNe == null) return null;

      final swJS = getSw.callAsFunction(boundsJS) as JSObject?;
      final neJS = getNe.callAsFunction(boundsJS) as JSObject?;

      if (swJS == null || neJS == null) return null;

      final swLat = _getLatitude(swJS);
      final swLng = _getLongitude(swJS);
      final neLat = _getLatitude(neJS);
      final neLng = _getLongitude(neJS);

      if (swLat == null || swLng == null || neLat == null || neLng == null) {
        return null;
      }

      return LatLngBounds(
        southwest: LatLng(latitude: swLat, longitude: swLng),
        northeast: LatLng(latitude: neLat, longitude: neLng),
      );
    } catch (e) {
      web.console.error('Error getting viewport bounds: $e'.toJS);
      return null;
    }
  }

  // ===== LOD Marker operations using MarkerClusterer =====

  /// Create a MarkerClusterer for LOD markers
  void _handleAddLodMarkerLayer(JSObject map, AddLodMarkerLayer methodCall) {
    final options = methodCall.options;
    final layerId = options.layerId;

    web.console.log('Creating LOD layer (MarkerClusterer): $layerId'.toJS);

    // Initialize marker storage for this layer
    _lodMarkers[layerId] = {};

    // Create MarkerClusterer
    final clusterer = _createMarkerClusterer(
      map: map,
      gridSize: options.radius?.toInt() ?? 60,
      minLevel: 6, // Default min level for clustering
    );

    if (clusterer != null) {
      _lodClusterers[layerId] = clusterer;
      web.console.log('LOD layer created: $layerId'.toJS);
    }
  }

  /// Create a MarkerClusterer instance
  JSObject? _createMarkerClusterer({
    required JSObject map,
    required int gridSize,
    required int minLevel,
  }) {
    final maps = _kakaoMaps;
    if (maps == null) return null;

    final clustererCtor = maps['MarkerClusterer'] as JSFunction?;
    if (clustererCtor == null) {
      web.console.error('MarkerClusterer not available'.toJS);
      return null;
    }

    try {
      // Create options object
      final options = JSObject();
      options['map'] = map;
      options['markers'] = <JSAny>[].toJS; // Start with empty markers array
      options['gridSize'] = gridSize.toJS;
      options['averageCenter'] = true.toJS;
      options['minLevel'] = minLevel.toJS;
      options['disableClickZoom'] = false.toJS;

      // Create clusterer
      final clusterer = clustererCtor.callAsConstructor<JSObject>(options);
      return clusterer;
    } catch (e) {
      web.console.error('Error creating MarkerClusterer: $e'.toJS);
      return null;
    }
  }

  void _handleRemoveLodMarkerLayer(String layerId) {
    web.console.log('Removing LOD layer: $layerId'.toJS);

    // Clear all markers in this layer first
    final markers = _lodMarkers[layerId];
    if (markers != null) {
      for (final marker in markers.values) {
        _callMapMethod(marker, 'setMap', [null]);
      }
    }

    // Remove the clusterer
    final clusterer = _lodClusterers.remove(layerId);
    if (clusterer != null) {
      _callMapMethod(clusterer, 'clear');
    }

    // Clear storage
    _lodMarkers.remove(layerId);
  }

  void _handleAddLodMarker(JSObject map, AddLodMarker methodCall) {
    _handleAddLodMarkers(
      map,
      AddLodMarkers(options: [methodCall.option], layerId: methodCall.layerId),
    );
  }

  void _handleAddLodMarkers(JSObject map, AddLodMarkers methodCall) {
    final layerId = methodCall.layerId;
    final clusterer = _lodClusterers[layerId];

    if (clusterer == null) {
      web.console.warn('LOD layer not found: $layerId'.toJS);
      return;
    }

    final layerMarkers = _lodMarkers[layerId];
    if (layerMarkers == null) {
      web.console.warn('LOD marker storage not found: $layerId'.toJS);
      return;
    }

    // Create markers
    final newMarkers = <JSObject>[];

    for (final option in methodCall.options) {
      // Get marker image from registered styles
      String? imageUrl;
      int? imageWidth;
      int? imageHeight;

      if (option.styleId != null) {
        final styleData = _getMarkerStyleData(option.styleId!);
        if (styleData != null) {
          imageUrl = styleData['imageUrl'] as String?;
          imageWidth = styleData['width'] as int?;
          imageHeight = styleData['height'] as int?;
        }
      }

      // Create marker (without setting map, clusterer will handle it)
      final marker = _createLodMarker(
        latitude: option.latLng.latitude,
        longitude: option.latLng.longitude,
        title: option.text,
        imageUrl: imageUrl,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );

      if (marker != null) {
        layerMarkers[option.id] = marker;
        newMarkers.add(marker);

        // Add click listener
        _addMarkerClickListener(
          marker,
          option.id,
          layerId,
          option.latLng,
        );
      }
    }

    // Add markers to clusterer
    if (newMarkers.isNotEmpty) {
      _addMarkersToClusterer(clusterer, newMarkers);
      web.console.log(
        'Added ${newMarkers.length} LOD markers to layer: $layerId'.toJS,
      );
    }
  }

  /// Create a marker for LOD (without setting map)
  JSObject? _createLodMarker({
    required double latitude,
    required double longitude,
    String? title,
    String? imageUrl,
    int? imageWidth,
    int? imageHeight,
  }) {
    final maps = _kakaoMaps;
    if (maps == null) return null;

    final markerCtor = maps['Marker'] as JSFunction?;
    if (markerCtor == null) return null;

    final latLng = _createLatLng(latitude, longitude);
    if (latLng == null) return null;

    final options = JSObject();
    options['position'] = latLng;
    // Don't set map - clusterer will manage it

    if (title != null) {
      options['title'] = title.toJS;
    }

    // Add custom marker image if provided
    if (imageUrl != null && imageWidth != null && imageHeight != null) {
      final markerImage = _createMarkerImage(
        imageUrl: imageUrl,
        width: imageWidth,
        height: imageHeight,
      );

      if (markerImage != null) {
        options['image'] = markerImage;
      }
    }

    return markerCtor.callAsConstructor<JSObject>(options);
  }

  /// Add markers to clusterer
  void _addMarkersToClusterer(JSObject clusterer, List<JSObject> markers) {
    try {
      final addMarkers = clusterer['addMarkers'] as JSFunction?;
      if (addMarkers != null) {
        addMarkers.callAsFunction(clusterer, markers.toJS);
      }
    } catch (e) {
      web.console.error('Error adding markers to clusterer: $e'.toJS);
    }
  }

  void _handleRemoveLodMarkers(String layerId, List<String> ids) {
    final clusterer = _lodClusterers[layerId];
    final layerMarkers = _lodMarkers[layerId];

    if (clusterer == null || layerMarkers == null) {
      web.console.warn('LOD layer not found: $layerId'.toJS);
      return;
    }

    final markersToRemove = <JSObject>[];

    for (final id in ids) {
      final marker = layerMarkers.remove(id);
      if (marker != null) {
        markersToRemove.add(marker);
      }
    }

    if (markersToRemove.isNotEmpty) {
      _removeMarkersFromClusterer(clusterer, markersToRemove);
      web.console.log(
        'Removed ${markersToRemove.length} LOD markers from layer: $layerId'
            .toJS,
      );
    }
  }

  /// Remove markers from clusterer
  void _removeMarkersFromClusterer(JSObject clusterer, List<JSObject> markers) {
    try {
      final removeMarkers = clusterer['removeMarkers'] as JSFunction?;
      if (removeMarkers != null) {
        removeMarkers.callAsFunction(clusterer, markers.toJS);
      }
    } catch (e) {
      web.console.error('Error removing markers from clusterer: $e'.toJS);
    }
  }

  void _handleClearAllLodMarkers(String layerId) {
    final clusterer = _lodClusterers[layerId];
    final layerMarkers = _lodMarkers[layerId];

    if (clusterer == null || layerMarkers == null) {
      web.console.warn('LOD layer not found: $layerId'.toJS);
      return;
    }

    // Clear all markers from clusterer
    _callMapMethod(clusterer, 'clear');

    // Clear storage
    layerMarkers.clear();

    web.console.log('Cleared all LOD markers from layer: $layerId'.toJS);
  }

  void _handleShowAllLodMarkers(String layerId) {
    final layerMarkers = _lodMarkers[layerId];

    if (layerMarkers == null) {
      web.console.warn('LOD layer not found: $layerId'.toJS);
      return;
    }

    // Show all markers by setting their map
    for (final marker in layerMarkers.values) {
      _callMapMethod(marker, 'setVisible', [true.toJS]);
    }

    web.console.log('Showed all LOD markers in layer: $layerId'.toJS);
  }

  void _handleHideAllLodMarkers(String layerId) {
    final layerMarkers = _lodMarkers[layerId];

    if (layerMarkers == null) {
      web.console.warn('LOD layer not found: $layerId'.toJS);
      return;
    }

    // Hide all markers
    for (final marker in layerMarkers.values) {
      _callMapMethod(marker, 'setVisible', [false.toJS]);
    }

    web.console.log('Hid all LOD markers in layer: $layerId'.toJS);
  }

  void _handleShowLodMarkers(String layerId, List<String> ids) {
    final layerMarkers = _lodMarkers[layerId];

    if (layerMarkers == null) {
      web.console.warn('LOD layer not found: $layerId'.toJS);
      return;
    }

    for (final id in ids) {
      final marker = layerMarkers[id];
      if (marker != null) {
        _callMapMethod(marker, 'setVisible', [true.toJS]);
      }
    }

    web.console.log('Showed ${ids.length} LOD markers in layer: $layerId'.toJS);
  }

  void _handleHideLodMarkers(String layerId, List<String> ids) {
    final layerMarkers = _lodMarkers[layerId];

    if (layerMarkers == null) {
      web.console.warn('LOD layer not found: $layerId'.toJS);
      return;
    }

    for (final id in ids) {
      final marker = layerMarkers[id];
      if (marker != null) {
        _callMapMethod(marker, 'setVisible', [false.toJS]);
      }
    }

    web.console.log('Hid ${ids.length} LOD markers in layer: $layerId'.toJS);
  }

  double _scale(num value) {
    // The GUI values seem to be specified in physical pixels.
    // To make them render consistently on high-DPR web screens,
    // we need to convert them to logical CSS pixels by dividing by the DPR.
    final dpr = web.window.devicePixelRatio;
    return value / dpr;
  }

  web.Element _buildGuiElement(GuiView guiComponent) {
    if (guiComponent is GuiText) {
      return _buildGuiText(guiComponent);
    } else if (guiComponent is GuiImage) {
      return _buildGuiImage(guiComponent);
    } else if (guiComponent is GuiLayout) {
      return _buildGuiLayout(guiComponent);
    }
    return web.HTMLDivElement()..innerText = 'Unsupported GUI component';
  }

  web.Element _buildGuiText(GuiText guiText) {
    final span = web.HTMLSpanElement()..innerText = guiText.text;
    span.style.fontSize = '${_scale(guiText.textSize)}px';
    span.style.color = _toCssColor(guiText.textColor);
    if (guiText.strokeSize > 0) {
      final strokeSize = _scale(guiText.strokeSize);
      final strokeColor = _toCssColor(guiText.strokeColor);
      span.style.textShadow =
          '-${strokeSize}px -${strokeSize}px 0 $strokeColor, '
          '${strokeSize}px -${strokeSize}px 0 $strokeColor, '
          '-${strokeSize}px ${strokeSize}px 0 $strokeColor, '
          '${strokeSize}px ${strokeSize}px 0 $strokeColor';
    }
    return span;
  }

  web.Element _buildGuiImage(GuiImage guiImage) {
    final img = web.HTMLImageElement()
      ..src = 'data:image/png;base64,${guiImage.base64EncodedImage}';
    return img;
  }

  web.Element _buildGuiLayout(GuiLayout guiLayout) {
    final div = web.HTMLDivElement();
    div.style.display = 'flex';
    div.style.flexDirection =
        (guiLayout.orientation == Orientation.horizontal) ? 'row' : 'column';
    div.style.alignItems = 'center';
    div.style.gap = '${_scale(4)}px'; // Also scale gap

    // Padding
    div.style.paddingLeft = '${_scale(guiLayout.paddingLeft ?? 0)}px';
    div.style.paddingTop = '${_scale(guiLayout.paddingTop ?? 0)}px';
    div.style.paddingRight = '${_scale(guiLayout.paddingRight ?? 0)}px';
    div.style.paddingBottom = '${_scale(guiLayout.paddingBottom ?? 0)}px';

    // Background
    if (guiLayout.background != null) {
      final bgImage = guiLayout.background!;
      final src = 'data:image/png;base64,${bgImage.base64EncodedImage}';

      if (bgImage.isNinepatch == true) {
        final area = bgImage.fixedArea;
        div.style.borderImageSource = 'url($src)';
        // border-image-slice is in source image pixels, so it should NOT be scaled.
        div.style.borderImageSlice =
            '${area.top} ${area.right} ${area.bottom} ${area.left} fill';
        // border-width is the rendered size on screen, so it SHOULD be scaled.
        div.style.borderWidth =
            '${_scale(area.top)}px ${_scale(area.right)}px ${_scale(area.bottom)}px ${_scale(area.left)}px';
        div.style.borderStyle = 'solid';
        div.style.borderColor = 'transparent';
        div.style.borderImageRepeat = 'stretch';
      } else {
        div.style.background = 'url($src) no-repeat center center';
        div.style.backgroundSize = 'cover';
      }
    }

    for (final child in guiLayout.children) {
      div.append(_buildGuiElement(child));
    }

    return div;
  }

  String _toCssColor(int argb) {
    final a = (argb >> 24) & 0xFF;
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    if (a == 255) {
      return 'rgb($r, $g, $b)';
    }
    return 'rgba($r, $g, $b, ${a / 255.0})';
  }
}
