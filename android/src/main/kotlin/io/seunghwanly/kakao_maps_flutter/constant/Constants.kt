package io.seunghwanly.kakao_maps_flutter.constant

import com.kakao.vectormap.label.LabelStyle
import com.kakao.vectormap.label.LabelTextStyle

class DefaultLabelTextStyle {
    companion object {
        const val FONT_SIZE: Int = 14
        const val FONT_COLOR: Int = 0xFF000000.toInt()
        const val STROKE_THICKNESS: Int = 4
        const val STROKE_COLOR: Int = 0xFFFFFFFF.toInt()

        fun getTextStyle(): LabelTextStyle {
            return LabelTextStyle.from(
                FONT_SIZE,
                FONT_COLOR,
                STROKE_THICKNESS,
                STROKE_COLOR,
            )
        }
    }
}

class DefaultLabelStyle {
    companion object {
        /**
         * DefaultLabelTextStyle을 이용한 LabelStyle 생성
         */
        fun getStyle(): LabelStyle {
            return LabelStyle.from(DefaultLabelTextStyle.getTextStyle())
        }
    }
}