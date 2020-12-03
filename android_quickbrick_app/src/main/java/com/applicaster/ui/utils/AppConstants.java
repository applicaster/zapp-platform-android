package com.applicaster.ui.utils;

import android.content.Context;

import com.applicaster.app.APProperties;
import com.applicaster.reactnative.utils.InitialProperties;
import com.applicaster.session.SessionStorage;
import com.applicaster.util.AppData;
import com.applicaster.util.OSUtil;

import java.util.HashMap;
import java.util.Map;

/**
 * Generates constants from AppData and OSUtil.
 * This is a toned-down version of the values in {@link com.applicaster.jspipes.JSManager} -
 * which has many properties do not need.
 *
 * Important: Also returns "initialProps" for legacy RN plugins,
 * based on {@link com.applicaster.reactnative.ReactNativeViewLoader}
 * @return      Key/value map of properties used by Zapp-Pipes (DSP) and React Native plugins.
 */
public class AppConstants {
    private static final String ACCOUNT_ID = "accountId";
    private static final String BROADCASTER_ID = "broadcasterId";
    private static final String BUNDLE_IDENTIFIER = "bundleIdentifier";
    private static final String ACCOUNTS_ACCOUNT_ID = "accountsAccountId";
    private static final String INITIAL_PROPS = "initialProps";
    private static final String API_SECRET_KEY = "apiSecretKey";
    private static final String ZAPP_VERSION = "versionName";
    private static final String DEVICE_ID = "deviceId";
    private static final String RIVERS_ID = "riversConfigurationId";
    private static final String BUILD_VERSION = "build_version";
    private static final String IS_TABLET_PORTRAIT = "isTabletPortrait";

    private static final String LANGUAGE_CODE = "languageCode";
    private static final String LANGUAGE_LOCALE = "languageLocale";
    private static final String COUNTRY_LOCALE = "countryLocale";

    public static Map<String, Object> generateMap(Context context) {
        Map<String, Object> constants = new HashMap<>();
        constants.put(ACCOUNT_ID,           AppData.getProperty(APProperties.ACCOUNT_ID_KEY));
        constants.put(BROADCASTER_ID,       AppData.getProperty(APProperties.BROADCASTER_ID_KEY));
        constants.put(BUNDLE_IDENTIFIER,    OSUtil.getBundleId());
        constants.put(ACCOUNTS_ACCOUNT_ID,  AppData.getProperty(APProperties.NEW_ACCOUNTS_ID_KEY));
        constants.put(INITIAL_PROPS,        InitialProperties.getBundle(context));
        constants.put(API_SECRET_KEY,       AppData.getProperty(APProperties.API_KEY));
        constants.put(ZAPP_VERSION,         OSUtil.getZappAppVersion());
        constants.put(DEVICE_ID,            OSUtil.getDeviceIdentifier(context));
        constants.put(RIVERS_ID,            AppData.getProperty(RIVERS_ID));
        constants.put(BUILD_VERSION,        OSUtil.getAppVersionCode(context));
        constants.put(IS_TABLET_PORTRAIT,   "true".equals(AppData.getProperty(APProperties.IS_TABLET_PORTRAIT)));

        constants.put(LANGUAGE_LOCALE, SessionStorage.INSTANCE.get(SessionStorage.LANGUAGE_LOCALE));
        constants.put(LANGUAGE_CODE, SessionStorage.INSTANCE.get(SessionStorage.LANGUAGE_CODE));
        constants.put(COUNTRY_LOCALE, SessionStorage.INSTANCE.get(SessionStorage.COUNTRY_LOCALE));

        return constants;
    }
}
