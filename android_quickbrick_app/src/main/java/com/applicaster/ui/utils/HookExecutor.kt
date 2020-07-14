package com.applicaster.ui.utils

import android.app.Activity
import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI
import com.applicaster.plugin_manager.hook.HookListener
import java.util.*

class HookExecutor(private val activity: Activity,
                   hooks: List<ApplicationLoaderHookUpI>,
                   private val onComplete: Runnable,
                   private val isAppReady: Boolean) : HookListener {

    private val hooks: Queue<ApplicationLoaderHookUpI>

    private operator fun next() {
        val hook = hooks.poll()
        if (null == hook) {
            onComplete.run()
        } else {
            if (isAppReady) {
                activity.runOnUiThread { hook.executeOnApplicationReady(activity, this) }
            } else {
                activity.runOnUiThread { hook.executeOnStartup(activity, this) }
            }
        }
    }

    override fun onHookFinished() = next()

    init {
        this.hooks = ArrayDeque(hooks)
        next()
    }
}