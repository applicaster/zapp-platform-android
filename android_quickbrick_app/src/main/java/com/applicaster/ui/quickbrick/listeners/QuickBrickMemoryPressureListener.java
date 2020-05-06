package com.applicaster.ui.quickbrick.listeners;

import android.content.ComponentCallbacks2;

import com.facebook.common.memory.MemoryTrimType;
import com.facebook.common.memory.MemoryTrimmable;
import com.facebook.common.memory.MemoryTrimmableRegistry;

import java.util.LinkedList;
import java.util.List;

public class QuickBrickMemoryPressureListener implements MemoryTrimmableRegistry, com.facebook.react.bridge.MemoryPressureListener {
    private final List<MemoryTrimmable> trimmables = new LinkedList<>();

    @Override
    public void registerMemoryTrimmable(MemoryTrimmable trimmable) {
        synchronized(this){
            trimmables.add(trimmable);
        }
    }

    @Override
    public void unregisterMemoryTrimmable(MemoryTrimmable trimmable) {
        synchronized(this){
            trimmables.remove(trimmable);
        }
    }

    @Override
    public void handleMemoryPressure(int level) {
        synchronized(this){
            MemoryTrimType trimType;
            switch (level) {
                case ComponentCallbacks2.TRIM_MEMORY_UI_HIDDEN:
                    trimType = MemoryTrimType.OnAppBackgrounded;
                    break;

                case ComponentCallbacks2.TRIM_MEMORY_RUNNING_MODERATE:
                case ComponentCallbacks2.TRIM_MEMORY_RUNNING_LOW:
                case ComponentCallbacks2.TRIM_MEMORY_RUNNING_CRITICAL:
                    trimType = MemoryTrimType.OnCloseToDalvikHeapLimit;
                    break;

                case ComponentCallbacks2.TRIM_MEMORY_BACKGROUND:
                case ComponentCallbacks2.TRIM_MEMORY_MODERATE:
                case ComponentCallbacks2.TRIM_MEMORY_COMPLETE:
                    trimType = MemoryTrimType.OnSystemLowMemoryWhileAppInBackground;
                    break;

                default:
                    trimType = MemoryTrimType.OnSystemLowMemoryWhileAppInForeground;
                    break;
            }
            for (MemoryTrimmable trimmable : trimmables) {
                trimmable.trim(trimType);
            }
        }
    }
}
