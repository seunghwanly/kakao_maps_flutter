package io.seunghwanly.kakao_maps_flutter.data.labelOption

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.kakao.vectormap.LatLng
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi

@ExperimentalEncodingApi
data class LabelOption(
    val id: String, val latLng: LatLng, val image: Bitmap?
) {
    constructor(
        id: String, latLng: LatLng, image: String?,
    ) : this(
        id, latLng, if (image == null) {
            null
        } else {
            val byteArray: ByteArray = Base64.Default.decode(image)
            BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
        }
    )
}
