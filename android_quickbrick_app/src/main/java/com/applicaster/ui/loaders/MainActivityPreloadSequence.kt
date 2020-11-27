package com.applicaster.ui.loaders

import com.applicaster.ui.activities.MainActivity
import com.applicaster.zapp.quickbrick.loader.DataLoader
import io.reactivex.Scheduler
import io.reactivex.android.schedulers.AndroidSchedulers


/**
 * Class responsible for startup sequence configuration
 * @return configured PreloadStateManager ready to run
 * @param {activity} main activity
 * @param {scheduler} default scheduler. Provided for Unit testing simplicity, *must* be AndroidSchedulers.mainThread() in runtime
 */

object MainActivityPreloadSequence {
    @JvmStatic
    fun configure(activity: MainActivity,
                  scheduler: Scheduler = AndroidSchedulers.mainThread()): PreloadStateManager {
        // scheduler is extracted for Unit testing simplicity, must be AndroidSchedulers.mainThread() in runtime
        with(PreloadStateManager(scheduler)) {
            addStep(PreloadStateManager.PreloadStep.VIDEO_INTRO,
                    activity.playVideoIntroIfPresent())

            addStep(PreloadStateManager.PreloadStep.STARTUP_HOOK,
                    activity.executeHooks(false))

            addStep(PreloadStateManager.PreloadStep.LOAD_DATA,
                    DataLoader.initialize(activity.applicationContext),
                    PreloadStateManager.PreloadStep.STARTUP_HOOK)

            addStep(PreloadStateManager.PreloadStep.APPLICATION_READY_HOOK,
                    activity.executeHooks(true),
                    PreloadStateManager.PreloadStep.LOAD_DATA)

            addStep(PreloadStateManager.PreloadStep.UI_READY,
                    activity.initializeUILayer(),
                    PreloadStateManager.PreloadStep.APPLICATION_READY_HOOK)

            addStep(PreloadStateManager.PreloadStep.RUNNING,
                    activity.showUI(),
                    PreloadStateManager.PreloadStep.VIDEO_INTRO, PreloadStateManager.PreloadStep.UI_READY)
            return this
        }
    }
}
