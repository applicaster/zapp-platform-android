package com.applicaster.ui.loaders;

import org.junit.Assert;
import org.junit.Test;

import io.reactivex.Completable;
import io.reactivex.schedulers.Schedulers;


public class PreloadStateManagerTest {

    @Test
    public void reachableTest() {
        new PreloadStateManager(Schedulers.trampoline())
                .addStep(PreloadStateManager.PreloadStep.VIDEO_INTRO,
                        Completable.complete())
                .addStep(PreloadStateManager.PreloadStep.STARTUP_HOOK,
                        Completable.complete())
                .addStep(PreloadStateManager.PreloadStep.LOAD_DATA,
                        Completable.complete(),
                        PreloadStateManager.PreloadStep.STARTUP_HOOK)
                .addStep(PreloadStateManager.PreloadStep.APPLICATION_READY_HOOK,
                        Completable.complete(),
                        PreloadStateManager.PreloadStep.LOAD_DATA)
                .addStep(PreloadStateManager.PreloadStep.UI_READY,
                        Completable.complete(),
                        PreloadStateManager.PreloadStep.APPLICATION_READY_HOOK)
                .addStep(PreloadStateManager.PreloadStep.RUNNING,
                        Completable.complete(),
                        PreloadStateManager.PreloadStep.VIDEO_INTRO, PreloadStateManager.PreloadStep.UI_READY)
                .verify();
    }

    @Test
    public void unreachableTest() throws Exception {
        try {
            new PreloadStateManager(Schedulers.trampoline())
                    .addStep(PreloadStateManager.PreloadStep.VIDEO_INTRO,
                            Completable.complete())
                    .addStep(PreloadStateManager.PreloadStep.STARTUP_HOOK,
                            Completable.complete())
                    .addStep(PreloadStateManager.PreloadStep.APPLICATION_READY_HOOK,
                            Completable.complete(),
                            PreloadStateManager.PreloadStep.LOAD_DATA)
                    .addStep(PreloadStateManager.PreloadStep.UI_READY,
                            Completable.complete(),
                            PreloadStateManager.PreloadStep.APPLICATION_READY_HOOK)
                    .addStep(PreloadStateManager.PreloadStep.RUNNING,
                            Completable.complete(),
                            PreloadStateManager.PreloadStep.VIDEO_INTRO, PreloadStateManager.PreloadStep.UI_READY)
                    .verify();
        } catch (IllegalStateException e) {
            // all is fine, we were waiting for that exception
            String message = e.getMessage();
            Assert.assertEquals("Some steps are unreachable: APPLICATION_READY_HOOK, UI_READY, RUNNING", message);
            return;
        }
        throw new Exception("Failed to detect unreachable steps");
    }

}
