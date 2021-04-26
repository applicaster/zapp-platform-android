package com.applicaster.ui
//
//import com.applicaster.eventbus.Event
//import com.applicaster.eventbus.Subscribe
//import com.applicaster.util.APLogger
//import com.facebook.react.bridge.ReadableMap
//import com.google.gson.JsonObject
//
//class EventsDemo {
//
//    data class PlayerEventPlay(val paused: Boolean, val playing: Boolean)
//
//    @Subscribe(event="play")
//    fun onPlay(data: Event<PlayerEventPlay>) {
//        APLogger.info(TAG, "Got event ${data.data}")
//    }
//
//    @Subscribe(event="pause")
//    fun onPause(data: ReadableMap) {
//        APLogger.info(TAG, "Got event $data")
//    }
//
//    @Subscribe(event="stop")
//    fun onStop(data: JsonObject) {
//        APLogger.info(TAG, "Got event $data")
//    }
//
//    @Subscribe(event="resume")
//    fun onResume(data: Event<PlayerEventPlay>) {
//        APLogger.info(TAG, "Got event ${data.data}")
//    }
//
//    companion object {
//        private const val TAG: String = "EventsDemo"
//    }
//}