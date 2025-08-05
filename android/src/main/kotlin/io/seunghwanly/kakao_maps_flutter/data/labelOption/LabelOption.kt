package io.seunghwanly.kakao_maps_flutter.data.labelOption

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import com.kakao.vectormap.LatLng
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi

@ExperimentalEncodingApi
data class LabelOption(
    val id: String,
    val latLng: LatLng,
    val image: Bitmap?,
    val rank: Long = 0,
    val text: String?,
    val textColor: Int?,
    val textSize: Int?,
    val strokeThickness: Int?,
    val strokeColor: Int?
) {
    constructor(
        id: String,
        latLng: LatLng,
        image: String?,
        rank: Long = 0,
        text: text,
        textColor: textColor,
        textSize: Int?,
        strokeThickness: Int?,
        strokeColor: Int?
    ) : this(
        id, latLng, if (image == null) {
            null
        } else {
            val byteArray: ByteArray = Base64.Default.decode(image)
            BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
        },
        rank = rank,
        text = text,
        textColor = textColor,
        textSize = textSize,
        strokeThickness = strokeThickness,
        strokeColor = strokeColor
    )
}
