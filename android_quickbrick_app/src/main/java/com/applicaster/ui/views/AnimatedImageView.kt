package com.applicaster.ui.views

import android.content.Context
import android.graphics.drawable.AnimationDrawable
import android.util.AttributeSet
import androidx.appcompat.widget.AppCompatImageView

class AnimatedImageView : AppCompatImageView {

    constructor(context: Context?)
            : super(context) {
        startDrawableAnimation()
    }

    constructor(context: Context?, attrs: AttributeSet?)
            : super(context, attrs) {
        startDrawableAnimation()
    }

    constructor(context: Context?, attrs: AttributeSet?, defStyleAttr: Int)
            : super(context, attrs, defStyleAttr) {
        startDrawableAnimation()
    }

    private fun startDrawableAnimation() =
            (drawable as? AnimationDrawable)?.start()
}
