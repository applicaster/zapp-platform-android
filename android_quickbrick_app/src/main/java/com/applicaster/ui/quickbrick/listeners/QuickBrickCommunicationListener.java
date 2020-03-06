package com.applicaster.ui.quickbrick.listeners;

import com.facebook.react.bridge.ReadableMap;

public interface QuickBrickCommunicationListener {
    void quickBrickEvent(String eventName, ReadableMap payload);
}
