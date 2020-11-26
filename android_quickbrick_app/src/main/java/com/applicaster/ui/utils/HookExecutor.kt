package com.applicaster.ui.utils

import android.app.Activity
import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI
import com.applicaster.plugin_manager.hook.HookListener
import io.reactivex.CompletableEmitter
import java.util.*

class HookExecutor(private val activity: Activity,
                   hooks: List<ApplicationLoaderHookUpI>,
                   private val onComplete: CompletableEmitter,
                   private val isAppReady: Boolean) : HookListener {

    private val hooks: Queue<ApplicationLoaderHookUpI>

    private fun next() {
        val hook = hooks.poll()
        if (null == hook) {
            onComplete.onComplete()
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