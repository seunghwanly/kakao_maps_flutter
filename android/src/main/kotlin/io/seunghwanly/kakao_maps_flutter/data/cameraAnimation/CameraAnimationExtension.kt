package io.seunghwanly.kakao_maps_flutter.data.cameraAnimation

import com.kakao.vectormap.camera.CameraAnimation
import org.json.JSONObject

fun JSONObject.toCameraAnimationOrNull(): CameraAnimation? {
    if (!this.has("duration")) {
        return null
    }

    if (this.has("autoElevation") && this.has("isConsecutive")) {
        return CameraAnimation.from(
            this.getInt("duration"),
            this.getBoolean("autoElevation"),
            this.getBoolean("isConsecutive")
        )
    }

    return CameraAnimation.from(
        this.getInt("duration")
    )
}