package com.applicaster.ui.loaders;

import android.util.Log;

/**
 * Does nothing except holding multiple boolean flags that are marked as steps to complete.
 * If all flags are set as true, the status is considered as complete - {@link #isPreloadComplete()}
 */
public class PreloadStateManager {
    public enum PreloadStep {
        LOAD_DATA,
        VIDEO_INTRO,
        UI_LAYER
    }
    private final String TAG = getClass().getSimpleName();
    private boolean loadDataComplete;
    private boolean videoIntroComplete;
    private boolean uiReadyToShow;

    /**
     * Set a {@link PreloadStep} flag to true.
     * @param step  Preload step to marked as complete
     */
    public synchronized void setStepComplete(PreloadStep step) {
        Log.d(TAG, "Preload step complete: " + step);
        switch (step) {
            case LOAD_DATA:
                loadDataComplete = true;
                break;
            case VIDEO_INTRO:
                videoIntroComplete = true;
                break;
            case UI_LAYER:
                uiReadyToShow = true;
                break;
            default:
                break;
        }
    }

    /**
     * @return Are all the preload steps marked as ready/complete?
     */
    public boolean isPreloadComplete() {
        return loadDataComplete && videoIntroComplete && uiReadyToShow;
    }
}
