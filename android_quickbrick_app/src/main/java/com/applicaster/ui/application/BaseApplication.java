package com.applicaster.ui.application;

import android.app.Application;
import android.util.Log;

import com.applicaster.app.APProperties;
import com.applicaster.app.CustomApplication;
import com.applicaster.audience.AudienceHelper;
import com.applicaster.plugin_manager.push_plugin.PushManager;
import com.applicaster.session.SessionStorage;
import com.applicaster.storage.LocalStorage;
import com.applicaster.storage.SharedPreferencesRepository;
import com.applicaster.util.APDebugUtil;
import com.applicaster.util.AppContext;
import com.applicaster.util.AppData;
import com.applicaster.util.ErrorMonitoringUtil;
import com.applicaster.util.OSUtil;
import com.applicaster.util.StringUtil;
import com.facebook.soloader.SoLoader;

import java.util.Locale;

public class BaseApplication
        extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        SoLoader.init(this, /* native exopackage */ false);
        AppContext.set(this);
        initAppData();
        ErrorMonitoringUtil.initPlugins(this);
        initLocale();
        LocalStorage.INSTANCE.init(new SharedPreferencesRepository(this));
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
            Log.e(CustomApplication.class.getSimpleName(), "add scheme_url_prefix to strings.xml");
        }
    }

    private void initLocale() {
        Locale locale = AppData.getLocale();
        if (locale != null) {
            return;
        }
        // No need to load the locale from the properties file if was already set / cached.
        String localeProperty = AppData.getProperty(APProperties.LOCALE);
        if (!StringUtil.isEmpty(localeProperty)) {
            locale = new Locale(localeProperty);
            AppData.setLocale(locale);
        }
    }

    private void reportAppPresented() {
        try {
            new AudienceHelper().reportAppPresented(this);
        } catch (Exception e) {
            Log.d("BaseApplication", "Could not report app presented event: " + e.getMessage());
        }

    }
}
