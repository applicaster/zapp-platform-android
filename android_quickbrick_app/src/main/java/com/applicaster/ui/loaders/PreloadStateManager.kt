package com.applicaster.ui.loaders

import com.applicaster.util.APLogger

/**
 * Does nothing except holding multiple steps to complete.
 * If no steps left, preload considered complete - [.isPreloadComplete]
 */
class PreloadStateManager {

    enum class PreloadStep {
        LOAD_DATA, VIDEO_INTRO
    }

    private val TAG = javaClass.simpleName
    private val steps = hashSetOf(*PreloadStep.values())

    /**
     * Complete [PreloadStep].
     * @param step  Preload step to marked as complete
     */
    @Synchronized
    fun setStepComplete(step: PreloadStep) {
        APLogger.debug(TAG, "Preload step complete: $step")
        steps.remove(step)
    }

    /**
     * @return Are all the preload steps marked as ready/complete?
     */
    val isPreloadComplete: Boolean
        @Synchronized
        get() = steps.isEmpty()
}
