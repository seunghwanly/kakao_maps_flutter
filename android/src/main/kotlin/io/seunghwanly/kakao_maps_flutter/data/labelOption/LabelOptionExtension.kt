package io.seunghwanly.kakao_maps_flutter.data.labelOption

import io.seunghwanly.kakao_maps_flutter.data.latLng.toLatLng
import org.json.JSONObject
import kotlin.io.encoding.ExperimentalEncodingApi


@OptIn(ExperimentalEncodingApi::class)
fun JSONObject.toLabelOptionOrNull(): LabelOption? {
    if (!this.has("id") && !this.has("latLng")) {
        return null
    }

    return LabelOption(
        this.getString("id"),
        this.getJSONObject("latLng").toLatLng(),
        this.optString("base64EncodedImage"),
        this.optLong("rank", 0),
    )
}