package com.applicaster.ui.loaders

import com.applicaster.util.APLogger
import io.reactivex.Completable
import io.reactivex.Scheduler

class PreloadStateManager(private val defaultScheduler: Scheduler) {

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
                vararg depends: PreloadStep): PreloadStateManager {
        actions.add(Step(step, executor, setOf(*depends)))
        return this
    }

    fun run() {
        verify()
        tryNext()
    }

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
                // For now we run and observe on UI thread.
                // Tasks can wrap it internally, or we will add an option to the step in the future.
                action.executor
                        .subscribeOn(defaultScheduler)
                        .observeOn(defaultScheduler)
                        .subscribe {
                            running.remove(action.step)
                            complete.add(action.step)
                            APLogger.info(TAG, "Initialization step complete: ${action.step}")
                            tryNext()
                        }
                // todo: handle errors
            }
        }
    }

    /**
     * Verify that current steps graph is correct.
     * Will throw an IllegalStateException if there are unreachable steps.
     */
    fun verify() {
        val left = LinkedHashSet<Step>(actions)
        val performed = mutableSetOf<PreloadStep>()
        while (left.isNotEmpty()) {
            val actionable = left.filter { performed.containsAll(it.depends) }.toList()
            if (actionable.isEmpty()) {
                val unreachable = left.joinToString { it.step.name }
                throw IllegalStateException("Some steps are unreachable: $unreachable")
            }
            left.removeAll(actionable)
            performed.addAll(actionable.map { it.step })
        }
    }

    @Synchronized
    fun complete() = actions.isEmpty() && running.isEmpty()

    companion object {
        private const val TAG = "PreloadStateManager"
    }
}
