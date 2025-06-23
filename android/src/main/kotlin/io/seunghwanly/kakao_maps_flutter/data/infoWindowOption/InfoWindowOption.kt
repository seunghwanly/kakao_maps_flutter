package io.seunghwanly.kakao_maps_flutter.data.infoWindowOption

import com.kakao.vectormap.LatLng

data class InfoWindowOption(
        val id: String,
        val latLng: LatLng,
        val title: String,
        val snippet: String?,
        val isVisible: Boolean,
        val offset: InfoWindowOffset,
)

data class InfoWindowOffset(
        val x: Double,
        val y: Double,
)
