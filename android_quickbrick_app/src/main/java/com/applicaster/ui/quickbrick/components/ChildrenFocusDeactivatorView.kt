package com.applicaster.ui.quickbrick.components

import android.content.Context
import android.view.View
import android.widget.LinearLayout
import com.facebook.react.bridge.ReactContext

class ChildrenFocusDeactivatorView (context: Context?) : LinearLayout(context as ReactContext?) {
    override fun onViewAdded(child: View?) {
        child?.isEnabled = false
        super.onViewAdded(child)
    }
}

