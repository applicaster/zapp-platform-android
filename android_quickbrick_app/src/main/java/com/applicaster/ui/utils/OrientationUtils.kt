package com.applicaster.ui.utils

import android.content.pm.ActivityInfo

object OrientationUtils {

    val PORTRAIT_DEGREES = 0
    val LANDSCAPE_DEGREES = 90 // landscapeRight: 2,
    val LANDSCAPE_REVERSE_DEGREES = 270
    val PORTRAIT_REVERSE_DEGREES = 180

    val JS_PORTAIT = 0x00000001
    val JS_LANDSCAPE = 0x00000002 // landscapeRight: 2,
    val JS_LANDSCAPE_REVERSED = 0x00000004
    val JS_PORTAIT_REVERSED = 0x00000008
    val JS_LANDSCAPE_SENSOR = JS_LANDSCAPE or JS_LANDSCAPE_REVERSED
    val JS_PORTAIT_SENSOR = JS_PORTAIT or JS_PORTAIT_REVERSED
    val JS_FULL_SENSOR = JS_LANDSCAPE_SENSOR or JS_PORTAIT_SENSOR
    val JS_SENSOR = JS_LANDSCAPE_SENSOR or JS_PORTAIT // AllButUpsideDown

    val js2NativeMap: HashMap<Int, Int> = hashMapOf(
        JS_FULL_SENSOR to ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR,
        JS_SENSOR to ActivityInfo.SCREEN_ORIENTATION_SENSOR,
        JS_LANDSCAPE_SENSOR to ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE,
        JS_PORTAIT_SENSOR to ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT,
        JS_PORTAIT to ActivityInfo.SCREEN_ORIENTATION_PORTRAIT,
        JS_LANDSCAPE to ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE,
        JS_PORTAIT_REVERSED to ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT,
        JS_LANDSCAPE_REVERSED to ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE)

    fun jsOrientationMapper(normalisedOrientation: Int): Int {
        if (PORTRAIT_DEGREES == normalisedOrientation) {
            return JS_PORTAIT
        } else if (LANDSCAPE_DEGREES == normalisedOrientation) {
            return JS_LANDSCAPE
        } else if (PORTRAIT_REVERSE_DEGREES == normalisedOrientation) {
            return JS_PORTAIT_REVERSED
        } else if (LANDSCAPE_REVERSE_DEGREES == normalisedOrientation) {
            return JS_LANDSCAPE_REVERSED
        }
        return 0
    }

    fun nativeOrientationMapper(jsOrientationflag: Int): Int {
        return js2NativeMap[jsOrientationflag] ?: ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
    }

    fun supportOrientation(normalisedOrientation: Int, nativeOrientationflag: Int): Boolean {
        val jsOrientationflag = js2NativeMap.filter { e -> e.value == nativeOrientationflag }.keys.first()
        return jsOrientationflag and jsOrientationMapper(normalisedOrientation) > 0
    }

    fun normaliseOrientation(orientation: Int): Int {
        return if (orientation >= 45 && orientation < 135) {
            90
        } else if (orientation >= 135 && orientation < 225) {
            180
        } else if (orientation >= 225 && orientation < 315) {
            270
        } else {
            0
        }
    }
}