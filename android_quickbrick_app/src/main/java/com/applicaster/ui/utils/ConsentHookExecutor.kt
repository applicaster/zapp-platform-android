package com.applicaster.ui.utils

import android.app.Activity
import com.applicaster.plugin_manager.cmp.IUserConsent
import io.reactivex.CompletableEmitter
import java.util.*

class ConsentHookExecutor(private val activity: Activity,
                          hooks: List<IUserConsent>,
                          private val onComplete: CompletableEmitter) : IUserConsent.IListener {

    private val hooks: Queue<IUserConsent>

    private fun next() = when (val hook = hooks.poll()) {
        null -> onComplete.onComplete()
        else -> activity.runOnUiThread {
            hook.presentStartupNotice(activity, this)
        }
    }

    init {
        this.hooks = ArrayDeque(hooks)
        next()
    }

    override fun onComplete() = next()

    override fun onError(error: String, e: Throwable?) =
            onComplete.onError(e ?: RuntimeException(error))

}
