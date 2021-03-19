package com.applicaster.ui.quickbrick.profiling;

import android.util.Log;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;

import com.facebook.react.ReactRootView;
import com.facebook.react.bridge.NotThreadSafeBridgeIdleDebugListener;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.devsupport.FpsView;

public class PerformanceOverlay extends FpsView implements NotThreadSafeBridgeIdleDebugListener {

    private final ReactContext reactContext;
    private final ReactRootView reactRootView;
    private long enterTime;

    private PerformanceOverlay(@NonNull ReactContext reactContext,
                               @NonNull ReactRootView reactRootView) {
        super(reactContext);
        this.reactContext = reactContext;
        this.reactRootView = reactRootView;
    }

    public static PerformanceOverlay create(@NonNull ReactContext reactContext,
                                            @NonNull ReactRootView reactRootView){
        PerformanceOverlay fpsView = new PerformanceOverlay(reactContext, reactRootView);
        LayoutParams params = new LayoutParams(
                LayoutParams.WRAP_CONTENT,
                LayoutParams.WRAP_CONTENT,
                Gravity.TOP| Gravity.RIGHT);
        fpsView.setLayoutParams(params);
        ((ViewGroup)reactRootView.getParent()).addView(fpsView);
        return fpsView;
    }

    public void release() {
        ((ViewGroup)reactRootView.getParent()).removeView(this);
    }

    @Override
    public void onTransitionToBridgeIdle() {
        if(0 == enterTime)
            return; // first call, ignore
        long work = System.nanoTime() - enterTime;
        if(work > 1_000_000_000 / 4) { // 1/4 second warn threshold
            String msg = "Bridge was busy for " + work / 1_000_000 + " ms";
            Log.w("TransitionTimer", msg);
            Toast.makeText(reactContext, msg, Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    public void onTransitionToBridgeBusy() {
        enterTime = System.nanoTime();
    }

    @Override
    public void onBridgeDestroyed() {
    }


    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        reactContext.getCatalystInstance().addBridgeIdleDebugListener(this);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        reactContext.getCatalystInstance().removeBridgeIdleDebugListener(this);
    }
}
