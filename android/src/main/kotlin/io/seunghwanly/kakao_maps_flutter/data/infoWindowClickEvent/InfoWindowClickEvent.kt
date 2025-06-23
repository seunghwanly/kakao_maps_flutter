package io.seunghwanly.kakao_maps_flutter.data.infoWindowClickEvent

import com.kakao.vectormap.LatLng

data class InfoWindowClickEvent(
        val infoWindowId: String,
        val latLng: LatLng,
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
                "infoWindowId" to infoWindowId,
                "latLng" to
                        mapOf(
                                "latitude" to latLng.latitude,
                                "longitude" to latLng.longitude,
                        ),
        )
    }
}
