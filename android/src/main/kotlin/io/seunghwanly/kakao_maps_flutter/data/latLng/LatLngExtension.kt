package io.seunghwanly.kakao_maps_flutter.data.latLng

import com.kakao.vectormap.LatLng
import org.json.JSONObject

fun JSONObject.toLatLng(): LatLng {
    return LatLng.from(
        this.getDouble("latitude"),
        this.getDouble("longitude")
    )
}