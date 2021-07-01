package com.applicaster.ui.application;

import android.app.Application;
import android.os.Build;
import android.util.Log;

import com.applicaster.app.APProperties;
import com.applicaster.app.CustomApplication;
import com.applicaster.audience.AudienceHelper;
import com.applicaster.plugin_manager.push_plugin.PushManager;
import com.applicaster.session.SessionStorage;
import com.applicaster.storage.LocalStorage;
import com.applicaster.storage.SecureSharedPreferencesRepository;
import com.applicaster.storage.SharedPreferencesRepository;
import com.applicaster.ui.BuildConfig;
import com.applicaster.util.APDebugUtil;
import com.applicaster.util.APLogger;
import com.applicaster.util.AppContext;
import com.applicaster.util.AppData;
import com.applicaster.util.ErrorMonitoringUtil;
import com.applicaster.util.OSUtil;
import com.facebook.soloader.SoLoader;

public class BaseApplication
        extends Application {

    private static final String TAG = "BaseApplication";

    @Override
    public void onCreate() {
        super.onCreate();
        SoLoader.init(this, /* native exopackage */ false);
        AppContext.set(this);
        initAppData();
        ErrorMonitoringUtil.initPlugins(this);
        initLocale();
        LocalStorage.INSTANCE.init(
                new SharedPreferencesRepository(this),
                Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP
                        ? new SecureSharedPreferencesRepository(this)
                        : new SharedPreferencesRepository(this));

        SessionStorage.INSTANCE.init(this);

        APDebugUtil.OnApplicationLoaded(this);
        reportAppPresented();

        PushManager.initPushProviders(this);
    }

    private void initAppData() {
        AppData.loadProperties(this);
        try {
            AppData.setProperty(APProperties.URL_SCHEME_PREFIX, getString(OSUtil.getStringResourceIdentifier("scheme_url_prefix")));
        }
        catch (Exception e) {
            APLogger.error(TAG, "add scheme_url_prefix to strings.xml");
        }
        // fix up store for Amazon FireTV until we have better solution on the SDK level
        if(BuildConfig.FLAVOR_vendor.equals("amazon") &&
                AppData.ApplicationStore.android == AppData.getApplicationStore()) {
            APLogger.warn(TAG, "AppData Store property did not match build config and was overridden from "
                    + AppData.getApplicationStore().toString() +
                    " to " + AppData.ApplicationStore.amazon.toString());
            AppData.setApplicationStore(AppData.ApplicationStore.amazon);
        }
    }

    private void initLocale() {
        CustomApplication.initLocale();
    }

    private void reportAppPresented() {
        try {
            new AudienceHelper().reportAppPresented(this);
        } catch (Exception e) {
            Log.d("BaseApplication", "Could not report app presented event: " + e.getMessage());
        }

    }
}
