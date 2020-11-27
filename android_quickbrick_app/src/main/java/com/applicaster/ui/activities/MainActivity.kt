package com.applicaster.ui.activities

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Handler
import android.text.TextUtils
import android.view.KeyEvent
import android.view.OrientationEventListener
import androidx.annotation.RawRes
import com.applicaster.plugin_manager.PluginManager
import com.applicaster.ui.R
import com.applicaster.ui.interfaces.HostActivityBase
import com.applicaster.ui.interfaces.IUILayerManager
import com.applicaster.ui.loaders.PreloadStateManager
import com.applicaster.ui.loaders.PreloadStateManager.PreloadStep
import com.applicaster.ui.quickbrick.QuickBrickManager
import com.applicaster.ui.utils.HookExecutor
import com.applicaster.ui.utils.OrientationUtils.jsOrientationMapper
import com.applicaster.ui.utils.OrientationUtils.nativeOrientationMapper
import com.applicaster.ui.utils.OrientationUtils.normaliseOrientation
import com.applicaster.ui.utils.OrientationUtils.supportOrientation
import com.applicaster.ui.views.ApplicationPreloaderView
import com.applicaster.util.APLogger
import com.applicaster.util.AppData
import com.applicaster.util.OSUtil
import com.applicaster.util.UrlSchemeUtil
import com.applicaster.util.ui.APUIUtils
import com.applicaster.util.ui.PreloaderListener
import com.applicaster.zapp.quickbrick.loader.DataLoader
import io.reactivex.Completable
import io.reactivex.CompletableEmitter
import java.util.*

class MainActivity : HostActivityBase() {

    private val orientationStack = Stack<Int>()
    private var uiLayer: IUILayerManager? = null

    public override fun onCreate(savedInstanceState: Bundle?) {
        APLogger.debug(TAG, "Activity onCreate called")
        super.onCreate(savedInstanceState)
        if (routeOrUpdateIntent(intent)) {
            // Abort launch if the intent was supposed to be handled in external application.
            // Can't use finishAndRemoveTask() since external app we launch is in the same stack, and will be terminated too
            // So our app still will be visible in the recent apps history.
            finish()
            return
        }
        setAppOrientation()
        setContentView(R.layout.intro)
        // todo: show debug setup dialog here
        with(PreloadStateManager()) {
            addStep(PreloadStep.VIDEO_INTRO,
                    playVideoIntroIfPresent())

            addStep(PreloadStep.STARTUP_HOOK,
                    executeHooks(false))

            addStep(PreloadStep.LOAD_DATA,
                    DataLoader.initialize(applicationContext),
                    PreloadStep.STARTUP_HOOK)

            addStep(PreloadStep.APPLICATION_READY_HOOK,
                    executeHooks(true),
                    PreloadStep.LOAD_DATA)

            addStep(PreloadStep.UI_READY,
                    initializeUILayer(),
                    PreloadStep.APPLICATION_READY_HOOK)

            addStep(PreloadStep.RUNNING,
                    showUI(),
                    PreloadStep.VIDEO_INTRO, PreloadStep.UI_READY)
            run()
        }
    }

