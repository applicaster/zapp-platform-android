package com.applicaster.ui.quickbrick;

import com.applicaster.ui.utils.AppConstants;
import com.applicaster.ui.quickbrick.listeners.QuickBrickCommunicationListener;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.util.Map;

class QuickBrickCommunicationModule extends ReactContextBaseJavaModule {
    private final QuickBrickCommunicationListener listener;
    private final Map<String, Object> constants;

    public QuickBrickCommunicationModule(ReactApplicationContext reactContext, QuickBrickCommunicationListener listener) {
        super(reactContext);
        this.listener = listener;
        this.constants = AppConstants.generateMap(reactContext);
    }

    @Override
    public String getName() {
        return "QuickBrickCommunicationModule";
    }

    /**
     * Pass whole event from js to the listener, moving the decision making to the subscriber.
     * @param eventName     Name of the event in js - we didn't settle yet on the various events so that'll be for later.
     * @param payload       Facebook's interpretation of a JSON object.
     *                      Not all event will require a meaningful payload, so it can be empty.
     */
    @ReactMethod
    public void quickBrickEvent(String eventName, ReadableMap payload) {
        listener.quickBrickEvent(eventName, payload);
    }

    /**
     * App Data constants, required for Zapp-Pipes adapter (main data source provider) and legacy RN plugins.
     * Unlike initialProperties or @ReactMethod, these properties
     * can be accessed synchronously anytime via {@link QuickBrickCommunicationModule}
     * @return      Key/value map of some unique app properties, see {@link AppConstants#generateMap()}.
     */
    @Override
    public Map<String, Object> getConstants() {
        return constants;
    }
}
