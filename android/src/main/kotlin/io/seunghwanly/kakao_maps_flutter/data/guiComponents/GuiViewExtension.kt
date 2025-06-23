package io.seunghwanly.kakao_maps_flutter.data.guiComponents

import android.graphics.BitmapFactory
import com.kakao.vectormap.mapwidget.component.*
import org.json.JSONObject
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi

/**
 * Extension functions to convert JSON to native Android GuiView components
 */

/**
 * Convert JSON to GuiView based on type
 */
fun JSONObject.toGuiView(): GuiView? {
    val type = this.optInt("type", -1)
    
    return when (type) {
        4 -> this.toGuiText()
        2, 3 -> this.toGuiImage()
        0, 1 -> this.toGuiLayout()
        else -> null
    }
}

/**
 * Apply common GuiView properties to any GuiView
 */
fun GuiView.applyCommonProperties(json: JSONObject): GuiView {
    // Set ID
    val id = json.optString("id", "")
    if (id.isNotEmpty()) {
        this.setId(id)
    }
    
    // Set clickable
    this.setClickable(json.optBoolean("clickable", true))
    
    // Set padding
    this.setPadding(
        json.optInt("paddingLeft", 0),
        json.optInt("paddingTop", 0),
        json.optInt("paddingRight", 0),
        json.optInt("paddingBottom", 0)
    )
    
    // Set origin alignment
    val verticalOrigin = json.optInt("verticalOrigin", Vertical.Bottom.value)
    val horizontalOrigin = json.optInt("horizontalOrigin", Horizontal.Center.value)
    this.setOrigin(
        Vertical.getEnum(verticalOrigin),
        Horizontal.getEnum(horizontalOrigin)
    )
    
    // Set alignment
    val verticalAlign = json.optInt("verticalAlign", Vertical.Center.value)
    val horizontalAlign = json.optInt("horizontalAlign", Horizontal.Center.value)
    this.setAlign(
        Vertical.getEnum(verticalAlign),
        Horizontal.getEnum(horizontalAlign)
    )
    
    // Set tag if present
    val tag = json.opt("tag")
    if (tag != null && tag != JSONObject.NULL) {
        this.setTag(tag)
    }
    
    return this
}

/**
 * Convert JSON to GuiText
 */
fun JSONObject.toGuiText(): GuiText? {
    val text = this.optString("text", "")
    
    val guiText = GuiText(text)
    
    // Apply text-specific properties
    guiText.setTextSize(this.optInt("textSize", 14))
    guiText.setTextColor(this.optInt("textColor", -16777216)) // Black default
    guiText.setStrokeSize(this.optInt("strokeSize", 0))
    guiText.setStrokeColor(this.optInt("strokeColor", 0))
    
    // Apply common properties
    guiText.applyCommonProperties(this)
    
    return guiText
}

/**
 * Convert JSON to GuiImage
 */
@OptIn(ExperimentalEncodingApi::class)
fun JSONObject.toGuiImage(): GuiImage? {
    val base64Image = this.optString("base64EncodedImage", null)
    val resourceId = this.optInt("resourceId", 0)
    val isNinepatch = this.optBoolean("isNinepatch", false)
    
    val guiImage = when {
        !base64Image.isNullOrEmpty() -> {
            try {
                val imageBytes = Base64.decode(base64Image.toByteArray())
                val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                GuiImage(bitmap)
            } catch (e: Exception) {
                return null
            }
        }
        resourceId != 0 -> {
            GuiImage(resourceId, isNinepatch)
        }
        else -> return null
    }
    
    // Set fixed area for nine-patch
    val fixedArea = this.optJSONObject("fixedArea")
    if (fixedArea != null && isNinepatch) {
        guiImage.setFixedArea(
            fixedArea.optInt("left", 0),
            fixedArea.optInt("top", 0),
            fixedArea.optInt("right", 0),
            fixedArea.optInt("bottom", 0)
        )
    }
    
    // Add child if present
    val child = this.optJSONObject("child")
    if (child != null) {
        val childView = child.toGuiView()
        if (childView != null) {
            guiImage.addChild(childView)
        }
    }
    
    // Apply common properties
    guiImage.applyCommonProperties(this)
    
    return guiImage
}

/**
 * Convert JSON to GuiLayout
 */
fun JSONObject.toGuiLayout(): GuiLayout? {
    val orientationValue = this.optInt("orientation", 0)
    val orientation = if (orientationValue == 0) Orientation.Horizontal else Orientation.Vertical
    
    val guiLayout = GuiLayout(orientation)
    
    // Set background if present
    val background = this.optJSONObject("background")
    if (background != null) {
        val backgroundImage = background.toGuiImage()
        if (backgroundImage != null) {
            guiLayout.setBackground(backgroundImage)
        }
    }
    
    // Add children
    val children = this.optJSONArray("children")
    if (children != null) {
        for (i in 0 until children.length()) {
            val childJson = children.optJSONObject(i)
            if (childJson != null) {
                val childView = childJson.toGuiView()
                if (childView != null) {
                    guiLayout.addView(childView)
                }
            }
        }
    }
    
    // Apply common properties
    guiLayout.applyCommonProperties(this)
    
    return guiLayout
} 