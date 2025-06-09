package io.seunghwanly.kakao_maps_flutter.view

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.common.JSONMethodCodec
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.seunghwanly.kakao_maps_flutter.KakaoMapsFlutterPlugin

class KakaoMapViewFactory(
    private val messenger: BinaryMessenger
) : PlatformViewFactory(JSONMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {

        // Create unique channel name
        val channelName = "${KakaoMapsFlutterPlugin.VIEW_METHOD_CHANNEL_NAME}#${viewId}"

        val methodChannel = MethodChannel(
            messenger,
            channelName,
            JSONMethodCodec.INSTANCE,
        )

        return KakaoMapController(context, viewId, args, methodChannel)
    }
}