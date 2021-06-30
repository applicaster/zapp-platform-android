package com.applicaster.ui.utils

import android.app.Activity
import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI
import com.applicaster.plugin_manager.hook.HookListener
import io.reactivex.CompletableEmitter
import java.util.*

class AppHookExecutor(private val activity: Activity,
                      hooks: List<ApplicationLoaderHookUpI>,
                      private val onComplete: CompletableEmitter,
                      private val isAppReady: Boolean) : HookListener {

    private val hooks: Queue<ApplicationLoaderHookUpI>

    private fun next() {
        when (val hook = hooks.poll()) {
            null -> onComplete.onComplete()
            else -> {
                activity.runOnUiThread {
                    when {
                        isAppReady -> hook.executeOnApplicationReady(activity, this)
                        else -> hook.executeOnStartup(activity, this)
                    }
                }
            }
        }
    }

    override fun onHookFinished() = next()

    init {
        this.hooks = ArrayDeque(hooks)
        next()
    }

}