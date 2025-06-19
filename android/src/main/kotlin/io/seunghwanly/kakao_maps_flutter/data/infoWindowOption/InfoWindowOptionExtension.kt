package io.seunghwanly.kakao_maps_flutter.data.infoWindowOption

import com.kakao.vectormap.LatLng
import io.seunghwanly.kakao_maps_flutter.data.latLng.toLatLng
import org.json.JSONObject

fun JSONObject.toInfoWindowOptionOrNull(): InfoWindowOption? {
    return try {
        val id = this.getString("id")
        val latLngJson = this.getJSONObject("latLng")
        val latLng = latLngJson.toLatLng()
        val title = this.getString("title")
        val snippet = if (this.isNull("snippet")) null else this.getString("snippet")
        val isVisible = this.optBoolean("isVisible", true)

        val offsetJson = this.optJSONObject("offset")
        val offset =
                if (offsetJson != null) {
                    InfoWindowOffset(
                            x = offsetJson.optDouble("x", 0.0),
                            y = offsetJson.optDouble("y", 0.0),
                    )
                } else {
                    InfoWindowOffset(x = 0.0, y = 0.0)
                }

        InfoWindowOption(
                id = id,
                latLng = LatLng.from(latLng.latitude, latLng.longitude),
                title = title,
                snippet = snippet,
                isVisible = isVisible,
                offset = offset,
        )
    } catch (e: Exception) {
        null
    }
}
