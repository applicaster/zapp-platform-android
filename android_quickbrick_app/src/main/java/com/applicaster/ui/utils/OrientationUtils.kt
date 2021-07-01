package com.applicaster.ui.utils

import android.content.pm.ActivityInfo

object OrientationUtils {

    private const val PORTRAIT_DEGREES = 0
    private const val LANDSCAPE_DEGREES = 90 // landscapeRight: 2,
    private const val LANDSCAPE_REVERSE_DEGREES = 270
    private const val PORTRAIT_REVERSE_DEGREES = 180

    private const val JS_PORTRAIT = 0x00000001
    private const val JS_LANDSCAPE = 0x00000002 // landscapeRight: 2,
    private const val JS_LANDSCAPE_REVERSED = 0x00000004
    private const val JS_PORTRAIT_REVERSED = 0x00000008
    private const val JS_LANDSCAPE_SENSOR = JS_LANDSCAPE or JS_LANDSCAPE_REVERSED
    private const val JS_PORTRAIT_SENSOR = JS_PORTRAIT or JS_PORTRAIT_REVERSED
    private const val JS_FULL_SENSOR = JS_LANDSCAPE_SENSOR or JS_PORTRAIT_SENSOR
    private const val JS_SENSOR = JS_LANDSCAPE_SENSOR or JS_PORTRAIT // AllButUpsideDown

    private val js2NativeMap: HashMap<Int, Int> = hashMapOf(
            JS_FULL_SENSOR to ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR,
            JS_SENSOR to ActivityInfo.SCREEN_ORIENTATION_SENSOR,
            JS_LANDSCAPE_SENSOR to ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE,
            JS_PORTRAIT_SENSOR to ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT,
            JS_PORTRAIT to ActivityInfo.SCREEN_ORIENTATION_PORTRAIT,
            JS_LANDSCAPE to ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE,
            JS_PORTRAIT_REVERSED to ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT,
            JS_LANDSCAPE_REVERSED to ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE)

    fun jsOrientationMapper(normalisedOrientation: Int): Int {
        return when (normalisedOrientation) {
            PORTRAIT_DEGREES -> JS_PORTRAIT
            LANDSCAPE_DEGREES -> JS_LANDSCAPE
            PORTRAIT_REVERSE_DEGREES -> JS_PORTRAIT_REVERSED
            LANDSCAPE_REVERSE_DEGREES -> JS_LANDSCAPE_REVERSED
            else -> 0
        }
    }

    fun nativeOrientationMapper(jsOrientationFlag: Int): Int =
            js2NativeMap[jsOrientationFlag] ?: ActivityInfo.SCREEN_ORIENTATION_PORTRAIT

    fun supportOrientation(normalisedOrientation: Int, nativeOrientationFlag: Int): Boolean {
        val jsOrientationFlag = js2NativeMap.filter { e -> e.value == nativeOrientationFlag }.keys.first()
        return jsOrientationFlag and jsOrientationMapper(normalisedOrientation) > 0
    }

    fun normaliseOrientation(orientation: Int): Int =
            when (orientation) {
                in 45..134 -> 90
                in 135..224 -> 180
                in 225..314 -> 270
                else -> 0
            }
}