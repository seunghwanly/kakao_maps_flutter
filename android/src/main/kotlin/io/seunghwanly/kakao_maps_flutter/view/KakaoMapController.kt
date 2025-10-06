package io.seunghwanly.kakao_maps_flutter.view

import android.content.Context
import android.graphics.BitmapFactory
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
import com.kakao.vectormap.label.Label
import com.kakao.vectormap.label.LabelLayer
import com.kakao.vectormap.label.LabelLayerOptions
import com.kakao.vectormap.label.LabelOptions
import com.kakao.vectormap.label.LabelStyle
import com.kakao.vectormap.label.LabelStyles
import com.kakao.vectormap.label.LabelTextBuilder
import com.kakao.vectormap.label.LabelTextStyle
import com.kakao.vectormap.label.LodLabel
import com.kakao.vectormap.label.LodLabelLayer
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.seunghwanly.kakao_maps_flutter.constant.DefaultLabelStyle
import io.seunghwanly.kakao_maps_flutter.constant.DefaultLabelTextStyle
import io.seunghwanly.kakao_maps_flutter.data.cameraAnimation.toCameraAnimationOrNull
import io.seunghwanly.kakao_maps_flutter.data.cameraUpdate.toCameraUpdate
import io.seunghwanly.kakao_maps_flutter.data.infoWindowOption.toNativeInfoWindowOptions
import io.seunghwanly.kakao_maps_flutter.data.labelClickEvent.LabelClickEvent
import io.seunghwanly.kakao_maps_flutter.data.labelOption.LabelOption
import io.seunghwanly.kakao_maps_flutter.data.labelOption.toLabelOptionOrNull
import io.seunghwanly.kakao_maps_flutter.data.latLng.toLatLng
import org.json.JSONArray
import org.json.JSONObject
import java.util.Collections
import kotlin.io.encoding.Base64
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
    private var initialPosition: LatLng?

    // Parse initial zoom level from args
    private var initialLevel: Int?

    // Parse compass configuration from args
    private var compassConfig: Map<String, Any?>?

    // Parse scaleBar configuration from args
    private var scaleBarConfig: Map<String, Any?>?

    // Parse logo configuration from args
    private var logoConfig: Map<String, Any?>?

    private var registeredLabelStylesIds = Collections.synchronizedSet(mutableSetOf<String>())

    // LOD layers registry (logical layerId -> SDK LodLabelLayer)
    private val lodLayers: MutableMap<String, LodLabelLayer> =
        Collections.synchronizedMap(mutableMapOf())

    init {
        // Register Flutter MethodCallHandler
        methodChannel.setMethodCallHandler(this@KakaoMapController)

        initialPosition = parseInitialPosition(args)
        initialLevel = parseInitialLevel(args)
        compassConfig = parseCompassConfig(args)
        scaleBarConfig = parseScaleBarConfig(args)
        logoConfig = parseLogoConfig(args)

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

                        val event = LabelClickEvent.fromLabel(
                            label = label,
                            layerId = labelLayer?.layerId,
                        )

                        methodChannel.invokeMethod("onLabelClicked", event.toMap())

                        true
                    }

                    kMap.setOnInfoWindowClickListener { kakaoMap, infoWindow, id ->

                        val event = mapOf(
                            "infoWindowId" to id, "latLng" to mapOf(
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

    // Helper to get a normal LabelLayer (no implicit creation when layerId is provided)
    private fun getOrCreateLabelLayer(layerId: String?): LabelLayer? {
        val manager = kMap.labelManager ?: return null
        if (layerId.isNullOrEmpty()) return manager.layer
        return manager.getLayer(layerId)
    }

    private fun JSONObject.toMap(): Map<String, Any?> = keys().asSequence().associateWith { key ->
        when (val value = this.get(key)) {
            is JSONObject -> value.toMap()
            else -> value
        }
    }

    // Convert Any? (Map/List/primitive/JSONObject) -> JSONObject/JSONArray/primitive recursively
    private fun toJSONDeep(value: Any?): Any? {
        return when (value) {
            is JSONObject -> value
            is JSONArray -> value
            is Map<*, *> -> {
                val obj = JSONObject()
                value.forEach { (k, v) ->
                    if (k != null) obj.put(k.toString(), toJSONDeep(v))
                }
                obj
            }

            is List<*> -> {
                val arr = JSONArray()
                value.forEach { item -> arr.put(toJSONDeep(item)) }
                arr
            }

            else -> value
        }
    }

    private fun asJSONObject(args: Any?): JSONObject {
        val converted = toJSONDeep(args)
        return when (converted) {
            is JSONObject -> converted
            else -> JSONObject()
        }
    }

    private fun parseInitialPosition(args: Any?): LatLng? {
        val data: Map<*, *>? = when (args) {
            is Map<*, *> -> args
            is JSONObject -> args.toMap()
            else -> null
        }
        if (data == null) return null

        val initialPositionMap = data["initialPosition"] as? Map<*, *> ?: return null
        val latitude = initialPositionMap["latitude"] as? Double ?: return null
        val longitude = initialPositionMap["longitude"] as? Double ?: return null

        return LatLng.from(latitude, longitude)
    }

    private fun parseInitialLevel(args: Any?): Int? {
        val data: Map<*, *>? = when (args) {
            is Map<*, *> -> args
            is JSONObject -> args.toMap()
            else -> null
        }
        if (data == null) return null

        return data["initialLevel"] as? Int
    }

    private fun parseCompassConfig(args: Any?): Map<String, Any?>? {
        val data: Map<*, *>? = when (args) {
            is Map<*, *> -> args
            is JSONObject -> args.toMap()
            else -> null
        }
        if (data == null) return null

        val compassRaw = data["compass"]
        return when (compassRaw) {
            is Map<*, *> -> compassRaw.entries.associate {
                it.key.toString() to it.value
            }

            is JSONObject -> compassRaw.toMap()
            else -> null
        }
    }

    private fun parseScaleBarConfig(args: Any?): Map<String, Any?>? {
        val data: Map<*, *>? = when (args) {
            is Map<*, *> -> args
            is JSONObject -> args.toMap()
            else -> null
        }
        if (data == null) return null

        val scaleBarRaw = data["scaleBar"]
        return when (scaleBarRaw) {
            is Map<*, *> -> scaleBarRaw.entries.associate {
                it.key.toString() to it.value
            }

            is JSONObject -> scaleBarRaw.toMap()
            else -> null
        }
    }

    private fun parseLogoConfig(args: Any?): Map<String, Any?>? {
        val data: Map<*, *>? = when (args) {
            is Map<*, *> -> args
            is JSONObject -> args.toMap()
            else -> null
        }
        if (data == null) return null

        val logoRaw = data["logo"]
        return when (logoRaw) {
            is Map<*, *> -> logoRaw.entries.associate {
                it.key.toString() to it.value
            }

            is JSONObject -> logoRaw.toMap()
            else -> null
        }
    }

    private fun JSONObject.extractLayerId(): String? {
        // optString(key, fallback)은 키가 없거나 값이 null일 때 fallback을 반환합니다.
        // 따라서 기존의 긴 if문과 완벽하게 동일한 역할을 합니다.
        return optString("layerId", null)
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
        val labelOption: LabelOption = args.toLabelOptionOrNull() ?: return result.error(
            "E001",
            "label must not be null",
            null,
        )

        val layer: LabelLayer =
            getOrCreateLabelLayer(args.extractLayerId()) ?: return result.error(
                "E002",
                "Either LabelManager or its layer is null",
                null,
            )

        if (layer.hasLabel(labelOption.id)) {
            layer.getLabel(labelOption.id)?.remove()
        }

        // Get registered style: registry -> SDK -> fallback(default text only)
        val styleId: String? =
            args.optString("styleId", "").takeIf { args.has("styleId") && it.isNotBlank() }
        var labelStyles: LabelStyles = LabelStyles.from(DefaultLabelStyle.getStyle())
        if (styleId != null) {
            val registered = kMap.labelManager?.getLabelStyles(styleId)
            if (registered != null) labelStyles = registered
        }

        val labelTextBuilder = LabelTextBuilder()
        if (labelOption.text?.isNotEmpty() ?: false) {
            labelTextBuilder.setTexts(labelOption.text)
        }

        layer
            .addLabel(
                LabelOptions.from(
                    labelOption.id,
                    labelOption.latLng,
                )
                    .setRank(labelOption.rank)
                    .setStyles(labelStyles)
            )
            .changeText(labelTextBuilder)

        return result.success(null)
    }

    private fun removeMarker(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val labelId: String? = args.optString("id")
        if (labelId.isNullOrEmpty()) {
            return result.error(
                "E001",
                "id must not be null or empty",
                null,
            )
        }

        val layer: LabelLayer? = getOrCreateLabelLayer(args.extractLayerId())
        layer?.getLabel(labelId)?.remove()

        return result.success(null)
    }

    @OptIn(ExperimentalEncodingApi::class)
    private fun addMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized)

        val options = args.getJSONArray("markers")

        val layer = getOrCreateLabelLayer(args.extractLayerId()) ?: return result.error(
            "E002", "Layer is null", null
        )

        val labelOptions: MutableList<LabelOptions> = mutableListOf()

        for (i in 0 until options.length()) {
            val option = options.getJSONObject(i).toLabelOptionOrNull() ?: continue

            if (layer.hasLabel(option.id)) {
                layer.getLabel(option.id)?.remove()
            }

            val item = options.getJSONObject(i)
            val styleId: String? =
                item.optString("styleId", "").takeIf { item.has("styleId") && it.isNotBlank() }
            var labelStyles = LabelStyles.from(DefaultLabelStyle.getStyle())
            if (styleId != null) {
                val registered = kMap.labelManager?.getLabelStyles(styleId)
                if (registered != null) labelStyles = registered
            }

            val labelTextBuilder = LabelTextBuilder()
            if (option.text?.isNotEmpty() ?: false) {
                labelTextBuilder.setTexts(option.text)
            }

            val labelOption = LabelOptions.from(option.id, option.latLng)
                .setRank(option.rank)
                .setStyles(labelStyles)
                .setTexts(labelTextBuilder)
            labelOptions.add(labelOption)
        }

        layer.addLabels(labelOptions)

        result.success(null)
    }

    private fun removeMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized)

        val layer = getOrCreateLabelLayer(args.extractLayerId()) ?: return result.error(
            "E002", "Layer is null", null
        )
        val parsedIds = args.getJSONArray("ids")

        val labels: MutableList<Label> = mutableListOf()

        for (i in 0 until parsedIds.length()) {
            val id = parsedIds.getString(i)
            val label = layer.getLabel(id) ?: continue
            labels.add(label)
        }

        layer.remove(*labels.toTypedArray())

        result.success(null)
    }

    private fun clearMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        if (layerId.isEmpty()) return result.error("E001", "layerId must not be empty", null)
        val layer = kMap.labelManager?.getLayer(layerId) ?: return result.success(null)
        layer.removeAll()
        return result.success(null)
    }

    // Add normal LabelLayer
    private fun addMarkerLayer(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        if (layerId.isEmpty()) return result.error("E001", "layerId must not be empty", null)
        val manager = kMap.labelManager
        if (manager == null) return result.error("E002", "LabelManager is null", null)
        val existing =
            manager.getLayer(layerId) ?: manager.addLayer(LabelLayerOptions.from(layerId))
        if (existing != null) {
            if (args.has("zOrder") && !args.isNull("zOrder")) existing.setZOrder(
                args.optInt(
                    "zOrder", existing.zOrder
                )
            )
            if (args.has("clickable") && !args.isNull("clickable")) existing.isClickable =
                args.optBoolean(
                    "clickable", true
                )
        }
        return result.success(null)
    }

    // ===== LabelLayer controls (non-LOD) =====
    private fun setMarkerLayerVisible(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        val visible = args.optBoolean("visible", true)
        if (layerId.isEmpty()) return result.error("E001", "layerId must not be empty", null)
        val layer = kMap.labelManager?.getLayer(layerId) ?: return result.success(null)
        layer.isVisible = visible
        return result.success(null)
    }

    private fun showAllMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        if (layerId.isEmpty()) return result.error("E001", "layerId must not be empty", null)
        val layer = kMap.labelManager?.getLayer(layerId) ?: return result.success(null)
        layer.showAllLabels()
        return result.success(null)
    }

    private fun hideAllMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        if (layerId.isEmpty()) return result.error("E001", "layerId must not be empty", null)
        val layer = kMap.labelManager?.getLayer(layerId) ?: return result.success(null)
        layer.hideAllLabels()
        return result.success(null)
    }

    // ===== LOD Marker (LodLabel) helpers =====
    private fun getOrCreateLodLayer(layerId: String): LodLabelLayer? {
        // If exists, return
        lodLayers[layerId]?.let { return it }

        // Acquire SDK default Lod layer (Android SDK exposes a single Lod layer)
        val sdkLayer = kMap.labelManager?.lodLayer
            ?: kMap.labelManager?.lodLayer // fallback if property not available
            ?: return null

        lodLayers[layerId] = sdkLayer
        return sdkLayer
    }

    private fun addLodMarkerLayer(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val layerId = args.optString("layerId", "")
        if (layerId.isEmpty()) {
            return result.error("E001", "layerId must not be empty", null)
        }

        val layer = getOrCreateLodLayer(layerId) ?: return result.error(
            "E002",
            "Failed to acquire LodLabelLayer",
            null
        )

        // Apply zOrder if provided
        if (args.has("zOrder") && !args.isNull("zOrder")) {
            layer.zOrder = args.optInt("zOrder", layer.zOrder)
        }
        // clickable default true
        if (args.has("clickable")) {
            layer.isClickable = args.optBoolean("clickable", true)
        }

        return result.success(null)
    }

    private fun removeLodMarkerLayer(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val layerId = args.optString("layerId", "")
        if (layerId.isEmpty()) {
            return result.error("E001", "layerId must not be empty", null)
        }
        val layer = lodLayers.remove(layerId) ?: return result.success(null)
        layer.removeAll()
        return result.success(null)
    }

    @OptIn(ExperimentalEncodingApi::class)
    private fun addLodMarker(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val layerId = args.optString("layerId", "")
        val optionJson = args.optJSONObject("option") ?: return result.error(
            "E001",
            "option must not be null",
            null
        )
        val option =
            optionJson.toLabelOptionOrNull() ?: return result.error("E001", "invalid option", null)

        val layer = getOrCreateLodLayer(layerId) ?: return result.error(
            "E002",
            "Failed to acquire LodLabelLayer",
            null
        )

        // Resolve styles
        val styleId: String? = optionJson.optString("styleId", "")
            .takeIf { optionJson.has("styleId") && it.isNotBlank() }
        var labelStyles: LabelStyles = LabelStyles.from(DefaultLabelStyle.getStyle())
        if (styleId != null) {
            val registered = kMap.labelManager?.getLabelStyles(styleId)
            if (registered != null) labelStyles = registered
        }

        val labelTextBuilder = LabelTextBuilder()
        if (option.text?.isNotEmpty() ?: false) {
            labelTextBuilder.setTexts(option.text)
        }

        val labelOptions =
            LabelOptions.from(option.id, option.latLng)
                .setStyles(labelStyles)
                .setRank(option.rank)

        // Replace if exists
        if (layer.hasLabel(option.id)) {
            layer.getLabel(option.id)?.remove()
        }

        val created: LodLabel? = layer.addLodLabel(labelOptions)
        created?.changeText(labelTextBuilder)
        created?.show()

        return result.success(created != null)
    }

    @OptIn(ExperimentalEncodingApi::class)
    private fun addLodMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val layerId = args.optString("layerId", "")
        val optionsArr = args.optJSONArray("options") ?: return result.error(
            "E001",
            "options must not be null",
            null
        )

        val layer = getOrCreateLodLayer(layerId) ?: return result.error(
            "E002",
            "Failed to acquire LodLabelLayer",
            null
        )

        val list = mutableListOf<LabelOptions>()

        for (i in 0 until optionsArr.length()) {
            val item = optionsArr.optJSONObject(i) ?: continue
            val option = item.toLabelOptionOrNull() ?: continue

            if (layer.hasLabel(option.id)) {
                layer.getLabel(option.id)?.remove()
            }

            val styleId: String? =
                item.optString("styleId", "").takeIf { item.has("styleId") && it.isNotBlank() }

            var labelStyles: LabelStyles = LabelStyles.from(DefaultLabelStyle.getStyle())
            if (styleId != null) {
                val fetched = kMap.labelManager?.getLabelStyles(styleId)
                if (fetched != null) labelStyles = fetched
            }

            val labelTextBuilder = LabelTextBuilder()
            if (option.text?.isNotEmpty() ?: false) {
                labelTextBuilder.setTexts(option.text)
            }

            val labelOption = LabelOptions
                .from(option.id, option.latLng)
                .setRank(option.rank)
                .setStyles(labelStyles)
                .setTexts(labelTextBuilder)

            list.add(labelOption)
        }

        val created = layer.addLodLabels(list.toList())
        // Optionally show all
        layer.showAllLodLabels()
        return result.success(created != null)
    }

    private fun removeLodMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        val ids =
            args.optJSONArray("ids") ?: return result.error("E001", "ids must not be null", null)
        val layer = lodLayers[layerId] ?: return result.success(null)

        val labels = mutableListOf<LodLabel>()
        for (i in 0 until ids.length()) {
            val id = ids.getString(i)
            val label = layer.getLabel(id) ?: continue
            labels.add(label)
        }
        if (labels.isNotEmpty()) layer.remove(*labels.toTypedArray())
        return result.success(null)
    }

    private fun clearAllLodMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        val layer = lodLayers[layerId] ?: return result.success(null)
        layer.removeAll()
        return result.success(null)
    }

    private fun showAllLodMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        val layer = lodLayers[layerId] ?: return result.success(null)
        layer.showAllLodLabels()
        return result.success(null)
    }

    private fun hideAllLodMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        val layer = lodLayers[layerId] ?: return result.success(null)
        layer.hideAllLodLabels()
        return result.success(null)
    }

    private fun showLodMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        val ids =
            args.optJSONArray("ids") ?: return result.error("E001", "ids must not be null", null)
        val layer = lodLayers[layerId] ?: return result.success(null)

        for (i in 0 until ids.length()) {
            val id = ids.getString(i)
            layer.getLabel(id)?.show()
        }
        return result.success(null)
    }

    private fun hideLodMarkers(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        val ids =
            args.optJSONArray("ids") ?: return result.error("E001", "ids must not be null", null)
        val layer = lodLayers[layerId] ?: return result.success(null)

        for (i in 0 until ids.length()) {
            val id = ids.getString(i)
            layer.getLabel(id)?.hide()
        }
        return result.success(null)
    }

    private fun setLodMarkerLayerClickable(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        val layerId = args.optString("layerId", "")
        val clickable = args.optBoolean("clickable", true)
        val layer = lodLayers[layerId] ?: return result.success(null)
        layer.isClickable = clickable
        return result.success(null)
    }

    // Marker styles registration (Flutter -> Native)
    @OptIn(ExperimentalEncodingApi::class)
    private fun registerMarkerStyles(args: Any?, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        // Support both StandardMethodCodec(Map/ByteArray) and JSON codec(JSONObject/Base64)
        val stylesListAny: List<*>? = when (args) {
            is Map<*, *> -> args["styles"] as? List<*>
            is JSONObject -> {
                val arr = args.optJSONArray("styles") ?: return result.error(
                    "E001", "Invalid arguments for registerMarkerStyles", null
                )
                (0 until arr.length()).map { arr.getJSONObject(it) }
            }

            else -> null
        }

        if (stylesListAny == null) {
            return result.error("E001", "Invalid arguments for registerMarkerStyles", null)
        }

        for (styleAny in stylesListAny) {
            val (styleId, perLevels) = when (styleAny) {
                is Map<*, *> -> Pair(
                    styleAny["styleId"] as String,
                    styleAny["perLevels"] as? List<*> ?: emptyList<Any>()
                )

                is JSONObject -> Pair(
                    styleAny.getString("styleId"),
                    (0 until styleAny.getJSONArray("perLevels").length()).map {
                        styleAny.getJSONArray("perLevels").getJSONObject(it)
                    })

                else -> continue
            }

            if (perLevels.isEmpty()) continue
            val first = perLevels.first()

            // Extract icon bytes
            val iconBytes: ByteArray? = when (first) {
                is Map<*, *> -> {
                    val iconAny = first["icon"]
                    when (iconAny) {
                        is ByteArray -> iconAny
                        is List<*> -> (iconAny.filterIsInstance<Number>()
                            .map { it.toByte() }).toByteArray()

                        is String -> Base64.Default.decode(
                            iconAny.substringAfter(
                                "base64,", iconAny
                            )
                        )

                        else -> null
                    }
                }

                is JSONObject -> {
                    val rawIcon = first.opt("icon")
                    when (rawIcon) {
                        is String -> Base64.Default.decode(
                            rawIcon.substringAfter(
                                "base64,", rawIcon
                            )
                        )

                        else -> null
                    }
                }

                else -> null
            }

            if (iconBytes == null || iconBytes.isEmpty()) {
                Log.e("KakaoMapController", "Invalid icon bytes for styleId=$styleId")
                continue
            }

            val bitmap = BitmapFactory.decodeByteArray(iconBytes, 0, iconBytes.size) ?: run {
                Log.e(
                    "KakaoMapController",
                    "Failed to decode icon bytes for styleId=$styleId (bytes=${iconBytes.size})"
                )
                return
            }

            val stylesList = mutableListOf<LabelStyle>()

            var fontSize: Int = DefaultLabelTextStyle.FONT_SIZE
            var fontColor: Int = DefaultLabelTextStyle.FONT_COLOR
            var strokeThickness: Int = DefaultLabelTextStyle.STROKE_THICKNESS
            var strokeColor: Int = DefaultLabelTextStyle.STROKE_COLOR

            // textStyle
            when (first) {
                is Map<*, *> -> {
                    val ts = first["textStyle"] as? Map<*, *>
                    if (ts != null) {
                        when (ts["fontSize"]) {
                            is Number -> fontSize = (ts["fontSize"] as Number).toInt()
                        }
                        when (ts["fontColor"]) {
                            is Number -> fontColor = (ts["fontColor"] as Number).toInt()
                        }
                        when (ts["strokeThickness"]) {
                            is Number -> strokeThickness = (ts["strokeThickness"] as Number).toInt()
                        }
                        when (ts["strokeColor"]) {
                            is Number -> strokeColor = (ts["strokeColor"] as Number).toInt()
                        }
                    }
                }

                is JSONObject -> {
                    val ts = first.optJSONObject("textStyle")
                    if (ts != null) {
                        fontSize = ts.optInt("fontSize", DefaultLabelTextStyle.FONT_SIZE)
                        fontColor = ts.optInt("fontColor", DefaultLabelTextStyle.FONT_COLOR)
                        strokeThickness =
                            ts.optInt("strokeThickness", DefaultLabelTextStyle.STROKE_THICKNESS)
                        strokeColor = ts.optInt("strokeColor", DefaultLabelTextStyle.STROKE_COLOR)
                    }
                }
            }

            val labelTextStyle =
                LabelTextStyle.from(fontSize, fontColor, strokeThickness, strokeColor)

            stylesList.add(LabelStyle.from(bitmap).setTextStyles(labelTextStyle))

            val labelStyles = LabelStyles.from(styleId, *stylesList.toTypedArray())
            kMap.labelManager?.addLabelStyles(labelStyles)
            registeredLabelStylesIds.add(styleId)
        }

        Log.d("KakaoMapController", "Marker styles registered: $registeredLabelStylesIds")

        result.success(null)
    }

    private fun removeMarkerStyles(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val styleIds = args.optJSONArray("styleIds") ?: return result.error(
            "E001",
            "Invalid arguments for removeMarkerStyles",
            null
        )
        for (i in 0 until styleIds.length()) {
            val sid = styleIds.getString(i)
            kMap.labelManager?.getLabelStyles(sid)?.styles = arrayOf()
            kMap.labelManager?.getLabelStyles(sid)?.styleId = ""
            registeredLabelStylesIds.remove(sid)
        }
        return result.success(null)
    }

    private fun clearMarkerStyles(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }
        registeredLabelStylesIds.forEach { id ->
            kMap.labelManager?.getLabelStyles(id)?.styles = arrayOf()
            kMap.labelManager?.getLabelStyles(id)?.styleId = ""
        }
        registeredLabelStylesIds.clear()
        return result.success(null)
    }

    private fun getCenter(result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        val center = kMap.cameraPosition?.position ?: return result.success(null)
        return result.success(
            mapOf(
                "latitude" to center.latitude,
                "longitude" to center.longitude,
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

        val latLng = kMap.fromScreenPoint(dx.toInt(), dy.toInt()) ?: return result.success(null)

        return result.success(
            mapOf(
                "latitude" to latLng.latitude,
                "longitude" to latLng.longitude,
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
                "northeast" to mapOf(
                    "latitude" to northeast.first,
                    "longitude" to northeast.second,
                ),
                "southwest" to mapOf(
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
            val options = args.toNativeInfoWindowOptions() ?: return result.error(
                "E003", "Failed to parse InfoWindow options", null
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
            val options = args.toNativeInfoWindowOptions() ?: return result.error(
                "E007", "Failed to parse InfoWindow options for update", null
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

    private fun setInfoWindowLayerVisible(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        try {
            val visible = args.optBoolean("visible", true)
            val layer = kMap.mapWidgetManager?.infoWindowLayer
            layer?.setVisible(visible)
            // 현재 등록된 모든 InfoWindow에 대해 show/hide를 호출하여 상태를 일치시킴
            val all = layer?.allInfoWindows
            if (all != null) {
                for (win in all) {
                    if (visible) win.show() else win.hide()
                }
            }
            return result.success(null)
        } catch (e: Exception) {
            return result.error(
                "E011", "Error setting InfoWindowLayer visibility: ${e.message}", null
            )
        }
    }

    private fun setInfoWindowVisible(args: JSONObject, result: MethodChannel.Result) {
        require(::kMap.isInitialized) { "kakaoMap is not initialized" }

        try {
            val id = args.getString("id")
            val visible = args.optBoolean("visible", true)
            val infoWindow = kMap.mapWidgetManager?.infoWindowLayer?.getInfoWindow(id)
            if (infoWindow == null) return result.success(null)
            if (visible) infoWindow.show() else infoWindow.hide()
            return result.success(null)
        } catch (e: Exception) {
            return result.error("E012", "Error setting InfoWindow visibility: ${e.message}", null)
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
            "registerMarkerStyles" -> registerMarkerStyles(call.arguments, result)
            "removeMarkerStyles" -> removeMarkerStyles(asJSONObject(call.arguments), result)
            "clearMarkerStyles" -> clearMarkerStyles(result)
            "getZoomLevel" -> getZoomLevel(result)
            "setZoomLevel" -> setZoomLevel(asJSONObject(call.arguments), result)
            "moveCamera" -> moveCamera(asJSONObject(call.arguments), result)
            "addMarker" -> addMarker(asJSONObject(call.arguments), result)
            "removeMarker" -> removeMarker(asJSONObject(call.arguments), result)
            "addMarkers" -> addMarkers(asJSONObject(call.arguments), result)
            "removeMarkers" -> removeMarkers(asJSONObject(call.arguments), result)
            "clearMarkers" -> clearMarkers(asJSONObject(call.arguments), result)
            "getCenter" -> getCenter(result)
            "toScreenPoint" -> toScreenPoint(asJSONObject(call.arguments), result)
            "fromScreenPoint" -> fromScreenPoint(asJSONObject(call.arguments), result)
            "setPoiVisible" -> setPoiVisible(asJSONObject(call.arguments), result)
            "setPoiClickable" -> setPoiClickable(asJSONObject(call.arguments), result)
            "setPoiScale" -> setPoiScale(asJSONObject(call.arguments), result)
            "setPadding" -> setPadding(asJSONObject(call.arguments), result)
            "setViewport" -> setViewport(asJSONObject(call.arguments), result)
            "getViewportBounds" -> getViewportBounds(result)
            "getMapInfo" -> getMapInfo(result)
            "addInfoWindow" -> addInfoWindow(asJSONObject(call.arguments), result)
            "removeInfoWindow" -> removeInfoWindow(asJSONObject(call.arguments), result)
            "addInfoWindows" -> addInfoWindows(asJSONObject(call.arguments), result)
            "removeInfoWindows" -> removeInfoWindows(asJSONObject(call.arguments), result)
            "updateInfoWindow" -> updateInfoWindow(asJSONObject(call.arguments), result)
            "clearInfoWindows" -> clearInfoWindows(result)
            "setInfoWindowLayerVisible" -> setInfoWindowLayerVisible(
                asJSONObject(call.arguments), result
            )

            "setInfoWindowVisible" -> setInfoWindowVisible(asJSONObject(call.arguments), result)
            "showCompass" -> showCompass(result)
            "hideCompass" -> hideCompass(result)
            "showScaleBar" -> showScaleBar(result)
            "hideScaleBar" -> hideScaleBar(result)
            "setCompassPosition" -> setCompassPosition(call.arguments as JSONObject, result)
            "showLogo" -> showLogo(result)
            "hideLogo" -> hideLogo(result)
            "setLogoPosition" -> setLogoPosition(call.arguments as JSONObject, result)
            "addMarkerLayer" -> addMarkerLayer(asJSONObject(call.arguments), result)
            // LabelLayer control (non-LOD)
            "setMarkerLayerVisible" -> setMarkerLayerVisible(asJSONObject(call.arguments), result)
            "showAllMarkers" -> showAllMarkers(asJSONObject(call.arguments), result)
            "hideAllMarkers" -> hideAllMarkers(asJSONObject(call.arguments), result)
            // LOD Marker (LodLabel) APIs
            "addLodMarkerLayer" -> addLodMarkerLayer(asJSONObject(call.arguments), result)
            "removeLodMarkerLayer" -> removeLodMarkerLayer(asJSONObject(call.arguments), result)
            "addLodMarker" -> addLodMarker(asJSONObject(call.arguments), result)
            "addLodMarkers" -> addLodMarkers(asJSONObject(call.arguments), result)
            "removeLodMarkers" -> removeLodMarkers(asJSONObject(call.arguments), result)
            "clearAllLodMarkers" -> clearAllLodMarkers(asJSONObject(call.arguments), result)
            "showAllLodMarkers" -> showAllLodMarkers(asJSONObject(call.arguments), result)
            "hideAllLodMarkers" -> hideAllLodMarkers(asJSONObject(call.arguments), result)
            "showLodMarkers" -> showLodMarkers(asJSONObject(call.arguments), result)
            "hideLodMarkers" -> hideLodMarkers(asJSONObject(call.arguments), result)
            "setLodMarkerLayerClickable" -> setLodMarkerLayerClickable(
                asJSONObject(call.arguments), result
            )

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