    private fun routeOrUpdateIntent(intent: Intent): Boolean {
        // Take care of url extra delivered from Firebase Console Firebase Push when app was not active
        // if url schema belongs to our app, we will update the intent,
        // otherwise we will try to route it as it was supposed to be done.
        val data = intent.data
        APLogger.info(TAG, "Intent received with data: " + (data?.toString() ?: "null"))
        if (!intent.hasExtra(INTENT_EXTRA_URL)) {
            return false
        }
        val url = intent.getStringExtra(INTENT_EXTRA_URL)
        if (TextUtils.isEmpty(url)) {
            return false
        }
        APLogger.info(TAG, "Received Url extra: $url")
        val uri = Uri.parse(url)
        return if (UrlSchemeUtil.isUrlScheme(url)) {
            // update intent in-place, and let caller proceed
            intent.data = uri
            setIntent(intent)
            APLogger.info(TAG, "Intent data was replaced with url extra: $url")
            false
        } else {
            val externalIntent = Intent(Intent.ACTION_VIEW, uri)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(externalIntent)
            APLogger.info(TAG, "Intent was routed to an external application")
            true
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (routeOrUpdateIntent(intent)) {
            // This was probably intent from Firebase Console Firebase Push when app was not active.
            // User has first launched the app, and then clicked the notification
            return
        }
        // Update current intent in any case,
        // since QB may still be launching, and will only check it later.
        setIntent(intent)
        if (true == uiLayer?.isReady) {
            val uri = UrlSchemeUtil.getUrlSchemeData(intent)
            if (null != uri) {
                uiLayer!!.handleURL(uri.toString())
            }
        }
    }

    private fun initOrientationListener() {
        object : OrientationEventListener(this) {
            private var lastKnownRotation = 0

            /**
             * This is either Surface.Rotation_0, _90, _180, _270, or -1 (invalid).
             */
            override fun onOrientationChanged(orientation: Int) {
                val normalisedOrientation = normaliseOrientation(orientation)
                if (!supportOrientation(normalisedOrientation, orientationStack.peek())) {
                    return
                }
                if (lastKnownRotation == normalisedOrientation) {
                    return
                }
                val from = jsOrientationMapper(lastKnownRotation)
                lastKnownRotation = normalisedOrientation
                val to = jsOrientationMapper(normalisedOrientation)
                if (uiLayer != null && uiLayer!!.isReady) {
                    uiLayer!!.orientationChange(from, to)
                }
            }

            init {
                if (canDetectOrientation()) {
                    enable()
                }
            }
        }
    }
    // region activity life cycle events
    /**
     * Handle onKeyDown in debug builds only
     */
    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        var shouldOverrideKeyDownEvent = false
        if (true == uiLayer?.isReady) {
            shouldOverrideKeyDownEvent = uiLayer!!.onKeyDown(keyCode, event)
        }
        return shouldOverrideKeyDownEvent || super.onKeyDown(keyCode, event)
    }

    /**
     * Let RN handle back button press, only after initialize is complete
     */
    override fun onBackPressed() {
        if (true == uiLayer?.isReady) {
            uiLayer!!.onBackPressed()
        } else {
            super.onBackPressed()
        }
    }

    /**
     * RN: Resume responding to touch events and re-register various event listeners.
     */
    override fun onResume() {
        super.onResume()
        uiLayer?.onResume()
    }

    /**
     * AppData: persist state in Preferences.
     * RN: un-register various event listeners & some cleanup.
     */
    override fun onPause() {
        super.onPause()
        AppData.persistAppData(this)
        uiLayer?.onPause()
    }

    /**
     * RN: stop RN's instance manager and detach RN's application from RN's root view.
     */
    override fun onDestroy() {
        super.onDestroy()
        uiLayer?.onDestroy()
    }

    //endregion
    private fun setAppOrientation() {
        APUIUtils.setOrientation(this)
        orientationStack.add(this.requestedOrientation)
    }

    override fun setAppOrientation(orientation: Int) {
        val nativeOrientation = nativeOrientationMapper(orientation)
        this.requestedOrientation = nativeOrientation
        orientationStack.add(this.requestedOrientation)
    }

    override fun releaseOrientation() {
        if (orientationStack.size > 1) {
            orientationStack.pop()
            this.requestedOrientation = orientationStack.peek()
        }
    }

    private fun executeHooks(isAppReady: Boolean) : Completable {
        val hookPluginList = PluginManager.getInstance().hookPluginList
        return when {
            hookPluginList == null || hookPluginList.isEmpty() -> Completable.complete()
            else -> Completable.create {
                HookExecutor(this,
                        hookPluginList,
                        it,
                        isAppReady)
            }
        }
    }

