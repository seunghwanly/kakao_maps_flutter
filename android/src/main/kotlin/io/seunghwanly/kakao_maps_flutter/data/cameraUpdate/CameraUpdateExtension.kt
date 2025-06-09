package io.seunghwanly.kakao_maps_flutter.data.cameraUpdate

import com.kakao.vectormap.LatLng
import com.kakao.vectormap.camera.CameraUpdate
import com.kakao.vectormap.camera.CameraUpdateFactory
import org.json.JSONObject

fun JSONObject.toCameraUpdate(): CameraUpdate {
    val position = this.getJSONObject("position")

    // TODO(seunghwanly): 추가 기능 개발
    return CameraUpdateFactory.newCenterPosition(
            LatLng.from(position.getDouble("latitude"), position.getDouble("longitude")),
            this.getInt("zoomLevel"),
    )
}
