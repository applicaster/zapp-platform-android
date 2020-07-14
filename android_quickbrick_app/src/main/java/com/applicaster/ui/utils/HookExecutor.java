package com.applicaster.ui.utils;

import android.app.Activity;

import androidx.annotation.NonNull;

import com.applicaster.plugin_manager.hook.ApplicationLoaderHookUpI;
import com.applicaster.plugin_manager.hook.HookListener;

import java.util.ArrayDeque;
import java.util.List;
import java.util.Queue;

public class HookExecutor implements HookListener {

    private final Queue<ApplicationLoaderHookUpI> hooks;
    private final Runnable onComplete;
    private final Activity activity;
    private final boolean isAppReady;

    public HookExecutor(@NonNull Activity activity,
                        @NonNull List<ApplicationLoaderHookUpI> hooks,
                        @NonNull Runnable onComplete,
                        boolean isAppReady) {
        this.activity = activity;
        this.hooks = new ArrayDeque<>(hooks);
        this.onComplete = onComplete;
        this.isAppReady = isAppReady;
        next();
    }

    private void next() {
        ApplicationLoaderHookUpI hook = hooks.poll();
        if(null == hook) {
            onComplete.run();
        }
        else {
            if (isAppReady) {
                this.activity.runOnUiThread(() -> hook.executeOnApplicationReady(activity, this));
            } else {
                this.activity.runOnUiThread(() -> hook.executeOnStartup(activity, this));
            }
        }
    }

    @Override
    public void onHookFinished() {
        next();
    }
}
