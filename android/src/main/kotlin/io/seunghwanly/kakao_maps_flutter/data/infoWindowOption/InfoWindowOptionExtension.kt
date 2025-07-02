package io.seunghwanly.kakao_maps_flutter.data.infoWindowOption

import com.kakao.vectormap.LatLng
import com.kakao.vectormap.mapwidget.InfoWindowOptions
import com.kakao.vectormap.mapwidget.component.GuiText
import io.seunghwanly.kakao_maps_flutter.data.guiComponents.toGuiImage
import io.seunghwanly.kakao_maps_flutter.data.guiComponents.toGuiView
import org.json.JSONObject

/**
 * Extension functions to convert InfoWindowOption JSON to native Android InfoWindowOptions
 */

/**
 * Convert JSON to InfoWindowOption data class
 */
fun JSONObject.toInfoWindowOptionOrNull(): InfoWindowOption? {
    if (!this.has("id") || !this.has("latitude") || !this.has("longitude")) {
        return null
    }

    val latLng = LatLng.from(
        this.getDouble("latitude"),
        this.getDouble("longitude")
    )

    val offset = this.optJSONObject("offset")?.let { offsetJson ->
        InfoWindowOffset(
            offsetJson.optDouble("x", 0.0),
            offsetJson.optDouble("y", 0.0)
        )
    } ?: InfoWindowOffset(0.0, 0.0)

    this.optJSONObject("bodyOffset")?.let { bodyOffsetJson ->
        InfoWindowOffset(
            bodyOffsetJson.optDouble("x", 0.0),
            bodyOffsetJson.optDouble("y", 0.0)
        )
    } ?: InfoWindowOffset(0.0, 0.0)

    return InfoWindowOption(
        id = this.getString("id"),
        latLng = latLng,
        title = this.optString("title", null),
        snippet = this.optString("snippet", null),
        isVisible = this.optBoolean("isVisible", true),
        offset = offset,
    )
}

/**
 * Convert JSON to native Android InfoWindowOptions with GuiView support
 */
fun JSONObject.toNativeInfoWindowOptions(): InfoWindowOptions? {
    val id = this.optString("id", null)
    val latitude = this.optDouble("latitude", Double.NaN)
    val longitude = this.optDouble("longitude", Double.NaN)

    if (id.isNullOrEmpty() || latitude.isNaN() || longitude.isNaN()) {
        return null
    }

    val position = LatLng.from(latitude, longitude)
    val options = InfoWindowOptions.from(id, position)

    // Set visibility
    options.isVisible = this.optBoolean("isVisible", true)

    // Set zOrder
    options.zOrder = this.optInt("zOrder", 0)

    // Handle custom body or fallback to text
    val hasCustomBody = this.optBoolean("hasCustomBody", false)

    if (hasCustomBody) {
        // Use custom GuiView body
        val bodyJson = this.optJSONObject("body")
        if (bodyJson != null) {
            val guiBody = bodyJson.toGuiView()
            if (guiBody != null) {
                options.body = guiBody
            }
        }

        // Set body offset if provided
        val bodyOffsetJson = this.optJSONObject("bodyOffset")
        if (bodyOffsetJson != null) {
            val x = bodyOffsetJson.optDouble("x", 0.0).toInt()
            val y = bodyOffsetJson.optDouble("y", 0.0).toInt()
            options.setBodyOffset(x.toFloat(), y.toFloat())
        }

        // Set tail if provided
        val tailJson = this.optJSONObject("tail")
        if (tailJson != null) {
            val tailImage = tailJson.toGuiImage()
            if (tailImage != null) {
                options.tail = tailImage
            }
        }
    } else {
        // Fallback to simple text body
        val title = this.optString("title", "")
        if (title.isNotEmpty()) {
            options.body = GuiText(title)
        }
    }

    return options
}

/**
 * Create native InfoWindowOptions from the Android SDK example pattern:
 *
 * ```kotlin
 * GuiLayout body = new GuiLayout(Orientation.Horizontal);
 * body.setPadding(20, 20, 20, 18);
 *
 * GuiImage bgImage = new GuiImage(R.drawable.window_body, true);
 * image.setFixedArea(7, 7, 7, 7);
 * body.setBackground(bgImage);
 *
 * GuiText text = new GuiText("InfoWindow!");
 * text.setTextSize(30);
 * body.addView(text);
 *
 * InfoWindowOptions options = InfoWindowOptions.from(position);
 * options.setBody(body);
 * options.setBodyOffset(0, -4);
 * options.setTail(new GuiImage(R.drawable.window_tail, false));
 * ```
 */
fun createComplexInfoWindow(
    id: String,
    position: LatLng,
    bodyJson: JSONObject,
    tailJson: JSONObject? = null,
    bodyOffsetX: Int = 0,
    bodyOffsetY: Int = 0,
): InfoWindowOptions? {
    val options = InfoWindowOptions.from(id, position)

    // Create body from JSON
    val guiBody = bodyJson.toGuiView()
    if (guiBody != null) {
        options.body = guiBody
    }

    // Set body offset
    options.setBodyOffset(bodyOffsetX.toFloat(), bodyOffsetY.toFloat())

    // Set tail if provided
    if (tailJson != null) {
        val tailImage = tailJson.toGuiImage()
        if (tailImage != null) {
            options.tail = tailImage
        }
    }

    return options
}
