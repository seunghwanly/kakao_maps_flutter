package io.seunghwanly.kakao_maps_flutter.data.labelClickEvent


import com.kakao.vectormap.LatLng
import com.kakao.vectormap.label.Label

data class LabelClickEvent(
    val labelId: String,
    val latLng: LatLng,
    val layerId: String?,
) {
    companion object {
        fun fromLabel(
            label: Label,
            layerId: String? = null,
        ): LabelClickEvent {
            return LabelClickEvent(
                labelId = label.labelId,
                latLng = LatLng.from(
                    label.position.latitude,
                    label.position.longitude,
                ),
                layerId = layerId,
            )
        }
    }

    fun toMap(): Map<String, Any?> {
        return mapOf(
            "labelId" to labelId,
            "latLng" to mapOf(
                "latitude" to latLng.latitude,
                "longitude" to latLng.longitude,
            ),
            "layerId" to layerId,
        )
    }
}

