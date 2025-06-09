package io.seunghwanly.kakao_maps_flutter

import android.content.Context
import com.kakao.vectormap.KakaoMapSdk
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.seunghwanly.kakao_maps_flutter.view.KakaoMapViewFactory

/** KakaoMapsFlutterPlugin */
class KakaoMapsFlutterPlugin : FlutterPlugin, MethodCallHandler {
    companion object {
        const val INIT_CHANNEL_NAME = "kakao_maps_flutter"
        const val VIEW_METHOD_CHANNEL_NAME = "view.method_channel.kakao_maps_flutter"
        const val VIEW_TYPE_ID = "kakao_map_view"
    }

    private var initializationChannel: MethodChannel? = null

    // Used for KakaoMapSdk initialization
    private lateinit var applicationContext: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

        // Store References
        applicationContext = flutterPluginBinding.applicationContext

        // Initialization Channel
        initializationChannel =
                MethodChannel(flutterPluginBinding.binaryMessenger, INIT_CHANNEL_NAME).apply {
                    setMethodCallHandler(this@KakaoMapsFlutterPlugin)
                }

        // Register PlatformViewFactory and Store
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
                VIEW_TYPE_ID,
                KakaoMapViewFactory(flutterPluginBinding.binaryMessenger)
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init" -> initSdk(call, result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Clean up channels
        initializationChannel?.setMethodCallHandler(null)
        initializationChannel = null
    }

    private fun initSdk(call: MethodCall, result: Result) {
        require(::applicationContext.isInitialized)

        val token = call.argument<String>("appKey")
        if (token.isNullOrEmpty()) {
            result.error("E001", "Token must not be null", null)
            return
        }

        if (!KakaoMapSdk.isInitialized()) {
            KakaoMapSdk.init(applicationContext, token)
        }
        result.success(true)
    }
}