    /**
     * Check if video intro resource exists.
     * - Exists? Play video and connect onIntroVideoFinished to PreloadStep.VIDEO_INTRO
     * - Does not exist? Set PreloadStep.VIDEO_INTRO as complete
     */
    private fun playVideoIntroIfPresent(): Completable {
        val introResource = videoIntroResource
        if (introResource == 0) {
            return Completable.complete()
        }
        return createUIThreadCompletable { completableEmitter ->
            findViewById<ApplicationPreloaderView>(R.id.preloader_view).let {
                it.setListener(PreloaderViewListener(completableEmitter))
                val videoIntroUri = buildVideoIntroUri(introResource)
                it.showIntro(videoIntroUri, this@MainActivity)
            }
        }
    }

    /**
     * VideoView requires a Uri scheme for the location of the video resource.
     *
     * @param videoIntroResourceID Resource in the res/raw folder.
     * @return Uri representation of the packaged video file location.
     */
    private fun buildVideoIntroUri(@RawRes videoIntroResourceID: Int): Uri {
        return Uri.parse("android.resource://$packageName/$videoIntroResourceID")
    }

    /**
     * Creates the QuickBrick manager that holds the RN view,
     * and handles the initialization process.
     * The Manager interacts with this activity using this interface:
     * [IUILayerManager.StatusListener]
     */
    private fun initializeUILayer(): Completable {
        if (isFinishing) {
            return Completable.complete()
        }
        return createUIThreadCompletable { completableEmitter ->
            APLogger.debug(TAG, "Initializing UI layer...")
            uiLayer = QuickBrickManager(this@MainActivity)
            uiLayer!!.setEventsListener(object : IUILayerManager.StatusListener {
                override fun onReady() = completableEmitter.onComplete()

                override fun onError(e: Exception?) {
                    APLogger.error(TAG, "QuickBrickManager error", e)
                    val handler = Handler()
                    handler.postDelayed({
                        finish() // Not very nice but we prefer failing hard and fast in this case
                    }, 1000)
                }
            })
            uiLayer!!.start()
        }
    }

    private fun showUI(): Completable {
        if (isFinishing) {
            return Completable.complete()
        }
        return createUIThreadCompletable { completableEmitter ->
            APLogger.debug(TAG, "UI ready...")
            initOrientationListener()
            setContentView(uiLayer!!.rootView) // simplistic approach, replace whole intro layout with RN layout
            val uri = UrlSchemeUtil.getUrlSchemeData(intent)
            if (null != uri) {
                APLogger.info(TAG, "Passing URI to UI Layer:$uri")
                uiLayer!!.handleURL(uri.toString())
            }
            completableEmitter.onComplete()
        }
    }

    // Not really needed right now, since we run callbacks on UI thread in PreloadStateManager.
    private fun createUIThreadCompletable(action: (CompletableEmitter) -> Unit): Completable {
        return Completable.create {
            runOnUiThread { action(it) }
        }
    }

    /**
     * Check return resource for video, if available.
     * Default: return default video resource (phone/portrait video)
     *
     * @return resource id of intro video
     */
    @get:RawRes
    private val videoIntroResource: Int
        get() = OSUtil.getRawResourceIdentifier(INTRO_VIDEO_RAW_RESOURCE_DEFAULT)

    internal class PreloaderViewListener(private val callback: CompletableEmitter) : PreloaderListener {

        /**
         * Will be called several times during pre-load process,
         * in no logical/useful manner. Just ignore everything.
         */
        override fun onPreloaderStart() {}

        /**
         * Handles other "onComplete" events in the [ApplicationPreloaderView],
         * like dismissed interstitial / ad / webview
         */
        override fun onPreloaderFinish() {}

        /**
         * NEVER called
         * @param e Exception from [ApplicationPreloaderView]
         */
        override fun handlePreloaderException(e: Exception) {}

        /**
         * Run callback when there is nothing left to do from the video playing perspective, either:
         * 1. There's an error in the player (error is swallowed, screw you)
         * 2. Video completed playing (VideoView visibility is already set as "gone")
         */
        override fun onIntroVideoFinished() = callback.onComplete()
    }

    companion object {
        private const val TAG = "MainActivity"
        private const val INTRO_VIDEO_RAW_RESOURCE_DEFAULT = "intro"

        // intents from Firebase Push messages handled in the background will deliver url in the extras
        private const val INTENT_EXTRA_URL = "url"
    }
}