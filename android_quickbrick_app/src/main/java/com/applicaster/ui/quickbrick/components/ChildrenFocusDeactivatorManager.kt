package com.applicaster.ui.quickbrick.components

import android.content.Context
import android.view.ViewGroup
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp

class ChildrenFocusDeactivatorManager(val context: ReactApplicationContext) : ViewGroupManager<ChildrenFocusDeactivatorView> (){
    override fun getName(): String {
        return "ChildrenFocusDeactivatorView"
    }

    override fun createViewInstance(reactContext: ThemedReactContext): ChildrenFocusDeactivatorView {
        val focusTrapView = ChildrenFocusDeactivatorView(reactContext as Context?)

        @ReactProp(name = "flex")
        fun setFlex(view: ChildrenFocusDeactivatorView,  sources: Int) {
            if(sources == 1) {
                view.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
            } else {
                view.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            }

            view.requestLayout()
        }

        return focusTrapView
    }

}