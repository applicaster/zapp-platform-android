package com.applicaster.ui.quickbrick;

import com.applicaster.ui.quickbrick.components.ChildrenFocusDeactivatorManager;
import com.applicaster.ui.quickbrick.listeners.QuickBrickCommunicationListener;
import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.List;

class QuickBrickCommunicationReactPackage implements ReactPackage {
    private QuickBrickCommunicationListener listener;

    public QuickBrickCommunicationReactPackage(QuickBrickCommunicationListener listener) {
        this.listener = listener;
    }

    @NotNull
    @Override
    public List<ViewManager> createViewManagers(@NotNull ReactApplicationContext reactContext) {
        List<ViewManager> modules = new ArrayList<>();
        modules.add(new ChildrenFocusDeactivatorManager(reactContext));

        return modules;
    }

    @NotNull
    @Override
    public List<NativeModule> createNativeModules(@NotNull ReactApplicationContext reactContext) {
        List<NativeModule> modules = new ArrayList<>();
        modules.add(new QuickBrickCommunicationModule(reactContext, listener));
        return modules;
    }
}
