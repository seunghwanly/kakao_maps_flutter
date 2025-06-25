package io.seunghwanly.kakao_maps_flutter.view

import android.content.Context
import android.util.Log
import android.view.View
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.KakaoMapReadyCallback
import com.kakao.vectormap.LatLng
import com.kakao.vectormap.MapGravity
import com.kakao.vectormap.MapLifeCycleCallback
import com.kakao.vectormap.MapView
import com.kakao.vectormap.PoiScale
import com.kakao.vectormap.camera.CameraAnimation
import com.kakao.vectormap.camera.CameraPosition
import com.kakao.vectormap.camera.CameraUpdate
import com.kakao.vectormap.camera.CameraUpdateFactory
import com.kakao.vectormap.label.LabelLayer
import com.kakao.vectormap.label.LabelOptions
import com.kakao.vectormap.label.LabelStyle
import com.kakao.vectormap.label.LabelStyles
import com.kakao.vectormap.label.LabelTextStyle
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.seunghwanly.kakao_maps_flutter.data.cameraAnimation.toCameraAnimationOrNull
import io.seunghwanly.kakao_maps_flutter.data.cameraUpdate.toCameraUpdate
import io.seunghwanly.kakao_maps_flutter.data.infoWindowOption.toNativeInfoWindowOptions
import io.seunghwanly.kakao_maps_flutter.data.labelClickEvent.LabelClickEvent
import io.seunghwanly.kakao_maps_flutter.data.labelOption.LabelOption
import io.seunghwanly.kakao_maps_flutter.data.labelOption.toLabelOptionOrNull
import io.seunghwanly.kakao_maps_flutter.data.latLng.toLatLng
import org.json.JSONObject
import kotlin.io.encoding.ExperimentalEncodingApi

