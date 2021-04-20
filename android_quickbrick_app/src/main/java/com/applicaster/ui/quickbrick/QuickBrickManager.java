package com.applicaster.ui.quickbrick;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;

import com.applicaster.reactnative.utils.DataUtils;
import com.applicaster.ui.interfaces.HostActivityBase;
import com.applicaster.ui.interfaces.IUILayerManager;
import com.applicaster.ui.quickbrick.listeners.QuickBrickCommunicationListener;
import com.applicaster.ui.utils.RTL_LOCALES;
import com.applicaster.util.APDebugUtil;
import com.applicaster.util.APLogger;
import com.applicaster.util.AppData;
import com.applicaster.util.NetworkRequestListener;
import com.applicaster.util.OSUtil;
import com.applicaster.util.server.SSLPinner;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactInstanceManagerBuilder;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.common.LifecycleState;
import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.modules.i18nmanager.I18nUtil;
import com.facebook.react.modules.network.OkHttpClientProvider;
import com.swmansion.gesturehandler.react.RNGestureHandlerEnabledRootView;
import com.facebook.react.ReactRootView;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.InvocationTargetException;
import java.util.List;

import okhttp3.OkHttpClient;

public class QuickBrickManager implements
        IUILayerManager,
        DefaultHardwareBackBtnHandler,
        QuickBrickCommunicationListener,
        ReactInstanceManager.ReactInstanceEventListener {

    private static final String RN_EVENT_HANDLE_OPEN_URL = "handleOpenUrl";
    private final String TAG = getClass().getSimpleName();
    private static final String REACT_NATIVE_MODULE_NAME = "QuickBrickApp";
    private static final String JS_BUNDLE_PATH = "main.jsbundle";

    private final HostActivityBase rootActivity;
    private final Application application;
    private StatusListener listener;
    private ReactInstanceManager reactInstanceManager;
    private String debugPackagerRoot;
    private Long lastRefreshTap = System.currentTimeMillis();
    private ReactPackagesManager reactPackagesManager;

    private boolean blockTVKeyEmit = true;

    private ReactRootView reactRootView;

    private boolean initialized;

    @Override
    public boolean isReady() {
        return initialized;
    }

    private boolean isBuildTypeDebug;

    private boolean isBuildTypeDebug() {
        return isBuildTypeDebug;
    }

    private void setIsBuildTypeDebug(boolean buildTypeDebug) {
        isBuildTypeDebug = buildTypeDebug;
    }

    public QuickBrickManager(HostActivityBase rootActivity) {
        this.rootActivity = rootActivity;
        this.application = rootActivity.getApplication();
        setRightToLeftFlag();
        reactPackagesManager = new ReactPackagesManager();
        debugPackagerRoot = getDebugPackagerRoot();
        setIsBuildTypeDebug(APDebugUtil.getIsInDebugMode());
    }

    // region Activity life cycle callbacks

    @Override
    public void onBackPressed() {
        if (reactInstanceManager != null) {
            reactInstanceManager.onBackPressed();
        } else {
            rootActivity.onBackPressed();
        }
    }

    @Override
    public void onPause() {
        if (reactInstanceManager != null) reactInstanceManager.onHostPause(rootActivity);
    }

    @Override
    public void onResume() {
        if (reactInstanceManager != null) reactInstanceManager.onHostResume(rootActivity, this);
    }

    @Override
    public void onDestroy() {
        if (reactInstanceManager != null) reactInstanceManager.onHostDestroy(rootActivity);
        if (reactRootView != null) reactRootView.unmountReactApplication();
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (reactInstanceManager != null) {
            reactInstanceManager.onActivityResult(this.rootActivity, requestCode, resultCode, data);
        }
    }

    // endregion


    /**
     * Method override onKeyDown and return true if override is needed
     * otherwise return false
     * Returns true when:
     * - Platform is TV
     * - Platform is not TV and it is in debug mode which returns true
     * Otherwise method return false (key not consumed)
     * Possible interactions with simulator:
     *
     * @param keyCode integer representation of pressed key
     * @param event   KeyEvent representation of pressed key
     * @return Boolean - whether super.onKeyDown() should be override
     */
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (OSUtil.isTv()) {
            return onTvKeyDown(keyCode, event);
        } else {
            return onMobileKeyDown(keyCode, event);
        }
    }

    private boolean onMobileKeyDown(int keyCode, KeyEvent event) {
        if (APDebugUtil.getIsInDebugMode()) {
            return onKeyDownDebug(keyCode);
        } else {
            return false;
        }
    }

    @Override
    public void orientationChange(int from, int to) {
        WritableNativeMap resultMap = new WritableNativeMap();
        DataUtils.pushToReactMap(resultMap, "toOrientation", to);
        DataUtils.pushToReactMap(resultMap, "fromOrientation", from);
        if (reactInstanceManager != null && reactInstanceManager.getCurrentReactContext() != null) {
            reactInstanceManager
                .getCurrentReactContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("orientationChange", resultMap);
        }
    }

    private boolean onTvKeyDown(int keyCode, KeyEvent event) {
        WritableNativeMap resultMap = new WritableNativeMap();
        DataUtils.pushToReactMap(resultMap, "keyCode", keyCode);
        DataUtils.pushToReactMap(resultMap, "code", event.toString());

        reactInstanceManager
            .getCurrentReactContext()
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit("onTvKeyDown", resultMap);

        if (APDebugUtil.getIsInDebugMode())
            this.onKeyDownDebug(keyCode);

        return blockTVKeyEmit;
    }

    // region Key event processing (simulator in Debug flavor)

    /**
     * Debug flavor only - check key codes when interacting with simulator.
     * Returns false when:
     * - Uninitialized
     * - Not using dev packager
     * - Irrelevant key
     * - Not a double-tap on the "R" key
     * Possible interactions with simulator:
     * - `adb shell input keyevent KEYCODE_MENU`    - show dev menu
     * - `cmd-m`                                    - show dev menu
     * - Double-tap on "R" key                      - reload dev packager
     *
     * @param keyCode Checking for KeyEvent.KEYCODE_MENU or KeyEvent.KEYCODE_R
     * @return Boolean - whether super.onKeyDown() should be override
     */
    @Override
    public boolean onKeyDownDebug(int keyCode) {
        if (debugPackagerRoot.isEmpty() || (reactInstanceManager == null))
            return false;

        switch (keyCode) {
            case KeyEvent.KEYCODE_MENU: {
                reactInstanceManager.showDevOptionsDialog();
                return true;
            }
            case KeyEvent.KEYCODE_R: {
                if (isDoubleTap()) {
                    reactInstanceManager.recreateReactContextInBackground();
                    return true;
                }
            }
            default: {
                return false;
            }
        }
    }

    /**
     * Debug flavor only: save last key tap and return true if this is a double-tap.
     * Crude, but again - debug only.
     *
     * @return Boolean - is it a double-tap?
     */
    private boolean isDoubleTap() {
        Long currentRefreshTap = System.currentTimeMillis();
        if ((currentRefreshTap - lastRefreshTap) < 250) {
            return true;
        }

        lastRefreshTap = currentRefreshTap;
        return false;
    }

    // endregion

    @Override
    public void setEventsListener(StatusListener listener) {
        this.listener = listener;
    }

    @Override
    public void start() {
        try {
            reactInstanceManager = getReactInstanceManager();
            reactInstanceManager.addReactInstanceEventListener(this);
            initOkHttpClientProvider();
            initializeFlipper(application, reactInstanceManager);
            reactInstanceManager.createReactContextInBackground();
        } catch (Exception e) {
            if (listener != null) listener.onError(e);
        }
    }

    private void initOkHttpClientProvider() {
        OkHttpClient.Builder builder = OkHttpClientProvider.createClientBuilder(application);
        SSLPinner.apply(builder);
        builder.addInterceptor(new NetworkRequestListener("QBNetworkRequestLogger"));
        OkHttpClientProvider.setOkHttpClientFactory(builder::build);
    }

    private void initializeFlipper(Context context, ReactInstanceManager reactInstanceManager) {
        if (!APDebugUtil.getIsInDebugMode()) {
            return;
        }
        /*
         We use reflection here to pick up the class that initializes
         Flipper, since Flipper library is not available in release mode
        */
        try {
            Class<?> aClass = Class.forName("com.applicaster.reactnative.flipper.ReactNativeFlipper");
            aClass.getMethod("initializeFlipper", Context.class, ReactInstanceManager.class).invoke(null, context, reactInstanceManager);
        } catch (ClassNotFoundException | NoSuchMethodException | IllegalAccessException | InvocationTargetException e) {
            APLogger.error(TAG, "Failed to initialize Flipper", e);
        }
    }

    private String getDebugPackagerRoot() {
        int packagerRootResourceID = OSUtil.getStringResourceIdentifier("REACT_NATIVE_PACKAGER_ROOT");
        if (packagerRootResourceID > 0) {
            return rootActivity.getString(packagerRootResourceID);
        }
        return "";
    }

    /**
     * React Native boilerplate - prepare React Native instance.
     * Takes a common instance manager and apply additional flags according to debug/release flavor.
     * IMPORTANT: In order to use the local react native server, this flag in the command line options:
     * -PREACT_NATIVE_PACKAGER_ROOT=localhost:8081
     * For Android Studio users: Preferences > Build, Execution, Development > Compiler > Command-line Options
     */
    private ReactInstanceManager getReactInstanceManager() throws FileNotFoundException {
        return isUsingDevPackager()
            ? getInstanceManagerWithPackager()
            : getInstanceManagerWithBundle();
    }

    /**
     * @return ReactInstanceManager in debug mode, loading bundle from RN dev packager.
     */
    private ReactInstanceManager getInstanceManagerWithPackager() {
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(application); // React Native is using the default shared prefs, we must comply
        preferences.edit().putString("debug_http_host", debugPackagerRoot).apply();

        return getQuickBrickReactManagerBuilder()
            .setUseDeveloperSupport(true)
            .setBundleAssetName("index.android.bundle")
            .setJSMainModulePath("index")
            .build();
    }

    /**
     * @return ReactInstanceManager in release mode, loading pre-packaged RN bundle.
     */
    private ReactInstanceManager getInstanceManagerWithBundle() throws FileNotFoundException {
        if (!assetExists(JS_BUNDLE_PATH)) {
            throw new FileNotFoundException("bundle not found in path: assets://" + JS_BUNDLE_PATH);
        }

        return getQuickBrickReactManagerBuilder()
            .setJSBundleFile("assets://" + JS_BUNDLE_PATH)
            .build();
    }

    /**
     * Returns builder with initialized values common to both debug and release builds.
     * The crucial part is the <code>addPackages()</code>,
     * where the list of UNIQTE packages returned from the {@link ReactPackagesManager}
     * are added to the {@link ReactInstanceManagerBuilder}, including the default MainReactPackage.
     *
     * @return Initialized ReactInstanceManagerBuilder with all required react packages,
     * including those extracted from the plugins configuration.
     */
    private ReactInstanceManagerBuilder getQuickBrickReactManagerBuilder() {
        reactPackagesManager.initializeDefaultPackages();
        reactPackagesManager.initializePackagesFromPlugins();
        reactPackagesManager.addExtraPackage(new QuickBrickCommunicationReactPackage(this)); // specific to QuickBrick interactions)

        Lifecycle.State currentState = rootActivity.getLifecycle().getCurrentState();

        return ReactInstanceManager.builder()
            .setApplication(application)
            .setCurrentActivity(rootActivity)
            .addPackages(reactPackagesManager.getAllReactPackages()) // packages: default, from plugins, extras
            .setInitialLifecycleState(Lifecycle.State.RESUMED == currentState
                    ? LifecycleState.RESUMED : LifecycleState.BEFORE_RESUME);
    }

    /**
     * Only when the {@linkplain ReactContext} is ready,
     * create the reactRootView and start the application.
     * This callback called every time the packager reloads the bundle in dev mode,
     * so we have to remove the event listener to prevent creating multiple root views.
     *
     * @param context
     */
    @Override
    public void onReactContextInitialized(ReactContext context) {
        reactInstanceManager.removeReactInstanceEventListener(this);
        if (OSUtil.isTv()) {
            reactRootView = new ReactRootView(context); // Extends ReactRootView
        } else {
            reactRootView = new RNGestureHandlerEnabledRootView(rootActivity);
        }

        initialized = true;
        reactRootView.startReactApplication(reactInstanceManager, REACT_NATIVE_MODULE_NAME, null);
    }

    @Override
    public void quickBrickEvent(String eventName, ReadableMap payload) {
        //
        // TODO: create the decision making mechanism
        // For now, it is hard-coded to "react native app is ready to be presented" event.

        switch (eventName) {
            case "quickBrickReady": {
                if (listener != null) listener.onReady();
                break;
            }
            case "blockTVKeyEmit": {
                blockTVKeyEmit = payload.getBoolean("blockTVKeyEmit");
                break;
            }
            case "moveAppToBackground": {
                this.rootActivity.moveTaskToBack(true);
                break;
            }
            case "allowedOrientationsForScreen": {
                int orientation = payload.getInt("orientation");
                this.rootActivity.setAppOrientation(orientation);
                break;
            }
            case "releaseOrientationsForScreen":
                this.rootActivity.releaseOrientation();
                break;

            default: {
                Log.e(TAG, "Got unrecognized quickBrickEvent. eventName: " + eventName + " payload: " + payload.toString());
                break;
            }
        }
    }

    private boolean isUsingDevPackager() {
        return (isBuildTypeDebug() && !debugPackagerRoot.isEmpty());
    }

    @Override
    public void invokeDefaultOnBackPressed() {
        this.rootActivity.onBackPressed();
    }

    //region QBEventsListener

    //endregion

    /**
     * Check if an asset exists.
     *
     * @param path File name / path (without the "assets://" root).
     * @return TRUE if the asset exists and FALSE otherwise.
     */
    private boolean assetExists(@NonNull String path) {
        boolean exists = false;
        try {
            InputStream stream = application.getAssets().open(path);
            stream.close();
            exists = true;
        } catch (FileNotFoundException e) {
            Log.e(TAG, "Asset in assets://" + path + " was not found", e);
        } catch (IOException e) {
            Log.e(TAG, "I/O error in retrieving asset from assets://" + path, e);
        }
        return exists;
    }

    @Override
    public void handleURL(@NonNull String url) {
        WritableNativeMap resultMap = new WritableNativeMap();
        DataUtils.pushToReactMap(resultMap, "url", url);
        reactInstanceManager
                .getCurrentReactContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(RN_EVENT_HANDLE_OPEN_URL, resultMap);
    }

    public void setRightToLeftFlag() {
        if (OSUtil.isTv()) {
            I18nUtil.getInstance().allowRTL(this.rootActivity, false);
            I18nUtil.getInstance().forceRTL(this.rootActivity, false);
        } else {
            List<String> languageList = AppData.getAvailableLocalizations();
            String appLocale = AppData.getLocale().toString();
            String localeToUse = languageList.isEmpty() || languageList.contains(appLocale)
                    ? appLocale : languageList.get(0);

            I18nUtil.getInstance().forceRTL(
                    this.rootActivity,
                    RTL_LOCALES.includes(localeToUse)
            );
        }
    }

    @Override
    @NonNull
    public View getRootView() {
        return reactRootView;
    }
}
