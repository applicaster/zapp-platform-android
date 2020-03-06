package com.applicaster.ui.interfaces;

import android.view.KeyEvent;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public interface IUILayerManager {

    boolean isInitialized();

    void setEventsListener(StatusListener listener);

    void start();

    void onBackPressed();

    void onPause();

    void onResume();

    void onDestroy();

    boolean onKeyDown(int keyCode, KeyEvent event);

    void orientationChange(int from, int to);

    boolean onKeyDownDebug(int keyCode);

    void handleURL(@NonNull String url);

    @NonNull
    View getRootView();

    /**
     * Events sent from QuickBrickManager to the activity holding it
     * - {@link #onReady()}    The RN view is ready to be presented,
     * let the subscriber decide how to handle the setContent/layout.
     * - {@link #onError(Exception)}
     */
    interface StatusListener {
        /**
         * RN view is ready to be presented / attached to layout / set as a content
         */
        void onReady();

        /**
         * Report error to the subscriber. Maybe it's recoverable -
         * don't let this manager decide what to do with it,
         * it should not be responsible for side effects.
         *
         * @param e Caught exception, if present
         */
        void onError(@Nullable Exception e);
    }
}
