package com.applicaster.ui.loaders

import com.applicaster.util.APLogger

class PreloadStateManager(private val onComplete: Runnable) {

    enum class PreloadStep {
        STARTUP_HOOK,
        LOAD_DATA,
        VIDEO_INTRO,
        APPLICATION_READY_HOOK,
        UI_READY
    }

    interface IStepHandler {
        fun handle(step: PreloadStep)
    }

    private val steps = hashSetOf(*PreloadStep.values())
    private val stepHandlers = mutableMapOf<PreloadStep, MutableList<IStepHandler>>()

    /**
     * Register step complete handler (no multiple dependencies for now)
     */
    fun whenStepComplete(step: PreloadStep, handler: IStepHandler): PreloadStateManager {
        val lst = stepHandlers.getOrPut(step) { mutableListOf() }
        lst.add(handler)
        return this
    }

    /**
     * Complete [PreloadStep].
     * @param step  Preload step to marked as complete
     */
    @Synchronized
    fun setStepComplete(step: PreloadStep) {
        APLogger.debug(TAG, "Preload step complete: $step")
        if(!steps.remove(step)) {
            APLogger.error(TAG, "Preload step was marked complete more than once: $step")
        }
        stepHandlers[step]?.forEach { it.handle(step) }
        if(steps.isEmpty()) {
            onComplete.run()
        }
    }

    companion object {
        private const val TAG = "PreloadStateManager"
    }
}
