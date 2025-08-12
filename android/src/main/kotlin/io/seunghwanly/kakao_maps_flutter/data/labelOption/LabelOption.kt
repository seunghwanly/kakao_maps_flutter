package io.seunghwanly.kakao_maps_flutter.data.labelOption

import com.kakao.vectormap.LatLng
import kotlin.io.encoding.ExperimentalEncodingApi

@ExperimentalEncodingApi
data class LabelOption(
    val id: String,
    val latLng: LatLng,
    val rank: Long = 0,
    val text: String?,
    // 텍스트 스타일 속성은 MarkerStyle(사전 등록)로만 처리
)