class KakaoMapController(
    private val context: Context,
    private val id: Int,
    private val args: Any?,
    private val methodChannel: MethodChannel,
) : PlatformView, MethodChannel.MethodCallHandler {
    private val mapView: MapView = MapView(context)

    private lateinit var kMap: KakaoMap

    // Parse initial position from args
    private val initialPosition: LatLng? = parseInitialPosition(args)

    // Parse initial zoom level from args
    private val initialLevel: Int? = parseInitialLevel(args)

    // Parse compass configuration from args
    private val compassConfig: Map<String, Any?>? = parseCompassConfig(args)

    // Parse scaleBar configuration from args
    private val scaleBarConfig: Map<String, Any?>? = parseScaleBarConfig(args)

    // Parse logo configuration from args
    private val logoConfig: Map<String, Any?>? = parseLogoConfig(args)

    init {
        // Register Flutter MethodCallHandler
        methodChannel.setMethodCallHandler(this@KakaoMapController)

        // Init Kakao Map
        // https://apis.map.kakao.com/android_v2/docs/getting-started/quickstart/#3-지도-시작-및-kakaomap-객체-가져오기
        mapView.start(
            object : MapLifeCycleCallback() {
                override fun onMapDestroy() {
                    mapView.finish()
                }

                override fun onMapError(p0: Exception?) {
                    methodChannel.invokeMethod("onMapError", p0.toString())
                }
            },
            object : KakaoMapReadyCallback() {
                override fun onMapReady(kakaoMap: KakaoMap) {
                    kMap = kakaoMap

                    // Send message to Flutter
                    methodChannel.invokeMethod("onMapReady", true)

                    // Null Check
                    if (!::kMap.isInitialized) {
                        throw IllegalStateException(
                            "onMapReady is called but kakaoMap is not initialized"
                        )
                    }

                    // Initial position is handled by getPosition() method

                    // Set Listener
                    kMap.setOnLabelClickListener { kakaoMap, labelLayer, label ->
                        val position = label.position

                        val event =
                            LabelClickEvent.fromLabel(
                                label = label,
                                layerId = labelLayer?.layerId,
                            )

                        methodChannel.invokeMethod("onLabelClicked", event.toMap())

                        true
                    }

                    kMap.setOnInfoWindowClickListener { kakaoMap, infoWindow, id ->

                        val event = mapOf(
                            "infoWindowId" to id,
                            "latLng" to mapOf(
                                "latitude" to infoWindow.position.latitude,
                                "longitude" to infoWindow.position.longitude,
                            )
                        )

                        methodChannel.invokeMethod("onInfoWindowClicked", event)

                        true
                    }

                    kMap.setOnCameraMoveEndListener { kakaoMap, cameraPosition, gestureType ->
                        // Notify Flutter about camera move end
                        val event = mapOf(
                            "latitude" to cameraPosition.position.latitude,
                            "longitude" to cameraPosition.position.longitude,
                            "zoomLevel" to cameraPosition.zoomLevel,
                            "rotation" to cameraPosition.rotationAngle,
                            "tilt" to cameraPosition.tiltAngle,
                        )
                        methodChannel.invokeMethod("onCameraMoveEnd", event)
                    }

                    // Configure compass if provided
                    compassConfig?.let { config ->
                        val compass = kMap.compass
                        compass?.show()

                        // Set back to north on click if specified
                        val isBackToNorthOnClick =
                            config["isBackToNorthOnClick"] as? Boolean != false
                        compass?.isBackToNorthOnClick = isBackToNorthOnClick

                        // Set compass position if alignment is specified
                        val alignment = config["alignment"] as? String
                        val offset = config["offset"] as? Map<*, *>

                        if (alignment != null) {
                            val mapGravity = convertAlignmentToMapGravity(alignment)
                            val offsetX = (offset?.get("dx") as? Number)?.toFloat() ?: 0f
                            val offsetY = (offset?.get("dy") as? Number)?.toFloat() ?: 0f

                            compass?.setPosition(mapGravity, offsetX, offsetY)
                        }
                    }

                    // Configure scalebar if provided
                    scaleBarConfig?.let { config ->
                        val scaleBar = kMap.scaleBar
                        scaleBar?.show()

                        // Set auto hide if specified
                        val isAutoHide = config["isAutoHide"] as? Boolean == true
                        scaleBar?.isAutoHide = isAutoHide

                        // Set fade in/out times if specified
                        val fadeInTime = config["fadeInTime"] as? Int ?: 300
                        val fadeOutTime = config["fadeOutTime"] as? Int ?: 300
                        val retentionTime = config["retentionTime"] as? Int ?: 3000
                        scaleBar?.setFadeInOutTime(fadeInTime, fadeOutTime, retentionTime)
                    }

                    // Configure logo if provided
                    logoConfig?.let { config ->
                        // Note: Android SDK doesn't have direct logo control methods
                        // The logo is typically controlled by the SDK internally
                        // We'll implement show/hide and position methods for consistency
                        Log.d("KakaoMapController", "Logo configuration provided: $config")
                    }

                    // Set Camera Move End Listener (placeholder implementation)
                    // Note: The exact camera listener API for Kakao Maps SDK may be different
                    // This is a placeholder that should be replaced with the correct API call
                    // when the proper camera listener method is available
                    Log.d("KakaoMapController", "Camera move end listener setup placeholder")
                }

                override fun getPosition(): LatLng {
                    // Return initialPosition if provided, otherwise use default
                    return initialPosition ?: LatLng.from(37.394726159, 127.111209047)
                }

                override fun getZoomLevel(): Int {
                    // Return initialLevel if provided, otherwise use default
                    return initialLevel ?: 15
                }
            },
        )
    }

    private fun parseInitialPosition(args: Any?): LatLng? {
        if (args !is Map<*, *>) return null

        val initialPositionMap = args["initialPosition"] as? Map<*, *> ?: return null
        val latitude = initialPositionMap["latitude"] as? Double ?: return null
        val longitude = initialPositionMap["longitude"] as? Double ?: return null

        return LatLng.from(latitude, longitude)
    }

    private fun parseInitialLevel(args: Any?): Int? {
        if (args !is Map<*, *>) return null

        return args["initialLevel"] as? Int
    }

    private fun parseCompassConfig(args: Any?): Map<String, Any?>? {
        if (args !is Map<*, *>) return null

        return args["compass"] as? Map<String, Any?>
    }

    private fun parseScaleBarConfig(args: Any?): Map<String, Any?>? {
        if (args !is Map<*, *>) return null

        return args["scaleBar"] as? Map<String, Any?>
    }

    private fun parseLogoConfig(args: Any?): Map<String, Any?>? {
        if (args !is Map<*, *>) return null

        return args["logo"] as? Map<String, Any?>
    }

    private fun getZoomLevel(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val level = kMap.cameraPosition?.zoomLevel
        return result.success(level)
    }

    private fun setZoomLevel(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val level = args["level"].toString().toInt()

        kMap.moveCamera(CameraUpdateFactory.zoomTo(level))
        return result.success(null)
    }

    private fun moveCamera(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        // cameraUpdate / animation?
        val animation: CameraAnimation? = args.optJSONObject("animation")?.toCameraAnimationOrNull()
        val cameraUpdate: CameraUpdate = args.getJSONObject("cameraUpdate").toCameraUpdate()

        if (animation == null) {
            kMap.moveCamera(cameraUpdate)
            return result.success(null)
        }

        kMap.moveCamera(cameraUpdate, animation)
        return result.success(null)
    }

    @OptIn(ExperimentalEncodingApi::class)
    private fun addMarker(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        // Parse Marker
        val labelOption: LabelOption =
            args.toLabelOptionOrNull()
                ?: return result.error(
                    "E001",
                    "label must not be null",
                    null,
                )

        val currentLayer: LabelLayer =
            kMap.labelManager?.layer
                ?: return result.error(
                    "E002",
                    "Either LabelManager or its layer is null",
                    null,
                )

        if (currentLayer.hasLabel(labelOption.id)) {
            currentLayer.getLabel(labelOption.id)?.remove()
        }

        // Create Label style
        val labelStyle: LabelStyle =
            if (labelOption.image == null) {
                LabelStyle.from(LabelTextStyle.from(10, 0xFF000000.toInt()))
            } else {
                LabelStyle.from(labelOption.image)
            }

        val labelStyles = LabelStyles.from(labelStyle)

        val option =
            LabelOptions.from(
                labelOption.id,
                labelOption.latLng,
            )
        option.setStyles(labelStyles)

        kMap.labelManager?.layer?.addLabel(option)

        return result.success(null)
    }

    private fun removeMarker(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val labelId: String = args.optString("id")
        if (labelId.isNullOrEmpty()) {
            return result.error(
                "E001",
                "id must not be null or empty",
                null,
            )
        }

        kMap.labelManager?.layer?.getLabel(labelId)?.remove()

        return result.success(null)
    }

    @OptIn(ExperimentalEncodingApi::class)
    private fun addMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized)

        val options = args.getJSONArray("markers")
        val layer = kMap.labelManager?.layer ?: return result.error("E002", "Layer is null", null)

        for (i in 0 until options.length()) {
            val option = options.getJSONObject(i).toLabelOptionOrNull() ?: continue

            if (layer.hasLabel(option.id)) {
                layer.getLabel(option.id)?.remove()
            }

            val labelStyle =
                if (option.image == null) {
                    LabelStyle.from(LabelTextStyle.from(10, 0xFF000000.toInt()))
                } else {
                    LabelStyle.from(option.image)
                }

            val labelStyles = LabelStyles.from(labelStyle)
            val labelOption = LabelOptions.from(option.id, option.latLng)
            labelOption.setStyles(labelStyles)

            layer.addLabel(labelOption)
        }

        result.success(null)
    }

    private fun removeMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized)

        val layer = kMap.labelManager?.layer ?: return result.error("E002", "Layer is null", null)
        val parsedIds = args.getJSONArray("ids")

        for (i in 0 until parsedIds.length()) {
            val id = parsedIds.getString(i)
            val label = layer.getLabel(id) ?: continue
            layer.remove(label)
        }

        result.success(null)
    }

    private fun clearMarkers(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        kMap.labelManager?.removeAllLabelLayer()

        return result.success(null)
    }

    private fun getCenter(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val center = kMap.cameraPosition?.position
        return result.success(
            mapOf(
                "latitude" to center?.latitude,
                "longitude" to center?.longitude,
            )
        )
    }

    private fun toScreenPoint(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val position = args.getJSONObject("position").toLatLng()
        val latLng = LatLng.from(position.latitude, position.longitude)

        val point = kMap.toScreenPoint(latLng)

        return result.success(
            mapOf(
                "dx" to point?.x,
                "dy" to point?.y,
            )
        )
    }

    private fun fromScreenPoint(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val point = args.getJSONObject("point")
        val dx = point.getDouble("dx")
        val dy = point.getDouble("dy")

        val latLng = kMap.fromScreenPoint(dx.toInt(), dy.toInt())

        return result.success(
            mapOf(
                "latitude" to latLng?.latitude,
                "longitude" to latLng?.longitude,
            )
        )
    }

    private fun setPoiVisible(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val isVisible = args.optBoolean("isVisible", true)
        kMap.isPoiVisible = isVisible

        return result.success(null)
    }

    private fun setPoiClickable(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val isClickable = args.optBoolean("isClickable", true)
        kMap.isPoiClickable = isClickable

        return result.success(null)
    }

    private fun setPoiScale(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val scale = args.optInt("scale", 1)
        kMap.poiScale = PoiScale.getEnum(scale)

        return result.success(null)
    }

    private fun setPadding(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val left = args.optInt("left", 0)
        val top = args.optInt("top", 0)
        val right = args.optInt("right", 0)
        val bottom = args.optInt("bottom", 0)

        kMap.setPadding(left, top, right, bottom)

        return result.success(null)
    }

    private fun setViewport(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val width = args.optInt("width", 0)
        val height = args.optInt("height", 0)

        kMap.setViewport(width, height)

        return result.success(null)
    }

    private fun getViewportBounds(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val northeast = kMap.viewport.right to kMap.viewport.top
        val southwest = kMap.viewport.left to kMap.viewport.bottom

        return result.success(
            mapOf(
                "northeast" to
                        mapOf(
                            "latitude" to northeast.first,
                            "longitude" to northeast.second,
                        ),
                "southwest" to
                        mapOf(
                            "latitude" to southwest.first,
                            "longitude" to southwest.second,
                        ),
            )
        )
    }

    private fun getMapInfo(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val cameraPosition: CameraPosition? = kMap.cameraPosition
        if (cameraPosition == null) {
            return result.success(null)
        }

        return result.success(
            mapOf(
                "zoomLevel" to cameraPosition.zoomLevel,
                "rotation" to cameraPosition.rotationAngle,
                "tilt" to cameraPosition.tiltAngle,
            )
        )
    }

    // InfoWindow methods using native InfoWindowLayer API with GuiView support
    private fun addInfoWindow(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        try {
            // Use the new extension method that supports GuiView components
            val options = args.toNativeInfoWindowOptions()
                ?: return result.error(
                    "E003",
                    "Failed to parse InfoWindow options",
                    null
                )

            // Add InfoWindow to the map using the native API
            kMap.mapWidgetManager?.infoWindowLayer?.addInfoWindow(options)

            return result.success(null)
        } catch (e: Exception) {
            return result.error("E003", "Error adding InfoWindow: ${e.message}", null)
        }
    }

    private fun removeInfoWindow(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        try {
            val id = args.getString("id") ?: throw IllegalArgumentException("id must not be null")
            val infoWindow = kMap.mapWidgetManager?.infoWindowLayer?.getInfoWindow(id)
            infoWindow?.remove()
            return result.success(null)
        } catch (e: Exception) {
            return result.error("E004", "Error removing InfoWindow: ${e.message}", null)
        }
    }

    private fun addInfoWindows(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        try {
            val infoWindowOptions = args.getJSONArray("infoWindowOptions")

            for (i in 0 until infoWindowOptions.length()) {
                val infoWindowJson = infoWindowOptions.getJSONObject(i)

                // Use the new extension method for each InfoWindow
                val options = infoWindowJson.toNativeInfoWindowOptions()
                if (options != null) {
                    kMap.mapWidgetManager?.infoWindowLayer?.addInfoWindow(options)
                }
            }
            return result.success(null)
        } catch (e: Exception) {
            return result.error("E005", "Error adding InfoWindows: ${e.message}", null)
        }
    }

    private fun removeInfoWindows(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        try {
            val ids = args.getJSONArray("ids")

            for (i in 0 until ids.length()) {
                val id = ids.getString(i)
                val infoWindow = kMap.mapWidgetManager?.infoWindowLayer?.getInfoWindow(id)
                infoWindow?.remove()
            }
            return result.success(null)
        } catch (e: Exception) {
            return result.error("E006", "Error removing InfoWindows: ${e.message}", null)
        }
    }

    private fun updateInfoWindow(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        try {
            val id = args.getString("id") ?: throw IllegalArgumentException("id must not be null")

            // Remove existing InfoWindow if it exists
            val existingInfoWindow = kMap.mapWidgetManager?.infoWindowLayer?.getInfoWindow(id)
            existingInfoWindow?.remove()

            // Add updated InfoWindow with new options
            val options = args.toNativeInfoWindowOptions()
                ?: return result.error(
                    "E007",
                    "Failed to parse InfoWindow options for update",
                    null
                )

            kMap.mapWidgetManager?.infoWindowLayer?.addInfoWindow(options)

            return result.success(null)
        } catch (e: Exception) {
            return result.error("E007", "Error updating InfoWindow: ${e.message}", null)
        }
    }

    private fun clearInfoWindows(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        try {
            // Use the native InfoWindowLayer removeAll() method as suggested
            kMap.mapWidgetManager?.infoWindowLayer?.removeAll()
            return result.success(null)
        } catch (e: Exception) {
            return result.error(
                "E010",
                "Error clearing InfoWindows: ${e.message}",
                null,
            )
        }
    }

    private fun showCompass(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val compass = kMap.compass
        compass?.show()

        return result.success(null)
    }

    private fun hideCompass(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val compass = kMap.compass
        compass?.hide()

        return result.success(null)
    }

    private fun showScaleBar(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val scaleBar = kMap.scaleBar
        scaleBar?.show()

        return result.success(null)
    }

    private fun hideScaleBar(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val scaleBar = kMap.scaleBar
        scaleBar?.hide()

        return result.success(null)
    }

    private fun setCompassPosition(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val alignment = args.getString("alignment")
        val offset = args.optJSONObject("offset")

        if (alignment == null) {
            return result.error("E008", "alignment must not be null", null)
        }

        val mapGravity = convertAlignmentToMapGravity(alignment)
        val offsetX = (offset?.get("dx") as? Number)?.toFloat() ?: 0f
        val offsetY = (offset?.get("dy") as? Number)?.toFloat() ?: 0f

        val compass = kMap.compass
        compass?.setPosition(mapGravity, offsetX, offsetY)

        return result.success(null)
    }

    private fun showLogo(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        // Note: Android SDK doesn't have direct logo control methods
        // The logo is typically controlled by the SDK internally
        Log.d("KakaoMapController", "showLogo called - logo visibility controlled by SDK")
        return result.success(null)
    }

    private fun hideLogo(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        // Note: Android SDK doesn't have direct logo control methods
        // The logo is typically controlled by the SDK internally
        Log.d("KakaoMapController", "hideLogo called - logo visibility controlled by SDK")
        return result.success(null)
    }

    private fun setLogoPosition(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val alignment = args.getString("alignment")
        args.optJSONObject("offset")

        if (alignment == null) {
            return result.error("E008", "alignment must not be null", null)
        }

        // Note: Android SDK doesn't have direct logo position control methods
        // The logo position is typically controlled by the SDK internally
        Log.d(
            "KakaoMapController",
            "setLogoPosition called with alignment: $alignment - logo position controlled by SDK"
        )
        return result.success(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d("KakaoMapController", "onMethodCall: ${call.method}")

        when (call.method) {
            "getZoomLevel" -> getZoomLevel(result)
            "setZoomLevel" -> setZoomLevel(call.arguments as JSONObject, result)
            "moveCamera" -> moveCamera(call.arguments as JSONObject, result)
            "addMarker" -> addMarker(call.arguments as JSONObject, result)
            "removeMarker" -> removeMarker(call.arguments as JSONObject, result)
            "addMarkers" -> addMarkers(call.arguments as JSONObject, result)
            "removeMarkers" -> removeMarkers(call.arguments as JSONObject, result)
            "clearMarkers" -> clearMarkers(result)
            "getCenter" -> getCenter(result)
            "toScreenPoint" -> toScreenPoint(call.arguments as JSONObject, result)
            "fromScreenPoint" -> fromScreenPoint(call.arguments as JSONObject, result)
            "setPoiVisible" -> setPoiVisible(call.arguments as JSONObject, result)
            "setPoiClickable" -> setPoiClickable(call.arguments as JSONObject, result)
            "setPoiScale" -> setPoiScale(call.arguments as JSONObject, result)
            "setPadding" -> setPadding(call.arguments as JSONObject, result)
            "setViewport" -> setViewport(call.arguments as JSONObject, result)
            "getViewportBounds" -> getViewportBounds(result)
            "getMapInfo" -> getMapInfo(result)
            "addInfoWindow" -> addInfoWindow(call.arguments as JSONObject, result)
            "removeInfoWindow" -> removeInfoWindow(call.arguments as JSONObject, result)
            "addInfoWindows" -> addInfoWindows(call.arguments as JSONObject, result)
            "removeInfoWindows" -> removeInfoWindows(call.arguments as JSONObject, result)
            "updateInfoWindow" -> updateInfoWindow(call.arguments as JSONObject, result)
            "clearInfoWindows" -> clearInfoWindows(result)
            "showCompass" -> showCompass(result)
            "hideCompass" -> hideCompass(result)
            "showScaleBar" -> showScaleBar(result)
            "hideScaleBar" -> hideScaleBar(result)
            "setCompassPosition" -> setCompassPosition(call.arguments as JSONObject, result)
            "showLogo" -> showLogo(result)
            "hideLogo" -> hideLogo(result)
            "setLogoPosition" -> setLogoPosition(call.arguments as JSONObject, result)
            else -> result.notImplemented()
        }
    }

    override fun getView(): View {
        return mapView
    }

    override fun dispose() {
        mapView.finish()
        methodChannel.setMethodCallHandler(null)
    }

    /**
     * Convert alignment string to MapGravity constant for compass positioning
     * Based on Android Kakao Maps SDK MapGravity constants
     */
    private fun convertAlignmentToMapGravity(alignment: String): Int {
        return when (alignment) {
            "topLeft" -> MapGravity.TOP or MapGravity.LEFT
            "topRight" -> MapGravity.TOP or MapGravity.RIGHT
            "bottomLeft" -> MapGravity.BOTTOM or MapGravity.LEFT
            "bottomRight" -> MapGravity.BOTTOM or MapGravity.RIGHT
            "center" -> MapGravity.CENTER
            "topCenter" -> MapGravity.TOP or MapGravity.CENTER_HORIZONTAL
            "bottomCenter" -> MapGravity.BOTTOM or MapGravity.CENTER_HORIZONTAL
            "leftCenter" -> MapGravity.LEFT or MapGravity.CENTER_VERTICAL
            "rightCenter" -> MapGravity.RIGHT or MapGravity.CENTER_VERTICAL
            else -> MapGravity.TOP or MapGravity.RIGHT // Default to top-right
        }
    }
}
