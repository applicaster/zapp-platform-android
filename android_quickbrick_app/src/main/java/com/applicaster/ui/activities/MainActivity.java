package com.applicaster.ui.activities;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.KeyEvent;
import android.view.OrientationEventListener;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.annotation.RawRes;
import androidx.core.view.ViewCompat;

import com.applicaster.ui.interfaces.HostActivityBase;
import com.applicaster.ui.interfaces.IUILayerManager;
import com.applicaster.ui.loaders.PreloadStateManager;
import com.applicaster.ui.loaders.PreloadStateManager.PreloadStep;
import com.applicaster.ui.quickbrick.QuickBrickManager;
import com.applicaster.ui.utils.OrientationUtils;
import com.applicaster.util.APLogger;
import com.applicaster.util.AppData;
import com.applicaster.util.OSUtil;
import com.applicaster.util.UrlSchemeUtil;
import com.applicaster.util.ui.APUIUtils;
import com.applicaster.util.ui.ApplicationPreloader;
import com.applicaster.util.ui.PreloaderListener;
import com.applicaster.zapp.quickbrick.loader.DataLoader;

import java.util.Stack;

import rx.android.schedulers.AndroidSchedulers;
import rx.schedulers.Schedulers;

public class MainActivity extends HostActivityBase {

    private static final String TAG = MainActivity.class.getSimpleName();

    private static final String INTRO_LAYOUT = "intro";
    private static final String INTRO_VIDEO_RAW_RESOURCE_DEFAULT = "intro";
    private static final String INTRO_VIDEO_RAW_RESOURCE_TABLET = "intro_tablet";
    private static final String APPLICATION_PRELOADER_LAYOUT_ID = "preloader_view";

    private final Stack<Integer> orientationStack = new Stack<>();

