package com.applicaster.ui.loaders

import com.applicaster.util.APLogger
import io.reactivex.Completable

class PreloadStateManager {

    enum class PreloadStep {
        STARTUP_HOOK,
        LOAD_DATA,
        VIDEO_INTRO,
        APPLICATION_READY_HOOK,
        UI_READY,
        RUNNING
    }

    private data class Step(val step: PreloadStep,
                            val executor: Completable,
                            val depends: Set<PreloadStep> = setOf())

    private val actions = mutableSetOf<Step>()
    private val complete = mutableSetOf<PreloadStep>()
    private val running = mutableSetOf<PreloadStep>()

    fun addStep(step: PreloadStep,
                executor: Completable,
                vararg depends: PreloadStep) {
        actions.add(Step(step, executor, setOf(*depends)))
    }

    fun run() = tryNext()

    @Synchronized
    private fun tryNext() {
        if (actions.isEmpty()) {
            if(running.isEmpty()) {
                APLogger.info(TAG, "Initialization complete")
            }
            return
        }

        val actionable = actions.filter { complete.containsAll(it.depends) }.toList()

        if (actionable.isEmpty()) {
            if(running.isEmpty()) {
                val stepsLeft = actions.joinToString { it.step.name }
                APLogger.error(TAG, "Initialization deadlock, some steps has failed to meet conditions: $stepsLeft")
            }
        } else {
            actions.removeAll(actionable)
            running.addAll(actionable.map { it.step })
            actionable.forEach { action: Step ->
                APLogger.info(TAG, "Executing initialization step: ${action.step}")
                action.executor.subscribe {
                    complete.add(action.step)
                    APLogger.info(TAG, "Initialization step complete: ${action.step}")
                    tryNext()
                }
                // todo: handle errors
            }
        }
    }

    companion object {
        private const val TAG = "PreloadStateManager"
    }
}