    private PreloadStateManager preloadStateManager;
    private IUILayerManager uiLayer;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        preloadStateManager = new PreloadStateManager();
        setAppOrientation();
        setSplashAndApplicationPreloaderView();
        playVideoIntroIfPresent();
        // todo: show debug setup dialog here
        loadData();
        // todo: check if it can run in BG
        new Handler().post(this::initializeUILayer);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        if(null != uiLayer && uiLayer.isInitialized()) {
            Uri uri = UrlSchemeUtil.getUrlSchemeData(intent);
            if (null != uri) {
                uiLayer.handleURL(uri.toString());
            }
        }
    }

    private void loadData() {
        // todo: move everything into single observable and remove preloadStateManager
        DataLoader.initialize(this, getIntent())
                .subscribeOn(Schedulers.io())
                .observeOn(AndroidSchedulers.mainThread()).subscribe(
                        () -> preloadStepComplete(PreloadStateManager.PreloadStep.LOAD_DATA),
                        throwable -> APLogger.error(TAG, "QuickBrickActivity load data failed", throwable));
    }

    private void initOrientationListener() {
        new OrientationEventListener(this) {

            private int lastKnownRotation = 0;

            {
                if (canDetectOrientation()) {
                    enable();
                }
            }

            /**
             * This is either Surface.Rotation_0, _90, _180, _270, or -1 (invalid).
             */
            @Override
            public void onOrientationChanged(int orientation) {
                int normalisedOrientation = OrientationUtils.INSTANCE.normaliseOrientation(orientation);
                if (!OrientationUtils.INSTANCE.supportOrientation(normalisedOrientation, orientationStack.peek())) {
                    return;
                }
                if (lastKnownRotation == normalisedOrientation) {
                    return;
                }
                int from = OrientationUtils.INSTANCE.jsOrientationMapper(lastKnownRotation);
                lastKnownRotation = normalisedOrientation;
                int to = OrientationUtils.INSTANCE.jsOrientationMapper(normalisedOrientation);
                if (uiLayer != null && uiLayer.isInitialized()) {
                    uiLayer.orientationChange(from, to);
                }
            }
        };
    }

    // region activity life cycle events

    /**
     * Handle onKeyDown in debug builds only
     */
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        boolean shouldOverrideKeyDownEvent = false;
        if (uiLayer != null && uiLayer.isInitialized()) {
            shouldOverrideKeyDownEvent = uiLayer.onKeyDown(keyCode, event);
        }
        return shouldOverrideKeyDownEvent || super.onKeyDown(keyCode, event);
    }

    /**
     * Let RN handle back button press, only after initialize is complete
     */
    @Override
    public void onBackPressed() {
        if (uiLayer != null && uiLayer.isInitialized()) {
            uiLayer.onBackPressed();
        } else {
            super.onBackPressed();
        }
    }

    /**
     * RN: Resume responding to touch events and re-register various event listeners.
     */
    @Override
    protected void onResume() {
        super.onResume();
        if (uiLayer != null && uiLayer.isInitialized()) uiLayer.onResume();
    }

    /**
     * AppData: persist state in Preferences.
     * RN: un-register various event listeners & some cleanup.
     */
    @Override
    protected void onPause() {
        super.onPause();
        AppData.persistAppData(this);
        if (uiLayer != null && uiLayer.isInitialized())uiLayer.onPause();
    }

    /**
     * RN: stop RN's instance manager and detach RN's application from RN's root view.
     */
    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (uiLayer != null) uiLayer.onDestroy();
    }
    //endregion

    private void setAppOrientation() {
        APUIUtils.setOrientation(this);
        orientationStack.add(this.getRequestedOrientation());
    }

    @Override
    public void setAppOrientation(int orientation) {
        int nativeOrientation = OrientationUtils.INSTANCE.nativeOrientationMapper(orientation);
        this.setRequestedOrientation(nativeOrientation);
        orientationStack.add(this.getRequestedOrientation());
    }

    @Override
    public void releaseOrientation() {
        if (orientationStack.size() > 1) {
            orientationStack.pop();
            this.setRequestedOrientation(orientationStack.peek());
        }
    }

    /**
     * intro.xml creates:
     * - intro_splash_layout containing @drawable/splash_logo
     * - ApplicationPreloader layout, which both creates a placeholder for
     * either image, webview or video, AND handles the dismiss behavior
     * (Yes! a linearLayout that makes decisions, brilliant)
     */
    private void setSplashAndApplicationPreloaderView() {
        setContentView(OSUtil.getLayoutResourceIdentifier(INTRO_LAYOUT));
        View root = getWindow().getDecorView().getRootView();
        ViewCompat.setOnApplyWindowInsetsListener(root, (v, insets) -> insets.consumeSystemWindowInsets());
    }

    /**
     * Update preload step complete and check if all steps are complete.
     * If true - set content view to RN's root view, replacing splash screen layout.
     * If preload was already complete before this call, return -
     * this is a safeguard against rogue events that are accidentally sent more than once.
     *
     * @param step Preload step like video play complete, RN initialize complete, etc.
     */
    private synchronized void preloadStepComplete(PreloadStep step) {
        if(isFinishing())
            return;

        if (preloadStateManager.isPreloadComplete())
            return; // preload was already complete, don't do anything

        preloadStateManager.setStepComplete(step);

        if (preloadStateManager.isPreloadComplete()) {
            runOnUiThread(() -> {
                uiLayer.onResume(); // This placement is intentional! can only be run inside a UI thread.
                setContentView(uiLayer.getRootView()); // simplistic approach, replace whole intro layout with RN layout
                Uri uri = UrlSchemeUtil.getUrlSchemeData(getIntent());
                if(null != uri) {
                    uiLayer.handleURL(uri.toString());
                }
            });
        }
    }

    /**
     * Check if video intro resource exists.
     * - Exists? Play video and connect onIntroVideoFinished to PreloadStep.VIDEO_INTRO
     * - Does not exist? Set PreloadStep.VIDEO_INTRO as complete
     */
    private void playVideoIntroIfPresent() {
        if (getVideoIntroResource() == 0) {
            preloadStepComplete(PreloadStep.VIDEO_INTRO);
            return;
        }

        ApplicationPreloader applicationPreloaderView = findViewById(OSUtil.getResourceId(APPLICATION_PRELOADER_LAYOUT_ID));
        applicationPreloaderView.setListener(new PreloaderViewListener(
                () -> preloadStepComplete(PreloadStep.VIDEO_INTRO))
        );

        Uri videoIntroUri = buildVideoIntroUri(getVideoIntroResource());
        applicationPreloaderView.showIntro(videoIntroUri, this);
    }

    /**
     * VideoView requires a Uri scheme for the location of the video resource.
     *
     * @param videoIntroResourceID Resource in the res/raw folder.
     * @return Uri representation of the packaged video file location.
     */
    private Uri buildVideoIntroUri(@RawRes int videoIntroResourceID) {
        return Uri.parse("android.resource://" + getPackageName() + "/" + videoIntroResourceID);
    }

    /**
     * Creates the QuickBrick manager that holds the RN view,
     * and handles the initialization process.
     * The Manager interacts with this activity using this interface:
     * {@link IUILayerManager.StatusListener}
     */
    private void initializeUILayer() {
        if(isFinishing()) {
            return;
        }
        uiLayer = new QuickBrickManager(this);
        uiLayer.setEventsListener(new IUILayerManager.StatusListener() {
            @Override
            public void onReady() {
                initOrientationListener();
                preloadStepComplete(PreloadStep.UI_LAYER);
            }

            @Override
            public void onError(@Nullable Exception e) {
                Log.e(TAG, "QuickBrickManager error", e);

                Handler handler = new Handler();
                handler.postDelayed(() -> {
                    finish(); // Not very nice but we prefer failing hard and fast in this case
                }, 1000);
            }
        });
        uiLayer.start();
    }

    /**
     * Check for device type, and return resource for tablet video, if available.
     * Default: return default video resource (phone/portrait video)
     *
     * @return resource id of intro video
     */
    @RawRes
    private int getVideoIntroResource() {
        int resourceId = OSUtil.getRawResourceIdentifier(INTRO_VIDEO_RAW_RESOURCE_DEFAULT);
        if (OSUtil.isTablet()) {
            int tabletResourceId = OSUtil.getRawResourceIdentifier(INTRO_VIDEO_RAW_RESOURCE_TABLET);
            if (tabletResourceId > 0) {
                resourceId = tabletResourceId;
            }
        }
        return resourceId;
    }

    static class PreloaderViewListener implements PreloaderListener {

        private final Runnable callback;

        public PreloaderViewListener(Runnable callback) {
            this.callback = callback;
        }

        /**
         * Will be called several times during pre-load process,
         * in no logical/useful manner. Just ignore everything.
         */
        @Override
        public void onPreloaderStart() {
        }

        /**
         * Handles other "onComplete" events in the {@link ApplicationPreloader},
         * like dismissed interstitial / ad / webview
         */
        @Override
        public void onPreloaderFinish() {
        }

        /**
         * NEVER called
         * @param e Exception from {@link ApplicationPreloader}
         */
        @Override
        public void handlePreloaderException(Exception e) {
        }

        /**
         * Run callback when there is nothing left to do from the video playing perspective, either:
         * 1. There's an error in the player (error is swallowed, screw you)
         * 2. Video completed playing (VideoView visibility is already set as "gone")
         */
        @Override
        public void onIntroVideoFinished() {
            callback.run();
        }
    }
}
